#define INVALID_OWNER_ID (-1)
#define INVALID_PAINTJOB_ID (-1)

enum (<<= 1)
{
    FLAG_VEH_BROKED = 1,
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

enum _:OWNER_TYPES
{
    OWNER_TYPE_PLAYER = 1,
    OWNER_TYPE_SERVER,
    OWNER_TYPE_COMPANY,
    OWNER_TYPE_ORG,
    INVALID_OWNER_TYPE
}

enum E_PLAYER_VEHICLE
{
    pyr::tick_gas_notify,
}

enum E_VEHICLES
{
    veh::dbid,
    veh::regionid,
    veh::ownerid, veh::owner_type,
    veh::modelid,
    veh::flags, veh::params,
    Float:veh::fuel, Float:veh::health,
    Float:veh::pX, Float:veh::pY, Float:veh::pZ, Float:veh::pA,
    veh::color1, veh::color2,
    veh::paintjobid,
    veh::interiorid, veh::worldid,

    veh::o_speed, Float:veh::o_accel, Float:veh::oX, Float:veh::oY, Float:veh::oZ,
    
    veh::tick,
    STREAMER_TAG_3D_TEXT_LABEL:veh::tex3did
}


new veh::Player[MAX_PLAYERS][E_PLAYER_VEHICLE];
new Vehicle[MAX_VEHICLES][E_VEHICLES];

forward OnSpeedOMeterUpdate(playerid);
forward Float:Veh::GetVehicleFuelUsed(Float:speed, Float:accel, Float:dt);
forward OnVehicleFuelChange(vehicleid, Float:new_fuel, Float:old_fuel);
forward OnVehicleCreate(vehicleid, modelid, regionid, Float:x, Float:y, Float:z);

#define FUEL_PRICE_PER_LITER (6.28)
#define ARMOUR_PRICE_PER_HP  (6.0)
