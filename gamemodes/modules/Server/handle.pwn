#include <YSI\YSI_Coding\y_hooks>

forward OnVehicleHealthChance(vehicleid, Float:new_health, Float:old_health);

hook OnGameModeInit()
{
    srv::Timer[srv::TIMER_ON_UPDATE_MILIS] = SetTimer("OnServerUpdateMilis", 32, true);
    srv::Timer[srv::TIMER_ON_UPDATE_SEC] = SetTimer("OnServerUpdateSeconds", 1000, true);
    srv::Timer[srv::TIMER_ON_UPDATE_MIN] = SetTimer("OnServerUpdateMinutes", 60 * 1000, true);

    Server[srv::gmt] = -3;

    SetWorldTime(Server[srv::hour]);

    return 1;
}

hook OnGameModeExit()
{
    KillTimer(srv::Timer[srv::TIMER_ON_UPDATE_MILIS]);
    KillTimer(srv::Timer[srv::TIMER_ON_UPDATE_SEC]);
    KillTimer(srv::Timer[srv::TIMER_ON_UPDATE_MIN]);
    
    return 1;
}

hook OnServerUpdateMilis()
{
    new Float:health;

    foreach(new i : Vehicle)
    {
        if(IsFlagSet(Vehicle[i][veh::flags], FLAG_VEH_IS_DEAD)) continue;
        
        GetVehicleHealth(i, health);
        if(Vehicle[i][veh::health] != health)
        {
            CallLocalFunction("OnVehicleHealthChance", "iff", i, health, Vehicle[i][veh::health]);
            Vehicle[i][veh::health] = health;
        }
    }

    return 1;
}

hook OnServerUpdateSeconds()
{
    Server[srv::timestamp] = gettime();
 
    TimestampToDate(Server[srv::timestamp], 
    Server[srv::year], Server[srv::month], Server[srv::day], 
    Server[srv::hour], Server[srv::minute], Server[srv::seconds], Server[srv::gmt]);

    Server[srv::weekday] = GetWeekDayFromTimestamp(Server[srv::timestamp], Server[srv::gmt]);

    SetWorldTime(Server[srv::hour]);

    return 1;
}

hook OnServerUpdateMinutes()
{

    return 1;
}
