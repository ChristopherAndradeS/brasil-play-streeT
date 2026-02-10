#include <YSI\YSI_Coding\y_hooks>

#define g_WEATHER_CHANGE    (0.0656)
#define j_WEATHER_CHANGE    (0.0108)

enum E_WEATHERS_INFO
{
    WEATHER_ID,
    WEATHER_NAME[32],
}

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

new const gJailWeathers[] = 
{
    7, 8, 9, 15, 16
};

hook OnGameModeInit()
{
    Server[srv::g_weather_prob] = 0.017;
    Server[srv::j_weather_prob] = 0.027;

    return 1;
}

hook OnServerUpdateMinutes()
{
    Server[srv::g_weather_prob] += ((g_WEATHER_CHANGE) * Server[srv::minute]/32) * 100.0;
    Server[srv::j_weather_prob] += ((j_WEATHER_CHANGE) * Server[srv::minute]/32) * 100.0;
    
    if(TryPercentage(floatround(Server[srv::g_weather_prob])))
    {
        new id = Server::GetRadomGlobalWeather();

        if(Server[srv::g_weatherid] != id)
        {
            Server[srv::g_weatherid] = id;

            foreach (new i : Player)
            {
                if(!IsFlagSet(Player[i][pyr::flags], MASK_PLAYER_IN_JAIL))
                {
                    SetPlayerWeather(i, Server[srv::g_weatherid]);
                    SendClientMessage(i, -1, 
                    "{99ff33}[ CLIMA ] {ffffff}O clima parece estar mudando para {99ff33}%s!", gWeathers[id][WEATHER_NAME]);
                }
            }
        }
    }

    if(TryPercentage(floatround(Server[srv::j_weather_prob])))
    {
        new id = Server::GetRadomJailWeather();

        if(Server[srv::j_weatherid] != id)
        {
            foreach (new i : Player)
            {
                if(IsFlagSet(Player[i][pyr::flags], MASK_PLAYER_IN_JAIL))
                {
                    SetPlayerWeather(i, Server[srv::j_weatherid]);
                    SendClientMessage(i, -1, "{ff3399}[ ILHA ] {ffffff}O clima parece estar mudando na ilha...");
                }
            }
        }
    }
    
    return 1;
}

stock Server::GetRadomGlobalWeather()
{
    return gWeathers[RandomMax(sizeof(gWeathers))][WEATHER_ID];
}

stock Server::GetRadomJailWeather()
{
    return gJailWeathers[RandomMax(sizeof(gJailWeathers))];
}