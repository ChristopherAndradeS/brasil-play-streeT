new const Float:Arena::gSpawns[][4] =
{
    {-2823.6274, 721.6258, 964.9241, 100.3857}, // arena1
    {-2835.0347, 721.3716, 964.9241, 112.2924}, // arena2
    {-2840.3401, 711.0156, 964.9241, 181.8531}, // arena3
    {-2833.6541, 703.7123, 964.9241, 260.1872}, // arena4
    {-2823.3025, 704.6317, 964.9241, 271.4673}, // arena5
    {-2810.1538, 704.4257, 964.9241, 291.1841}, // arena6
    {-2823.3718, 712.7670,964.9241,  6.384}    // arena7
};

new const Float:Arena::gSpec[][4] =
{
    {-2823.7285, 737.5068, 969.2119, 180.0},    // ESPEC 1
    {-2823.5251, 690.0143, 969.2119, 0.0}      // ESPEC 2
};

#define ARENA_MATCH_TIME      (300)
#define ARENA_RESPAWN_TIME_MS (6000)

enum (<<= 1)
{
    FLAG_ARENA_CREATED = 1,
}

enum E_GAME_ARENA
{
    arena::flags,
    WEAPON:arena::weapons[3],
    arena::ammos[3],
    Float:arena::rewards[MAX_GAME_PARTICIPANTS],
    arena::best_player,
    arena::best_kill,
    STREAMER_TAG_OBJECT:arena::objectid,
    Map:arena::participant,
}

enum _:E_ARENA_SEAT
{
    arena::playerid,
    arena::kills,
    arena::deaths,
    arena::respawn_timer,
    arena::killer,
}

new Arena[MAX_GAMES_INSTANCES][E_GAME_ARENA];

forward ARN_DoRespawn(playerid, gameid);

