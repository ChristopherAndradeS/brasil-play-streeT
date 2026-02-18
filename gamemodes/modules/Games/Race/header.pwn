#define MAX_RACE_VEHICLES       (5)
#define MAX_RACE_PARTICIPANTS   (5)
#define MAX_GAME_RACES          (5)
#define MAX_LAPS                (3)
#define INVALID_RACE_ID         (-1)

/* ------------------- Tabelas globais da corrida -------------------- */
// Spawn dos karts (X, Y, Z, ANGLE)
new const Float:Race::gVehicleSpawns[][4] =
{
    {-1392.1642, -230.3090, 1042.5342, 8.2200}, // pos_kart_1
    {-1395.9572, -232.7750, 1042.5399, 7.7789}, // pos_kart_2
    {-1399.4191, -235.6807, 1042.5432, 8.2266}, // pos_kart_3
    {-1393.3723, -237.1489, 1042.6235, 6.0405}, // pos_kart_4
    {-1397.1626, -239.5044, 1042.6101, 8.0659}  // pos_kart_5
};

// Checkpoints sequenciais (X, Y, Z)
new const Float:Race::gCheckpoints[][3] =
{
    {-1407.3843, -150.4694, 1043.2502}, // check2
    {-1503.4323, -151.5957, 1048.5673}, // check3
    {-1517.9471, -249.8785, 1049.8755}, // check4
    {-1419.1387, -277.5760, 1050.4873}, // check5
    {-1354.6580, -130.7808, 1050.3792}, // check6
    {-1265.3080, -193.3538, 1049.9474}, // check7
    {-1308.0317, -271.3692, 1047.4279},  // check8
    {-1395.7150, -216.3227, 1042.4036} // check1
};

new const Race::gModels[] = { 424, 441, 462, 468, 509, 571, 574 };

enum E_GAME_RACE
{
    race::name[32],
    race::gameid,
    race::modelid,
    race::flags,
    List:race::podium,
    race::finisheds,
    race::vehicleid[MAX_RACE_VEHICLES],
}

enum E_RACE_PART
{
    race::checkid,
    race::lap,
    race::vehicleid,
}

new game::Race[MAX_GAME_RACES][E_GAME_RACE];
new race::Player[MAX_PLAYERS][E_RACE_PART];
new Race::IndexByGameID[MAX_GAMES] = {INVALID_RACE_ID, ...};

enum (<<= 1)
{
    FLAG_RACE_CREATED = 1,
    FLAG_RACE_FINISHED,
}

forward Float:GetPlayerRaceProgress(playerid, raceid);

stock Race::Create(gameid, notify = false)
{
    new raceid = Race::GetFreeSlotID();

    if(raceid == INVALID_RACE_ID) return 0;

    static old_modelid;

    game::Race[raceid][race::podium] = list_new();
    game::Race[raceid][race::gameid] = gameid;
    game::Race[raceid][race::finisheds] = 0;
    SetFlag(game::Race[raceid][race::flags], FLAG_RACE_CREATED);
    ResetFlag(game::Race[raceid][race::flags], FLAG_RACE_FINISHED);
    Race::IndexByGameID[gameid] = raceid;

    game::Race[raceid][race::modelid] = RandomMinMaxExcept(0, sizeof(Race::gModels), old_modelid) % sizeof(Race::gModels);
    
    new modelid = game::Race[raceid][race::modelid];

    old_modelid = game::Race[raceid][race::modelid];

    new name[64];

    GetVehicleNameByModel(Race::gModels[modelid], name);

    format(game::Race[raceid][race::name], 32, "Corrida de %s", name);

    for(new i = 0; i < MAX_RACE_VEHICLES; i++)
    {
        game::Race[raceid][race::vehicleid][i] = Veh::Create(Race::gModels[modelid],
        Race::gVehicleSpawns[i][0], Race::gVehicleSpawns[i][1], Race::gVehicleSpawns[i][2],
        Race::gVehicleSpawns[i][3], RandomMinMax(3, 12), RandomMinMax(3, 12), 7, Game[gameid][game::vw], 0);
    }

    if(notify)
        SendClientMessageToAll(-1, "{ff5533}[ CORRIDA ] {ffffff}Um nova corrida de {ff5533}%s foi criada! {ffffff}Venha jogar para ganhar prêmios!", name);

    printf("[ CORRIDA ] Corrida de %s, criada com sucesso\n", name);

    return 1;
}

stock Race::Destroy(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);
    if(raceid == INVALID_RACE_ID) return 0;

    for(new i = 0; i < MAX_RACE_VEHICLES; i++)
        if(IsValidVehicle(game::Race[raceid][race::vehicleid][i]))
            Veh::Destroy(game::Race[raceid][race::vehicleid][i]);

    if(list_valid(game::Race[raceid][race::podium]))
        list_delete(game::Race[raceid][race::podium]);

    game::Race[raceid][race::gameid]    = INVALID_GAME_ID;
    game::Race[raceid][race::flags]     = 0;
    game::Race[raceid][race::finisheds] = 0;
    Race::IndexByGameID[gameid]         = INVALID_RACE_ID;

    printf("[ EVENTO ] Evento %s destruido com sucesso\n", game::Race[raceid][race::name]);

    game::Race[raceid][race::name] = '\0';
    
    return 1;
}

stock Race::AddPodium(playerid, raceid)
{
    if(!list_valid(game::Race[raceid][race::podium])) return 0;

    if(list_find(game::Race[raceid][race::podium], playerid) == -1)
    {
        list_add(game::Race[raceid][race::podium], playerid);
        return 1;
    }

    return 0;
}

stock Race::RemPodium(playerid, raceid, reason)
{
    #pragma unused reason

    if(!list_valid(game::Race[raceid][race::podium])) return 0;

    new idx = list_find(game::Race[raceid][race::podium], playerid);

    if(idx != -1)
    {
        list_remove(game::Race[raceid][race::podium], idx);        
        return 1;
    }

    return 0;
}

stock Race::GetIDByGameID(gameid)
{
    if(gameid < 0 || gameid >= MAX_GAMES) return INVALID_RACE_ID;

    new raceid = Race::IndexByGameID[gameid];

    if(raceid >= 0 && raceid < MAX_GAME_RACES && GetFlag(game::Race[raceid][race::flags], FLAG_RACE_CREATED))
        return raceid;

    for(new i = 0; i < MAX_GAME_RACES; i++)
    {
        if(game::Race[i][race::gameid] == gameid && GetFlag(game::Race[i][race::flags], FLAG_RACE_CREATED))
        {
            Race::IndexByGameID[gameid] = i;
            return i;
        }
    }

    return INVALID_RACE_ID;
}

stock Race::GetFreeSlotID()
{
    for(new i = 0; i < MAX_GAME_RACES; i++)
        if(!GetFlag(game::Race[i][race::flags], FLAG_RACE_CREATED))
            return i;

    return INVALID_RACE_ID;
}

stock Race::GetPodiumPlace(raceid, playerid)
{
    if(!list_valid(game::Race[raceid][race::podium])) return 0;
    return (list_find(game::Race[raceid][race::podium], playerid) + 1);
}

stock Race::EliminatePlayer(playerid, gameid)
{   
    new raceid = game::Player[playerid][pyr::raceid];
    
    if(raceid == INVALID_RACE_ID || !list_valid(game::Race[raceid][race::podium]))
        return 0;
    
    Game::SendMessageToAll(gameid, 
    "{ff5533}[ CORRIDA ] {ffffff}O corredor {ff5533}%s {ffffff}desistiu da corrida", GetPlayerNameStr(playerid));
    
    Race::RemPodium(playerid, raceid, 1);
    Race::UpdatePodium(gameid);

    DisablePlayerCheckpoint(playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);

    Veh::Destroy(race::Player[playerid][race::vehicleid]);
      
    Game::RemovePlayer(gameid, playerid);
    
    return 1;
}

stock Race::SendPlayer(playerid, gameid)
{
    new raceid = Race::GetIDByGameID(gameid);
    game::Player[playerid][pyr::raceid] = raceid;

    SetPlayerPos(playerid, -1403.0116, -250.4526, 1043.5341);
    SetPlayerInterior(playerid, 7);
    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);
    SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você entrou no evento {ff5533}%s.", game::Race[raceid][race::name]);
}

stock Race::UpdatePlayerCheck(playerid, lap, checkid)
{
    new raceid = game::Player[playerid][pyr::raceid];

    if(raceid == INVALID_RACE_ID || !list_valid(game::Race[raceid][race::podium]))
        return 0;

    SetPlayerCheckpoint(playerid,
    Race::gCheckpoints[checkid][0], Race::gCheckpoints[checkid][1], Race::gCheckpoints[checkid][2], 25.0);

    race::Player[playerid][race::checkid] = checkid;
    race::Player[playerid][race::lap] = lap;

    new place = Race::GetPodiumPlace(raceid, playerid);
    
    SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Checkpoint {44ff66}%d/%d {ffffff}| Volta: {44ff66}%d/%d {ffffff}| Posição: {44ff66}%d| Lugar",
    checkid + 1, sizeof(Race::gCheckpoints), lap, MAX_LAPS, place);

    return 1;
}

stock Float:GetPlayerRaceProgress(playerid, raceid)
{
    #pragma unused raceid
    new lap = race::Player[playerid][race::lap];
    new check = race::Player[playerid][race::checkid];
    new total = sizeof(Race::gCheckpoints);

    // new next = (check + 1) % total;

    // new Float:px, Float:py, Float:pz;

    // GetPlayerPos(playerid, px, py, pz);

    // new 
    //     Float:ax = Race::gCheckpoints[next][0], 
    //     Float:ay = Race::gCheckpoints[next][1]
    // ;

    // new Float:dist = floatpower(px - ax, 2.0) + floatpower(py - ay, 2.0);

    return float((lap * total) + check);// + (1.0 / (dist + 1.0));
}

stock Race::UpdatePodium(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    if(raceid == INVALID_RACE_ID)
        return 0;

    if(!list_valid(game::Race[raceid][race::podium]))
        return 0;

    new count = list_size(game::Race[raceid][race::podium]);

    if(count <= 1)
        return 1;

    for(new i = 1; i < count; i++)
    {
        new player = list_get(game::Race[raceid][race::podium], i);

        new Float:player_progress = GetPlayerRaceProgress(player, raceid);

        new j = i - 1;

        while(j >= 0)
        {
            new other = list_get(game::Race[raceid][race::podium], j);

            if(GetFlag(game::Player[other][pyr::flags], FLAG_PLAYER_FINISHED)) break;
        
            new Float:other_progress = GetPlayerRaceProgress(other, raceid);

            if(player_progress <= other_progress)
                break;

            list_set(game::Race[raceid][race::podium], j + 1, other);
            list_set(game::Race[raceid][race::podium], j, player);

            new name1[MAX_PLAYER_NAME];
            new name2[MAX_PLAYER_NAME];

            GetPlayerName(player, name1, sizeof(name1));
            GetPlayerName(other, name2, sizeof(name2));

            Game::SendMessageToAll(
                gameid,
                "{44ff66}[ CORRIDA ] {ffffff}O corredor {44ff66}%s {ffffff}ultrapassou {44ff66}%s",
                name1,
                name2
            );

            j--;
        }
    }

    return 1;
}

stock Race::Ready(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);
    if(raceid == INVALID_RACE_ID) return 0;

    for(new i = 0; i < MAX_RACE_PARTICIPANTS; i++)
    {
        Veh::Destroy(game::Race[raceid][race::vehicleid][i]);
        
        new playerid = Game[gameid][game::players][i];

        if(playerid == INVALID_PLAYER_ID)continue;

        Race::AddPodium(playerid, raceid);

        if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);

    }

    new modelid = game::Race[raceid][race::modelid];

    for(new idx = 0; idx < list_size(game::Race[raceid][race::podium]); idx++)
    {
        new playerid = list_get(game::Race[raceid][race::podium], idx);

        SetPlayerPos(playerid, Race::gVehicleSpawns[idx][0], 
        Race::gVehicleSpawns[idx][1], Race::gVehicleSpawns[idx][2]);

        game::Race[raceid][race::vehicleid][idx] = Veh::Create(Race::gModels[modelid],
        Race::gVehicleSpawns[idx][0], Race::gVehicleSpawns[idx][1], Race::gVehicleSpawns[idx][2],
        Race::gVehicleSpawns[idx][3], RandomMinMax(3, 12), RandomMinMax(3, 12), 7, Game[gameid][game::vw], FLAG_PARAM_ENGINE);
        
        SetPVarInt(playerid, "PutPlayerInVehicle", 1);

        race::Player[playerid][race::vehicleid] = game::Race[raceid][race::vehicleid][idx];

        SetVehicleHealth(race::Player[playerid][race::vehicleid], 1000.0 + 1000.0);
        SetVehicleZAngle(race::Player[playerid][race::vehicleid], Float:Race::gVehicleSpawns[idx][3]);

        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);

        SetPlayerInterior(playerid, GetVehicleInterior(race::Player[playerid][race::vehicleid]));
        SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(race::Player[playerid][race::vehicleid]));      
        
        TogglePlayerControllable(playerid, false);
        
        Veh::UpdateParams(game::Race[raceid][race::vehicleid][idx], FLAG_PARAM_ENGINE, 1);
    }
    

    return 1;
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
    if( GetFlag(game::Player[forplayerid][pyr::flags], FLAG_PLAYER_PLAYING) && 
        GetPVarInt(forplayerid, "PutPlayerInVehicle") && 
        vehicleid == race::Player[forplayerid][race::vehicleid]
    )
    {
        PutPlayerInVehicle(forplayerid, race::Player[forplayerid][race::vehicleid], 0);
        DeletePVar(forplayerid, "PutPlayerInVehicle");
    }

    return 1;
}

stock Race::Start(gameid)
{
    for(new i = 0; i < Game[gameid][game::max_players]; i++)
    {
        new playerid = Game[gameid][game::players][i];

        if(playerid != INVALID_PLAYER_ID)
        {
            Race::UpdatePlayerCheck(playerid, 1, 0);
            TogglePlayerControllable(playerid, true);
        }
    }

    return 1;
}

stock Race::Update(gameid)
{        
    new raceid = Race::GetIDByGameID(gameid);

    if(list_size(game::Race[raceid][race::podium]) <= 0)
    {
        SendClientMessageToAll(-1, "{ff5533}[ CORRIDA ] {ffffff}Os jogadores desistiram da corrida. Não houve vencedores");
        Game[gameid][game::start_time] = 0;
    }

    for(new i = 0; i < list_size(game::Race[raceid][race::podium]); i++)
    {
        new playerid = list_get(game::Race[raceid][race::podium], i);

        if(playerid == INVALID_PLAYER_ID) continue;

        if(!IsPlayerInAnyVehicle(playerid) && IsValidVehicle(race::Player[playerid][race::vehicleid]))
            PutPlayerInVehicle(playerid, race::Player[playerid][race::vehicleid], 0);
    }

    Race::UpdatePodium(gameid);

    return 1;
}

stock Race::Finish(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    if(raceid == INVALID_RACE_ID || !list_valid(game::Race[raceid][race::podium]))
        return 0;

    if(GetFlag(game::Race[raceid][race::flags], FLAG_RACE_FINISHED))
        return 1;

    SetFlag(game::Race[raceid][race::flags], FLAG_RACE_FINISHED);

    new len = list_size(game::Race[raceid][race::podium]);

    if(game::Race[raceid][race::finisheds] < 1)
        SendClientMessageToAll(-1, "{ff5533}[ CORRIDA ] {ffffff}A corrida terminou! {ff5533}Ninguém conseguiu finalizar!");
    
    for(new i = len - 1; i >= 0; i--)
    {
        new playerid = list_get(game::Race[raceid][race::podium], i);

        if(playerid == INVALID_PLAYER_ID) continue;

        if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED)) continue;

        Race::RemPodium(playerid, raceid, 1);
        game::Player[playerid][pyr::flags] = 0;
    
        DisablePlayerCheckpoint(playerid);

        if(IsPlayerInAnyVehicle(playerid)) 
            RemovePlayerFromVehicle(playerid);

        Veh::Destroy(race::Player[playerid][race::vehicleid]);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);

        PlayerPlaySound(playerid, 31202, 0.0, 0.0, 0.0);
        Game::RemovePlayer(gameid, playerid);

        Player::Spawn(playerid, true);

        //SendClientMessage(playerid, -1, "{ff5533}[ CORRIDA ] {ffffff}Você não conseguiu finalizar a corrida :(");
    }

    return 1;
}

stock Race::GiveRewards(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    if(raceid == INVALID_RACE_ID || !list_valid(game::Race[raceid][race::podium])) return 0;

    new len = list_size(game::Race[raceid][race::podium]);

    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(game::Race[raceid][race::podium], i);

        if(playerid == INVALID_PLAYER_ID || !IsPlayerConnected(playerid)) continue;

        if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED)) continue;

        new Float:reward = 0.0;

        switch(i)
        {
            case 0: reward = 100.0;
            case 1: reward = 75.0;
            case 2: reward = 25.0;
        }

        if(reward > 0.0)
        {
            SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Premiação da corrida: {44ff66}R$ %.2f{ffffff} por terminar em {44ff66}%d {ffffff} | lugar.", reward, i + 1);
            Player::GiveMoney(playerid, reward);
        }
    }

    SendClientMessageToAll(-1, "{ff5533}[ EVENTO ] {ffffff}O evento {ff5533}%s {ffffff}acabou!", game::Race[raceid][race::name]);

    return 1;
}
