new const Float:Arena::gSpawns[][4] =
{
    {-2823.7285, 737.5068, 969.2119, 180.0},    // ESPEC 1
    {-2823.5251, 690.0143, 969.2119, 0.0},      // ESPEC 2
    {-2841.5415, 712.7768, 964.9241, 270.0},    // player 1
    {-2805.7141, 712.7639, 964.9241, 90.0}      // player 2
};

#define ARENA_MATCH_TIME      (10)
#define ARENA_RESPAWN_TIME_MS (2170)

enum (<<= 1)
{
    FLAG_ARENA_CREATED = 1,
}

enum E_GAME_ARENA
{
    arena::flags,
    Map:arena::participant,
}

enum _:E_ARENA_SEAT
{
    arena::playerid,
    arena::kills,
    arena::deaths,
    arena::respawn_timer,
    arena::last_killer,
    bool:arena::is_alive,
    bool:arena::is_respawning,
}

new Arena[MAX_GAMES_INSTANCES][E_GAME_ARENA];

stock Arena::Create(gameid, const args[])
{
    #pragma unused args

    Arena[gameid][arena::flags] = FLAG_ARENA_CREATED;
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
    Arena[gameid][arena::flags] = 0;

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
    data[arena::last_killer] = INVALID_PLAYER_ID;
    data[arena::is_alive] = false;
    data[arena::is_respawning] = false;

    map_add_arr(Arena[gameid][arena::participant], playerid, data);

    if(TryPercentage(50))
        SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], -2823.7285 + Float:RandomFloatMinMax(-1.5, 1.5), 737.5068 + Float:RandomFloatMinMax(-1.5, 1.5), 969.2119, 180.0);
    else
        SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], -2823.5251 + Float:RandomFloatMinMax(-1.5, 1.5), 690.0143 + Float:RandomFloatMinMax(-1.5, 1.5), 969.2119, 0.0);

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

    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    TogglePlayerControllable(playerid, true);

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

        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);

        data[arena::is_alive] = true;
        data[arena::is_respawning] = false;
        map_set_arr(Arena[gameid][arena::participant], playerid, data);

        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);

        ResetPlayerWeapons(playerid);
        GivePlayerWeapon(playerid, WEAPON_M4, 1000);
        GivePlayerWeapon(playerid, WEAPON_DEAGLE, 1000);
        GivePlayerWeapon(playerid, WEAPON_UZI, 1000);

        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        Player[playerid][pyr::health] = 200.0;

        new idx = RandomMinMax(2, 4);

        SetPlayerPos(playerid, Arena::gSpawns[idx][0], Arena::gSpawns[idx][1], Arena::gSpawns[idx][2]);
        SetPlayerFacingAngle(playerid, Arena::gSpawns[idx][3]);
        SetCameraBehindPlayer(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);

        TogglePlayerControllable(playerid, false);
    }

    Game::SendMessageToAll(gameid, "{ff3333}[ ARENA ] {ffffff}Partida encontrada! Prepare-se...");

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
    
    return 1;
}

stock Arena::Finish(gameid)
{
    new len = Game::GetPlayersCount(gameid);

    for(new i = len - 1; i >= 0; i--)
    {
        new playerid = list_get(Game[gameid][game::players], i);
        if(!map_has_key(Arena[gameid][arena::participant], playerid)) continue;

        new data[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], playerid, data);

        SendClientMessage(playerid, -1,
        "{ff3333}[ ARENA ] {ffffff}Resultado -> Kills: {33ff33}%d {ffffff}| Mortes: {ff3333}%d",
        data[arena::kills], data[arena::deaths]);

        Game::RemovePlayer(gameid, playerid);
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
    data[arena::is_alive] = true;
    data[arena::is_respawning] = false;
    map_set_arr(Arena[gameid][arena::participant], playerid, data);

    TogglePlayerSpectating(playerid, false);

    //new idx = RandomMinMax(3, 4);

    // if(TryPercentage(50))
    //     SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], -2823.7285 + Float:RandomFloatMinMax(-1.5, 1.5), 737.5068 + Float:RandomFloatMinMax(-1.5, 1.5), 969.2119, 180.0);
    // else
    //     SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], -2823.5251 + Float:RandomFloatMinMax(-1.5, 1.5), 690.0143 + Float:RandomFloatMinMax(-1.5, 1.5), 969.2119, 0.0);

    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);

    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, WEAPON_M4, 1000);
    GivePlayerWeapon(playerid, WEAPON_DEAGLE, 1000);
    GivePlayerWeapon(playerid, WEAPON_UZI, 1000);

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
    victim[arena::last_killer] = killerid;
    victim[arena::is_alive] = false;
    victim[arena::is_respawning] = true;
  
    if(IsValidPlayer(killerid)
    && map_has_key(Arena[gameid][arena::participant], killerid)
    && killerid != playerid)
    {
     
        new killer[E_ARENA_SEAT];
        map_get_arr(Arena[gameid][arena::participant], killerid, killer);
   
        killer[arena::kills]++;
        map_set_arr(Arena[gameid][arena::participant], killerid, killer);

        SendDeathMessage(killerid, playerid, reason);
    }
    else
        SendDeathMessage(INVALID_PLAYER_ID, playerid, reason);
    
    map_set_arr(Arena[gameid][arena::participant], playerid, victim);

    return 1;
}

forward ARN_DoRespawn(playerid, gameid);
public ARN_DoRespawn(playerid, gameid)
{
    Arena::RespawnPlayer(playerid, gameid);
    return 1;
}
