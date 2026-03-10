
stock Veh::AddToRegion(vehicleid, regionid)
{
    if(regionid < 0 || regionid >= REGION_COUNT) return 0;

    new count = linked_list_size(veh::Region[regionid]);
    for(new i = 0; i < count; i++)
    {
        if(linked_list_get(veh::Region[regionid], i) == vehicleid)
        {
            Vehicle[vehicleid][veh::regionid] = regionid;
            return 1;
        }
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
