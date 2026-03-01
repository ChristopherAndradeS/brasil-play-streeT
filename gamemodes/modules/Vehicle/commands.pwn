YCMD:trancar(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    new Float:distance;
    new vehicleid = GetClosestVehicle(playerid, distance);
    
    if(vehicleid == INVALID_VEHICLE_ID || distance > 2.0) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Chegue perto de um veiculo!");

    Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_DOORS);

    return 1;
}

YCMD:motor(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
    {
        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED))
        {
            GameTextForPlayer(playerid, "~r~~h~QUEBRADO", 1500, 3);
            return 1;
        }
        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_EMPTY))
        {
            GameTextForPlayer(playerid, "~h~SEM COMBUSTIVEL", 1500, 3);
            return 1;
        }

        Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_ENGINE);
    }  

    return 1;
}

YCMD:farol(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
        Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_LIGHTS);

    return 1;
}

YCMD:capo(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
        Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_BONNET);

    return 1;
}

YCMD:portamalas(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
        Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_BOOT);

    return 1;
}

YCMD:alarme(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa estar dentro de um veiculo!");

    new vehicleid = GetPlayerVehicleID(playerid);

    if(IsValidVehicle(vehicleid))
        Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_ALARM);

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

YCMD:abastecer(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(Player[playerid][pyr::regionid] != 27)
        return SendClientMessage(playerid, -1, "{ff3333}[ GAS ] {ffffff}Você nao esta perto da bomba de combustível.");

    for(new i = 0; i < sizeof(Gas); i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, Gas[i][gas::pX], Gas[i][gas::pY], Gas[i][gas::pZ]))
            break;
        if(i == sizeof(Gas) - 1)
            return SendClientMessage(playerid, -1, "{ff3333}[ GAS ] {ffffff}Você nao esta perto da bomba de combustível.");
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    if(!vehicleid)
        return SendClientMessage(playerid, -1, "{ff3333}[ GAS ] {ffffff}Entre num veículo para abastecer.");
    
    if(Model_IsManual(GetVehicleModel(vehicleid)))
        return SendClientMessage(playerid, -1, "{ff3333}[ GAS ] {ffffff}Esse veículo não é movido a combustão");
    
    inline gas_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, listitem
        if(!response) return 1;

        new percent;

        RemoverChar(inputtext, '%');

        if(sscanf(inputtext, "'Encher'i{s[32]}", percent))
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Um erro incomum aconteceu! Avise um moderador!");
            return 1;
        }
    
        new 
            Float:Ofuel = Vehicle[vehicleid][veh::fuel],
            Float:litres = (0.6 * percent),
            Float:total  = litres - Ofuel,
            Float:price =  total * FUEL_PRICE_PER_LITER
        ;

        if(!Player::RemoveMoney(playerid, price, true)) return 1;

        Veh::UpdateFuel(playerid, vehicleid, litres);
        
        Player::RemoveMoney(playerid, price);

        SendClientMessage(playerid, -1, "{33ff33}[ GAS ] {ffffff}Veículo abastecido com {33ff33}%.1f {ffffff}litros!", total);
    
        return 1;
    }

    new Float:fuel = Vehicle[vehicleid][veh::fuel];

    new str[256];

    for(new i = 1; i <= 4; i++)
    {
        new Float:targetFuel = 15.0 * i;

        if(fuel >= targetFuel) continue;

        format(str, 256, "%s%d. Encher {ff9933}%d%% {ffffff}do tanque\t{55ff55}R$ %.2f\n", 
        str, i, 25 * i, (targetFuel - fuel) * FUEL_PRICE_PER_LITER);
    }

    if(isnull(str))
        return SendClientMessage(playerid, -1, "{ff3333}[ GAS ] {ffffff}Seu tanque já esta {ff3333}cheio.");
    
    Dialog_ShowCallback(playerid, using inline gas_dialog, DIALOG_STYLE_TABLIST, 
    "Posto de Gasolina", 
    str,
    "Abastecer", "Fechar");
    
    return 1;
}

YCMD:oficina(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(Player[playerid][pyr::regionid] != 27 || !IsPlayerInRangeOfPoint(playerid, 2.0, Mec[ofc::pX], Mec[ofc::pY], Mec[ofc::pZ]))
        return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Você nao dentro da oficina mecânica.");
    
    new vehicleid = GetPlayerVehicleID(playerid);

    if(!vehicleid)
        return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Entre num veículo para isso.");
    
    if(Model_IsManual(GetVehicleModel(vehicleid)))
        return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Não consertamos esse veículo.");
    
    new Float:price;
    new Float:health = Vehicle[vehicleid][veh::health];
    Officine::GetRepairPrice(health, price);

    inline oficine_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, inputtext

        if(!response) return 1;

        switch(listitem)
        {
            case 0:
            {
                if(health >= 1000.0)
                    return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Seu veículo está em {ff3333}ótimas {ffffff}condições!");
                
                inline repair_dialog(playerid2, dialogid2, response2, listitem2, string:inputtext2[])
                {
                    #pragma unused playerid2, dialogid2, listitem2, inputtext2

                    if(!response2) return Command_ReProcess(playerid, "oficina", false);

                    if(!Player::RemoveMoney(playerid, price, true)) return 1;

                    Veh::UpdateHealth(playerid, vehicleid, 1000.0);
                    RepairVehicle(vehicleid);

                    Player::RemoveMoney(playerid, price);

                    SendClientMessage(playerid, -1, "{33ff33}[ MEC ] {ffffff}Veículo reparado com {33ff33}sucesso!");
                    
                    return 1;
                }   

                new str[256];

                switch(floatround(health))
                {
                    case 0..390:    format(str, 256, "{ff5599}[ MEC ] {ffffff}NPC_Rogerio diz:\n\n{ffffff}Caramba! Seu veiculo ta so a {ff5599}capa da gaita. {ffffff}Vou dar um jeito nele por: {ff5599}500.00 R$\n\nDeseja {ff5599}reparar {ffffff}o veículo?");
                    case 391..650:  format(str, 256, "{ff5599}[ MEC ] {ffffff}NPC_Rogerio diz:\n\n{ffffff}A situacao {ff5599}nao ta legal. {ffffff}Vou dar um trato no seu veiculo por: {ff5599}350.00 R$\n\nDeseja {ff5599}reparar {ffffff}o veículo?");
                    case 651..999:  format(str, 256, "{ff5599}[ MEC ] {ffffff}NPC_Rogerio diz:\n\n{ffffff}Ta um {ff5599}poquinho amassado. {ffffff}Vou desamassar por: {ff5599}150.00 R$\n\nDeseja {ff5599}reparar {ffffff}o veículo?");
                }

                Dialog_ShowCallback(playerid, using inline repair_dialog, DIALOG_STYLE_MSGBOX,  "Oficina Mecanica", str, "Confirmar", "Voltar");   
            }

            case 1:
            {
                if(health >= 2000.0)
                    return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Seu veículo já está {ff3333}blindado!");
                
                new Float:armour = floatclamp(Vehicle[vehicleid][veh::health] - 1000.0, 0.0, 1000.0);

                inline armour_dialog(playerid3, dialogid3, response3, listitem3, string:inputtext3[])
                {
                    #pragma unused playerid3, dialogid3, listitem3
                    
                    if(!response3) return Command_ReProcess(playerid, "oficina", false);

                    new percent;

                    RemoverChar(inputtext3, '%');

                    if(sscanf(inputtext3, "'Blindar'i{s[32]}", percent))
                    {
                        SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Um erro incomum aconteceu! Avise um moderador!");
                        return 1;
                    }
                
                    new 
                        Float:Narmour = (10 * percent),
                        Float:total  = price + ((Narmour - armour) * ARMOUR_PRICE_PER_HP)
                    ;
                    
                    if(!Player::RemoveMoney(playerid, total, true)) return 1;
       
                    Veh::UpdateHealth(playerid, vehicleid, 1000.0 + Narmour);
                    
                    Player::RemoveMoney(playerid, total);

                    SendClientMessage(playerid, -1, "{33ff33}[ GAS ] {ffffff}Veículo {33ff33}blindado%s{ffffff}com {33ff33}sucesso!", price > 0.0 ? " e reparado " : " ");
                
                    return 1;
                }

                new str[512];

                for(new i = 1; i <= 4; i++)
                {
                    new Float:targetArmour = 250.0 * i;

                    if(armour >= targetArmour) continue;

                    format(str, 512, "%s%d. Blindar {ff9933}%d%% {ffffff}da lataria\t{55ff55}R$ %.2f\t{ffffff}+ Reparo: {55ff55} R$ %.2f\n", 
                    str, i, 25 * i, (targetArmour - armour) * ARMOUR_PRICE_PER_HP, price);
                }

                if(isnull(str))
                    return SendClientMessage(playerid, -1, "{ff3333}[ MEC ] {ffffff}Seu veículo já está {ff3333}quase totalmente blindado.");

                Dialog_ShowCallback(playerid, using inline armour_dialog, DIALOG_STYLE_TABLIST, 
                "Blindagem", 
                str,
                "Blindar", "Fechar");
            }
        }

        return 1;
    }

    Dialog_ShowCallback(playerid, using inline oficine_dialog, DIALOG_STYLE_TABLIST, 
    "Oficina Mecanica", 
    "{ff5599}1{ffffff}. Reparar veículo {33ff33}(100%%)\n\
    {ff5599}2{ffffff}. Comprar {dedede}Blindagem",
    "Abrir", "Fechar");

    return 1;
}  

stock Officine::GetRepairPrice(Float:health, &Float:price)
{
    switch(floatround(health))
    {
        case 0..390:   price = 500.0;
        case 391..650: price = 350.0;
        case 651..999: price = 150.0;
    }
}
