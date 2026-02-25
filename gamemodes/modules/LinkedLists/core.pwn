
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

    new count = linked_list_size(veh::Region[regionid]);
    for(new i = 0; i < count; i++)
        if(linked_list_get(veh::Region[regionid], i) == vehicleid)
        {
            Vehicle[vehicleid][veh::regionid] = regionid;
            return 1;
        }

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

    new count = linked_list_size(pyr::Region[regionid]);
    for(new i = 0; i < count; i++)
        if(linked_list_get(pyr::Region[regionid], i) == playerid)
        {
            Player[playerid][pyr::regionid] = regionid;
            return 1;
        }

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

stock Player::GetPlayersIntoRange(Float:x, Float:y, Float:z, Float:radius, playerid_list[])
{
    new regionid = GetRegionFromXY(x, y), count = 0;

    if(regionid == INVALID_REGION_ID) return count;

    new len = linked_list_size(pyr::Region[regionid]);

    for(new i = 0; i < len; i++)
    {
        new playerid = linked_list_get(pyr::Region[regionid], i);
        
        if(!IsValidPlayer(playerid)) continue;
        
        new Float:dist = GetPlayerDistanceFromPoint(playerid, x, y, z);
        if(dist <= radius)
        {
            playerid_list[count] = playerid;
            count++;
        }
    }

    return count;
}

stock Veh::GetClosest(Float:x, Float:y, Float:z, &Float:min_dist_sq)
{
    new regionid = GetRegionFromXY(x, y);

    min_dist_sq = FLOAT_INFINITY;

    if(regionid == INVALID_REGION_ID) return INVALID_VEHICLE_ID;

    new closest_vehicleid   = INVALID_VEHICLE_ID;
    new count = linked_list_size(veh::Region[regionid]);

    for(new i = 0; i < count; i++)
    {
        new vehicleid = linked_list_get(veh::Region[regionid], i);

        if(!IsValidVehicle(vehicleid)) continue;
        
        new Float:dist = GetVehicleDistanceFromPoint(vehicleid, x, y, z);

        if(dist < min_dist_sq)
        {
            min_dist_sq = dist;
            closest_vehicleid = vehicleid;
        }
    }

    return closest_vehicleid;
}
