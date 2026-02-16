#define MAX_GAME_PARTICIPANTS (5)
#define MAX_GAMES             (5)

#define GAME_TIME_WAIT        (60)

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
    GAME_STATE_FINISHED     = 1,
    GAME_STATE_WAIT_FILL    = 2,
    GAME_STATE_STARTING     = 3,
    GAME_STATE_STARTED      = 4,
    GAME_STATE_FINISHING    = 5,
}

enum E_GAMES
{
    GAME_TYPES:game::type,
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

stock Game::Create(GAME_TYPES:typeid, min_players, max_players, notify = false)
{
    new gameid = Game::GetFreeSlotID();

    if(gameid == INVALID_GAME_ID) return 0;

    /* VAR INIT */
    Game[gameid][game::type] = typeid;
    Game[gameid][game::vw] = gameid + 1;
    Game[gameid][game::start_time] = GAME_TIME_WAIT;
    Game[gameid][game::min_players] = min_players;
    Game[gameid][game::max_players] = max_players;
    Game[gameid][game_state]  = GAME_STATE_FINISHED;
    SetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED);
    Game::ClearPlayers(gameid, max_players);

    switch(typeid)
    {
        case GAME_TYPE_RACE: return Race::Create(gameid, notify);

        default: return 0;
    }
}

stock Game::Clear(gameid)
{
    new min_p, max_p, GAME_TYPES:type;

    min_p = Game[gameid][game::min_players];
    max_p = Game[gameid][game::max_players];
    type  = Game[gameid][game::type];
    
    Game::Destroy(gameid);
    Game::Create(type, min_p, max_p, true);

    // new raceid = Race::GetIDByGameID(gameid);

    // if(notify)
    //     SendClientMessageToAll(-1, "{ff5533}[ EVENTO ] {ffffff}Evento {ff5533}%s {ffffff}reiniciou.", game::Race[raceid][race::name]);
}

stock Game::Destroy(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return 1;

    new GAME_TYPES:typeid = Game[gameid][game::type];
 
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
    return Game[gameid][game::players_count];
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

    if(seat == INVALID_SEAT_ID) return 0;

    Game[gameid][game::players][seat] = INVALID_PLAYER_ID;
    Game[gameid][game::players_count]--;
    
    Game::ClearPlayer(playerid);

    SetPlayerVirtualWorld(playerid, 0);

    return 1;
}

stock Game::ClearPlayer(playerid)
{
    game::Player[playerid][pyr::seat]   = INVALID_SEAT_ID;
    game::Player[playerid][pyr::gameid] = INVALID_GAME_ID;
    game::Player[playerid][pyr::raceid] = -1;
    game::Player[playerid][pyr::flags]  = 0;
}

stock Game::ClearPlayers(gameid, lenght)
{
    for(new i = 0; i < lenght; i++)
    {
        new playerid = Game[gameid][game::players][i];

        if(playerid != INVALID_PLAYER_ID)
            Game::RemovePlayer(gameid, playerid);

        Game[gameid][game::players][i] = INVALID_PLAYER_ID;
    }
    
    Game[gameid][game::players_count] = 0;
}


stock Game::GetIDByListIndex(listitem)
{
    if(listitem < 0) return INVALID_GAME_ID;

    new idx;

    for(new i = 0; i < MAX_GAMES; i++)
    {
        if(!GetFlag(Game[i][game::flags], FLAG_GAME_CREATED))
            continue;

        if(idx == listitem)
            return i;

        idx++;
    }

    return INVALID_GAME_ID;
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

stock Game::ShowTextForAll(gameid, const str[], time, style, GLOBAL_TAG_TYPES:...)
{
    new format_msg[144];
    va_format(format_msg, 144, str, ___(4)); 

    new lenght = Game[gameid][game::max_players];

    for(new i = 0; i < lenght; i++)
        if(Game[gameid][game::players][i] != INVALID_PLAYER_ID)
            GameTextForPlayer(Game[gameid][game::players][i], format_msg, time, style);
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

            Game::ShowTextForAll(gameid, "~p~Aguardando %d jogadores...", 1000, 4, Game[gameid][game::min_players]);
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
                    Game::ShowTextForAll(gameid, "~y~Iniciando...", 1500, 4);
                    Game[gameid][game::start_time] = 5;

                    Game::SendMessageToAll(gameid, "{ff5533}[ EVENTO ] {ffffff}Iniciando Corrida! {ff5533}Se preparem!");
                    Game::SetPlayersReady(gameid);   
                    Game[gameid][game_state] = GAME_STATE_STARTING;
                    return;    
                }

                else
                {
                    Game::ShowTextForAll(gameid, "~g~~h~~h~Esperando %02d:%02d", (time <= 10) ? 500 : 990, 4, floatround(time/60), time % 60);
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
                Game::ShowTextForAll(gameid, "~r~VAI...", 1500, 3);
                Game::PlaySoundForAll(gameid, 1057);
                Game[gameid][game::start_time] = 240; //5 minutos para acabar o evento
                Game::StartPlayers(gameid); 
                Game[gameid][game_state] = GAME_STATE_STARTED;
                return;   
            }

            else
            {
                Game::ShowTextForAll(gameid, "~r~~h~%d", 990, 3, time);
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
                Game::FinishPlayers(gameid);
                Game[gameid][game::start_time] = 0;
                Game[gameid][game_state] = GAME_STATE_FINISHING;
                return;
            }
        }

        case GAME_STATE_FINISHING:
        {
            Game::GivePlayerRewards(gameid);
            Game::Clear(gameid);
            return;
        }

        default: return;
    }

    return;
}
