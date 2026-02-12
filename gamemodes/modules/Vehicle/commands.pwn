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
    new name[32], category[32], msg[512], start, count = 1;
    new DBResult:result = DB_ExecuteQuery(db_stock, "SELECT COUNT(DISTINCT category) FROM locations;");
    
    inline select_gps_cat_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, listitem
        if(!response) return 1;

        count = 1;
        start = strfind(inputtext, "f}", true);
        printf("%s > %d", category, start);
        strdel(category, start, strlen(category));

        inline select_gps_name_dialog(playerid2, dialogid2, response2, listitem2, string:inputtext2[])
        {
            #pragma unused playerid2, dialogid2, listitem2
            if(!response2) return 1;

            start = strfind(inputtext2, "f}", true);
            printf("%s > %d", name, start);
            strdel(name, start, strlen(name));

            new Float:pX, Float:pY, Float:pZ, Float:tX, Float:tY, Float:tZ;

            DB::GetDataFloat(db_stock, "locations", "pX", pX, "name = '%q'", name);
            DB::GetDataFloat(db_stock, "locations", "pY", pY, "name = '%q'", name);
            DB::GetDataFloat(db_stock, "locations", "pZ", pZ, "name = '%q'", name);
            GetPlayerPos(playerid, tX, tY, tZ);

            new Float:distance = floatsqroot(floatpower(pX - tX, 2) + floatpower(pY - tY, 2) + floatpower(pZ - tZ, 2));

            SetPlayerCheckpoint(playerid, pX, pY, pZ, 2.5);

            SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}GPS selecionou {33ff33}%s {ffffff}> {33ff33}%s", category, name);
            SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Ponto marcado a uma distância de: {33ff33}%.2f KM", distance); 
        
            return 1;
        }

        result = DB_ExecuteQuery(db_stock, "SELECT name FROM locations WHERE category = '%q';", category);

        if(!result)
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Essa categoria esta vazia!"); 

        do
        {
            DB_GetFieldStringByName(result, "name", name);
            format(msg, 512, "%s{ff5555}%d. {ffffff}%s\n", msg, count, category);
            count++;
        }

        while(DB_SelectNextRow(result));

        Dialog_ShowCallback(playerid, using inline select_gps_name_dialog, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha o nome", msg, "Selecionar", "Fechar");
        
        return 1;
    }

    if(!result)
        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}O GPS está desativado no momento!"); 
    
    do
    {
        DB_GetFieldStringByName(result, "category", category);
        format(msg, 512, "%s{ff5555}%d. {ffffff}%s\n", msg, count, category);
        count++;
    }

    while(DB_SelectNextRow(result));

    format(msg, 512, "%s{ff5555}%d. {ffffff}CRIAR CATEGORIA NOVA", msg, count);

    Dialog_ShowCallback(playerid, using inline select_gps_cat_dialog, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha a Categoria", msg, "Abrir", "Fechar");
    
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
