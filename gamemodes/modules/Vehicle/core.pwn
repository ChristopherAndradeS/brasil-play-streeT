
stock Veh::Destroy(&vehicleid)
{
    if(IsValidVehicle(vehicleid))
        DestroyVehicle(vehicleid);
    
    Veh::Clear(vehicleid);
    vehicleid = INVALID_VEHICLE_ID;
}

stock Veh::UpdateParams(vehicleid, params, status)
{  
    if(status)
        SetFlag(Vehicle[vehicleid][veh::params], params);
    else
        ResetFlag(Vehicle[vehicleid][veh::params], params);

    SetVehicleParamsEx(vehicleid,
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_ENGINE), 
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_LIGHTS),
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_ALARM),
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_DOORS),
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_BONNET), 
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_BOOT),
    GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_OBJECTIVE) 
    );
}

stock GetClosestVehicle(playerid, &Float:distance = 0.0)
{
    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);
    
    return Veh::GetClosest(pX, pY, pZ, distance);
}

stock Veh::ToogleDoor(playerid, vehicleid)
{
    if(GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_DOORS))
    {
        Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS, 0);
        GameTextForPlayer(playerid, "~g~~h~Aberto", 2000, 3);
        PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
    }

    else
    {
        Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS, 1);
        GameTextForPlayer(playerid, "~r~~h~Trancado", 2000, 3);
        PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
    } 
}

stock Veh::ToogleEngine(playerid, vehicleid)
{
    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
    {
        SendClientMessage(playerid, -1, "{ff9933}[ ! ] {ffffff}Este veículo está {ff9933}quebrado! {ffffff}Chame um {ff9933}mecânico");
        GameTextForPlayer(playerid, "~r~~h~QUEBRADO", 1500, 3);
        return 1;
    }

    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
    {
        SendClientMessage(playerid, -1, "{ff9933}[ ! ] {ffffff}Este veículo está {ff9933}sem gasolina! {ffffff}Chame um {ff9933}mecânico");
        GameTextForPlayer(playerid, "~h~SEM COMBUSTIVEL", 1500, 3);
        return 1;
    }

    if(GetFlag(Vehicle[vehicleid][veh::params], FLAG_PARAM_ENGINE))
    {
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);
        GameTextForPlayer(playerid, "~r~~h~Motor OFF", 1500, 3);
        PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
    }

    else
    {
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 1);
        GameTextForPlayer(playerid, "~g~~h~Motor ON", 1500, 3);
        PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
    } 

    return 1;
}

stock Veh::Create(modelid, Float:x, Float:y, Float:z, Float:rotation, c1, c2, interiorid, vw, flags)
{
    new vehicleid = CreateVehicle(modelid, x, y, z, rotation, c1, c2, -1);

    Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, flags & FLAG_PARAM_ENGINE);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_LIGHTS, flags & FLAG_PARAM_LIGHTS);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_ALARM, flags & FLAG_PARAM_ALARM);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS, flags & FLAG_PARAM_DOORS);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_BONNET, flags & FLAG_PARAM_BONNET);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_BOOT, flags & FLAG_PARAM_BOOT);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_OBJECTIVE, flags & FLAG_PARAM_OBJECTIVE);

    Vehicle[vehicleid][veh::health] = 1500.0;
    Vehicle[vehicleid][veh::fuel] = 45.0;
    SetVehicleHealth(vehicleid, 1500.0);
    ResetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD);
    ResetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY);

    LinkVehicleToInterior(vehicleid, interiorid);
    SetVehicleVirtualWorld(vehicleid, vw);

    return vehicleid;
}

stock Veh::Clear(vehicleid)
{
    Vehicle[vehicleid][veh::regionid] = INVALID_REGION_ID;
    Vehicle[vehicleid][veh::owner_type] = 0;
    Vehicle[vehicleid][veh::ownerid] = INVALID_OWNER_ID;
    Vehicle[vehicleid][veh::flags] = 0;
    Vehicle[vehicleid][veh::params] = 0;
    Vehicle[vehicleid][veh::health] = 0.0;
}

stock Veh::SetOwner(vehicleid, ownerid, type)
{
    Vehicle[vehicleid][veh::ownerid] = ownerid;
    Vehicle[vehicleid][veh::owner_type] = type;
}

stock Float:Veh::GetVehicleFuelUsed(Float:speed, Float:accel, Float:dt)
{   
    const Float:C_DIST  = 0.001;   // consumo por metro
    const Float:C_ACCEL = 0.005;    // esforço de aceleração

    new Float:fuelUsed = 0.0;

    fuelUsed += speed * dt * C_DIST;

    if (accel > 0.0)
        fuelUsed += accel * dt * C_ACCEL;
    
    return fuelUsed;    
}

stock GetVehicleSpeed(vehicleid)
{
    new Float:vX, Float:vY, Float:vZ;
    GetVehicleVelocity(vehicleid, vX, vY, vZ);

    new Float:speed =
        floatsqroot(
            floatpower(vX, 2) +
            floatpower(vY, 2) +
            floatpower(vZ, 2)
        );
    
    // Float:0x43431F38 = 195.121948
    return floatround(speed * Float:0x43431F38); 
}
