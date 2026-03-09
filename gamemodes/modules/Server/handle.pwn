#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    //CA_Init();

    Server[srv::timestamp] = gettime();
    
    Server[srv::gmt] = -3;

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

    SetWorldTime(Server[srv::hour]);
    SetWeather(Server[srv::g_weatherid]);
    
    for(new i = 0; i < MAX_SERVER_VEHICLES; i++)
    {
        new vehicleid =  Veh::Load("Server", i, OWNER_TYPE_SERVER, 1001);

        new str[144];
        format(str, 144, "{99ff99}[ VEH ][ BPS ]");

        Vehicle[vehicleid][veh::labelid] = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, -0.25, 60.0, .attachedvehicle = vehicleid, .testlos = 1);
    }   
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
    foreach(new i : Vehicle)
    {
        if(Model_IsManual(GetVehicleModel(i))) continue;
        
        if(!IsVehicleOccupied(i) || GetFlag(Vehicle[i][veh::flags], FLAG_VEH_BROKED) || GetFlag(Vehicle[i][veh::flags], FLAG_VEH_EMPTY)) continue;
        
        new driverid = GetVehicleDriver(i);

        if(IsValidPlayer(driverid))
            CallLocalFunction("OnVehicleUpdate", "ii", driverid, i);
    
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


    if(!(Server[srv::minute] % 2))
    {
        if(TryPercentage(40))
        {
            Server[srv::g_weatherid] = RandomMinMaxExcept(0, sizeof(gWeathers) - 1, Server[srv::g_weatherid]);
            
            new weatherid = Server[srv::g_weatherid];

            new str[144], desc[144];

            format(str, 144, "{99ff33}[ CLIMA ] {ffffff}O clima parece estar mudando para {99ff33}%s!", 
            gWeathers[weatherid][WEATHER_NAME]);

            format(desc, 144, "O clima em *StreeT City* parece estar mudando para:\n%s!", 
            gWeathers[weatherid][WEATHER_NAME]);

            new const field_name[1][1];
            new field_value[1][1];
            new bool:finline[1];

            DC::SendCustomEmbedMsg
            (
                DC_CHANNEL_ID_SERVER_WARN,
                ":white_sun_rain_cloud: CLIMA\n",
                DC_THUMBNAIL_ICON, 0x99FF33, desc,
                field_name, field_value, finline,
                "Sistema de Informação • Brasil Play StreeT",
                DC_FOOTER_ICON,
                0
            );
            
            foreach (new i : Player)
            {
                if(!GetFlag(Player[i][pyr::flags], FLAG_PLAYER_IN_JAIL))
                {
                    SetPlayerWeather(i, weatherid);
                    SendClientMessage(i, -1, str);
                }
            }
        }
    }

    return 1;
}
