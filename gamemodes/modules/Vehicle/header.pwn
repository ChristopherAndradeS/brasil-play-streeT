#define REGION_GRID_SIZE        (8)
#define REGION_COUNT            (64)
#define REGION_SIZE             (750.0)
#define WORLD_MIN               (-3000.0)
#define WORLD_MAX               (3000.0)
#define INVALID_REGION_ID       (-1)

new LinkedList:veh::gRegion[REGION_COUNT];

new STREAMER_TAG_AREA:veh::gAreas[REGION_COUNT];

enum (<<= 1)
{
    FLAG_VEH_OPENED = 1,
}

enum (<<= 1)
{
    FLAG_PARAM_ENGINE = 1,
    FLAG_PARAM_LIGHTS,
    FLAG_PARAM_ALARM,
    FLAG_PARAM_DOORS,
    FLAG_PARAM_BONNET,
    FLAG_PARAM_BOOT,
    FLAG_PARAM_OBJECTIVE,
}

enum E_VEHICLES
{
    veh::regionid,
    veh::flags,
    veh::params,
    STREAMER_TAG_3D_TEXT_LABEL:veh::tex3did
}

new Vehicle[MAX_VEHICLES][E_VEHICLES];

forward OnVehicleCreate(vehicleid, modelid, regionid, Float:x, Float:y, Float:z);

stock GetRegionFromXY(Float:x, Float:y)
{
    if(x < WORLD_MIN || x > WORLD_MAX || y < WORLD_MIN || y > WORLD_MAX)
        return INVALID_REGION_ID;

    new col = floatround((x - WORLD_MIN) / REGION_SIZE, floatround_floor);
    new row = floatround((y - WORLD_MIN) / REGION_SIZE, floatround_floor);

    if(col >= REGION_GRID_SIZE) col = REGION_GRID_SIZE - 1;
    if(row >= REGION_GRID_SIZE) row = REGION_GRID_SIZE - 1;

    return (row * REGION_GRID_SIZE) + col;
}

stock GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new region = 0; region < REGION_COUNT; region++)
        if(veh::gAreas[region] == areaid)
            return region;

    return INVALID_REGION_ID;
}

stock GetRegionCellX(region)
    return (region % REGION_GRID_SIZE);

stock GetRegionCellY(region)
    return (region / REGION_GRID_SIZE);

stock Veh::RemoveFromRegion(vehicleid)
{
    new regionid = Vehicle[vehicleid][veh::regionid];

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    new count = linked_list_size(veh::gRegion[regionid]);

    for(new i = 0; i < count; i++)
    {
        if(linked_list_get(veh::gRegion[regionid], i) == vehicleid)
        {
            linked_list_remove(veh::gRegion[regionid], i);
            Vehicle[vehicleid][veh::regionid] = INVALID_REGION_ID;
            break;
        }
    }

    return 1;
}

stock Veh::AddToRegion(vehicleid, regionid)
{
    if(Vehicle[vehicleid][veh::regionid] == regionid) return 1;

    Veh::RemoveFromRegion(vehicleid);

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    linked_list_add(veh::gRegion[regionid], vehicleid);
    Vehicle[vehicleid][veh::regionid] = regionid;

    return 1;
}

stock Veh::UpdateRegionByPosition(vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return 0;

    new Float:x, Float:y, Float:z;
    GetVehiclePos(vehicleid, x, y, z);
    
    new regionid = GetRegionFromXY(x, y);
    new count = linked_list_size(veh::gRegion[regionid]);

    new str[128];
    format(str, 128, "Veiculo: {33ff33}%d {ffffff}| Regiao: {33ff33}%d {ffffff}| QTR: {33ff33}%d", vehicleid, regionid, count);

    Veh::AddToRegion(vehicleid, regionid);

    UpdateDynamic3DTextLabelText(Vehicle[vehicleid][veh::tex3did], -1, str);

    return 1;
}

stock Veh::GetClosest(Float:x, Float:y, Float:z, &Float:min_dist_sq)
{
    new regionid = GetRegionFromXY(x, y);

    min_dist_sq = FLOAT_INFINITY;

    if(regionid == INVALID_REGION_ID) return INVALID_VEHICLE_ID;

    new closest_vehicle   = INVALID_VEHICLE_ID;
    new count = linked_list_size(veh::gRegion[regionid]);

    for(new i = 0; i < count; i++)
    {
        new vehicleid = linked_list_get(veh::gRegion[regionid], i);

        if(!IsValidVehicle(vehicleid)) continue;
        
        new Float:dist = GetVehicleDistanceFromPoint(vehicleid, x, y, z);

        if(dist < min_dist_sq)
        {
            min_dist_sq = dist;
            closest_vehicle = vehicleid;
        }
    }

    return closest_vehicle;
}

stock GetClosestVehicle(playerid, &Float:distance = 0.0)
{
    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);
    
    return Veh::GetClosest(pX, pY, pZ, distance);
}