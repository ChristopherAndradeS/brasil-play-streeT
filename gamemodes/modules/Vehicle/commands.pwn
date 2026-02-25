YCMD:trancar(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    new Float:distance;
    new vehicleid = GetClosestVehicle(playerid, distance);
    
    if(vehicleid == INVALID_VEHICLE_ID || distance > 2.0) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Chegue perto de um veiculo!");

    Veh::ToogleDoor(playerid, vehicleid);

    return 1;
}

YCMD:motor(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
        Veh::ToogleEngine(playerid, GetPlayerVehicleID(playerid));

    return 1;
}

YCMD:gps(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    new category[32], name[32], msg[512];

    new DBResult:result = DB_ExecuteQuery(db_stock, "SELECT EXISTS (SELECT 1 FROM locations LIMIT 1);");
    if(!DB_GetFieldInt(result))
        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}O GPS está desativado no momento!");

    result = DB_ExecuteQuery(db_stock, "SELECT category FROM locations GROUP BY category ORDER BY category ASC;");

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
        result = DB_ExecuteQuery(db_stock, "SELECT name FROM locations WHERE category = '%q' ORDER BY name ASC;", category);

        if(!result)
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Essa categoria está vazia!");

        do
        {
            DB_GetFieldStringByName(result, "name", name);
            format(msg_name, sizeof(msg_name), "%s%s\n", msg_name, name);
        }
        while(DB_SelectNextRow(result));

        DB_FreeResultSet(result);

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
            SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT);
            PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
            
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
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você nao tem nenhum GPS ativo.");
    
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}GPS desligado.");
    return 1;
}

YCMD:mochila(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;
    
    return 1;
}
