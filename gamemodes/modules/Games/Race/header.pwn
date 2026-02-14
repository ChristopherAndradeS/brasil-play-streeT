#define MAX_RACE_VEHICLES       (5)
#define MAX_RACE_PARTICIPANTS   (5)
#define MAX_GAME_RACES          (5)
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
stock const Float:Race::gCheckpoints[][3] =
{
    {-1395.7150, -216.3227, 1042.4036}, // check1
    {-1407.3843, -150.4694, 1043.2502}, // check2
    {-1503.4323, -151.5957, 1048.5673}, // check3
    {-1517.9471, -249.8785, 1049.8755}, // check4
    {-1419.1387, -277.5760, 1050.4873}, // check5
    {-1354.6580, -130.7808, 1050.3792}, // check6
    {-1265.3080, -193.3538, 1049.9474}, // check7
    {-1308.0317, -271.3692, 1047.4279}  // check8
};

enum E_GAME_RACE
{
    race::gameid,
    race::flags,
    List:podium[MAX_RACE_PARTICIPANTS],
    race::vehicleid[MAX_RACE_VEHICLES],
}

enum E_RACE_PART
{
    race::checkid,
    race::lap,
}

new game::Race[MAX_GAME_RACES][E_GAME_RACE];

new race::Player[MAX_RACE_PARTICIPANTS][]

enum (<<= 1)
{
    FLAG_RACE_CREATED = 1,
}

stock Race::Create(gameid, notify = false)
{
    new raceid = Race::GetFreeSlotID();

    if(raceid == INVALID_RACE_ID) return 0;

    game::Race[raceid][race::podium] = list_new();

    game::Race[raceid][race::gameid] = gameid;
    SetFlag(game::Race[raceid][race::flags], FLAG_RACE_CREATED);

    for(new i = 0; i < MAX_RACE_VEHICLES; i++)
    {
        game::Race[raceid][race::vehicleid][i] = Veh::Create(571, 
        Race::gVehicleSpawns[i][0], Race::gVehicleSpawns[i][1], Race::gVehicleSpawns[i][2], 
        Race::gVehicleSpawns[i][3], RandomMinMax(3, 12), RandomMinMax(3, 12), 7, Game[gameid][game::vw], 0);
    }

    if(notify)
        SendClientMessageToAll(-1, "{ff5533}[ CORRIDA KART ] {ffffff}Um novo evento foi criado. Digite {ff5533}/evento {ffffff}para conferir");

    printf("[ CORRIDA ] Corrida %d criada com sucesso\n", raceid);
    
    return 1;
}

stock Race::Destroy(gameid, const name[])
{
    new raceid = Race::GetIDByGameID(gameid);

    if(raceid == INVALID_RACE_ID) return 0;

    for(new i = 0; i < MAX_RACE_VEHICLES; i++)
        Veh::Destroy(game::Race[raceid][race::vehicleid][i]);
    
    list_destroy(game::Race[raceid][race::podium]);

    game::Race[raceid][race::gameid] = INVALID_GAME_ID;
    game::Race[raceid][race::flags] = 0;

    printf("[ EVENTO ] Evento %s destruido com sucesso\n", name);
    
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
    for(new i = 0; i < MAX_GAME_RACES; i++)
        if(game::Race[i][race::gameid] == gameid)
            return i;
    
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

stock Race::SendPlayer(playerid, gameid)
{
    game::Player[playerid][pyr::raceid] =  Race::GetIDByGameID(gameid);
    SetPlayerPos(playerid, -1403.0116, -250.4526, 1043.5341);
    SetPlayerInterior(playerid, 7);
    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);
    SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você entrou no evento {ff5533}%s.", Game[gameid][game::name]);
}

stock Race::UpdatePlayerCheck(playerid, laps, checkid)
{
    new raceid = game::Player[playerid][pyr::raceid];
    new len = list_size(game::Race[raceid][race::podium]);

    SetPlayerCheckpoint(playerid, 
    Race::gCheckpoints[checkid][0], Race::gCheckpoints[checkid][1], Race::gCheckpoints[checkid][2], 2.5);

    race::Player[playerid][race::checkid] = check;
    race::Player[playerid][race::lap] = laps;

    new place = Race::GetPodiumPlace(raceid, playerid);

    SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Checkpoint {44ff66}%d/%d {ffffff}| Volta: {44ff66}%d/%d {ffffff}| Posição: {44ff66}%dº Lugar",
    checkid + 1, sizeof(gCheckpoints), laps, MAX_LAPS, place, len);
}

stock Race::UpdatePodium(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);
    
    new len = list_size(game::Race[raceid][race::podium]);

    for(new i )
}

stock Race::Ready(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    for(new i = 0; i < Game[gameid][game::players_count]; i++)
    {
        new playerid = Game[gameid][game::players][i];

        if(playerid != INVALID_PLAYER_ID)
        {
            Race::AddPodium(playerid, raceid); 
        
            ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_WAITING);
            SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);

            PutPlayerInVehicle(game::Race[raceid][race::vehicleid][i]);
            TogglePlayerControllable(playerid, false);
            Veh::UpdateParams(game::Race[raceid][race::vehicleid][i], FLAG_PARAMS_ENGINE, 1);
        }
        else
            Veh::Destroy(game::Race[raceid][race::vehicleid][i]);
    }

    return 1;
}

stock Race::Start(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    for(new i = 0; i < Game[gameid][game::players_count]; i++)
    {
        new playerid = Game[gameid][game::players][i];

        if(playerid != INVALID_PLAYER_ID)
        {
            race::Player[i][race::checkid] = 0;
            race::Player[i][race::laps]    = 0;

            Race::UpdateCheck(playerid, 0, 0);
            TogglePlayerControllable(playerid, true);
            Race::UpdateCheck(playerid, i, race::Player[i][race::checkid]);
        }
    }
    
    return 1;
}

stock Race::Update(gameid)
{
    Race::UpdatePodium(gameid);

    //AQUI VÃO FUNÇÕES QUE EXECUTARAM DE 1 EM 1segundo para atualizar a corrida
    return 1;
}

stock Race::Finish(gameid)
{
    /* Aqui deve remover todos os jogadores do veículo que ainda estiverem na corrida e executar Player::Spawn(playerid)
    e tocar o soundid 31202 */

    return 1;
}

stock Race::GiveRewards(gameid)
{
    /* Aqui deve enviar uma mensagem personalizada de bonificação para os 3 melhores colocados:
    
    1º 350.0 / 2º 200.0 / 3º 150.0 
    
    Use a função Player::GiveMoney(playerid, Float:price) para isso

    */
    return 1;
}