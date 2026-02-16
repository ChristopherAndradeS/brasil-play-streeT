#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Game::Create(GAME_TYPE_RACE, 2, 5);
    Game::Create(GAME_TYPE_RACE, 2, 5);
    Game::Create(GAME_TYPE_RACE, 2, 5);

    return 1;
}

hook OnGameModeExit()
{
    for(new i = 0; i < MAX_GAMES; i++)
        Game::Destroy(i);
    
    return 1;
}