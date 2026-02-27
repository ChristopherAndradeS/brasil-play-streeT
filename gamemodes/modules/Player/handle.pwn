#include <YSI\YSI_Coding\y_hooks>

#if defined ON_DEBUG_MODE

hook OnPlayerConnect(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return -1;

    return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return -1;
    
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

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION))
    {
        Player::KillTimer(playerid, pyr::TIMER_RESUSCITATION);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

        new targetid = Player[playerid][pyr::resuscitation_targetid];
        if(IsValidPlayer(targetid))
        {
            ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
            Player[targetid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
            TogglePlayerControllable(targetid, GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED) ? false : true);
            ClearAnimations(targetid, SYNC_ALL);

            if(GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED))
                ApplyAnimation(targetid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_ALL);
        }
    }

    Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;

    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);
    Acessory::HideTDForPlayer(playerid);
    Adm::HideTDForPlayer(playerid);
    Veh::HideTDForPlayer(playerid);

    Player::ClearData(playerid);

    Adm::RemSpectatorInList(playerid, 1);

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


stock Player::HandleResuscitationAction(playerid)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 0;
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED)) return 0;
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION)) return 0;

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    new near_players[MAX_PLAYERS];
    for(new i = 0; i < MAX_PLAYERS; i++)
        near_players[i] = INVALID_PLAYER_ID;

    Player::GetPlayersFlaggedInRange(pX, pY, pZ, FLAG_PLAYER_INJURED, 2.25, near_players);

    new targetid = near_players[0];

    if(targetid == INVALID_PLAYER_ID) return 0;

    if(targetid == playerid)
    {
        for(new i = 1; i < MAX_PLAYERS; i++)
        {
            if(near_players[i] != INVALID_PLAYER_ID)
            {
                targetid = near_players[i];
                break;
            }
        }
    }

    if(targetid == INVALID_PLAYER_ID || targetid == playerid) return 0;

    return Player::StartResuscitation(playerid, targetid);
}

stock Player::HandleKeySelector(playerid, KEY:newkeys, KEY:oldkeys)
{
    if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
        Player::HandleResuscitationAction(playerid);

    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if(IsPlayerNPC(playerid)) return -1;

    Player::HandleKeySelector(playerid, newkeys, oldkeys);

    return 1;
}

public Player::Kick(playerid, E_PLAYER_TIMERS:timerid, const msg[]) 
{    
    Player::KillTimer(playerid, timerid);
    
    if(IsPlayerConnected(playerid))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}%s", msg);
        Kick(playerid);
    }
    
    return 1; 
}
