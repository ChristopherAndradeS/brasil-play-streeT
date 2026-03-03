#include <YSI\YSI_Coding\y_hooks>

hook OnVehicleUpdate(driverid, vehicleid)
{
    new Float:Nhealth;

    GetVehicleHealth(vehicleid, Nhealth);
    
    new Float:Ohealth = Vehicle[vehicleid][veh::health];

    if(Ohealth != Nhealth)
    {
        CallLocalFunction("OnVehicleHealthChange", "iiff", vehicleid, driverid, Nhealth, Ohealth);
    }

    if(Vehicle[vehicleid][veh::tick] < GetTickCount()) 
    {
        new 
            speed       = GetVehicleSpeed(vehicleid),
            tick        = GetTickCount(),
            Float:dt    = float(tick - Vehicle[vehicleid][veh::tick]) / 1000.0,
            Float:accel = (speed - Vehicle[vehicleid][veh::o_speed]) / dt,
            Float:fuel
        ; 

        accel = ((accel * 0.2) + (0.8 * Vehicle[vehicleid][veh::o_accel])) * (0.277);
        fuel = Veh::GetVehicleFuelUsed(speed / 3.6, accel, dt);

        new Float:Ofuel = Vehicle[vehicleid][veh::fuel];
        new Float:Nfuel = Ofuel - fuel;

        if(Ofuel != Nfuel)
        {
            CallLocalFunction("OnVehicleFuelChange", "iiff", vehicleid, driverid, Nfuel, Ofuel);
        
            Vehicle[vehicleid][veh::o_speed] = speed;
            Vehicle[vehicleid][veh::o_accel] = accel;
        }

        Vehicle[vehicleid][veh::tick] = tick + 1000;
    }

    else if(!Vehicle[vehicleid][veh::tick])       
        Vehicle[vehicleid][veh::tick] = GetTickCount() + 1000;

    return 1;
}


hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    #pragma unused ispassenger

    if(!IsValidVehicle(vehicleid)) return 1;

    if(!Veh::HasPermission(playerid, vehicleid))
    {
        SetVehicleParamsForPlayer(vehicleid, playerid, .doors = 1);
        return 1;
    }

    return 1;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(IsPlayerNPC(playerid)) return -1;
    
    new vehicleid = GetPlayerVehicleID(playerid);  

    if(newstate == PLAYER_STATE_DRIVER)
    {
        if(!IsValidVehicle(vehicleid)) return 1;    

        if(!Veh::HasPermission(playerid, vehicleid))
        {
            SetVehicleParamsForPlayer(vehicleid, playerid, .doors = 1);
            RemovePlayerFromVehicle(playerid);
            return 1;
        }

        SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_OCCUPED);
        Player[playerid][pyr::ocupped_vehicleid] = vehicleid;
        
        Veh::KillTimer(vehicleid, veh::TIMER_STREAM_OUT);
        Veh::KillTimer(vehicleid, veh::TIMER_EMPTY_RESPAWN);

        if(Model_IsManual(GetVehicleModel(vehicleid))) return 1;

        Baseboard::HideTDForPlayer(playerid);
        Veh::ShowTDForPlayer(playerid);

        new vehname[64];
        GetVehicleNameByModel(GetVehicleModel(vehicleid), vehname);
        Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_NAME, "Veiculo: ~g~~h~~h~%s", vehname);
        
        Veh::UpdateHealth(playerid, vehicleid, Vehicle[vehicleid][veh::health]);
        Veh::UpdateFuel(playerid, vehicleid, Vehicle[vehicleid][veh::fuel]); 

        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED))
            return SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está {ff9933}quebrado! {ffffff}Chame um mecânico");
        
        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
            return SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está {ff9933}sem gasolina! {ffffff}Chame um mecânico");

        if(!(Vehicle[vehicleid][veh::params] & FLAG_PARAM_ENGINE))
            SendClientMessage(playerid, -1, "{ffff99}[ VEH ] {ffffff}Aperte {ffff99}'Y' {ffffff}ou digite {ffff99}/motor {ffffff}para ligar o motor.");
        
        Player::CreateTimer(playerid, pyr::TIMER_SPEEDOMETER, "OnSpeedOMeterUpdate", 75, true, "i", playerid);
    }

    if(oldstate == PLAYER_STATE_DRIVER)
    {
        if(IsValidVehicle(Player[playerid][pyr::ocupped_vehicleid]))
        {
            ResetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_OCCUPED);
        
            if(Vehicle[vehicleid][veh::owner_type] == OWNER_TYPE_ORG)
                Veh::CreateTimer(vehicleid, veh::TIMER_EMPTY_RESPAWN, "OnVehicleEmptyTimeout", 300000, false, "ii", vehicleid, playerid);
        }
        
        if(IsValidTimer(pyr::Timer[playerid][pyr::TIMER_SPEEDOMETER]))
            Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);

        if(Veh::IsVisibleTDForPlayer(playerid))
        {
            Veh::HideTDForPlayer(playerid);
            Baseboard::ShowTDForPlayer(playerid);
        }
    }

    return 1;
}

hook OnVehicleHealthChange(vehicleid, driverid, Float:new_health, Float:old_health)
{
    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED))
    {
        Veh::UpdateHealth(driverid, vehicleid, 390.0);
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);
        return 1;
    }

    if(!IsValidPlayer(driverid)) return 1;

    if(Race::IsRaceVehicle(vehicleid)) return 1;

    if(new_health <= 250.0)
    {
        Veh::Flip(vehicleid);
        SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);

        SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED);

        Veh::UpdateHealth(driverid, vehicleid, 390.0);

        foreach (new i : VehicleOccupant[vehicleid])
            SendClientMessage(i, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está {ff9933}quebrado! {ffffff}Chame um mecânico");

        CallLocalFunction("OnVehicleBroke", "ii", vehicleid, driverid);
        
        return 1;
    }

    if(old_health > 1000.0)
    {
        RepairVehicle(vehicleid);
    
        if(new_health <= 1000.0)
            SendClientMessage(driverid, -1, "{ff9933}[ VEH ] {ffffff}Seu veículo perdeu a {ff9933}blindagem!");
    }

    Veh::UpdateHealth(driverid, vehicleid, new_health);
    
    return 1;
}

public OnSpeedOMeterUpdate(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid);

    if(!IsValidVehicle(vehicleid))
    {

        return 1;
    }

    new 
        speed = GetVehicleSpeed(vehicleid)
    ; 
    
    new fully_dots = floatround(speed / 20) + PTD_VEH_FIRST_DOT;

    if(fully_dots > PTD_VEH_LAST_DOT) fully_dots = PTD_VEH_LAST_DOT;

    for(new i = PTD_VEH_FIRST_DOT; i < fully_dots; i++)
        Veh::UpdateTextDrawColor(playerid, i, -1);
    
    new color_level = clamp(floatround((speed % 20) * 13.42), 0, 255);
    Veh::UpdateTextDrawColor(playerid, fully_dots, (color_level * 0x01010100) | 0xFF);

    for(new i = fully_dots + 1; i <= PTD_VEH_LAST_DOT; i++)
        Veh::UpdateTextDrawColor(playerid, i, 0 | 0xFF);
    
    Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "%i", speed);

    return 1;
}

hook OnVehicleFuelChange(vehicleid, driverid, Float:new_fuel, Float:old_fuel)
{
    #pragma unused old_fuel

    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
    {
        Veh::UpdateFuel(driverid, vehicleid, 0.0);
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);
        return 1;
    }
    
    if(!IsValidPlayer(driverid)) return 1;

    if(new_fuel <= 0.0)
    {
        Veh::UpdateFuel(driverid, vehicleid, 0.0);
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);
        SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY);
        SendClientMessage(driverid, -1, "{ff3333}[ VEH ] {ffffff}Gasolina acabou. Procure um {ff3333}serviço mecânico ou abasteça!");
        
        return 1;
    }

    if(new_fuel < 15.0 && veh::Player[driverid][pyr::tick_gas_notify] <= GetTickCount())
    {
        SendClientMessage(driverid, -1, "{ff9933}[ VEH ] {ffffff}Gasolina abaixo de {ff9933}25%% {ffffff}procure um posto para abastecer!");   
        veh::Player[driverid][pyr::tick_gas_notify] = GetTickCount() + (2 * 60000);
    }

    Veh::UpdateFuel(driverid, vehicleid, new_fuel);

    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        if(IsValidVehicle(vehicleid))
        {
            if(!Veh::HasPermission(playerid, vehicleid)) return 1;
            Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_ENGINE);
        }

        return 1;
    }

    return 1;
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
    printf("%d destrimado %d ocuped", vehicleid, Player[forplayerid][pyr::ocupped_vehicleid]);

    if(Player[forplayerid][pyr::ocupped_vehicleid] != vehicleid) return 1;

    switch(Vehicle[vehicleid][veh::owner_type])
    {
        case OWNER_TYPE_PLAYER, OWNER_TYPE_ORG, OWNER_TYPE_SERVER:
        {
            if(!GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_OCCUPED))
                return 1;

            if(IsValidPlayer(forplayerid))
                SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}Você se afastou muito do seu veículo. Ele vai respawnar em {ff9933}90 segundos.");
            
            Veh::CreateTimer(vehicleid, veh::TIMER_STREAM_OUT, "OnVehicleStreamOutTimeout", 90000, false, "ii", vehicleid, forplayerid);
        }

        default: Veh::Destroy(vehicleid);
    }

    return 1;
}

public OnVehicleStreamOutTimeout(vehicleid, forplayerid)
{
    if(!IsValidVehicle(vehicleid)) return 1;

    veh::Timer[vehicleid][veh::TIMER_STREAM_OUT] = INVALID_TIMER;

    Player[forplayerid][pyr::ocupped_vehicleid] = INVALID_VEHICLE_ID;

    switch(Vehicle[vehicleid][veh::owner_type])
    {
        case OWNER_TYPE_PLAYER:
        {
            if(IsValidPlayer(forplayerid))
                SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}Seu veículo retornou para garagem");

            Veh::Respawn(vehicleid, OWNER_TYPE_PLAYER);    
        }

        case OWNER_TYPE_ORG:
        {
            if(IsValidPlayer(forplayerid))
                SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}O veículo {ff9933}[ {ffffff}SID {ff9933}%d ] retornou para garagem da organização",
                Vehicle[vehicleid][veh::slotid]);

            Veh::Respawn(vehicleid, OWNER_TYPE_ORG);
        }

        default:
        {
            if(IsValidPlayer(forplayerid))
                SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}O veículo que você estava voltou para {ff9933}seu local.");
            
            Veh::Respawn(vehicleid, OWNER_TYPE_SERVER);      
        }
    }

    return 1;
}

public OnVehicleEmptyTimeout(vehicleid, forplayerid)
{
    if(!IsValidVehicle(vehicleid)) return 1;

    veh::Timer[vehicleid][veh::TIMER_EMPTY_RESPAWN] = INVALID_TIMER;

    Player[forplayerid][pyr::ocupped_vehicleid] = INVALID_VEHICLE_ID;

    switch(Vehicle[vehicleid][veh::owner_type])
    {
        case OWNER_TYPE_PLAYER:
        {
            if(IsValidPlayer(forplayerid))
                SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}Seu veículo retornou para garagem por {ff9933}desocupação");
            
            Veh::Respawn(vehicleid, OWNER_TYPE_PLAYER);    
        }

        case OWNER_TYPE_ORG:
        {
            SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}O veículo {ff9933}[ {ffffff}SID {ff9933}%d ] retornou para garagem da organização por {ff9933}desocupação",
            Vehicle[vehicleid][veh::slotid]);

            Veh::Respawn(vehicleid, OWNER_TYPE_ORG);
        }

        default:
        {
            SendClientMessage(forplayerid, -1, "{ff9933}[ VEH ] {ffffff}O veículo que você estava voltou para {ff9933}seu local.");
            Veh::Respawn(vehicleid, OWNER_TYPE_SERVER);      
        }
    }

    return 1;
}
