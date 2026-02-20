#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Game::Create("[ EVENTO AUTO ] Corrida ", "Server", GAME_TYPE_RACE, 2, 5, true, "571 2 100.0 75.0 50.0 25.0 0.0");
    Game::Create("[ EVENTO AUTO ] Arena ", "Server", GAME_TYPE_ARENA, 2, 5, true, "");

    return 1;
}

hook OnGameModeExit()
{
    for(new i = 0; i < MAX_GAMES_INSTANCES; i++)
        Game::Destroy(i);
    
    return 1;
}

hook OnPlayerConnect(playerid)
{
    Game::ClearPlayer(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    printf("teste");

    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid != INVALID_GAME_ID)
        Game::RemovePlayer(gameid, playerid);

    return 1;
}
