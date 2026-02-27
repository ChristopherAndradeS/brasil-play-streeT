forward OnServerUpdate();

#define g_WEATHER_CHANGE    (0.0656)
#define j_WEATHER_CHANGE    (0.0108)

enum E_WEATHERS_INFO
{
    WEATHER_ID,
    WEATHER_NAME[32],
}

enum E_SERVER
{
    srv::year, srv::month, srv::day,
    srv::hour, srv::minute, srv::seconds,
    srv::weekday, srv::timestamp, srv::gmt,

    srv::g_weatherid, srv::j_weatherid,
    Float:srv::g_weather_prob, Float:srv::j_weather_prob,

    srv::is_count_down,
    srv::last_rand_msgid,
}

new Server[E_SERVER];

enum E_SERVER_TIMER
{
    srv::TIMER_ON_UPDATE_MILIS,
    srv::TIMER_ON_UPDATE_SEC,
    srv::TIMER_ON_UPDATE_MIN,
    srv::TIMER_COUNT_DOWN
}

new E_SERVER_TIMER:srv::Timer[E_SERVER_TIMER];

new gWeathers[][E_WEATHERS_INFO] = 
{
    {0, "Muito Ensolarado"},
    {1, "Ensolarado"},
    {2, "Muito Ensolarado com neblina"},
    {3, "Ensolarado com neblina"},
    {4, "Nublado"},
    {5, "Ensolarado"},
    {6, "Muito Ensolarado"},
    {7, "Nublado"},
    {8, "Chuva Forte"},
    {9, "Enevoado"}
};

new Server::gRandMgs[][144] = 
{
    {"Use {99ff99}/evento {ffffff}para jogar nos mini-games do servidor"},
    {"Use {99ff99}/acessorios {ffffff}para comprar e configurar seus acessorios"},
    {"Você pode voltar ao spawn civil digitando {99ff99}/spawn"},
    {"Está perdido? Use {99ff99}/gps"}
};

forward OnVehicleHealthChange(vehicleid, Float:new_health, Float:old_health);
