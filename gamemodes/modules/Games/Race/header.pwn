new const Float:Race::gVehicleSpawns[][4] =
{
    {-1392.1642, -230.3090, 1042.5342, 8.2200}, // pos_kart_1
    {-1395.9572, -232.7750, 1042.5399, 7.7789}, // pos_kart_2
    {-1399.4191, -235.6807, 1042.5432, 8.2266}, // pos_kart_3
    {-1393.3723, -237.1489, 1042.6235, 6.0405}, // pos_kart_4
    {-1397.1626, -239.5044, 1042.6101, 8.0659}  // pos_kart_5
};

new const Float:Race::gCheckpoints[][3] =
{
    {-1407.3843, -150.4694, 1043.2502},         // check2
    {-1503.4323, -151.5957, 1048.5673},         // check3
    {-1517.9471, -249.8785, 1049.8755},         // check4
    {-1419.1387, -277.5760, 1050.4873},         // check5
    {-1354.6580, -130.7808, 1050.3792},         // check6
    {-1265.3080, -193.3538, 1049.9474},         // check7
    {-1308.0317, -271.3692, 1047.4279},         // check8
    {-1395.7150, -216.3227, 1042.4036}          // check1
};

new const Race::gModels[] = { 424, 441, 462, 468, 509, 571, 574 };
new const Race::gInteriorID = 7;

enum (<<= 1)
{
    FLAG_RACE_CREATED = 1,
    FLAG_RACE_FINISHED,
}

enum E_GAME_RACE
{
    race::modelid,
    Float:race::rewards[MAX_GAME_PARTICIPANTS],
    race::lap,
    race::flags,
    List:race::podium,
    race::finisheds,
    Map:race::participant,
}

enum _:E_RACE_SEAT
{
    race::playerid,
    race::laps,
    race::checkid,
    race::vehicleid,
}

new Race[MAX_GAMES_INSTANCES][E_GAME_RACE];

stock bool:Race::IsRaceVehicle(vehicleid, &raceid = INVALID_GAME_ID, &playerid = INVALID_PLAYER_ID)
{
    for(new gid = 0; gid < MAX_GAMES_INSTANCES; gid++)
    {
        if(!GetFlag(Game[gid][game::flags], FLAG_GAME_CREATED)) continue;
        if(Game[gid][game::type] != GAME_TYPE_RACE) continue;
        if(!map_valid(Race[gid][race::participant])) continue;

        new len = Game::GetPlayersCount(gid);
        for(new i = 0; i < len; i++)
        {
            new pid = list_get(Game[gid][game::players], i);
            if(!map_has_key(Race[gid][race::participant], pid)) continue;

            new data[E_RACE_SEAT];
            map_get_arr(Race[gid][race::participant], pid, data);

            if(data[race::vehicleid] != vehicleid) continue;

            raceid = gid;
            playerid = pid;
            return true;
        }
    }

    return false;
}

stock Race::ProtectVehicle(vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return 0;

    new Float:health;
    GetVehicleHealth(vehicleid, health);

    if(health < 2000.0)
        SetVehicleHealth(vehicleid, 2000.0);

    new Float:qw, Float:qx, Float:qy, Float:qz;
    GetVehicleRotationQuat(vehicleid, qw, qx, qy, qz);

    // m33 < 0: eixo "up" invertido -> veículo tombado/capotado.
    new Float:m33 = 1.0 - 2.0 * (qx * qx + qy * qy);
    if(m33 < 0.0)
    {
        new Float:x, Float:y, Float:z, Float:a;
        GetVehiclePos(vehicleid, x, y, z);
        GetVehicleZAngle(vehicleid, a);

        SetVehiclePos(vehicleid, x, y, z + 0.15);
        SetVehicleZAngle(vehicleid, a);
        SetVehicleHealth(vehicleid, 2000.0);
    }

    return 1;
}

stock Race::Create(raceid, const args[])
{
    if(sscanf(args, "iia<f>["#MAX_GAME_PARTICIPANTS"]", Race[raceid][race::modelid], Race[raceid][race::lap], Race[raceid][race::rewards]))
    {
        printf("[ EVENTO ] Houve erro de argumento no sscanf ao tentar criar evento de corrida");
        return 0;
    }    

    Race[raceid][race::flags]      |= FLAG_GAME_CREATED;
    Race[raceid][race::podium]      = list_new();
    Race[raceid][race::finisheds]   = 0;
    Race[raceid][race::participant]   = map_new();

    return 1;
}

stock Race::Destroy(raceid)
{
    if(!list_valid(Race[raceid][race::podium]))      return 0;
    if(!map_valid(Race[raceid][race::participant]))  return 0;

    new len = Race::GetPlayersCount(raceid),
        playerid,
        data[E_RACE_SEAT]
    ;

    for(new i = 0; i < len; i++)
    {
        playerid = list_get(Race[raceid][race::podium], i);
        map_get_arr(Race[raceid][race::participant], playerid, data);
        Veh::Destroy(data[race::vehicleid]);
    }

    list_delete(Race[raceid][race::podium]);
    
    Race[raceid][race::modelid]   = 0;

    for(new i = 0; i < MAX_GAME_PARTICIPANTS; i++)
        Race[raceid][race::rewards][i] = 0.0;

    Race[raceid][race::lap]       = 0;
    Race[raceid][race::flags]     = 0;
    Race[raceid][race::finisheds] = 0;

    map_delete(Race[raceid][race::participant]);

    return 1;
}

stock Race::SendPlayer(playerid, raceid)
{
    SetPlayerPos(playerid, -1403.0116, -250.4526, 1043.5341);
    SetPlayerInterior(playerid, 7);
    SetPlayerVirtualWorld(playerid, Game[raceid][game::vw]);

    new data[E_RACE_SEAT];

    data[race::laps]      = 1;
    data[race::checkid]   = 0;
    data[race::vehicleid] = INVALID_VEHICLE_ID;

    map_add_arr(Race[raceid][race::participant], playerid, data);

    SendClientMessage(playerid, -1, "{3399ff}[ EVENTO ] {ffffff}Você entrou no evento {3399ff}%s.", Game[raceid][game::name]);

    return 1;
}

stock Race::QuitPlayer(raceid, playerid)
{
    if(!list_valid(Race[raceid][race::podium]))      return 0;
    if(!map_valid(Race[raceid][race::participant]))  return 0;
    
    new data[E_RACE_SEAT];
    if(map_has_key(Race[raceid][race::participant], playerid))
    {
        map_get_arr(Race[raceid][race::participant], playerid, data);
        if(IsValidVehicle(data[race::vehicleid]))
            Veh::Destroy(data[race::vehicleid]);

        map_remove(Race[raceid][race::participant], playerid);
    }
    
    //Game::SendMessageToAll(raceid, "{ff3333}[ CORRIDA ] {ffffff}%s {ff3333}saiu {ffffff}da corrida", GetPlayerNameStr(playerid));
    
    if(!IsPlayerConnected(playerid)) return 1;
    
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    PlayerPlaySound(playerid, 31202, 0.0, 0.0, 0.0);
    DisablePlayerCheckpoint(playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    Player::Spawn(playerid); 

    ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
    
    return 1;
}

stock Race::Ready(raceid)
{
    new len = Game::GetPlayersCount(raceid);

    new data[E_RACE_SEAT];

    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(Game[raceid][game::players], i);
     
        if(!IsValidPlayer(playerid)) continue;

        map_get_arr(Race[raceid][race::participant], playerid, data);

        /* SET VEHICLE */
        data[race::vehicleid] = Veh::Create(Race[raceid][race::modelid],
        Race::gVehicleSpawns[i][0], Race::gVehicleSpawns[i][1], Race::gVehicleSpawns[i][2], Race::gVehicleSpawns[i][3], 
        RandomMinMax(3, 12), RandomMinMax(3, 12), Race::gInteriorID, Game[raceid][game::vw], FLAG_PARAM_ENGINE);
        
        SetVehicleHealth(data[race::vehicleid], 1000.0 + 1000.0);
       
        /* SET PLAYER */
        map_set_arr(Race[raceid][race::participant], playerid, data);
        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
        
        SetPVarInt(playerid, "PutPlayerInVehicle", 1);

        SetPlayerPos(playerid, Race::gVehicleSpawns[i][0], Race::gVehicleSpawns[i][1], Race::gVehicleSpawns[i][2]);
        SetPlayerInterior(playerid, GetVehicleInterior(data[race::vehicleid]));
        SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(data[race::vehicleid]));      
        
        Race::AddPodium(playerid, raceid);

        TogglePlayerControllable(playerid, false);
    }
    
    Game::SendMessageToAll(raceid, "{ff9933}[ EVENTO ] {ffffff}Iniciando Corrida! {ff9933}Se preparem!");
    
    return 1;
}

stock Race::Start(raceid, tick, &new_tick)
{
    new len = Race::GetPlayersCount(raceid);

    if(tick <= 0)
    {
        for(new i = 0; i < len; i++)
        {
            new playerid = list_get(Race[raceid][race::podium], i);
            
            if(!IsValidPlayer(playerid)) continue;

            new data[E_RACE_SEAT];
            map_get_arr(Race[raceid][race::participant], playerid, data);   

            Race::UpdatePlayerCheck(playerid, data);
            TogglePlayerControllable(playerid, true);
        }

        Game::ShowTextForAll(raceid, "~r~VAI...", 1000, 3);
        Game::PlaySoundForAll(raceid, 1057);
        new_tick = 240; 
    }

    else
    {
        Game::ShowTextForAll(raceid, "~r~~h~%d", 990, 3, tick);
        Game::PlaySoundForAll(raceid, 1056);
    }

    return 1;
}

stock Race::GetPlayersCount(raceid)
{
    if(!list_valid(Race[raceid][race::podium])) return 0;
    return list_size(Race[raceid][race::podium]);
}

stock Race::Update(raceid, tick)
{        
    new len = Race::GetPlayersCount(raceid);

    if(len <= 0)
    {
        SendClientMessageToAll(-1, "{ff3333}[ CORRIDA ] {ffffff}Todos desistiram da corrida. {ff3333}Não houve vencedores.");
        Game[raceid][game::tick] = 0;
        return 1;
    }

    if(tick <= 60)
    {
        if(tick == 60)
            Game::SendMessageToAll(raceid, "{ff9933}[ EVENTO ] {ffffff}A corrida vai termina em {ff9933}1 minuto!");
       
        Game::ShowTextForAll(raceid, "~r~%02d~w~:~r~%02d", (tick <= 10) ? 600 : 990, 4, floatround(tick/60), tick % 60);
    }

    for(new i = 0; i < len; i++)
    {
        new playerid = list_get(Race[raceid][race::podium], i);
        if(!map_has_key(Race[raceid][race::participant], playerid)) continue;

        new data[E_RACE_SEAT];
        map_get_arr(Race[raceid][race::participant], playerid, data);

        Race::ProtectVehicle(data[race::vehicleid]);
    }

    Race::UpdatePodium(raceid);

    return 1;
}

stock Race::Finish(raceid)
{
    SetFlag(Race[raceid][race::flags], FLAG_RACE_FINISHED);

    new len = Race::GetPlayersCount(raceid);

    for(new i = len - 1; i >= 0; i--)
    {
        new playerid = list_get(Race[raceid][race::podium], i);

        if(!IsValidPlayer(playerid)) continue;

        if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED))
        {
            new place = Race::GetPodiumPlace(raceid, playerid) - 1;
            new Float:reward = (place >= 0 && place < MAX_GAME_PARTICIPANTS) ? Race[raceid][race::rewards][place] : 0.0;

            if(reward > 0.0)
            {
                SendClientMessage(playerid, -1, "{3399ff}[ CORRIDA ] {ffffff}Premiação da corrida: {3399ff}R$ %.2f{ffffff} por terminar em {3399ff}%d {ffffff} | lugar.", reward, i + 1);
                Player::GiveMoney(playerid, reward);
            }

            else
            {
                SendClientMessage(playerid, -1, "{ff3333}[ CORRIDA ] {ffffff}Você {ff3333}não se classificou {ffffff}para receber recomepensa!");
            }
        }
        
        else
        {
            ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
            SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_ELIMINATED);
            Game::RemovePlayer(raceid, playerid);
        }
    }

    return 1;
}

stock GetPlayerRaceProgress(playerid, raceid)
{
    new data[E_RACE_SEAT];
    map_get_arr(Race[raceid][race::participant], playerid, data);   
    return (data[race::laps] * sizeof(Race::gCheckpoints)) + data[race::checkid];
}

stock Race::UpdatePodium(raceid)
{
    new len = Race::GetPlayersCount(raceid);

    if(len <= 1) return 1;

    for(new i = 1; i < len; i++)
    {
        new playerid = list_get(Race[raceid][race::podium], i);

        if(!IsValidPlayer(playerid)) continue;

        new 
            player_progress = GetPlayerRaceProgress(playerid, raceid),
            j = i - 1
        ;

        while(j >= 0)
        {
            new otherid = list_get(Race[raceid][race::podium], j);

            if(GetFlag(game::Player[otherid][pyr::flags], FLAG_PLAYER_FINISHED)) break;
        
            new other_progress = GetPlayerRaceProgress(otherid, raceid);

            if(player_progress <= other_progress) break;

            list_set(Race[raceid][race::podium], j + 1, otherid);
            list_set(Race[raceid][race::podium], j, playerid);

            Game::SendMessageToAll(
                raceid,
                "{3399ff}[ CORRIDA ] {ffffff}O corredor {3399ff}%s {ffffff}ultrapassou {3399ff}%s",
                GetPlayerNameStr(playerid),
                GetPlayerNameStr(otherid)
            );

            j--;
        }
    }

    return 1;
}

stock Race::AddPodium(playerid, raceid)
{
    if(!list_valid(Race[raceid][race::podium])) return 0;

    if(list_find(Race[raceid][race::podium], playerid) == -1)
    {
        list_add(Race[raceid][race::podium], playerid);
        return 1;
    }

    return 0;
}

// stock Race::RemPodium(playerid, raceid)
// {
//     if(!list_valid(Race[raceid][race::podium])) return 0;

//     new idx = list_find(Race[raceid][race::podium], playerid);

//     if(idx != -1)
//     {
//         list_remove(Race[raceid][race::podium], idx);      
//         return 1;
//     }

//     return 0;
// }

stock Race::GetPodiumPlace(raceid, playerid)
{
    if(!list_valid(Race[raceid][race::podium])) return 0;
    return (list_find(Race[raceid][race::podium], playerid) + 1);
}

stock Race::GiveRewards(raceid)
{
    #pragma unused raceid
    return 1;
}
