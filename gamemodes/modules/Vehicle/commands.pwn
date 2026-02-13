#include <YSI\YSI_Coding\y_hooks>

YCMD:trancar(playerid, params[], help)
{
    new vehicleid = GetClosestVehicle(playerid, _);
    
    if(vehicleid == INVALID_VEHICLE_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Chegue perto de um veiculo!");

    Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS, 1);
    
    GameTextForPlayer(playerid, "~r~~h~Trancado", 2000, 3);
    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);

    return 1;
}

YCMD:abrir(playerid, params[], help)
{
    new vehicleid = GetClosestVehicle(playerid, _);
    if(vehicleid == INVALID_VEHICLE_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Chegue perto de um veiculo!");

    Veh::UpdateParams(vehicleid, FLAG_PARAM_DOORS, 0);
    
    GameTextForPlayer(playerid, "~g~~h~Aberto", 2000, 3);
    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);

    return 1;
}

YCMD:gps(playerid, params[], help)
{
    new category[32], name[32], msg[512];

    new DBResult:result = DB_ExecuteQuery(db_stock, "SELECT DISTINCT category FROM locations ORDER BY category ASC;");
    if(!result)
        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}O GPS está desativado no momento!");

    do
    {
        DB_GetFieldStringByName(result, "category", category);
        format(msg, sizeof(msg), "%s%s\n", msg, category);
    }
    while(DB_SelectNextRow(result));

    DB_FreeResultSet(result);

    inline select_gps_cat_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, listitem
        if(!response) return 1;

        if(sscanf(inputtext, "s[32]", category))
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve selecionar uma categoria válida");

        new msg_name[512];
        new DBResult:result_name = DB_ExecuteQuery(db_stock, "SELECT name FROM locations WHERE category = '%q' ORDER BY name ASC;", category);

        if(!result_name)
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Essa categoria está vazia!");

        do
        {
            DB_GetFieldStringByName(result_name, "name", name);
            format(msg_name, sizeof(msg_name), "%s%s\n", msg_name, name);
        }
        while(DB_SelectNextRow(result_name));

        DB_FreeResultSet(result_name);

        inline select_gps_name_dialog(playerid2, dialogid2, response2, listitem2, string:inputtext2[])
        {
            #pragma unused playerid2, dialogid2, listitem2
            if(!response2) return 1;

            if(sscanf(inputtext2, "s[32]", name))
                return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve selecionar um local válido");

            new Float:pX, Float:pY, Float:pZ, Float:tX, Float:tY, Float:tZ;

            if(!DB::GetDataFloat(db_stock, "locations", "pX", pX, "name = '%q' AND category = '%q'", name, category)) return 1;
            if(!DB::GetDataFloat(db_stock, "locations", "pY", pY, "name = '%q' AND category = '%q'", name, category)) return 1;
            if(!DB::GetDataFloat(db_stock, "locations", "pZ", pZ, "name = '%q' AND category = '%q'", name, category)) return 1;

            GetPlayerPos(playerid, tX, tY, tZ);

            new Float:distance = floatsqroot(floatpower(pX - tX, 2) + floatpower(pY - tY, 2) + floatpower(pZ - tZ, 2));

            SetPlayerCheckpoint(playerid, pX, pY, pZ, 2.5);

            SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}GPS selecionou {33ff33}%s {ffffff}> {33ff33}%s", category, name);
            SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Ponto marcado a uma distância de: {33ff33}%.2f KM", distance / 1000.0);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline select_gps_name_dialog, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha o local", msg_name, "Selecionar", "Fechar");
        return 1;
    }

    Dialog_ShowCallback(playerid, using inline select_gps_cat_dialog, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha a categoria", msg, "Abrir", "Fechar");
    return 1;
}

YCMD:cancelargps(playerid, params[], help)
{
    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_CHECKPOINT)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você nao tem nenhum GPS ativo.");
    
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}GPS desligado.");
    return 1;
}
