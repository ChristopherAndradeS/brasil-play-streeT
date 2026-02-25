#include <YSI\YSI_Coding\y_hooks>

forward OnPlayerDied(playerid, killerid, WEAPON:reason);
forward OnPlayerSpawnAfterDied(playerid, killerid, WEAPON:reason);
forward PYR_RefreshDeath(playerid, killerid, WEAPON:reason);

hook OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid)) return -1;
            
    ClearChat(playerid, 20);

    Player::ClearAllData(playerid);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    /* VERIFICAR NOME - É ADEQUADO ?  */
    if(!IsValidNickName(name))
    {
        SendClientMessage(playerid, -1 , "{ff3333}[ KICK ] {ffffff}Seu nome de usuario e invalido!");
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

hook OnPlayerDisconnect(playerid, reason)
{
    /* JOGADOR É NPC */
    if(IsPlayerNPC(playerid)) return -1;

    /* JOGADOR É VÁLIDO MAS NÃO LOGOU */
    
    Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return -1;

    /* JOGADOR É VÁLIDO / LOGOU / ESTÁ EM MODO ESPECTADOR */
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING)) 
    {
        return -1;
    }
    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(IsValidTimer(pyr::Timer[playerid][pyr::TIMER_PAYDAY]))
    {
        new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);
        DB::SetDataInt(db_entity, "players", "payday_tleft", t_left, "name = '%q'", name);
        Player::KillTimer(playerid, pyr::TIMER_PAYDAY);
    }

    /* JOGADOR É VÁLIDO / LOGOU / ESTÁ PRESO */
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        if(DB::Exists(db_entity, "punishments", "name = '%q' AND level = 1", name))
        {
            new left_time = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);
            DB::SetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = '%q' AND level = 1", name);
        }

        Player::KillTimer(playerid, pyr::TIMER_JAIL); 
    }

    else if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME)) 
        return 1;

    else
    {
        new Float:pX, Float:pY, Float:pZ, Float:pA;

        GetPlayerName(playerid, name);
        GetPlayerPos(playerid, pX, pY, pZ);
        GetPlayerFacingAngle(playerid, pA);
    
        DB::Update(db_entity, "players", 
        "pX = %f, pY = %f, pZ = %f, pA = %f WHERE name = '%q'",
        pX, pY, pZ, pA, name);
    }

    if(IsValidVehicle(Player[playerid][pyr::vehicleid]))
        Veh::Destroy(Player[playerid][pyr::vehicleid]);
        
    Player::DestroyCpfTag(playerid);
    Adm::RemSpectatorInList(playerid, 1);
    Player::ClearAllData(playerid);

    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);
    Acessory::HideTDForPlayer(playerid);
    Adm::HideTDForPlayer(playerid);
    Veh::HideTDForPlayer(playerid);

    return 1;
}

hook OnPlayerLogin(playerid)
{
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

    Player[playerid][pyr::health] = 100.0;

    Player::Spawn(playerid);

    /* PÓS SPAWN */

    // CPF
    Player::SetCPF(playerid);

    ApplyAnimation(playerid, "ped", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "DANCING", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "CRACK", "null", 0.0, false, false, false, false, 0); 

    // RODAPÉ
    Baseboard::ShowTDForPlayer(playerid);

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 2000, 3);

    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
    Player[playerid][pyr::vehicleid] = INVALID_VEHICLE_ID; 

    return 1;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
    if(GetFlag(Player[damagedid][pyr::flags], FLAG_PLAYER_INVUNERABLE)) return -1;

    Player::UpdateDamage(damagedid, playerid, amount, weaponid, bodypart);
    
    return 1;
}

hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid)) return 1;

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH)) return 1;

    if(killerid == INVALID_PLAYER_ID) 
        if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH))
            if(reason != WEAPON_DROWN && reason != WEAPON_COLLISION && reason != REASON_EXPLOSION)
            {
                printf("[ PVP ] Morte suspeita: %s (ID: %d) morreu sem assassino. Motivo: %d", GetPlayerNameStr(playerid), playerid, _:reason);
                return 0;
            }
    
    return 1;
}

public PYR_RefreshDeath(playerid, killerid, WEAPON:reason)
{
    Player[playerid][pyr::health] = 100.0;
    SetPlayerHealth(playerid, 100.0);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);

    SpawnPlayer(playerid);

    Player::KillTimer(playerid, pyr::TIMER_DEATH);

    CallLocalFunction("OnPlayerSpawnAfterDied", "iii", playerid, killerid, reason);

    return 1;
}

hook OnPlayerDied(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid) && !IsValidPlayer(killerid)) return 1;

    new time;
    Player::AplyRandomDeathAnim(playerid, time);

    Player::CreateTimer(playerid, pyr::TIMER_DEATH, "PYR_RefreshDeath", time, false, "iii", playerid, killerid, reason);

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
