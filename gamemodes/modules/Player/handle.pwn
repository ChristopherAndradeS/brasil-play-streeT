#include <YSI\YSI_Coding\y_hooks>

new const gNameIssue[][32] =
{
    {"INVALID_ISSUE"},
    {"contem caracter ilegal"},
    {"tem tamanho invalido"}
};

hook OnPlayerConnect(playerid)
{
    Player::ClearAllData(playerid);

    if(IsPlayerNPC(playerid)) return -1;
        
    ClearChat(playerid, 20);

    new name[MAX_PLAYER_NAME], issue;
    GetPlayerName(playerid, name);

    /* VERIFICAR NOME - É ADEQUADO ?  */
    if(!IsValidPlayerName(name, issue))
    {
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}Seu nome de usuario e invalido: {ff3333}%s", gNameIssue[issue]);
        Kick(playerid);
        return -1; // ENCERRA PROXÍMAS EXECUÇÕES DE hook OnPlayerConnect
    }

    /* VERIFICAR PUNIÇÃO - ESTÁ BANIDO ?  */
    if(!Punish::VerifyPlayer(playerid))
    {
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}Você esta {ff3333}banido {ffffff}deste servidor!");
        Kick(playerid);
        return -1;
    }

    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    /* JOGADOR É NPC */
    if(IsPlayerNPC(playerid)) return -1;

    /* JOGADOR É VÁLIDO MAS NÃO LOGOU */
    
    Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);

    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return -1;

    /* JOGADOR É VÁLIDO / LOGOU / ESTÁ EM MODO ESPECTADOR */
    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING)) 
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
    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL))
    {
        if(DB::Exists(db_entity, "punishments", "name = '%q' AND level = 1", name))
        {
            new left_time = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);
            DB::SetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = '%q' AND level = 1", name);
        }

        Player::KillTimer(playerid, pyr::TIMER_JAIL); 
    }

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING))
    {
        new gameid = game::Player[playerid][pyr::gameid];
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Game::RemovePlayer(gameid, playerid);
    }

    else if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) 
    {
        new gameid = game::Player[playerid][pyr::gameid];
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Race::EliminatePlayer(playerid, gameid);
    }

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

    Player::DestroyCpfTag(playerid);
    Adm::RemSpectatorInList(playerid, 1);
    Player::ClearAllData(playerid);

    return 1;
}

hook OnPlayerLogin(playerid)
{
    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL))
    {
        new time;
        DB::GetDataInt(db_entity, "punishments", "left_tstamp", time, "name = '%q' AND level = 1", GetPlayerNameStr(playerid));
        
        Punish::SendPlayerToJail(playerid, time);
        SendClientMessage(playerid, -1, "{ff3399}[ PUNICAO ADM ] {ffffff}Voce ainda precisa cumprir sua pena aqui na ilha!");
        return -1;
    }

    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IS_PARDON))
    {
        SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");
        ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IS_PARDON);
    }

    Player::Spawn(playerid);

    /* PÓS SPAWN */

    // CPF
    Player::SetCPF(playerid);

    // RODAPÉ
    Baseboard::ShowTDForPlayer(playerid);

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 2000, 3);

    return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;
   
    //if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_DEATH)) return 1;

    Player::Spawn(playerid);

    return 1;
}

hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;
    
    SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_DEATH);

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING))
    {
        new gameid = game::Player[playerid][pyr::gameid];
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Game::RemovePlayer(gameid, playerid);
        //Player::Spawn(playerid, true);
    }

    else if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING))
    {
        new gameid = game::Player[playerid][pyr::gameid];
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Race::EliminatePlayer(playerid, gameid);
        //Player::Spawn(playerid, true);
        SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você foi eliminado do evento, porque morreu!");
    }

    return 1;
}

hook OnPlayerSpawn(playerid)
{    
    if(IsPlayerNPC(playerid)) return -1;

    if(GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_DEATH))
        ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_DEATH);

    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}Um erro desconhecido aconteceu! Voce spawnou sem estar logado!");
        Kick(playerid);
        return -1;
    }


    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING))
    {
        ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING);  
        ApplyAnimation(playerid, "ped", "null", 0.0, false, false, false, false, 0); 
        ApplyAnimation(playerid, "DANCING", "null", 0.0, false, false, false, false, 0); 
        //SendClientMessage(playerid, -1, "{33ff33}[ SERVER ] {ffffff}Voce saiu do modo espectador!");
        Adm::AddSpectatorInList(playerid); 
        SetPlayerWeather(playerid, Server[srv::g_weatherid]);

        return 1;
    }

    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL))
    {
        SetPlayerWeather(playerid, Server[srv::j_weatherid]);
        return -1;
    }
   
    return 1;
}

stock Player::DestroyCpfTag(playerid)
{
    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]))
    {
        DestroyDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]);
        Player[playerid][pyr::cpf_tag] = INVALID_3DTEXT_ID;
    }
}