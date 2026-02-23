enum VEHICLE_OWNER_TYPE
{
    VEH_OWNER_SERVER = 0,
    VEH_OWNER_PLAYER,
    VEH_OWNER_ORG
}
enum (<<= 1)
{
    FLAG_VEH_IS_DEAD = 1,
    FLAG_VEH_EMPTY
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

enum E_PLAYER_VEHICLE
{
    pyr::tick_gas_notify,
}

enum E_VEHICLES
{
    veh::regionid,
    veh::owner_type,
    veh::ownerid,
    veh::flags,
    veh::params,
    Float:veh::fuel,
    Float:veh::health,
    veh::old_speed,
    Float:veh::old_accel,
    veh::tick,
    Float:veh::oX, Float:veh::oY, Float:veh::oZ,
    STREAMER_TAG_3D_TEXT_LABEL:veh::tex3did
}

new veh::Player[MAX_PLAYERS][E_PLAYER_VEHICLE];
new Vehicle[MAX_VEHICLES][E_VEHICLES];

forward OnVehicleCreate(vehicleid, modelid, regionid, Float:x, Float:y, Float:z);

stock GetClosestVehicle(playerid, &Float:distance = 0.0)
{
    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);
    
    return Veh::GetClosest(pX, pY, pZ, distance);
}