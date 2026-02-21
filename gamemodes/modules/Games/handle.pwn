#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Game::Create("[ SERVER ] Corrida", "Server", GAME_TYPE_RACE, 1, 2, false, "571 1 100.0 0.0 0.0 0.0 0.0");
    Game::Create("[ SERVER ] Arena", "Server", GAME_TYPE_ARENA, 2, 5, false, "200.0 40.0 0.0 0.0 0.0");

    return 1;
}

hook OnGameModeExit()
{
    for(new i = 0; i < MAX_GAMES_INSTANCES; i++) Game::Destroy(i);
    return 1;
}

hook OnPlayerConnect(playerid)
{
    Game::ClearPlayer(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid != INVALID_GAME_ID)
    {
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED);
        Game::RemovePlayer(gameid, playerid);
    }
    return 1;
}
