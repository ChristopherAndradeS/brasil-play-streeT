#include <YSI\YSI_Coding\y_hooks>

forward OnServerUpdate();

enum E_SERVER
{
    srv::update_time,
}

new Server[E_SERVER];

hook OnGameModeInit()
{
    Server[srv::update_time] = SetTimer("OnServerUpdate", 1000, true);
    
    return 1;
}

hook OnGameModeExit()
{
    KillTimer(Server[srv::update_time]);
    
    return 1;
}

public OnServerUpdate()
{
    new day, mouth, year, hour, minute, sec; 
    
    getdate(year, mouth, day);
    gettime(hour, minute, sec);

    Server::UpdatePlayerTime(hour, minute);

    TextDrawSetString(Baseboard::PublicTD[TD_BASEBOARD_CLOCK], "%02d:%02d:%02d~n~%02d_de_%s_de_%04d", 
    hour, minute, sec, day, gMonths[mouth], year);

    return 1;
}

stock Server::UpdatePlayerTime(hour, minute)
{
    foreach (new i : Player)
    {
        SetPlayerTime(i, hour, minute);

        if(IsValidTimer(pdy::Player[i][pdy::timerid]))
        {
            new left_time = GetTimerRemaining(pdy::Player[i][pdy::timerid]);
            new lmin  = floatround((left_time / 60000));
            new lsec  = floatround((left_time % 60000) / 1000);

            Baseboard::UpdateTDForPlayer(i, PTD_BASEBOARD_PAYDAY, 
            "~b~~h~~h~PAYDAY~n~~w~%02d~b~~h~~h~:~w~%02d", lmin, lsec);
        }
    }
}

stock Server::SetRandomWeather()
{
    new weatherid = RandomMinMax(0, 18);
    SetWeather(weatherid);
}