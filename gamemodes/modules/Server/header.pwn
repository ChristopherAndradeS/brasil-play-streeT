forward OnServerUpdate();

enum E_SERVER
{
    srv::year, srv::month, srv::day,
    srv::hour, srv::minute, srv::seconds,
    srv::weekday, srv::timestamp, srv::gmt,

    srv::g_weatherid, srv::j_weatherid,
    Float:srv::g_weather_prob, Float:srv::j_weather_prob,

    srv::is_count_down
}

new Server[E_SERVER];

enum E_SERVER_TIMER
{
    srv::TIMER_ON_UPDATE_SEC,
    srv::TIMER_ON_UPDATE_MIN,
    srv::TIMER_COUNT_DOWN
}

new E_SERVER_TIMER:srv::Timer[E_SERVER_TIMER];

stock Server::IsNewDay()
    return (!Server[srv::hour] && !Server[srv::minute]);

stock Server::IsNewHour()
    return (!Server[srv::minute]);
