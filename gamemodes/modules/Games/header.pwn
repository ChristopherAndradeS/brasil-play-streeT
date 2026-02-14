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
    pyr::raceid, //LEMBRAR DE LIMPAR ISSO QUANDO O JOGO ACABAR
}

new game::Player[MAX_PLAYERS][E_PLAYER_GAMES];

forward Game_Update(gameid);

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

stock Game::Clear(gameid, notify = false)
{
    new name[32], min_p, max_p, GAME_TYPES:type;

    format(name, 32, "%s", Game[gameid][game::name]);
    min_p = Game[gameid][game::min_players];
    max_p = Game[gameid][game::max_players];
    type = Game[gameid][game::type];

    Game::Destroy(gameid);
    Game::Create(type, name, min_p, max_p, false);

    if(notify)
        SendClientMessageToAll(-1, "{ff5533}[ EVENTO ] {ffffff}Evento {ff5533}%s {ffffff}reiniciou.", name);
}

stock Game::Destroy(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return 1;

    new GAME_TYPES:typeid = Game[gameid][game::type];

    new name[32];
    format(name, 32, "%s", Game[gameid][game::name]);
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
        case GAME_TYPE_RACE: return Race::Destroy(gameid, name);

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
            SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
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

stock Game::SendMessageToAll(gameid, const message[], GLOBAL_TAG_TYPES:...)
{
    new formatted_message[144];
    va_format(formatted_message, 144, message, ___(2));
    
    new lenght = Game[gameid][game::max_players];

    for(new i = 0; i < lenght; i++)
        if(Game[gameid][game::players][i] != INVALID_PLAYER_ID)
            SendClientMessage(Game[gameid][game::players][i], -1, formatted_message);
}

stock Game::SetPlayersReady(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Ready(gameid);
        default: return 0;
    }
}

stock Game::StartPlayers(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Start(gameid);
        default: return 0;
    }
}

stock Game::UpdatePlayers(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Update(gameid);
        default: return 0;
    }
}

stock Game::FinishPlayers(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Finish(gameid);
        default: return 0;
    }
}

stock Game::GivePlayerRewards(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::GiveRewards(gameid);
        default: return 0;
    }    
}

stock Game::PlaySoundForAll(gameid, soundid)
{
    for(new i = 0; i < MAX_GAME_PARTICIPANTS; i++)
    {
        new playerid = Game[gameid][game::players][i];

        if(playerid != INVALID_PLAYER_ID)
            PlayerPlaySound(playerid, soundid);
    }
}

/* MAQUINA DE ESTADOS */

public Game_Update(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return;

    switch(Game[gameid][game_state])
    {
        case GAME_STATE_FINISHED:
        {
            if(Game[gameid][game::players_count] >= Game[gameid][game::min_players])
            {
                Game::SendMessageToAll(gameid, "{ff5533}[ EVENTO ] {ffffff}O número mínimo de jogadores foi atingido");
                Game::SendMessageToAll(gameid, "{ff5533}[ EVENTO ] {ffffff}Iniciando evento em {ff5533}%d {ffffff}segundos", GAME_TIME_WAIT);

                Game[gameid][game::start_time] = GAME_TIME_WAIT;
                Game[gameid][game_state] = GAME_STATE_WAIT_FILL;
                return;
            }   

            Game[gameid][game_state] = GAME_STATE_FINISHED;
            return;
        }

        case GAME_STATE_WAIT_FILL:
        {
            if(Game[gameid][game::players_count] < Game[gameid][game::min_players])
            {
                Game::SendMessageToAll(gameid, "{ff5533}[ EVENTO ] {ffffff}Contagem parou! \
                Precisamos de {ff5533}%d jogadores {ffffff}para iniciar o evento", Game[gameid][game::min_players]);        

                Game[gameid][game::start_time] = GAME_TIME_WAIT;
                Game[gameid][game_state] = GAME_STATE_FINISHED;
                return;
            }

            else
            {   
                new time = Game[gameid][game::start_time];

                if(time <= 0)
                {
                    GameTextForAll("~y~Iniciando...", 1500, 3);
                    Game[gameid][game::start_time] = 15;

                    Game::SendMessageToAll(gameid, "{ff5533}[ EVENTO ] {ffffff}Iniciando Corrida! {ff5533}Se preparem!");
                    Game::SetPlayersReady(gameid);   
                    Game[gameid][game_state] = GAME_STATE_STARTING;
                    return;    
                }

                else
                {
                    GameTextForAll("~g~~h~~h~Esperando:%02d:%02d", 990, 3, floatround(time/60), time % 60);
                    Game[gameid][game::start_time]--;
                    Game[gameid][game_state] = GAME_STATE_WAIT_FILL;
                    return;   
                }
            }
        }
        
        case GAME_STATE_STARTING:
        {
            new time = Game[gameid][game::start_time];

            if(time <= 0)
            {
                GameTextForAll("~r~VAI...", 1500, 3);
                Game::PlaySoundForAll(gameid, 1057);
                Game[gameid][game::start_time] = 300; //5 minutos para acabar o evento
                Game::StartPlayers(gameid); 
                Game[gameid][game_state] = GAME_STATE_STARTED;
                return;   
            }

            else
            {
                GameTextForAll("~r~~h~%d", 990, 3, time);
                Game::PlaySoundForAll(gameid, 1056);
                Game[gameid][game::start_time]--;
                Game[gameid][game_state] = GAME_STATE_STARTING;
                return;
            }
        }

        case GAME_STATE_STARTED:
        {
            new time = Game[gameid][game::start_time];

            if(time > 0)
            {
                Game::UpdatePlayers(gameid);
                Game[gameid][game::start_time]--;
                Game[gameid][game_state] = GAME_STATE_STARTED;
                return;
            }

            else
            {
                GameTextForAll("~r~O evento acabou!", 1500, 3);
                SendClientMessageToAll(-1, "{ff5533}[ EVENTO ] {ffffff}O evento {ff5533}%s {ffffff}acabou!", Game[gameid][game::name]);
                
                Game::FinishPlayers(gameid);
                Game[gameid][game_state] = GAME_STATE_FINISHING;
                return;
            }
        }

        case GAME_STATE_FINISHING:
        {
            Game::GivePlayerRewards(gameid);
            Game::Clear(gameid, true);
            Game[gameid][game_state] = GAME_STATE_FINISHED;
            return;
        }

        default: return;
    }

    return;
}