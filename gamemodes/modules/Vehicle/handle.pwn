#include <YSI\YSI_Coding\y_hooks>

forward OnSpeedOMeterUpdate(playerid);

hook OnGameModeInit()
{
    for(new row = 0; row < REGION_GRID_SIZE; row++)
    {
        for(new col = 0; col < REGION_GRID_SIZE; col++)
        {
            new region = (row * REGION_GRID_SIZE) + col;

            veh::gRegion[region] = linked_list_new();

            new Float:min_x = WORLD_MIN + (float(col) * REGION_SIZE);
            new Float:min_y = WORLD_MIN + (float(row) * REGION_SIZE);
            new Float:max_x = min_x + REGION_SIZE;
            new Float:max_y = min_y + REGION_SIZE;

            veh::gAreas[region] = CreateDynamicRectangle(min_x, min_y, max_x, max_y);
        }
    }

    return 1;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        Baseboard::HideTDForPlayer(playerid);
        Veh::ShowTDForPlayer(playerid);
        Player::CreateTimer(playerid, pyr::TIMER_SPEEDOMETER, "OnSpeedOMeterUpdate", 32, true, "i", playerid);
    }

    else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        Veh::HideTDForPlayer(playerid);
        Baseboard::ShowTDForPlayer(playerid);
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);
    }

    return 1;
}

hook OnVehicleHealthChance(vehicleid, Float:new_health, Float:old_health)
{
    if((!IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD)) && new_health <= 250.0)
    {
        SetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD);
        
        Veh::UpdateParams(vehicleid, FLAG_PARAM_ENGINE, 0);

        SetVehicleHealth(vehicleid, 390);
        SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);

        foreach (new i : VehicleOccupant[vehicleid])
        {
            SendClientMessage(i, -1, "{ff9933}[ ! ] {ffffff}Este veículo está quebrado! Chame um mecânico");
            RemovePlayerFromVehicle(i);
        }
    }
}

public OnSpeedOMeterUpdate(playerid)
{
    if(!Veh::IsVisibleTDForPlayer(playerid) || !IsPlayerInAnyVehicle(playerid)) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
    {
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);
        return 1;
    }

    new 
        speed = GetVehicleSpeed(vehicleid),
        Float:health
    ; 

    new fully_dots = floatround(speed / 20) + PTD_VEH_FIRST_DOT;

    if(fully_dots > PTD_VEH_LAST_DOT) fully_dots = PTD_VEH_LAST_DOT;

    for(new i = PTD_VEH_FIRST_DOT; i < fully_dots; i++)
        Veh::UpdateTextDrawColor(playerid, i, -1);
    
    new color_level = clamp(floatround((speed % 20) * 13.42), 0, 255);
    Veh::UpdateTextDrawColor(playerid, fully_dots, (color_level * 0x01010100) | 0xFF);

    for(new i = fully_dots + 1; i <= PTD_VEH_LAST_DOT; i++)
        Veh::UpdateTextDrawColor(playerid, i, 0 | 0xFF);
    
    GetVehicleHealth(vehicleid, health);

    Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_HEALTH, 100.0, floatclamp(health - 250.0, 0.0, 750.0)/7.5);
    Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_ARMOUR, 100.0, floatclamp(health - 1000.0, 0.0, 1000.0)/10.0);
    Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "%d", speed);

    return 1;
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
    if(newkeys == KEY_NO)
    {
        if(!IsPlayerInAnyVehicle(playerid)) return 1;
        
        new vehicleid = GetPlayerVehicleID(playerid);

        if(IsFlagSet(Vehicle[vehicleid][veh::flags], FLAG_VEH_IS_DEAD))
        {
            SendClientMessage(playerid, -1, "{ff9933}[ ! ] {ffffff}Este veículo está quebrado! Chame um mecânico");
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

    if(newkeys == KEY_YES) 
    {
        if(IsPlayerInAnyVehicle(playerid)) return 1;

        new Float:distance;
        new vehicleid = GetClosestVehicle(playerid, distance);

        if(vehicleid == INVALID_VEHICLE_ID || distance > 2.0) return 1;
        
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

        return 1;
    }

    return 1;
}

hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return 1;

    Veh::AddToRegion(vehicleid, regionid);

    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)  return 1;

    Veh::RemoveFromRegion(vehicleid);
    Veh::UpdateRegionByPosition(vehicleid);
    
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

    LinkVehicleToInterior(vehicleid, interiorid);

    SetVehicleVirtualWorld(vehicleid, vw);

    return vehicleid;
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
    DestroyVehicle(vehicleid);
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