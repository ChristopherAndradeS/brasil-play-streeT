#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    //CA_Init();

    Server[srv::timestamp] = gettime();
 
    TimestampToDate(Server[srv::timestamp], 
    Server[srv::year], Server[srv::month], Server[srv::day], 
    Server[srv::hour], Server[srv::minute], Server[srv::seconds], Server[srv::gmt]);

    Server[srv::weekday] = GetWeekDayFromTimestamp(Server[srv::timestamp], Server[srv::gmt]);

    SetWorldTime(Server[srv::hour]);

    Server[srv::g_weatherid]     = 1;
    Server[srv::j_weatherid]     = 9;
    Server[srv::last_rand_msgid] = -1;

    AllowNickNameCharacter('[', false);
    AllowNickNameCharacter(']', false);
    AllowNickNameCharacter(')', false);
    AllowNickNameCharacter('(', false);
    AllowNickNameCharacter('@', false);
    AllowNickNameCharacter('$', false);
    AllowNickNameCharacter('=', false);
    AllowNickNameCharacter('.', false);

    srv::Timer[srv::TIMER_ON_UPDATE_MILIS] = SetTimer("OnServerUpdateMilis", 32, true);
    srv::Timer[srv::TIMER_ON_UPDATE_SEC]   = SetTimer("OnServerUpdateSeconds", 1000, true);
    srv::Timer[srv::TIMER_ON_UPDATE_MIN]   = SetTimer("OnServerUpdateMinutes", 60 * 1000, true);

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
        if(GetFlag(Vehicle[i][veh::flags], FLAG_VEH_IS_DEAD)) continue;
        
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

    for(new gameid = 0; gameid < MAX_GAMES_INSTANCES; gameid++)
    {
        if(!GetFlag(Game[gameid][game::flags], FLAG_GAME_CREATED))
            continue;

        Game_Update(gameid);
    }

    TextDrawSetString(Baseboard::PublicTD[TD_BASEBOARD_CLOCK], "%02d:%02d:%02d~n~~g~~h~~h~%s - %02d_de_%s_de_%04d", 
    Server[srv::hour], Server[srv::minute], Server[srv::seconds],
    gWeekDays[Server[srv::weekday]], Server[srv::day], gMonths[Server[srv::month]], Server[srv::year]);

    Server::UpdatePlayerSeconds();

    return 1;
}

hook OnServerUpdateMinutes()
{
    if(!(Server[srv::minute] % 5))
    {
        Server[srv::last_rand_msgid] = RandomMinMaxExcept(0, sizeof(Server::gRandMgs) - 1, Server[srv::last_rand_msgid]);
        SendClientMessageToAll(-1, "{99ff99}[ BPS ] {ffffff}%s.", Server::gRandMgs[Server[srv::last_rand_msgid]]);
    }
    
    if(!(Server[srv::minute] % 10))
    {
        new count = DB::GetCount(db_stock, "acessorys", "");

        if(count <= 4)
        {
            new modelid, name[64], sucess;
            Acessory::GetNameByModelid(modelid, name);

            for(new i = 1; i <= 8; i++)
            {
                if(DB::Exists(db_stock, "acessorys", "uid = %d", i))
                    continue;

                for(;;)
                {
                    modelid = RandomMinMax(18632, 19914);
                    sucess = Acessory::GetNameByModelid(modelid, name);
                    
                    if(sucess)
                        break;
                }

                DB::Insert(db_stock, "acessorys", 
                "uid, name, creator, price, modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, color1, color2", 
                "%i, '%s', 'SERVER', %.2f, %i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %f, %i, %i", 
                i, name, Float:RandomFloatMinMax(100.0, 500.0), modelid, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, -1, -1);
            }        

            SendClientMessageToAll(-1, "{ff9933}[ LOJA ACS ] {ffffff}Novos itens no estoque da loja de acessórios! Use {ff9933}/acessorios {ffffff}para conferir!");
        }
    }


    if(!(Server[srv::minute] % 30))
    {
        if(TryPercentage(40))
        {
            Server[srv::g_weatherid] = RandomMinMaxExcept(0, sizeof(gWeathers) - 1, Server[srv::g_weatherid]);
            
            new weatherid = Server[srv::g_weatherid];
            
            foreach (new i : Player)
            {
                if(!GetFlag(Player[i][pyr::flags], FLAG_PLAYER_IN_JAIL))
                {
                    SetPlayerWeather(i, weatherid);
                    SendClientMessage(i, -1, 
                    "{99ff33}[ CLIMA ] {ffffff}O clima parece estar mudando para {99ff33}%s!", 
                    gWeathers[weatherid][WEATHER_NAME]);
                }
            }
        }
    }

    return 1;
}
