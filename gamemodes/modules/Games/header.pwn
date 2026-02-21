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

stock Game::GetFreeSlotID()
{
    for(new i = 0; i < MAX_GAMES_INSTANCES; i++)
        if(!GetFlag(Game[i][game::flags], FLAG_GAME_CREATED))
            return i;

    return _:INVALID_GAME_ID;
}

stock Game::Create(const name[], const creator[], GAME_TYPES:type, minparts, maxparts, notify = false, GLOBAL_TAG_TYPES:...)
{
    new gameid = Game::GetFreeSlotID();

    if(gameid == INVALID_GAME_ID) 
    {
        printf("[ EVENTOS ] Não foi possível criar o evento %s, pois não existia slot livre!");
        return 0;
    }
    
    format(Game[gameid][game::name], 32, "%s", name);
    Game[gameid][game::type]                = type;
    Game[gameid][game_state]                = GAME_STATE_FINISHED;
    Game[gameid][game::tick]                = 0;
    Game[gameid][game::flags]              |= FLAG_GAME_CREATED;
    Game[gameid][game::vw]                  = gameid + 1;
    Game[gameid][game::players]             = list_new();
    Game[gameid][game::minparts]            = minparts;
    Game[gameid][game::maxparts]            = maxparts;

    va_format(Game[gameid][game::args], 128, "%s", ___(6));

    if(notify)
        SendClientMessageToAll(-1, "{3399ff}[ EVENTOS ] {ffffff}Novo evento {3399ff}%s {ffffff}foi criador por {3399ff}%s!",
        name, creator);

    switch(type)
    {
        case GAME_TYPE_RACE: return Race::Create(gameid, Game[gameid][game::args]);
        case GAME_TYPE_ARENA: return Arena::Create(gameid, Game[gameid][game::args]);

        default: return 0;
    }
}

stock Game::Clear(gameid)
{
    new name[32], args[128], minp, maxp, GAME_TYPES:type;

    format(name, 32, "%s", Game[gameid][game::name]);
    format(args, 128, "%s", Game[gameid][game::args]);

    minp    = Game[gameid][game::minparts];
    maxp    = Game[gameid][game::maxparts];
    type    = Game[gameid][game::type];

    Game::Destroy(gameid);
    
    return Game::Create(name, "Server", type, minp, maxp, true, args);
}

stock Game::Destroy(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return 1;

    new GAME_TYPES:type = Game[gameid][game::type];
 
    Game::ClearPlayers(gameid);

    Game[gameid][game::name]     = '\0';
    Game[gameid][game::args]     = '\0';
    Game[gameid][game::type]     = INVALID_GAME_TYPE;
    Game[gameid][game_state]     = INVALID_GAME_STATE;
    Game[gameid][game::tick]     = 0;
    Game[gameid][game::flags]    = 0;
    Game[gameid][game::vw]       = -1;
    list_delete(Game[gameid][game::players]);
    Game[gameid][game::minparts] = 0;
    Game[gameid][game::maxparts] = 0;

    printf("[ EVENTO ] Evento %d destruido com sucesso\n", gameid);

    switch(type)
    {
        case GAME_TYPE_RACE:  return Race::Destroy(gameid);
        case GAME_TYPE_ARENA: return Arena::Destroy(gameid);

        default: return 0;
    }
}

stock Game::InsertPlayer(gameid, playerid)
{
    if((Game[gameid][game_state] > GAME_STATE_STARTING))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Esse jogo já começou, aguarde a próxima partida");
        return 0;
    }

    if(!list_valid(Game[gameid][game::players]))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Houve um erro inesperado. {ff3333}Avise um programador!");
        return 0;
    }

    new len = list_size(Game[gameid][game::players]);

    if(len >= Game[gameid][game::maxparts])
    {
        SendClientMessage(playerid, -1, "{ff3333}[ EVENTO ] {ffffff}Esse jogo está cheio, aguarde a próxima partida.");
        return 0;
    }

    if(list_find(Game[gameid][game::players], playerid) == -1)
    {
        list_add(Game[gameid][game::players], playerid);

        game::Player[playerid][pyr::gameid] = gameid;
        
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
        
        switch(Game[gameid][game::type])
        {
            case GAME_TYPE_RACE: return Race::SendPlayer(playerid, gameid);
            case GAME_TYPE_ARENA: return Arena::SendPlayer(playerid, gameid);
            default: return 0;
        }

        return 1;
    }

    print("[ ERRO ] O código não podia chegar aqui 1");

    return 0;
}

stock Game::RemovePlayer(gameid, playerid)
{
    if(!list_valid(Game[gameid][game::players])) return 0;

    new idx = list_find(Game[gameid][game::players], playerid);

    if(idx != -1)
    {
        switch(Game[gameid][game::type])
        {
            case GAME_TYPE_RACE: 
            {
                Race::QuitPlayer(gameid, playerid);
                if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED))
                    Game::SendMessageToAll(gameid, "{ff3333}[ CORRIDA ] {ffffff}%s {ff3333}saiu {ffffff}da corrida", GetPlayerNameStr(playerid));
            }
            case GAME_TYPE_ARENA: 
            {
                Arena::QuitPlayer(gameid, playerid);
                if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED))
                    Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] {ffffff}%s {ff3333}saiu {ffffff}da arena", GetPlayerNameStr(playerid));
            }
        }

        if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED))
        {
            list_remove(Game[gameid][game::players], idx); 
            Game::ClearPlayer(playerid); 
        }
    }

    return 1;
}

stock Game::SetPlayersReady(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Ready(gameid);
        case GAME_TYPE_ARENA: return Arena::Ready(gameid);
        default: return 0;
    }
}

stock Game::StartPlayers(gameid, tick, &new_tick = 0)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Start(gameid, tick, new_tick);
        case GAME_TYPE_ARENA: return Arena::Start(gameid, tick, new_tick);
        default: return 0;
    }
}

stock Game::UpdatePlayers(gameid, tick)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Update(gameid, tick);
        case GAME_TYPE_ARENA: return Arena::Update(gameid, tick);
        default: return 0;
    }
}

stock Game::FinishPlayers(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::Finish(gameid);
        case GAME_TYPE_ARENA: return Arena::Finish(gameid);
        default: return 0;
    }
}

stock Game::GivePlayerRewards(gameid)
{
    switch(Game[gameid][game::type])
    {
        case GAME_TYPE_RACE: return Race::GiveRewards(gameid);
        case GAME_TYPE_ARENA: return Arena::GiveRewards(gameid);
        default: return 0;
    }    
}

stock Game::GetCount()
{
    new count;
    for(new i = 0; i < MAX_GAMES_INSTANCES; i++)
        if(GetFlag(Game[i][game::flags], FLAG_GAME_CREATED))
            count++;
    
    return count;
}

stock Game::ClearPlayer(playerid)
{
    game::Player[playerid][pyr::gameid] = INVALID_GAME_ID;
    game::Player[playerid][pyr::flags]  = 0;
}

stock Game::ClearPlayers(gameid)
{
    for(new i = 0; i < Game::GetPlayersCount(gameid); i++)
        Game::ClearPlayer(list_get(Game[gameid][game::players], i));
}

stock Game::GetPlayersCount(gameid)
{
    if(!list_valid(Game[gameid][game::players])) return 0;
    return list_size(Game[gameid][game::players]);
}

stock Game::SendMessageToAll(gameid, const message[], GLOBAL_TAG_TYPES:...)
{
    if(!list_valid(Game[gameid][game::players])) return 0;

    new len = list_size(Game[gameid][game::players]);

    new formatted_message[144];
    va_format(formatted_message, 144, message, ___(2));
    
    for(new i = 0; i < len; i++)
        SendClientMessage(list_get(Game[gameid][game::players], i), -1, formatted_message);
    
    return 1;
}

stock Game::ShowTextForAll(gameid, const str[], time, style, GLOBAL_TAG_TYPES:...)
{
    if(!list_valid(Game[gameid][game::players])) return 0;

    new len = list_size(Game[gameid][game::players]);

    new format_msg[144];
    va_format(format_msg, 144, str, ___(4)); 

    for(new i = 0; i < len; i++)
        GameTextForPlayer(list_get(Game[gameid][game::players], i), format_msg, time, style);
    
    return 1;
}

stock Game::PlaySoundForAll(gameid, soundid)
{
    if(!list_valid(Game[gameid][game::players])) return 0;

    new len = list_size(Game[gameid][game::players]);

    for(new i = 0; i < len; i++)
        PlayerPlaySound(list_get(Game[gameid][game::players], i), soundid);
    
    return 1;
}

/* MAQUINA DE ESTADOS */

public Game_Update(gameid)
{
    if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED)) return;

    switch(Game[gameid][game_state])
    {
        case GAME_STATE_FINISHED:
        {
            new count = Game::GetPlayersCount(gameid);

            if(count >= Game[gameid][game::minparts])
            {
                Game[gameid][game::tick] = GAME_TIME_WAIT;
                Game::SendMessageToAll(gameid, "{3399ff}[ EVENTO ] {ffffff}O número {3399ff}mínimo {ffffff}de jogadores foi atingido!");
                Game::SendMessageToAll(gameid, "{3399ff}[ EVENTO ] {ffffff}Iniciando evento em {3399ff}%d {ffffff}segundos", Game[gameid][game::tick]);
                Game[gameid][game_state] = GAME_STATE_WAIT_FILL;
            }   

            else if(count >= Game[gameid][game::maxparts])
            {
                Game[gameid][game::tick] = 10;
                Game::SendMessageToAll(gameid, "{3399ff}[ EVENTO ] {ffffff}O número {3399ff}máximo {ffffff}de jogadores foi atingido!");
                Game[gameid][game_state] = GAME_STATE_WAIT_FILL;
            }

            else
            {
                Game::ShowTextForAll(gameid, "~p~Aguardando...~n~%d de %d jogadores", 
                1000, 4, count, Game[gameid][game::minparts]);
                Game[gameid][game_state] = GAME_STATE_FINISHED;
            }

            return;
        }

        case GAME_STATE_WAIT_FILL:
        {
            new time = Game[gameid][game::tick];

            if(time <= 0)
            {
                Game::ShowTextForAll(gameid, "~h~Iniciando Evento", 1000, 4);
                Game::SetPlayersReady(gameid);  
                Game[gameid][game::tick] = 5; 
                Game[gameid][game_state] = GAME_STATE_STARTING;
                return;    
            }

            else
            {
                new count = Game::GetPlayersCount(gameid);

                if(count < Game[gameid][game::minparts])
                {
                    Game::SendMessageToAll(gameid, "{ff3333}[ EVENTO ] {ffffff}Contagem parou! Precisamos de {ff3333}%d jogadores {ffffff}para iniciar!", Game[gameid][game::minparts]);        
                    Game[gameid][game::tick] = 0;
                    Game[gameid][game_state] = GAME_STATE_FINISHED;
                    return;
                }

                else if(count >= Game[gameid][game::maxparts] && Game[gameid][game::tick] > 10)
                {
                    Game[gameid][game::tick] = 10;
                    Game::SendMessageToAll(gameid, "{3399ff}[ EVENTO ] {ffffff}O número {3399ff}máximo {ffffff}de jogadores foi atingido!");
                }

                Game::ShowTextForAll(gameid, "~g~~h~~h~Esperando~n~%02d:%02d", (time <= 10) ? 600 : 990, 4, floatround(time/60), time % 60);
                Game[gameid][game::tick]--;
                Game[gameid][game_state] = GAME_STATE_WAIT_FILL;
                return;   
            }
        }
        
        case GAME_STATE_STARTING:
        {        
            new time = Game[gameid][game::tick]--;

            if(time <= 0)
            {
                Game::StartPlayers(gameid, 0, Game[gameid][game::tick]); 
                Game[gameid][game_state] = GAME_STATE_STARTED;
                return;   
            }

            else
            {
                Game::StartPlayers(gameid, time); 
                Game[gameid][game_state] = GAME_STATE_STARTING;
                return;
            }
        }

        case GAME_STATE_STARTED:
        {
            new time = Game[gameid][game::tick];

            if(time > 0)
            {
                Game[gameid][game::tick]--;
                Game::UpdatePlayers(gameid, Game[gameid][game::tick]);
                Game[gameid][game_state] = GAME_STATE_STARTED;
                return;
            }

            else
            {
                Game::ShowTextForAll(gameid, "~h~~h~Terminou", 990, 4);
                Game::FinishPlayers(gameid);
                Game[gameid][game::tick] = 0;
                Game[gameid][game_state] = GAME_STATE_FINISHING;
                return;
            }
        }

        case GAME_STATE_FINISHING:
        {
            Game::Clear(gameid);
            return;
        }

        default: return;
    }

    return;
}
