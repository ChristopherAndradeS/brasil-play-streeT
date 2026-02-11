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
    printf("1");
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
    printf("2");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    /* JOGADOR É VÁLIDO / LOGOU / ESTÁ PRESO */
    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL))
    {
        printf("3");
        if(DB::Exists(db_entity, "punishments", "name, level", "name = '%q' AND level = 1", name))
        {
            new left_time = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);
            DB::SetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = '%q' AND level = 1", name);
        }

        Player::KillTimer(playerid, pyr::TIMER_JAIL); 
    }

    else
    {
        printf("4");
        new Float:pX, Float:pY, Float:pZ, Float:pA;

        GetPlayerName(playerid, name);
        GetPlayerPos(playerid, pX, pY, pZ);
        GetPlayerFacingAngle(playerid, pA);
        new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);

        DB::Update(db_entity, "players", 
        "pX = %f, pY = %f, pZ = %f, pA = %f, payday_tleft = %i WHERE name = '%q'",
        pX, pY, pZ, pA, t_left, name);

        Player::KillTimer(playerid, pyr::TIMER_PAYDAY);
    }

    printf("5");
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
        DB::GetDataInt(db_entity, "punishments", "left_tstamp", time, "name = '%q' AND level = 1", GetPlayerNameEx(playerid));
        
        Punish::SendPlayerToJail(playerid, time);
        SendClientMessage(playerid, -1, "{ff3399}[ PUNICAO ADM ] {ffffff}Voce ainda precisa cumprir sua pena aqui na ilha!");
        return -1;
    }

    //Handle Spawn
    Player::Spawn(playerid);

    return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
    if(!IsValidPlayer(playerid)) return -1;

    SpawnPlayer(playerid);
    return SpawnPlayer(playerid);
}

hook OnPlayerSpawn(playerid)
{    
    if(IsPlayerNPC(playerid)) return -1;

    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}Um erro desconhecido aconteceu! Voce spawnou sem estar logado!");
        Kick(playerid);
        return -1;
    }

    if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING))
    {
        ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING);  
        //SendClientMessage(playerid, -1, "{33ff33}[ SERVER ] {ffffff}Voce saiu do modo espectador!");
        Adm::AddSpectatorInList(playerid); 
        SetPlayerWeather(playerid, Server[srv::g_weatherid]);

        return -1;
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