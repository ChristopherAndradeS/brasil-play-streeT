enum (<<= 1)
{
    FLAG_VEH_IS_DEAD = 1,
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
    Float:veh::health,
    Float:veh::oX, Float:veh::oY, Float:veh::oZ,
    STREAMER_TAG_3D_TEXT_LABEL:veh::tex3did
}

new Vehicle[MAX_VEHICLES][E_VEHICLES];

forward OnVehicleCreate(vehicleid, modelid, regionid, Float:x, Float:y, Float:z);

stock Veh::GetClosest(Float:x, Float:y, Float:z, &Float:min_dist_sq)
{
    new regionid = GetRegionFromXY(x, y);

    min_dist_sq = FLOAT_INFINITY;

    if(regionid == INVALID_REGION_ID) return INVALID_VEHICLE_ID;

    new closest_vehicle   = INVALID_VEHICLE_ID;
    new count = linked_list_size(veh::Region[regionid]);

    for(new i = 0; i < count; i++)
    {
        new vehicleid = linked_list_get(veh::Region[regionid], i);

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