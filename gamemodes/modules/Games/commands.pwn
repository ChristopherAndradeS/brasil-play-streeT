YCMD:evento(playerid, params[], help)
{
    if(IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Sai do modo de trabalho: {ff3333}/aw {ffffff}para poder jogar nos eventos!");

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME) || GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING))
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Você já está em um evento. Digite {ff3333}/sair {ffffff}para sair deste evento.");

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED))
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Você terminou uma corrida, aguarde a {ff3333}premiação {ffffff}para iniciar outra partida.");

    if(Game::GetCount() <= 0)
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Não há eventos disponíveis no momento.");
    
    new msg[1024];
    
    strcat(msg, "{3399ff}Evento\t{ffffff}Tipo\t{3399ff}Status\t{ffffff}Vagas\n");

    for(new gameid = 0; gameid < MAX_GAMES_INSTANCES; gameid++)
    {
        if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) continue;

        format(msg, 512, "%s{ffffff}%s\t%s\t%s\t{55ff55}%02d{ffffff}/{55ff55}%02d\n", msg,
        Game[gameid][game::name], 
        Game::gTypeName[_:Game[gameid][game::type]], Game::gStateName[_:Game[gameid][game_state]],
        Game::GetPlayersCount(gameid), Game[gameid][game::maxparts]);
    }

    inline event_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, inputtext

        if(!response) return 1;
        
        Game::InsertPlayer(listitem, playerid);

        return 1;
    }

    Dialog_ShowCallback(playerid, using inline event_dialog, DIALOG_STYLE_TABLIST_HEADERS, 
    "Clique para entrar no evento", msg, "Selecionar", "Fechar");
    
    return 1;
}

YCMD:sair(playerid, params[], help)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Você não está participando de nenhum evento.");

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED))
        return SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Você está esperando uma partida a qual você já se classificou terminar!");

    SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED);
    Game::RemovePlayer(game::Player[playerid][pyr::gameid], playerid);
    
    return 1;
}