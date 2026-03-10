
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


stock Player::GetPlayersFlaggedInRange(Float:x, Float:y, Float:z, flags, Float:radius, playerid_list[])
{
    new regionid = GetRegionFromXY(x, y), count = 0;

    if(regionid == INVALID_REGION_ID) return count;

    new len = linked_list_size(pyr::Region[regionid]);

    for(new i = 0; i < len; i++)
    {
        new playerid = linked_list_get(pyr::Region[regionid], i);

        if(!IsValidPlayer(playerid)) continue;
        if(!GetFlag(Player[playerid][pyr::flags], flags)) continue;

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
