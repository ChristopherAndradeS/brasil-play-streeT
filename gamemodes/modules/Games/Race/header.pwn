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

//new const Race::gModels[] = { 424, 441, 462, 468, 509, 571, 574 };
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
    race::countpart,
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
