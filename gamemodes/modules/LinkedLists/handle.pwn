#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    new count;

    for(new row = 0; row < REGION_GRID_SIZE; row++)
    {
        for(new col = 0; col < REGION_GRID_SIZE; col++)
        {
            new regionid = (row * REGION_GRID_SIZE) + col;

            veh::Region[regionid] = linked_list_new();
            pyr::Region[regionid] = linked_list_new();
            
            new Float:min_x = WORLD_MIN + (float(col) * REGION_SIZE);
            new Float:min_y = WORLD_MIN + (float(row) * REGION_SIZE);
            new Float:max_x = min_x + REGION_SIZE;
            new Float:max_y = min_y + REGION_SIZE;

            Areas[regionid] = CreateDynamicRectangle(min_x, min_y, max_x, max_y);
            count++;
        }
    }

    printf("[ AREAS ] %d areas globais de %.1fx%.1f (m) foram criadas com sucesso\n", count, REGION_SIZE, REGION_SIZE);
    printf("[ REGIONS ] %d regioes de jogadores foram criadas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de veículos foram criadas com sucesso\n", count);

    return 1;
}


hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;
    
    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::AddToRegion(playerid, regionid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID) return 1;

        Veh::AddToRegion(vehicleid, regionid);
    }

    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;
    
    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::RemoveFromRegion(playerid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID)  return 1;

        Veh::RemoveFromRegion(vehicleid);
    }

    return 1;
}

stock GetRegionFromXY(Float:x, Float:y)
{
    if(x < WORLD_MIN || x > WORLD_MAX || y < WORLD_MIN || y > WORLD_MAX) return INVALID_REGION_ID;

    new col = floatround((x - WORLD_MIN) / REGION_SIZE, floatround_floor);
    new row = floatround((y - WORLD_MIN) / REGION_SIZE, floatround_floor);

    if(col >= REGION_GRID_SIZE) col = REGION_GRID_SIZE - 1;
    if(row >= REGION_GRID_SIZE) row = REGION_GRID_SIZE - 1;

    return (row * REGION_GRID_SIZE) + col;
}

stock GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
        if(Areas[regionid] == areaid)
            return regionid;

    return INVALID_REGION_ID;
}

stock GetRegionCellX(regionid)
    return (regionid % REGION_GRID_SIZE);

stock GetRegionCellY(regionid)
    return (regionid / REGION_GRID_SIZE);

/*                  VEHICLES                  */

stock Veh::AddToRegion(vehicleid, regionid)
{
    if(Vehicle[vehicleid][veh::regionid] == regionid) return 1;

    Veh::RemoveFromRegion(vehicleid);

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    linked_list_add(veh::Region[regionid], vehicleid);
    Vehicle[vehicleid][veh::regionid] = regionid;

    return 1;
}

stock Veh::RemoveFromRegion(vehicleid)
{
    new regionid = Vehicle[vehicleid][veh::regionid];

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    new count = linked_list_size(veh::Region[regionid]);

    for(new i = 0; i < count; i++)
    {
        if(linked_list_get(veh::Region[regionid], i) == vehicleid)
        {
            linked_list_remove(veh::Region[regionid], i);
            Vehicle[vehicleid][veh::regionid] = INVALID_REGION_ID;
            break;
        }
    }

    return 1;
}

/*                  PLAYER                  */

stock Player::AddToRegion(playerid, regionid)
{
    if(Player[playerid][pyr::regionid] == regionid) return 1;

    Player::RemoveFromRegion(playerid);

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    linked_list_add(pyr::Region[regionid], playerid);
    Player[playerid][pyr::regionid] = regionid;

    return 1;
}

stock Player::RemoveFromRegion(playerid)
{
    new regionid = Player[playerid][pyr::regionid];

    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    new count = linked_list_size(pyr::Region[regionid]);

    for(new i = 0; i < count; i++)
    {
        if(linked_list_get(pyr::Region[regionid], i) == playerid)
        {
            linked_list_remove(pyr::Region[regionid], i);
            Player[playerid][pyr::regionid] = INVALID_REGION_ID;
            break;
        }
    }

    return 1;
}