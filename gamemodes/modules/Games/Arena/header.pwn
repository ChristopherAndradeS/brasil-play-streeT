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

#define ARENA_MATCH_TIME      (120)
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

stock Arena::Create(gameid, const args[])
{
    if(sscanf(args, "a<i>[3]a<i>[3]a<f>["#MAX_GAME_PARTICIPANTS"]",
        Arena[gameid][arena::weapons], Arena[gameid][arena::ammos], Arena[gameid][arena::rewards]))
    {
        printf("[ EVENTO ] Houve erro de argumento no sscanf ao tentar criar evento de arena");
        return 0;
    }    

    Arena[gameid][arena::flags] = FLAG_ARENA_CREATED;
    Arena[gameid][arena::best_player] = INVALID_PLAYER_ID;
    Arena[gameid][arena::best_kill] = 0;
    Arena[gameid][arena::participant] = map_new();

    return 1;
}

stock Arena::Destroy(gameid)
{
    if(!map_valid(Arena[gameid][arena::participant])) return 0;

    new len = Game::GetPlayersCount(gameid);
    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(Game[gameid][game::players], i);
        if(!map_has_key(Arena[gameid][arena::participant], playerid)) continue;

        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);

        if(IsValidTimer(data[arena::respawn_timer]))
            KillTimer(data[arena::respawn_timer]);
    }

    map_delete(Arena[gameid][arena::participant]);
    Arena[gameid][arena::best_player] = INVALID_PLAYER_ID;
    Arena[gameid][arena::flags] = 0;
    Arena[gameid][arena::best_kill] = 0;
    for(new i = 0; i < 3; i++)
    {
        Arena[gameid][arena::weapons][i] = WEAPON_FIST;
        Arena[gameid][arena::ammos][i]   = WEAPON_FIST;
    }
    DestroyDynamicObject(Arena[gameid][arena::objectid]);

    return 1;
}

stock Arena::SendPlayer(playerid, gameid)
{
    if(!map_valid(Arena[gameid][arena::participant])) return 0;

    new data[E_ARENA_SEAT];

    data[arena::playerid] = playerid;
    data[arena::kills] = 0;
    data[arena::deaths] = 0;
    data[arena::respawn_timer] = INVALID_TIMER;
    data[arena::killer] = INVALID_PLAYER_ID;

    map_add_arr(Arena[gameid][arena::participant], playerid, data);

    new idx = TryPercentage(50) ? 1 : 0;

    SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], 
    Arena::gSpec[idx][0] + Float:RandomFloatMinMax(-1.5, 1.5), 
    Arena::gSpec[idx][1] + Float:RandomFloatMinMax(-1.5, 1.5), 
    Arena::gSpec[idx][2] , Arena::gSpec[idx][3]);

    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);
    SetPlayerInterior(playerid, 0);
    ResetPlayerWeapons(playerid);
    SetCameraBehindPlayer(playerid);

    SpawnPlayer(playerid);

    return 1;
}

stock Arena::QuitPlayer(gameid, playerid)
{
    if(!map_valid(Arena[gameid][arena::participant])) return 0;

    if(map_has_key(Arena[gameid][arena::participant], playerid))
    {
        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);

        if(IsValidTimer(data[arena::respawn_timer]))
            KillTimer(data[arena::respawn_timer]);

        map_remove(Arena[gameid][arena::participant], playerid);
    }

    TogglePlayerSpectating(playerid, false);

    ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);
    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    TogglePlayerControllable(playerid, true);
    Player[playerid][pyr::health] = 100.0;
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);

    if(IsPlayerConnected(playerid))
        Player::Spawn(playerid, true);

    return 1;
}

stock Arena::Ready(gameid)
{
    new len = Game::GetPlayersCount(gameid);

    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(Game[gameid][game::players], i);

        if(!IsValidPlayer(playerid)) continue;
        if(!map_has_key(Arena[gameid][arena::participant], playerid)) continue;

        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
        
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

        ResetPlayerWeapons(playerid);
        for(new j = 0; j < 3; j++)
        {
            new WEAPON:weaponid = Arena[gameid][arena::weapons][j];
            new ammo = Arena[gameid][arena::ammos][j];

            if(weaponid > WEAPON_FIST && ammo > 0)
                GivePlayerWeapon(playerid, weaponid, ammo);
        }

        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        Player[playerid][pyr::health] = 200.0;

        SetPlayerPos(playerid, Arena::gSpawns[i][0], Arena::gSpawns[i][1], Arena::gSpawns[i][2]);
        SetPlayerFacingAngle(playerid, Arena::gSpawns[i][3]);
        SetCameraBehindPlayer(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);

        TogglePlayerControllable(playerid, false);
    }

    Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] {ffffff}Partida começou!");

    return 1;
}

stock Arena::Start(gameid, tick, &new_tick)
{
    if(tick <= 0)
    {
        new len = Game::GetPlayersCount(gameid);
        for(new i = 0; i < len; i++)
        {
            new playerid = list_get(Game[gameid][game::players], i);
            if(!IsValidPlayer(playerid)) continue;
            TogglePlayerControllable(playerid, true);
        }

        Arena[gameid][arena::objectid] = CreateDynamicObject(18688, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, .worldid = gameid + 1, .interiorid = 0, .playerid = -1);
    
        Game::ShowTextForAll(gameid, "~r~~h~MATA-MATA", 1000, 3);
        Game::PlaySoundForAll(gameid, 1057);
        new_tick = ARENA_MATCH_TIME;
        return 1;
    }

    Game::ShowTextForAll(gameid, "~y~~h~%d", 990, 3, tick);
    Game::PlaySoundForAll(gameid, 1056);

    return 1;
}

stock Arena::Update(gameid, tick)
{
    if(tick <= 60)
    {
        if(tick == 60)
            Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] {ffffff}Falta {ff3333}1 minuto{ffffff} para encerrar!");

        Game::ShowTextForAll(gameid, "~r~%02d~w~:~r~%02d", (tick <= 10) ? 600 : 990, 4, floatround(tick / 60), tick % 60);
    }

    new len = Game::GetPlayersCount(gameid);
    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(Game[gameid][game::players], i);
        if(!IsValidPlayer(playerid)) continue;
        if(!map_has_key(Arena[gameid][arena::participant], playerid)) continue;
        
        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);
        
        new best = Arena[gameid][arena::best_player];

        if(data[arena::kills] > Arena[gameid][arena::best_kill])
        {
            if(playerid == best) continue;

            AttachDynamicObjectToPlayer(Arena[gameid][arena::objectid], playerid, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0);

            Arena[gameid][arena::best_player] = playerid;
            Arena[gameid][arena::best_kill] = data[arena::kills];
            
            if(best == INVALID_PLAYER_ID)
                Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] {ffffff}O atirador {ff3333}%s {ffffff}fez o {ff3333}firtblood {ffffff}e está com a {ff3333}glória!", GetPlayerNameStr(playerid));
            else
                Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] %s {ffffff}roubou a glória de {ff3333}%s", GetPlayerNameStr(playerid), GetPlayerNameStr(best));
        }
    }

    return 1;
}

stock Arena::Finish(gameid)
{
    if(!map_valid(Arena[gameid][arena::participant])) return 1;

    new players[MAX_GAME_PARTICIPANTS],
        kills[MAX_GAME_PARTICIPANTS],
        deaths[MAX_GAME_PARTICIPANTS],
        count
    ;

    new len = Game::GetPlayersCount(gameid);

    for(new i = len - 1; i >= 0; i--)
    {
        new playerid = list_get(Game[gameid][game::players], i);
        if(!map_has_key(Arena[gameid][arena::participant], playerid)) continue;

        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);

        if(count < MAX_GAME_PARTICIPANTS)
        {
            players[count] = playerid;
            kills[count] = data[arena::kills];
            deaths[count] = data[arena::deaths];
            count++;
        }

        SendClientMessage(playerid, -1,
        "{ff3333}[ ARENA ] {ffffff}Resultado | Kills: {33ff33}%d {ffffff}| Mortes: {ff3333}%d",
        data[arena::kills], data[arena::deaths]);

        Game::RemovePlayer(gameid, playerid);
    }

    for(new i = 0; i < count - 1; i++)
    {
        for(new j = i + 1; j < count; j++)
        {
            if(kills[j] > kills[i] || (kills[j] == kills[i] && deaths[j] < deaths[i]))
            {
                new temp;

                temp = players[i];
                players[i] = players[j];
                players[j] = temp;

                temp = kills[i];
                kills[i] = kills[j];
                kills[j] = temp;

                temp = deaths[i];
                deaths[i] = deaths[j];
                deaths[j] = temp;
            }
        }
    }

    if(count > 0 && IsValidPlayer(players[0]))
        SendClientMessageToAll(-1, "{ff3333}[ ARENA ] {ffffff}Jogador {ff3333}%s {ffffff}foi MVP da arena {ff3333}%s", GetPlayerNameStr(players[0]), Game[gameid][game::name]);
    else
        SendClientMessageToAll(-1, "{ff3333}[ ARENA ] {ffffff}A arena {ff3333}%s {ffffff}terminou sem vencedores", Game[gameid][game::name]);
    
    for(new i = 0; i < count; i++)
    {
        new playerid = players[i];
        if(!IsValidPlayer(playerid)) continue;

        new Float:reward = (i >= 0 && i < MAX_GAME_PARTICIPANTS) ? Arena[gameid][arena::rewards][i] : 0.0;

        if(reward <= 0.0) 
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ARENA ] {ffffff}Você {ff3333}não se classificou {ffffff}para receber recompensa!");
            continue;
        }

        Player::GiveMoney(playerid, reward);
        SendClientMessage(playerid, -1,
        "{ff3333}[ ARENA ] {ffffff}Premiação da arena: {33ff33}R$ %.2f{ffffff} por terminar em {33ff33}%d| lugar{ffffff}.",
        reward, i + 1);
    }

    return 1;
}

stock Arena::GiveRewards(gameid)
{
    #pragma unused gameid
    return 1;
}

stock Arena::RespawnPlayer(playerid, gameid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!map_valid(Arena[gameid][arena::participant])) return 1;
    if(!map_has_key(Arena[gameid][arena::participant], playerid)) return 1;

    new data[E_ARENA_SEAT];

    map_get_arr(Arena[gameid][arena::participant], playerid, data);
    
    if(IsValidTimer(data[arena::respawn_timer]))
        KillTimer(data[arena::respawn_timer]);

    data[arena::respawn_timer] = INVALID_TIMER;
    map_set_arr(Arena[gameid][arena::participant], playerid, data);
    
    TogglePlayerSpectating(playerid, false);

    new idx = RandomMax(sizeof(Arena::gSpawns));

    SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], 
    Arena::gSpawns[idx][0] + Float:RandomFloatMinMax(-1.5, 1.5), 
    Arena::gSpawns[idx][1] + Float:RandomFloatMinMax(-1.5, 1.5), 
    Arena::gSpawns[idx][2], Arena::gSpawns[idx][3]);

    SpawnPlayer(playerid);

    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);

    ResetPlayerWeapons(playerid);
    for(new i = 0; i < 3; i++)
    {
        new WEAPON:weaponid = Arena[gameid][arena::weapons][i];
        new ammo = Arena[gameid][arena::ammos][i];

        if(weaponid > WEAPON_FIST && ammo > 0)
            GivePlayerWeapon(playerid, weaponid, ammo);
    }

    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 100.0);
    Player[playerid][pyr::health] = 200.0;

    return 1;
}

stock Arena::RegisterDeath(playerid, killerid, WEAPON:reason)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 0;

    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid == INVALID_GAME_ID) return 0;
    if(Game[gameid][game::type] != GAME_TYPE_ARENA) return 0;
    if(Game[gameid][game_state] != GAME_STATE_STARTED) return 0;
    if(!map_valid(Arena[gameid][arena::participant])) return 0;
    if(!map_has_key(Arena[gameid][arena::participant], playerid)) return 0;

    new victim[E_ARENA_SEAT];
    map_get_arr(Arena[gameid][arena::participant], playerid, victim);

    victim[arena::deaths]++;
    victim[arena::killer] = killerid;
  
    if(IsValidPlayer(killerid)
    && map_has_key(Arena[gameid][arena::participant], killerid)
    && killerid != playerid)
    {
        new killer[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], killerid, killer);
   
        killer[arena::kills]++;
        map_set_arr(Arena[gameid][arena::participant], killerid, killer);

        if(Player[killerid][pyr::health] < 150.0)
        {
            SetPlayerHealth(killerid, 100.0);
            SetPlayerArmour(killerid, 50.0);
            Player[killerid][pyr::health] = 150.0;
            SendClientMessage(killerid, -1, "{ff3333}[ ARENA ] {ffffff}Vida recuperada +50%% de colete por ter matado {ff3333}%s",
            GetPlayerNameStr(playerid));
        }
        
        SendDeathMessage(killerid, playerid, reason);
    }

    map_set_arr(Arena[gameid][arena::participant], playerid, victim);

    return 1;
}

forward ARN_DoRespawn(playerid, gameid);
public ARN_DoRespawn(playerid, gameid)
{
    Arena::RespawnPlayer(playerid, gameid);
    return 1;
}
