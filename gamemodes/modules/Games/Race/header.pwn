#define MAX_RACE_VEHICLES (5)
#define MAX_GAME_RACES    (5)
#define INVALID_RACE_ID   (-1)

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
    race::vehicleid[MAX_RACE_VEHICLES],
}

new game::Race[MAX_GAME_RACES][E_GAME_RACE];

enum (<<= 1)
{
    FLAG_RACE_CREATED = 1,
}

stock Race::Create(gameid, notify = false)
{
    new raceid = Race::GetFreeSlotID();

    if(raceid == INVALID_RACE_ID) return 0;

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

    printf("[ CORRIDA ] Corrida %d criada com sucesso", raceid);
    
    return 1;
}

stock Race::Destroy(gameid)
{
    new raceid = Race::GetIDByGameID(gameid);

    if(raceid == INVALID_RACE_ID) return 0;

    for(new i = 0; i < MAX_RACE_VEHICLES; i++)
    {
        Veh::Destroy(game::Race[raceid][race::vehicleid][i]);
        //game::Race[raceid][race::vehicleid][i] = INVALID_VEHICLE_ID;
    }

    game::Race[raceid][race::gameid] = INVALID_GAME_ID;
    game::Race[raceid][race::flags] = 0;

    return 1;
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

stock Race::SendPlayer(playerid, gameid)
{
    SetPlayerPos(playerid, -1403.0116, -250.4526, 1043.5341);
    SetPlayerInterior(playerid, 7);
    SetPlayerVirtualWorld(playerid, Game[gameid][game::vw]);

    SendClientMessage(playerid, -1, "{ff5533}[ EVENTO ] {ffffff}Você entrou no evento {ff5533}%s.", Game[gameid][game::name]);
}