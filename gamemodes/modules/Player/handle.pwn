#include <YSI\YSI_Coding\y_hooks>

forward OnPlayerInjury(playerid, killerid, WEAPON:reason);
forward PYR_SetInjured(playerid, killerid, WEAPON:reason);
forward OnPlayerInjuryUpate(playerid);

#define MAX_PLAYER_TICK_INJURY (10000)

#if defined ON_DEBUG_MODE

hook OnPlayerConnect(playerid, classid)
{
    if(IsPlayerNPC(playerid))
    {
        return -1;
    } 

    return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid))
    {
        return -1;
    } 

    Login::UnSetPlayer(playerid);

    return 1;
}

#else

hook OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid)) return -1;
    
    ClearChat(playerid, 20);

    Player::ClearData(playerid);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    //DB::GetDataInt(db_entity, "players", "flags", Player[playerid][pyr::flags], "name = '%q'", name);

    /* VERIFICAR NOME - É ADEQUADO ?  */
    if(!IsValidNickName(name))
    {
        SendClientMessage(playerid, -1 , "{ff3333}[ KICK ] {ffffff}Seu nome de usuário e inválido!");
        Kick(playerid);
        return -1; // ENCERRA PROXÍMAS EXECUÇÕES DE hook OnPlayerConnect
    }

    /* VERIFICAR PUNIÇÃO - ESTÁ BANIDO ?  */
    if(!Punish::VerifyPlayer(playerid))
    {
        SendClientMessage(playerid, -1 , "{ff3333}[ KICK ] {ffffff}Você esta {ff3333}banido {ffffff}deste servidor!");
        Kick(playerid);
        return -1;
    }

    Officine::RemoveGTAObjects(playerid, MAP_MEC_LS);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_AIRPORT);
    Org::RemoveGTAObjects(playerid);
    Store::RemoveGTAObjects(playerid, MAP_STORE_BINCO);
    Spawn::RemoveGTAObjects(playerid);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_HP);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_LS);
    Ammu::RemoveGTAObjects(playerid);
    Bank::RemoveGTAObjects(playerid, MAP_BANK_LOTTERY);
    House::RemoveGTAObjects(playerid);

    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);
    Acessory::HideTDForPlayer(playerid);
    Adm::HideTDForPlayer(playerid);
    Veh::HideTDForPlayer(playerid);

    return 1;
}

#endif

hook OnPlayerDisconnect(playerid, reason)
{
    if(IsPlayerNPC(playerid)) return -1;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) 
    {
        Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);
        return -1;
    }

    Player::KillTimer(playerid, pyr::TIMER_PAYDAY);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING)) 
    {
        TogglePlayerSpectating(playerid, false);
    }
    
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        if(DB::Exists(db_entity, "punishments", "name = '%q' AND level = 1", name))
            Player::KillTimer(playerid, pyr::TIMER_JAIL);
    }
    
    if(IsPlayerInAnyVehicle(playerid))
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);

    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);
    Acessory::HideTDForPlayer(playerid);
    Adm::HideTDForPlayer(playerid);
    Veh::HideTDForPlayer(playerid);

    Player::ClearData(playerid);

    //Adm::RemSpectatorInList(playerid, 1);

    return 1;
}

hook OnPlayerLogin(playerid)
{
    ApplyAnimation(playerid, "ped", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "DANCING", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "CRACK", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "SWAT", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "KNIFE", "null", 0.0, false, false, false, false, 0); 

    Player[playerid][pyr::health] = 100.0;

    Player::SetNameTag(playerid);

    //SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

    Baseboard::ShowTDForPlayer(playerid);

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 2000, 3);

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        new time;
        DB::GetDataInt(db_entity, "punishments", "left_tstamp", time, "name = '%q' AND level = 1", GetPlayerNameStr(playerid));
        Punish::SendPlayerToJail(playerid, time);
        SendClientMessage(playerid, -1, "{ff3399}[ PUNICAO ADM ] {ffffff}Voce ainda precisa cumprir sua pena aqui na ilha!");

        return -1;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IS_PARDON))
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IS_PARDON);
    }

    Player::Spawn(playerid);

    return 1;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
    if(!IsValidPlayer(damagedid)) return 1;

    if(GetFlag(Player[damagedid][pyr::flags], FLAG_PLAYER_INJURED))  
    {
        GameTextForPlayer(playerid, "~r~~h~OVERKILL", 1000, 4);
        return -1;
    }

    if(GetFlag(Player[damagedid][pyr::flags], FLAG_PLAYER_INVUNERABLE)) return -1;

    if(org::Player[playerid][pyr::orgid] == org::Player[damagedid][pyr::orgid])
    {
        GameTextForPlayer(playerid, "~r~~h~FOGO AMIGO", 1000, 3);
        return -1;
    }

    Player::UpdateDamage(damagedid, playerid, amount, weaponid, bodypart);
    
    return 1;
}

hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid)) return 1;

    if(killerid == INVALID_PLAYER_ID) 
    {
        if(reason != WEAPON_DROWN && reason != WEAPON_COLLISION && reason != REASON_EXPLOSION)
        {
            printf("[ PVP ] Morte suspeita: %s (ID: %d) morreu sem assassino. Motivo: %d", GetPlayerNameStr(playerid), playerid, _:reason);
            return 0;
        }
    }

    else
    {
        printf("[ PVP ] Morte suspeita: %s (ID: %d) morreu por %s (ID: %d) Sem validação do SERVER.", GetPlayerNameStr(playerid), playerid, GetPlayerNameStr(killerid), killerid);
        printf("[ PVP ] Motivo: %d", _:reason);  
    }

    return 1;
}

hook OnPlayerInjury(playerid, killerid, WEAPON:reason)
{
    #pragma unused reason
    
    if(!IsValidPlayer(playerid) && !IsValidPlayer(killerid)) return 1;

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))return 1;
    
    inline update()
    {
        new tick = Player[playerid][pyr::death_tick] - GetTickCount();

        if(!IsValidPlayer(playerid))
        {
            Timer_KillCallback(pyr::Timer[playerid][pyr::TIMER_INJURY]);
            DestroyDynamic3DTextLabel(Player[playerid][pyr::deathtag]);
            print("invalido");
            Player[playerid][pyr::deathtag] = INVALID_3DTEXT_ID;
            return 1;
        }

        new str[256];

        if(tick <= 0)
        {

            Player[playerid][pyr::health] = 50.0;
            SetPlayerHealth(playerid, 50.0);

            ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED);
            ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
            
            Travel::ShowTDForPlayer(playerid, 
            "A emergencia chegou e~n~Voce foi para o hospital...",
            1182.2079 + RandomFloatMinMax(-2.0, 2.0), 
            -1323.2695 + RandomFloatMinMax(-2.0, 2.0), 13.5798, 270.0);
            
            Timer_KillCallback(pyr::Timer[playerid][pyr::TIMER_INJURY]);
            DestroyDynamic3DTextLabel(Player[playerid][pyr::deathtag]);
            Player[playerid][pyr::deathtag] = INVALID_3DTEXT_ID;

            print("TIMERMORT");

            //CallLoca

            return 1;
        }

        format(str, 256, "[ {ff4444}FERIDO {ffffff}]\nUse {ff4444}'F' {ffffff}ou {ff4444}/rev {ffffff}para socorrer\n{ff4444}Emergencia {ffffff}chegara em: {ff4444}%02d{ffffff}:{ff4444}%02d", 
        floatround((tick / 60000)), floatround((tick % 60000) / 1000));

        if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED))
        {
            Player[playerid][pyr::deathtag] = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, -0.3, 60.0, .attachedplayer = playerid, .testlos = 1);
            SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED);
        }

        else
        {
            UpdateDynamic3DTextLabelText(Player[playerid][pyr::deathtag], -1, str);
            GameTextForPlayer(playerid, "~r~~h~Emergencia chegara em:~n~~w~%02d~r~~h~:~w~%02d", 900, 3, floatround((tick / 60000)), floatround((tick % 60000) / 1000));
        }

        foreach (new i : StreamedPlayer[playerid])
        {
            Streamer_Update(i, STREAMER_TYPE_3D_TEXT_LABEL);
        }
    }
    
    TogglePlayerControllable(playerid, false);

    ClearAnimations(playerid, SYNC_ALL);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_OTHER);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_ALL);

    new time_sos = floatround(GetPlayerDistanceFromPoint(playerid, 1182.2079, -1323.2695, 13.5798) / 0.012);
    Player[playerid][pyr::death_tick] = GetTickCount() + time_sos;
    
    new count = floatround(time_sos / 1000.0, floatround_ceil);
    
    printf("%d %d", time_sos, count);

    pyr::Timer[playerid][pyr::TIMER_INJURY] = Timer_CreateCallback(using inline update, 1000, count);

    return 1;
}

hook OnPlayerSpawn(playerid)
{    
    if(IsPlayerNPC(playerid)) return -1;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}Um erro desconhecido aconteceu! Voce spawnou sem estar logado!");
        Kick(playerid);
        return -1;
    }
    
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING))
    {
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING);  
        Adm::AddSpectatorInList(playerid); 
        SetPlayerWeather(playerid, Server[srv::g_weatherid]);
        SetPlayerHealth(playerid, Player[playerid][pyr::health]);
        return 1;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        SetPlayerWeather(playerid, Server[srv::j_weatherid]);
        return -1;
    }
   
    return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT)) return 1;
    
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT);
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Você chegou ao seu destino!");
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0); 
    
    return 1;
}

hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::AddToRegion(playerid, regionid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID) return 1;

        Veh::AddToRegion(vehicleid, regionid);
    }

    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;
    
    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::RemoveFromRegion(playerid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID)  return 1;

        Veh::RemoveFromRegion(vehicleid);
    }

    return 1;
}
