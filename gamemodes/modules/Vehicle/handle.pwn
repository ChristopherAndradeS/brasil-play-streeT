#include <YSI\YSI_Coding\y_hooks>

#define INVALID_OWNER_ID (-1)

forward OnSpeedOMeterUpdate(playerid);
forward Float:Veh::GetVehicleFuelUsed(Float:speed, Float:accel, Float:dt);
forward OnVehicleFuelChange(playerid, Float:new_fuel, Float:old_fuel);

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

    if(!IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
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

    if(IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
    {
        Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "X");
        return 1;
    }

    if(IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
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

hook OnVehicleDamageStatusUpdate(vehicleid, playerid)
{

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
    if(IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
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

stock Veh::Destroy(&vehicleid)
{
    if(IsValidVehicle(vehicleid))
        DestroyVehicle(vehicleid);
    
    Veh::Clear(vehicleid);
    vehicleid = INVALID_VEHICLE_ID;
}

hook function DestroyVehicle(vehicleid)
{
    Veh::RemoveFromRegion(vehicleid);
    CallLocalFunction("OnVehicleDestroy", "i", vehicleid);
    return continue(vehicleid);
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
