#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        if(IsValidVehicle(vehicleid))
        {
            if(!(Vehicle[vehicleid][veh::params] & FLAG_PARAM_ENGINE))
                SendClientMessage(playerid, -1, "{ffff99}[ VEH ] {ffffff}Aperte {ffff99}'Y' {ffffff}ou digite {ffff99}/motor {ffffff}para ligar o motor.");
        }

        Baseboard::HideTDForPlayer(playerid);
        Veh::ShowTDForPlayer(playerid);
        Player::CreateTimer(playerid, pyr::TIMER_SPEEDOMETER, "OnSpeedOMeterUpdate", 75, true, "i", playerid);
    }

    else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        Baseboard::ShowTDForPlayer(playerid);
    }

    return 1;
}

hook OnVehicleHealthChance(vehicleid, Float:new_health, Float:old_health)
{
    #pragma unused old_health

    new raceid, playerid = GetVehicleDriver(vehicleid);
    if(Race::IsRaceVehicle(vehicleid, raceid, playerid) && Game[raceid][game_state] == GAME_STATE_STARTED)
        return 1;

    if(old_health > 1000.0)
    {
        RepairVehicle(vehicleid);
        SetVehicleHealth(vehicleid, new_health);

        if(new_health <= 1000.0)
            SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Seu veículo perdeu a {ff9933}blindagem!");
    }

    if(!GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
    {
        if(new_health <= 250.0)
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

            SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD);
            
            Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);

            SetVehicleHealth(vehicleid, 390.0);
            Vehicle[vehicleid][veh::health] = 390.0;

            SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);

            foreach (new i : VehicleOccupant[vehicleid])
            {
                SendClientMessage(i, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está quebrado! Chame um mecânico");
                RemovePlayerFromVehicle(i);
            }
        }
    }
    
    return 1;
}

public OnSpeedOMeterUpdate(playerid)
{
    if(!IsValidTimer(pyr::Timer[playerid][pyr::TIMER_SPEEDOMETER])) return 1;

    if(!IsPlayerInAnyVehicle(playerid))
    {
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);
        Veh::HideTDForPlayer(playerid);
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
    {
        Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "X");
        return 1;
    }

    if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
    {
        return 1;
    }

    new 
        speed = GetVehicleSpeed(vehicleid),
        tick = GetTickCount(),
        Float:dt = float(tick - Vehicle[vehicleid][veh::tick])/ 1000.0,
        Float:accel = (speed - Vehicle[vehicleid][veh::old_speed]) / dt,
        Float:health,
        Float:fuel
    ; 

    accel = ((accel * 0.2) + (0.8 * Vehicle[vehicleid][veh::old_accel])) * (0.277);
    fuel = Veh::GetVehicleFuelUsed(speed / 3.6, accel, dt);
    
    new fully_dots = floatround(speed / 20) + PTD_VEH_FIRST_DOT;

    if(fully_dots > PTD_VEH_LAST_DOT) fully_dots = PTD_VEH_LAST_DOT;

    for(new i = PTD_VEH_FIRST_DOT; i < fully_dots; i++)
        Veh::UpdateTextDrawColor(playerid, i, -1);
    
    new color_level = clamp(floatround((speed % 20) * 13.42), 0, 255);
    Veh::UpdateTextDrawColor(playerid, fully_dots, (color_level * 0x01010100) | 0xFF);

    for(new i = fully_dots + 1; i <= PTD_VEH_LAST_DOT; i++)
        Veh::UpdateTextDrawColor(playerid, i, 0 | 0xFF);
    
    GetVehicleHealth(vehicleid, health);

    new Float:old_fuel = Vehicle[vehicleid][veh::fuel];
    Vehicle[vehicleid][veh::fuel] -= fuel;

    CallLocalFunction("OnVehicleFuelChange", "iff", vehicleid, Vehicle[vehicleid][veh::fuel], old_fuel);

    Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_HEALTH, 100.0, floatclamp(health - 250.0, 0.0, 750.0)/7.5);
    Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_ARMOUR, 100.0, floatclamp(health - 1000.0, 0.0, 1000.0)/10.0);
    Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_FUEL, 100.0, (floatclamp(Vehicle[vehicleid][veh::fuel], 0.0, 60.0) * 1.67));
    
    Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "%i", speed);

    Vehicle[vehicleid][veh::old_speed] = speed;
    Vehicle[vehicleid][veh::old_accel] = accel;
    Vehicle[vehicleid][veh::tick] = tick;

    return 1;
}

hook OnVehicleFuelChange(vehicleid, Float:new_fuel, Float:old_fuel)
{
    new playerid = GetVehicleDriver(vehicleid);

    if(new_fuel <= 0.0)
    {
        Vehicle[vehicleid][veh::fuel] = 0.0;
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);
        SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY);
        if(IsValidPlayer(playerid))
            SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Gasolina acabou. Procure chame o {ff3333}serviço mecânico ou abasteça!");
        return 1;
    }

    if(new_fuel < 15.0)
    {
        if(veh::Player[playerid][pyr::tick_gas_notify] > GetTickCount()) return 1;
        
        if(IsValidPlayer(playerid))
            SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Gasolina abaixo de {ff9933}25%% {ffffff}procure um posto para abastecer!");
        
        veh::Player[playerid][pyr::tick_gas_notify] = GetTickCount() + 2 * 60000;
    }

    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if(newkeys == KEY_YES)
    {
        if(!IsPlayerInAnyVehicle(playerid)) return 1;
        
        new vehicleid = GetPlayerVehicleID(playerid);

        if(IsValidVehicle(vehicleid))
            Veh::ToogleEngine(playerid, GetPlayerVehicleID(playerid));

        return 1;
    }

    return 1;
}

hook function CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:rotation, colour1, colour2, respawn_delay, bool:add_siren = false)
{
    new regionid = GetRegionFromXY(x, y);

    new vehicleid = continue(modelid, x, y, z, rotation, colour1, colour2, respawn_delay, add_siren);

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        CallLocalFunction("OnVehicleCreate", "iiifff", vehicleid, modelid, regionid, x, y, z);
        
        if(regionid != INVALID_REGION_ID) 
            Veh::AddToRegion(vehicleid, regionid);
    }

    return vehicleid;
}

hook function DestroyVehicle(vehicleid)
{
    Veh::RemoveFromRegion(vehicleid);
    CallLocalFunction("OnVehicleDestroy", "i", vehicleid);
    return continue(vehicleid);
}
