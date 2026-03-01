stock Veh::Insert(ownerid, OWNER_TYPES:ownertype, modelid, color1, color2, paintjobid = INVALID_PAINTJOB_ID)
{
    if(ownerid == INVALID_OWNER_ID || ownertype == INVALID_OWNER_TYPE)
        return 0;

    return DB::Insert(db_entity, "vehicles",
    "ownerid, owner_type, modelid, flags, params, fuel, health, pX, pY, pZ, pA, color1, color2, paintjobid, interiorid, worldid",
    "%d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %d, %d",
    ownerid, _:ownertype, modelid, 0, 0, 60.0, 1000.0, 0.0, 0.0, 0.0, 0.0, color1, color2, paintjobid, 0, 0);
}

stock Veh::Load(playerid)
{
    new vehicle_data[E_VEHICLES];

    if(!DB::Exists(db_entity, "vehicles", "ownerid = %d AND owner_type = %d", playerid, _:OWNER_TYPE_PLAYER))
        return 0;

    DB::GetDataInt(db_entity, "vehicles", "rowid", vehicle_data[veh::dbid], "ownerid = %d AND owner_type = %d", playerid, _:OWNER_TYPE_PLAYER);
    DB::GetDataInt(db_entity, "vehicles", "ownerid", vehicle_data[veh::ownerid], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "owner_type", vehicle_data[veh::owner_type], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "modelid", vehicle_data[veh::modelid], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "flags", vehicle_data[veh::flags], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "params", vehicle_data[veh::params], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "fuel", vehicle_data[veh::fuel], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "health", vehicle_data[veh::health], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "pX", vehicle_data[veh::pX], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "pY", vehicle_data[veh::pY], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "pZ", vehicle_data[veh::pZ], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataFloat(db_entity, "vehicles", "pA", vehicle_data[veh::pA], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "color1", vehicle_data[veh::color1], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "color2", vehicle_data[veh::color2], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "paintjobid", vehicle_data[veh::paintjobid], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "interiorid", vehicle_data[veh::interiorid], "rowid = %d", vehicle_data[veh::dbid]);
    DB::GetDataInt(db_entity, "vehicles", "worldid", vehicle_data[veh::worldid], "rowid = %d", vehicle_data[veh::dbid]);

    Player[playerid][pyr::vehicleid] = Veh::Create(vehicle_data[veh::modelid], vehicle_data);

    if(vehicle_data[veh::paintjobid] != INVALID_PAINTJOB_ID)
        ChangeVehiclePaintjob(Player[playerid][pyr::vehicleid], vehicle_data[veh::paintjobid]);

    return 1;
}

stock Veh::Save(playerid)
{
    new vehicleid = Player[playerid][pyr::vehicleid];

    if(!IsValidVehicle(vehicleid)) return 0;
    if(Vehicle[vehicleid][veh::owner_type] != OWNER_TYPE_PLAYER) return 0;

    GetVehiclePos(vehicleid, Vehicle[vehicleid][veh::pX], Vehicle[vehicleid][veh::pY], Vehicle[vehicleid][veh::pZ]);
    GetVehicleZAngle(vehicleid, Vehicle[vehicleid][veh::pA]);
    GetVehicleHealth(vehicleid, Vehicle[vehicleid][veh::health]);

    return DB::Update(db_entity, "vehicles",
    "ownerid = %d, owner_type = %d, modelid = %d, flags = %d, params = %d, fuel = %f, health = %f, pX = %f, pY = %f, pZ = %f, pA = %f, color1 = %d, color2 = %d, paintjobid = %d, interiorid = %d, worldid = %d WHERE rowid = %d",
    Vehicle[vehicleid][veh::ownerid], Vehicle[vehicleid][veh::owner_type], GetVehicleModel(vehicleid), Vehicle[vehicleid][veh::flags], Vehicle[vehicleid][veh::params],
    Vehicle[vehicleid][veh::fuel], Vehicle[vehicleid][veh::health], Vehicle[vehicleid][veh::pX], Vehicle[vehicleid][veh::pY], Vehicle[vehicleid][veh::pZ], Vehicle[vehicleid][veh::pA],
    Vehicle[vehicleid][veh::color1], Vehicle[vehicleid][veh::color2], Vehicle[vehicleid][veh::paintjobid], Vehicle[vehicleid][veh::interiorid], Vehicle[vehicleid][veh::worldid],
    Vehicle[vehicleid][veh::dbid]);
}

stock Veh::Delete(playerid)
{
    new vehicleid = Player[playerid][pyr::vehicleid];

    if(!IsValidVehicle(vehicleid)) return 0;

    new deleted = DB::Delete(db_entity, "vehicles", "rowid = %d", Vehicle[vehicleid][veh::dbid]);

    Veh::Destroy(Player[playerid][pyr::vehicleid]);

    return deleted;
}

stock Veh::TransferOwnership(vehicleid, ownerid, OWNER_TYPES:ownertype)
{
    if(!IsValidVehicle(vehicleid)) return 0;
    if(ownerid == INVALID_OWNER_ID || ownertype == INVALID_OWNER_TYPE) return 0;

    Vehicle[vehicleid][veh::ownerid] = ownerid;
    Vehicle[vehicleid][veh::owner_type] = _:ownertype;

    return DB::Update(db_entity, "vehicles", "ownerid = %d, owner_type = %d WHERE rowid = %d", ownerid, _:ownertype, Vehicle[vehicleid][veh::dbid]);
}

stock Veh::HasPermission(playerid, vehicleid, bool:allow_other = false)
{
    if(!IsValidVehicle(vehicleid)) return 0;

    if(allow_other) return 1;

    if(Vehicle[vehicleid][veh::owner_type] == OWNER_TYPE_PLAYER)
    {
        if(Vehicle[vehicleid][veh::ownerid] == playerid)
            return 1;

        SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você só pode usar isso no seu veículo.");
        return 0;
    }

    if(Vehicle[vehicleid][veh::owner_type] == OWNER_TYPE_ORG)
    {
        if(org::Player[playerid][pyr::orgid] != INVALID_ORG_ID && Vehicle[vehicleid][veh::ownerid] == org::Player[playerid][pyr::orgid])
            return 1;

        SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Esse veículo pertence a outra organização.");
        return 0;
    }

    SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você não tem permissão para este veículo.");
    return 0;
}

stock Veh::Create(modelid, data[E_VEHICLES])
{
    new vehicleid = CreateVehicle(modelid, 
    data[veh::pX], data[veh::pY], data[veh::pZ], 
    data[veh::pA], data[veh::color1], data[veh::color2], -1);
    
    data[veh::params] = Model_IsManual(GetVehicleModel(vehicleid)) ? 1 : data[veh::params];
    Vehicle[vehicleid][veh::fuel] = Model_IsManual(GetVehicleModel(vehicleid)) ? 0.0 : data[veh::fuel];
   
    Vehicle[vehicleid][veh::dbid]           = data[veh::dbid];
    Vehicle[vehicleid][veh::ownerid]        = data[veh::ownerid];
    Vehicle[vehicleid][veh::owner_type]     = data[veh::owner_type];
    Vehicle[vehicleid][veh::modelid]        = modelid;
    Vehicle[vehicleid][veh::flags]          = data[veh::flags];
    Vehicle[vehicleid][veh::params]         = data[veh::params];
    Vehicle[vehicleid][veh::fuel]           = data[veh::fuel];
    Vehicle[vehicleid][veh::health]         = data[veh::health];
    Vehicle[vehicleid][veh::pX]             = data[veh::pX];
    Vehicle[vehicleid][veh::pY]             = data[veh::pY];
    Vehicle[vehicleid][veh::pZ]             = data[veh::pZ];
    Vehicle[vehicleid][veh::pA]             = data[veh::pA];
    Vehicle[vehicleid][veh::color1]         = data[veh::color1];
    Vehicle[vehicleid][veh::color2]         = data[veh::color2];
    Vehicle[vehicleid][veh::paintjobid]     = data[veh::paintjobid];
    Vehicle[vehicleid][veh::interiorid]     = data[veh::interiorid];
    Vehicle[vehicleid][veh::worldid]        = data[veh::worldid];

    new regionid = GetRegionFromXY(data[veh::pX], data[veh::pY]);

    if(regionid != INVALID_REGION_ID) 
    {
        Vehicle[vehicleid][veh::regionid]       = regionid;
        Veh::AddToRegion(vehicleid, regionid);
    }
    else
        printf("[ ERRO (VEH) ] Veiculo %d criado numa região inválida", vehicleid);
    
    Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE,     data[veh::params] & FLAG_PARAM_ENGINE);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_LIGHTS,     data[veh::params] & FLAG_PARAM_LIGHTS);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_ALARM,      data[veh::params] & FLAG_PARAM_ALARM);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS,      data[veh::params] & FLAG_PARAM_DOORS);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_BONNET,     data[veh::params] & FLAG_PARAM_BONNET);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_BOOT,       data[veh::params] & FLAG_PARAM_BOOT);
    Veh::UpdateParams(vehicleid, FLAG_PARAM_OBJECTIVE,  data[veh::params] & FLAG_PARAM_OBJECTIVE);

    Vehicle[vehicleid][veh::health] = data[veh::health];

    SetVehicleHealth(vehicleid, Vehicle[vehicleid][veh::health]);

    Vehicle[vehicleid][veh::fuel] = data[veh::fuel];
   
    ResetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED);
    ResetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY);

    if(data[veh::paintjobid] != INVALID_PAINTJOB_ID)
        ChangeVehiclePaintjob(vehicleid, data[veh::paintjobid]);

    LinkVehicleToInterior(vehicleid, data[veh::interiorid]);
    SetVehicleVirtualWorld(vehicleid, data[veh::worldid]);

    return vehicleid;
}

stock Veh::Destroy(&vehicleid)
{
    Veh::RemoveFromRegion(vehicleid);

    Veh::Clear(vehicleid);
    
    if(IsValidVehicle(vehicleid)) DestroyVehicle(vehicleid);

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

stock Veh::ToggleParams(playerid, vehicleid, params)
{
    if(Model_IsManual(GetVehicleModel(vehicleid))) return 1;

    switch(params)
    {
        case FLAG_PARAM_ENGINE, FLAG_PARAM_LIGHTS, FLAG_PARAM_ALARM:
        {
            if(GetFlag(Vehicle[vehicleid][veh::params], params))
            {
                Veh::UpdateParams(vehicleid, params, 0);
                GameTextForPlayer(playerid, "~r~~h~Desligado", 2000, 3);
                PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
            }

            else
            {
                Veh::UpdateParams(vehicleid, params, 1);
                GameTextForPlayer(playerid, "~g~~h~Ligado", 2000, 3);
                PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
            }     

            return 1;       
        }

        case FLAG_PARAM_DOORS:
        {
            if(GetFlag(Vehicle[vehicleid][veh::params], params))
            {
                Veh::UpdateParams(vehicleid, params, 0);
                GameTextForPlayer(playerid, "~g~~h~Destrancado", 2000, 3);
                PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
            }

            else
            {
                Veh::UpdateParams(vehicleid, params, 1);
                GameTextForPlayer(playerid, "~r~~h~Trancado", 2000, 3);
                PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
            } 

            return 1;
        }

        case FLAG_PARAM_BONNET, FLAG_PARAM_BOOT:
        {
            if(!GetFlag(Vehicle[vehicleid][veh::params], params))
            {
                Veh::UpdateParams(vehicleid, params, 1);
                GameTextForPlayer(playerid, "~g~~h~Aberto", 2000, 3);
                PlayerPlaySound(playerid, 21000, 0.0, 0.0, 0.0);
            }

            else
            {
                Veh::UpdateParams(vehicleid, params, 0);
                GameTextForPlayer(playerid, "~r~~h~Fechado", 2000, 3);
                PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
            } 

            return 1;
        }

        default: return 1;
    }
}

stock Veh::Clear(vehicleid)
{
    new data[E_VEHICLES];
    Vehicle[vehicleid] = data;
    Vehicle[vehicleid][veh::dbid]            = INVALID_RECORD_ID;
    Vehicle[vehicleid][veh::regionid]        = INVALID_REGION_ID;
    Vehicle[vehicleid][veh::ownerid]         = INVALID_OWNER_ID;
    Vehicle[vehicleid][veh::owner_type]      = INVALID_OWNER_TYPE;
    Vehicle[vehicleid][veh::paintjobid]      = INVALID_PAINTJOB_ID;
}

stock Float:Veh::GetVehicleFuelUsed(Float:speed, Float:accel, Float:dt)
{   
    const Float:C_DIST  = 0.0075;   // consumo por metro
    const Float:C_ACCEL = 0.1;      // esforço de aceleração
    
    new Float:fuelUsed = 0.0;

    fuelUsed += speed * dt * C_DIST;   

    if(accel > 0.0) fuelUsed += accel * dt * C_ACCEL;
    
    return fuelUsed;    
}

stock GetVehicleSpeed(vehicleid)
{
	static 
		Float:Vx = 0.0,
		Float:Vy = 0.0,
		Float:Vz = 0.0
	;
	GetVehicleVelocity(vehicleid, Vx, Vy, Vz);
	return floatround(VectorSize(Vx, Vy, Vz) * 136.666667);
    // Float:0x43431F38 = 195.121948
}

stock Veh::UpdateHealth(driverid, vehicleid, Float:health)
{
    Vehicle[vehicleid][veh::health] = floatclamp(health, 250.0, 2000.0); 
    SetVehicleHealth(vehicleid, Vehicle[vehicleid][veh::health]);

    if(Veh::IsVisibleTDForPlayer(driverid))
    {
        if(!GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED))
        {    
            Veh::UpdatePTDBar(driverid, PTD_VEH_BAR_HEALTH, 100.0, floatclamp(Vehicle[vehicleid][veh::health] - 250.0, 0.0, 750.0) / 7.5);
            Veh::UpdatePTDBar(driverid, PTD_VEH_BAR_ARMOUR, 100.0, floatclamp(Vehicle[vehicleid][veh::health] - 1000.0, 0.0, 1000.0) * 0.1);
        }

        else
        {
            Veh::UpdatePTDBar(driverid, PTD_VEH_BAR_HEALTH, 100.0, 0.0);
            Veh::UpdatePTDBar(driverid, PTD_VEH_BAR_ARMOUR, 100.0, 0.0);
        }
    }
}

stock Veh::UpdateFuel(driverid, vehicleid, Float:fuel)
{
    Vehicle[vehicleid][veh::fuel] = fuel; 
    
    if(Veh::IsVisibleTDForPlayer(driverid))
        Veh::UpdatePTDBar(driverid, PTD_VEH_BAR_FUEL, 100.0, floatclamp(Vehicle[vehicleid][veh::fuel], 0.0, 60.0) * 1.67);
}


stock Veh::Flip(vehicleid)
{
    new Float:qw, Float:qx, Float:qy, Float:qz;
    GetVehicleRotationQuat(vehicleid, qw, qx, qy, qz);

    // m33 < 0: eixo "up" invertido -> veículo tombado/capotado.
    new Float:m33 = 1.0 - 2.0 * (qx * qx + qy * qy);
    if(m33 < 0.0)
    {
        new Float:x, Float:y, Float:z, Float:a;
        GetVehiclePos(vehicleid, x, y, z);
        GetVehicleZAngle(vehicleid, a);
        SetVehiclePos(vehicleid, x, y, z + 0.15);
        SetVehicleZAngle(vehicleid, a);
    }

}
