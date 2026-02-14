#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Game::Create(GAME_TYPE_RACE, "Corrida de Kart 1", 2, 5);
    Game::Create(GAME_TYPE_RACE, "Corrida de Kart 2", 2, 5);
    Game::Create(GAME_TYPE_RACE, "Corrida de Kart 3", 2, 5);
    // Game::Create(GAME_TYPE_RACE, "Corrida de Kart 4", 2, 5);
    // Game::Create(GAME_TYPE_RACE, "Corrida de Kart 5", 2, 5);

    return 1;
}

hook OnGameModeExit()
{
    for(new i = 0; i < MAX_GAMES; i++)
    {   
        printf("[ EVENTO ] Evento %s destruido com sucesso", Game[i][game::name]);
        Game::Destroy(i);
    }

    return 1;
}