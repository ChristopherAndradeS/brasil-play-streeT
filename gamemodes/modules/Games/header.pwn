#define MAX_GAME_PARTICIPANTS (5)
#define MAX_GAMES             (5)

#define GAME_TIME_WAIT        (90)

#define INVALID_GAME_ID       (-1)
#define INVALID_SEAT_ID       (-1)

enum GAME_TYPES
{
    INVALID_GAME_TYPE       = 0,
    GAME_TYPE_RACE          = 1,
}

enum GAME_STATES
{
    INVALID_GAME_STATE      = 0,
    GAME_STATE_WAIT_FILL    = 1,
    GAME_STATE_STARTING     = 2,
    GAME_STATE_STARTED      = 3,
    GAME_STATE_FINISHING    = 4,
    GAME_STATE_FINISHED     = 5,
}

// enum GAME_PLAYER_STATES
// {
//     GAME_PLAYER_ELIMINATED  = -1,
//     GAME_PLAYER_FINISHED    = 0,
//     GAME_PLAYER_IN_GAME     = 2,
//     GAME_PLAYER_WAITING     = 3,
// }

enum E_GAMES
{
    GAME_TYPES:game::type,
    game::name[32],
    game::start_time,
    game::flags,
    game::vw,
    game::players[MAX_GAME_PARTICIPANTS],
    game::players_count,
    GAME_STATES:game_state,
    game::min_players,
    game::max_players,
}

new Game[MAX_GAMES][E_GAMES];

enum (<<= 1)
{
    FLAG_GAME_CREATED      = 1,
    FLAG_GAME_WAIT_FILL,
    FLAG_GAME_STARTING ,
    FLAG_GAME_STARTED  ,
    FLAG_GAME_FINISHING,
    FLAG_GAME_FINISHED ,
}

enum (<<= 1)
{
    FLAG_PLAYER_INGAME = 1,
    FLAG_PLAYER_WAITING,
    FLAG_PLAYER_PLAYING,
    FLAG_PLAYER_FINISHED,
    FLAG_PLAYER_ELIMINATED,
}


enum E_PLAYER_GAMES
{
    pyr::flags,
    pyr::gameid,
    pyr::seat,
}

new game::Player[MAX_PLAYERS][E_PLAYER_GAMES];

stock Game::Create(GAME_TYPES:typeid, const name[], min_players, max_players, notify = false)
{
    new gameid = Game::GetFreeSlotID();

    if(gameid == INVALID_GAME_ID) return 0;

    /* VAR INIT */
    format(Game[gameid][game::name], 32, "%s", name);
    Game[gameid][game::type] = typeid;
    Game[gameid][game::vw] = gameid + 1;
    Game[gameid][game::start_time] = GAME_TIME_WAIT;
    Game[gameid][game::min_players] = min_players;
    Game[gameid][game::max_players] = max_players;
    Game[gameid][game_state]  = GAME_STATE_WAIT_FILL;
    SetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED);
    Game::ClearPlayers(gameid, max_players);

    switch(typeid)
    {
        case GAME_TYPE_RACE: return Race::Create(gameid, notify);

        default: return 0;
    }
}

stock Game::Destroy(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return 1;

    new GAME_TYPES:typeid = Game[gameid][game::type];
    
    format(Game[gameid][game::name], 32, "");
    Game[gameid][game::type]        = INVALID_GAME_TYPE;
    Game[gameid][game::vw]          = -1;
    Game[gameid][game::start_time]  = 0;
    Game[gameid][game::min_players] = 0;
    Game[gameid][game::max_players] = 0;
    Game[gameid][game::flags]       = 0;
    Game[gameid][game_state]  = INVALID_GAME_STATE;
    Game::ClearPlayers(gameid, MAX_GAME_PARTICIPANTS);

    switch(typeid)
    {
        case GAME_TYPE_RACE: return Race::Destroy(gameid);

        default: return 0;
    }
}

stock Game::HandlePlayer(playerid, gameid)
{
    if((Game[gameid][game_state] > GAME_STATE_STARTING))
    {
        SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Esse jogo já começou, aguarde a próxima partida");
        return 0;
    }

    if(Game[gameid][game_state] == GAME_STATE_STARTING && Game[gameid][game::start_time] <= 10)
    {
        SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Esse jogo está começando, aguarde a próxima partida");
        return 0;
    }

    if(!Game::InsertPlayer(gameid, playerid))
    {
        SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Esse jogo está cheio, aguarde a próxima partida.");
        return 0;
    }

    new GAME_TYPES:typeid = Game[gameid][game::type];

    switch(typeid)
    {
        case GAME_TYPE_RACE:
        {
            Race::SendPlayer(playerid, gameid);
            return 1;
        }

        default: return 0;
    }
}

stock Game::GetCount()
{
    new count;
    for(new i = 0; i < MAX_GAMES; i++)
        if(GetFlag(Game[i][game::flags], FLAG_GAME_CREATED))
            count++;
    
    return count;
}

stock Game::GetPlayerCount(gameid)
{
    new count;
    for(new i = 0; i < Game[gameid][game::max_players]; i++)
        if(Game[gameid][game::players][i] != INVALID_PLAYER_ID)
            count++;
    
    return count;
}

stock Game::InsertPlayer(gameid, playerid)
{
    new lenght = Game[gameid][game::max_players];

    for(new i = 0; i < lenght; i++)
    {
        if(Game[gameid][game::players][i] == INVALID_PLAYER_ID)
        {
            Game[gameid][game::players][i] = playerid;
            Game[gameid][game::players_count]++;

            game::Player[playerid][pyr::seat] = i;
            game::Player[playerid][pyr::gameid] = gameid;
            SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);

            return 1;
        }
    }

    return 0;
}

stock Game::RemovePlayer(gameid, playerid)
{
    new seat = game::Player[playerid][pyr::seat];

    if(seat == INVALID_SEAT_ID) return 1;

    Game[gameid][game::players][seat] = INVALID_PLAYER_ID;
    Game[gameid][game::players_count]--;

    Game::ClearPlayer(playerid);

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player::Spawn(playerid);

    return 0;
}

stock Game::ClearPlayer(playerid)
{
    game::Player[playerid][pyr::seat]   = INVALID_SEAT_ID;
    game::Player[playerid][pyr::gameid] = INVALID_GAME_ID;
    game::Player[playerid][pyr::flags]  = 0;
}

stock Game::ClearPlayers(gameid, lenght)
{
    for(new i = 0; i < lenght; i++)
    {
        Game[gameid][game::players][i] = INVALID_PLAYER_ID;
        Game::ClearPlayer(i);
    }
    
    Game[gameid][game::players_count] = 0;
}

stock Game::GetFreeSlotID()
{
    for(new i = 0; i < MAX_GAMES; i++)
    {
        if(!GetFlag(Game[i][game::flags], FLAG_GAME_CREATED))
            return i;
    }

    return _:INVALID_GAME_ID;
}

stock Game::Update(gameid)
{
    switch(Game[gameid][game_state])
    {
        case GAME_STATE_WAIT_FILL:
        {

        }
        case GAME_STATE_STARTING:
        {
            
        }
        case GAME_STATE_STARTED:
        {
            
        }
        case GAME_STATE_FINISHING:
        {
            
        }
        case GAME_STATE_FINISHED:
        {
            
        }
    }
}