#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    for(new row = 0; row < REGION_GRID_SIZE; row++)
    {
        for(new col = 0; col < REGION_GRID_SIZE; col++)
        {
            new region = (row * REGION_GRID_SIZE) + col;

            veh::gRegion[region] = linked_list_new();

            new Float:min_x = WORLD_MIN + (float(col) * REGION_SIZE);
            new Float:min_y = WORLD_MIN + (float(row) * REGION_SIZE);
            new Float:max_x = min_x + REGION_SIZE;
            new Float:max_y = min_y + REGION_SIZE;

            veh::gAreas[region] = CreateDynamicRectangle(min_x, min_y, max_x, max_y);
        }
    }

    return 1;
}

hook OnGameModeExit()
{
    for(new region = 0; region < REGION_COUNT; region++)
    {
        if(linked_list_valid(veh::gRegion[region]))
            linked_list_delete(veh::gRegion[region]);

        if(IsValidDynamicArea(veh::gAreas[region]))
            DestroyDynamicArea(veh::gAreas[region]);
    }

    return 1;
}

hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return 1;

    Veh::AddToRegion(vehicleid, regionid);

    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)  return 1;

    Veh::RemoveFromRegion(vehicleid);
    Veh::UpdateRegionByPosition(vehicleid);
    
    return 1;
}

hook function CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:rotation, colour1, colour2, respawn_delay, bool:add_siren = false)
{
    new regionid = GetRegionFromXY(x, y);

    new vehicleid = continue(modelid, x, y, z, rotation, colour1, colour2, respawn_delay, add_siren);

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        CallLocalFunction("OnVehicleCreate", "iiifff", vehicleid, modelid, regionid, x, y, z);
        
        if(regionid != INVALID_REGION_ID) 
            Veh::AddToRegion(vehicleid, regionid);
    }

    return vehicleid;
}

hook function DestroyVehicle(vehicleid)
{
    Veh::RemoveFromRegion(vehicleid);
    CallLocalFunction("OnVehicleDestroy", "i", vehicleid);
    return continue(vehicleid);
}

stock Veh::UpdateParams(vehicleid, params, status)
{  
    if(status)
        SetFlag(Vehicle[vehicleid][veh::params], params);
    else
        ResetFlag(Vehicle[vehicleid][veh::params], params);

    SetVehicleParamsEx(
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_ENGINE, 
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_LIGHTS, 
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_ALARM, 
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_BONNET, 
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_BOOT, 
    Vehicle[vehicleid][veh::params] & FLAG_PARAM_OBJECTIVE);
}