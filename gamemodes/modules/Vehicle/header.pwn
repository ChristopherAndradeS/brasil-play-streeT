#include <YSI\YSI_Coding\y_hooks>

#define VEHICLE_REGION_GRID_SIZE        (8)
#define VEHICLE_REGION_COUNT            (64)
#define VEHICLE_REGION_SIZE             (750.0)
#define VEHICLE_WORLD_MIN               (-3000.0)
#define VEHICLE_WORLD_MAX               (3000.0)
#define INVALID_VEHICLE_REGION          (-1)

new LinkedList:veh::RegionVehicles[VEHICLE_REGION_COUNT];
new STREAMER_TAG_AREA:veh::RegionAreas[VEHICLE_REGION_COUNT];
new veh::VehicleRegion[MAX_VEHICLES] = {INVALID_VEHICLE_REGION, ...};
new bool:veh::IsOpen[MAX_VEHICLES];

stock Vehicle::GetRegionFromXY(Float:x, Float:y)
{
    if(x < VEHICLE_WORLD_MIN || x > VEHICLE_WORLD_MAX || y < VEHICLE_WORLD_MIN || y > VEHICLE_WORLD_MAX)
        return INVALID_VEHICLE_REGION;

    new col = floatround((x - VEHICLE_WORLD_MIN) / VEHICLE_REGION_SIZE, floatround_floor);
    new row = floatround((y - VEHICLE_WORLD_MIN) / VEHICLE_REGION_SIZE, floatround_floor);

    if(col >= VEHICLE_REGION_GRID_SIZE)
        col = VEHICLE_REGION_GRID_SIZE - 1;

    if(row >= VEHICLE_REGION_GRID_SIZE)
        row = VEHICLE_REGION_GRID_SIZE - 1;

    return (row * VEHICLE_REGION_GRID_SIZE) + col;
}

stock Vehicle::GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new region = 0; region < VEHICLE_REGION_COUNT; region++)
    {
        if(veh::RegionAreas[region] == areaid)
            return region;
    }

    return INVALID_VEHICLE_REGION;
}

stock Vehicle::GetRegionCellX(region)
    return (region % VEHICLE_REGION_GRID_SIZE);

stock Vehicle::GetRegionCellY(region)
    return (region / VEHICLE_REGION_GRID_SIZE);

stock bool:Vehicle::RemoveFromRegion(vehicleid, region = INVALID_VEHICLE_REGION)
{
    if(region == INVALID_VEHICLE_REGION)
        region = veh::VehicleRegion[vehicleid];

    if(region < 0 || region >= VEHICLE_REGION_COUNT)
        return false;

    new count = linked_list_size(veh::RegionVehicles[region]);
    for(new index = 0; index < count; index++)
    {
        if(linked_list_get(veh::RegionVehicles[region], index) == vehicleid)
        {
            linked_list_remove(veh::RegionVehicles[region], index);
            break;
        }
    }

    if(veh::VehicleRegion[vehicleid] == region)
        veh::VehicleRegion[vehicleid] = INVALID_VEHICLE_REGION;

    return true;
}

stock bool:Vehicle::AddToRegion(vehicleid, region)
{
    if(veh::VehicleRegion[vehicleid] == region)
        return true;

    Vehicle::RemoveFromRegion(vehicleid);

    if(region < 0 || region >= VEHICLE_REGION_COUNT)
        return false;

    linked_list_add(veh::RegionVehicles[region], vehicleid);
    veh::VehicleRegion[vehicleid] = region;
    return true;
}

stock bool:Vehicle::UpdateRegionByPosition(vehicleid)
{
    if(!IsValidVehicle(vehicleid))
        return false;

    new Float:x, Float:y, Float:z;
    GetVehiclePos(vehicleid, x, y, z);

    return Vehicle::AddToRegion(vehicleid, Vehicle::GetRegionFromXY(x, y));
}

stock GetClosestVehicle(Float:x, Float:y, Float:z)
{
    new center_region = Vehicle::GetRegionFromXY(x, y);
    if(center_region == INVALID_VEHICLE_REGION)
        return INVALID_VEHICLE_ID;

    new center_x = Vehicle::GetRegionCellX(center_region);
    new center_y = Vehicle::GetRegionCellY(center_region);

    new closest_vehicle = INVALID_VEHICLE_ID;
    new Float:min_dist_sq = 99999999.0;

    for(new off_y = -1; off_y <= 1; off_y++)
    {
        for(new off_x = -1; off_x <= 1; off_x++)
        {
            new cell_x = center_x + off_x;
            new cell_y = center_y + off_y;

            if(cell_x < 0 || cell_x >= VEHICLE_REGION_GRID_SIZE || cell_y < 0 || cell_y >= VEHICLE_REGION_GRID_SIZE)
                continue;

            new region = (cell_y * VEHICLE_REGION_GRID_SIZE) + cell_x;
            new count = linked_list_size(veh::RegionVehicles[region]);

            for(new index = 0; index < count; index++)
            {
                new vehicleid = linked_list_get(veh::RegionVehicles[region], index);
                if(!IsValidVehicle(vehicleid))
                    continue;

                new Float:veh_x, Float:veh_y, Float:veh_z;
                GetVehiclePos(vehicleid, veh_x, veh_y, veh_z);

                new Float:dx = veh_x - x;
                new Float:dy = veh_y - y;
                new Float:dz = veh_z - z;
                new Float:dist_sq = (dx * dx) + (dy * dy) + (dz * dz);

                if(dist_sq < min_dist_sq)
                {
                    min_dist_sq = dist_sq;
                    closest_vehicle = vehicleid;
                }
            }
        }
    }

    return closest_vehicle;
}

stock bool:IsVehicleOpened(vehicleid)
    return (IsValidVehicle(vehicleid) && veh::IsOpen[vehicleid]);

stock bool:IsVehicleClosed(vehicleid)
    return (IsValidVehicle(vehicleid) && !veh::IsOpen[vehicleid]);

stock Veh::Open(vehicleid)
{
    if(!IsValidVehicle(vehicleid))
        return 0;

    veh::IsOpen[vehicleid] = true;
    return 1;
}

stock Veh::Close(vehicleid)
{
    if(!IsValidVehicle(vehicleid))
        return 0;

    veh::IsOpen[vehicleid] = false;
    return 1;
}

hook OnGameModeInit()
{
    for(new row = 0; row < VEHICLE_REGION_GRID_SIZE; row++)
    {
        for(new col = 0; col < VEHICLE_REGION_GRID_SIZE; col++)
        {
            new region = (row * VEHICLE_REGION_GRID_SIZE) + col;

            veh::RegionVehicles[region] = linked_list_new();

            new Float:min_x = VEHICLE_WORLD_MIN + (float(col) * VEHICLE_REGION_SIZE);
            new Float:min_y = VEHICLE_WORLD_MIN + (float(row) * VEHICLE_REGION_SIZE);
            new Float:max_x = min_x + VEHICLE_REGION_SIZE;
            new Float:max_y = min_y + VEHICLE_REGION_SIZE;

            veh::RegionAreas[region] = CreateDynamicRectangle(min_x, min_y, max_x, max_y);
        }
    }

    return 1;
}

hook OnGameModeExit()
{
    for(new region = 0; region < VEHICLE_REGION_COUNT; region++)
    {
        if(linked_list_valid(veh::RegionVehicles[region]))
            linked_list_delete(veh::RegionVehicles[region]);

        if(IsValidDynamicArea(veh::RegionAreas[region]))
            DestroyDynamicArea(veh::RegionAreas[region]);
    }

    return 1;
}

hook function CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:rotation, colour1, colour2, respawn_delay, bool:add_siren = false)
{
    new spawn_region = Vehicle::GetRegionFromXY(x, y);
    new vehicleid = continue(modelid, x, y, z, rotation, colour1, colour2, respawn_delay, add_siren);

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        veh::IsOpen[vehicleid] = false;

        if(spawn_region != INVALID_VEHICLE_REGION)
            Vehicle::AddToRegion(vehicleid, spawn_region);
    }

    return vehicleid;
}

hook function DestroyVehicle(vehicleid)
{
    Vehicle::RemoveFromRegion(vehicleid);
    veh::IsOpen[vehicleid] = false;
    return continue(vehicleid);
}

hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid))
        return 1;

    new region = Vehicle::GetRegionByArea(areaid);
    if(region == INVALID_VEHICLE_REGION)
        return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
        return 1;

    Vehicle::AddToRegion(vehicleid, region);
    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid))
        return 1;

    new region = Vehicle::GetRegionByArea(areaid);
    if(region == INVALID_VEHICLE_REGION)
        return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
        return 1;

    if(veh::VehicleRegion[vehicleid] == region)
        Vehicle::RemoveFromRegion(vehicleid, region);

    Vehicle::UpdateRegionByPosition(vehicleid);
    return 1;
}
