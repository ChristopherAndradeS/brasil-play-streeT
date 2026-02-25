#define MAX_GAMES_INSTANCES     (5)
#define MAX_GAME_PARTICIPANTS   (5)
#define GAME_TIME_WAIT          (60)
#define INVALID_GAME_ID         (-1)

#define INVALID_GAME_TYPE       (GAME_TYPES:0)

enum GAME_TYPES
{
    GAME_TYPE_RACE          = 1,
    GAME_TYPE_ARENA         = 2,
}

enum GAME_STATES
{
    INVALID_GAME_STATE      = 0,
    GAME_STATE_FINISHED     = 1,
    GAME_STATE_WAIT_FILL    = 2,
    GAME_STATE_STARTING     = 3,
    GAME_STATE_STARTED      = 4,
    GAME_STATE_FINISHING    = 5,
}

enum (<<= 1)
{
    FLAG_GAME_CREATED      = 1,
}

enum (<<= 1)
{
    FLAG_PLAYER_INGAME = 1,
    FLAG_PLAYER_WAITING,
    FLAG_PLAYER_PLAYING,
    FLAG_PLAYER_FINISHED,
    FLAG_PLAYER_ELIMINATED
}

enum E_GAMES
{
    game::name[32],
    game::args[128],
    GAME_TYPES:game::type,
    GAME_STATES:game_state,
    game::tick,
    game::flags,
    game::vw,
    List:game::players,
    game::minparts,
    game::maxparts,
}

new Game[MAX_GAMES_INSTANCES][E_GAMES];

enum E_PLAYER_GAMES
{
    pyr::flags,
    pyr::gameid,
}

new game::Player[MAX_PLAYERS][E_PLAYER_GAMES];

new const Game::gStateName[][32] =
{
    {"{cdcdcd}Estado invalido"},
    {"{7f7f7f}Terminou"},
    {"{ffff99}Esperando..."},
    {"{99ff99}Comecando"},
    {"{ff9999}Em partida"},
    {"{9999ff}Terminando"}
};

new const Game::gTypeName[][32] =
{
    {"{cdcdcd}Tipo invalido"},
    {"{ff9999}Corrida"},
    {"{ff3333}Arena"}
};

forward Game_Update(gameid);
