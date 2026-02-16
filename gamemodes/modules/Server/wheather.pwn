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

new Server::gRandMgs[][144] = 
{
    {"Use {99ff99}/evento {ffffff}para jogar nos mini-games do servidor"},
    {"Use {99ff99}/acessorios {ffffff}para comprar e configurar seus acessorios"},
    {"Você pode voltar ao spawn civil digitando {99ff99}/spawn"},
    {"Está perdido? Use {99ff99}/gps"}
};

new const gJailWeathers[] = 
{
    7, 8, 9, 15, 16
};

hook OnGameModeInit()
{
    Server[srv::g_weatherid]     = 1;
    Server[srv::j_weatherid]     = 9;
    Server[srv::last_rand_msgid] = -1;
    //Server[srv::g_weather_prob] = 0.017;
    //Server[srv::j_weather_prob] = 0.027;

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
                if(!IsFlagSet(Player[i][pyr::flags], MASK_PLAYER_IN_JAIL))
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


// hook OnServerUpdateMinutes()
// {
//     Server[srv::g_weather_prob] += ((g_WEATHER_CHANGE) * Server[srv::minute]/32) * 100.0;
//     Server[srv::j_weather_prob] += ((j_WEATHER_CHANGE) * Server[srv::minute]/32) * 100.0;
    
//     if(TryPercentage(floatround(Server[srv::g_weather_prob])))
//     {
//         new id = Server::GetRadomGlobalWeather();

//         if(Server[srv::g_weatherid] != id)
//         {
//             Server[srv::g_weatherid] = id;

//             foreach (new i : Player)
//             {
//                 if(!IsFlagSet(Player[i][pyr::flags], MASK_PLAYER_IN_JAIL))
//                 {
//                     SetPlayerWeather(i, Server[srv::g_weatherid]);
//                     SendClientMessage(i, -1, 
//                     "{99ff33}[ CLIMA ] {ffffff}O clima parece estar mudando para {99ff33}%s!", gWeathers[id][WEATHER_NAME]);
//                 }
//             }
//         }
//     }

//     if(TryPercentage(floatround(Server[srv::j_weather_prob])))
//     {
//         new id = Server::GetRadomJailWeather();

//         if(Server[srv::j_weatherid] != id)
//         {
//             foreach (new i : Player)
//             {
//                 if(IsFlagSet(Player[i][pyr::flags], MASK_PLAYER_IN_JAIL))
//                 {
//                     SetPlayerWeather(i, Server[srv::j_weatherid]);
//                     SendClientMessage(i, -1, "{ff3399}[ ILHA ] {ffffff}O clima parece estar mudando na ilha...");
//                 }
//             }
//         }
//     }
    
//     return 1;
// }

stock Server::GetRadomGlobalWeather()
{
    return gWeathers[RandomMax(sizeof(gWeathers))][WEATHER_ID];
}

stock Server::GetRadomJailWeather()
{
    return gJailWeathers[RandomMax(sizeof(gJailWeathers))];
}