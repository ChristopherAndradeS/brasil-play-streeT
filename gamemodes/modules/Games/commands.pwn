YCMD:evento(playerid, params[], help)
{
    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING))
        return SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você já está em um evento. Digite {ff5533}/sair {ffffff}para sair deste evento.");

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))
        return SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você já está em um jogo. Digite {ff5533}/sair {ffffff}para sair.");

    if(Game::GetCount() <= 0)
        return SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Não há eventos disponíveis no momento.");
    
    new msg[512];

    strcat(msg, "ID\tEvento\tStatus\tParticipantes\t \n");

    new idx = 1;

    for(new i = 0; i < MAX_GAMES; i++)
    {
        if(!GetFlag(Game[i][game::flags], FLAG_GAME_CREATED)) continue;

        format(msg, 512, "%s{ff5533}%d.\t{ffffff}%s\t%s\t{55ff55}%d{ffffff}/{55ff55}%d\t{cdcdcd}CLIQUE AQUI PARA ENTRAR\n", msg,
        idx, Game[i][game::name], 
        Game[i][game_state] <= GAME_STATE_STARTING ? "{99ff99}Aguardando" : "{ffff99}Em andamento", 
        Game::GetPlayerCount(i), Game[i][game::max_players]);

        idx++;
    }

    inline event_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, inputtext

        if(!response) return 1;

        new gameid = Game::GetIDByListIndex(listitem);

        if(gameid == INVALID_GAME_ID || !Game::HandlePlayer(playerid, gameid))
        {
            SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Não foi possível entrar no evento.");
        }
        else
        {
            SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você entrou no evento com sucesso.");
        }
        return 1;
    }

    Dialog_ShowCallback(playerid, using inline event_dialog, DIALOG_STYLE_TABLIST_HEADERS, "Clique para entrar no evento", msg, "Selecionar", "Fechar");
    
    return 1;
}

YCMD:sair(playerid, params[], help)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING) && !GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))
        return SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você não está participando de nenhum evento.");

    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid == INVALID_GAME_ID)
    {
        printf("[ EVENTO ] ERRO FATAL: O jogador %s tentou sair de um evento, mas não tinha um ID de jogo válido.", GetPlayerNameStr(playerid));
        return SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Ocorreu um erro ao tentar sair do evento. Tente novamente.");
    }
    
    Game::RemovePlayer(gameid, playerid);
    SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você saiu do evento com sucesso.");
    
    return 1;
}