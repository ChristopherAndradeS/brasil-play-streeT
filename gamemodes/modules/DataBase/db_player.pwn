#include <YSI\YSI_Coding\y_hooks>

stock Player::InsertData(playerid, GLOBAL_TAG_TYPES:...)
{
    new name[MAX_PLAYER_NAME], query[256], DBResult:db_result;

    GetPlayerName(playerid, name);

    if(!Database::GetRowCount("players", "name", name, db_result))
    {
        DB_FreeResultSet(db_result);

        va_format(query, sizeof(query), "INSERT INTO `players` (\
        name, pass, payday_tleft, bitcoin, money, pX, pY, pZ, pA, score, skinid, orgid) \
        VALUES('%q', '%q', %i, %i, %f, %f, %f, %f, %f, %i, %i, %i);",
        name, ___(1));

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

        printf("[ DB (PLAYER) ] Conta do jogador %s, adicionada ao banco", name);
        return 1;
    }

    DB_FreeResultSet(db_result);

    return 0;
}

stock Player::LoadAllData(playerid)
{
    new name[MAX_PLAYER_NAME], DBResult:db_result;

    GetPlayerName(playerid, name);

    if(!Database::GetRowCount("players", "name", name, db_result))
    {
        DB_FreeResultSet(db_result);
        //print("[ DB (ERRO) ] Falha ao tentar carregar dados na table `players` > %s, pois não existia\n", name);
        return 0;
    }

    DB_GetFieldStringByName(db_result, "pass", Player[playerid][pyr::pass]); 
    Player[playerid][pyr::payday_tleft]     = DB_GetFieldIntByName(db_result, "payday_tleft"); 
    Player[playerid][pyr::bitcoin]          = DB_GetFieldIntByName(db_result, "bitcoin"); 
    Player[playerid][pyr::money]            = DB_GetFieldFloatByName(db_result, "money");  
    Player[playerid][pyr::score]            = DB_GetFieldIntByName(db_result, "score"); 
    Player[playerid][pyr::orgid]            = DB_GetFieldIntByName(db_result, "orgid"); 

    DB_FreeResultSet(db_result);
  
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////                                                             
/*                                          VEHICLES                                        */
////////////////////////////////////////////////////////////////////////////////////////////// 

stock Vehicle::SaveSlotData(playerid, slotid)
{
    new query[256], DBResult:db_result, name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);
    
    format(query, sizeof(query), "SELECT * FROM `player_vehicles` \
    WHERE `owner` = '%q' AND slotid = %i LIMIT 1", name, slotid);

    db_result = DB_ExecuteQuery(db_handle, query);

    if(DB_GetRowCount(db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `player_vehicles` \
        SET modelid = %i, \
        pX = %f, pY = %f, pZ = %f, pA = %f\
        color1 = %i, color2 = %i \
        WHERE `owner` = '%q' AND slotid = %i;",
        veh::Player[playerid][slotid][veh::modelid], veh::Player[playerid][slotid][veh::pX], 
        veh::Player[playerid][slotid][veh::pY], veh::Player[playerid][slotid][veh::pZ],
        veh::Player[playerid][slotid][veh::pA], veh::Player[playerid][slotid][veh::color1], 
        veh::Player[playerid][slotid][veh::color2], name, slotid);

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));
    }

    else
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "INSERT INTO `player_vehicles` (\
        owner, slotid, modelid, \
        pX, pY, pZ, pA, \
        color1, color2) \
        VALUES('%q', '%i', %i, '%f', %f, %f, %f, %i, %i);",
        name, slotid, veh::Player[playerid][slotid][veh::modelid], 
        veh::Player[playerid][slotid][veh::pX], veh::Player[playerid][slotid][veh::pY], 
        veh::Player[playerid][slotid][veh::pZ], veh::Player[playerid][slotid][veh::pA], 
        veh::Player[playerid][slotid][veh::color1], veh::Player[playerid][slotid][veh::color2]
        );

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

        printf("[ DB (VEHICLE) ] Veículo #%d do jogador %s, adicionada ao banco", slotid, name);
    }    
}

stock Vehicle::LoadSlotData(playerid, slotid)
{
    new query[256], DBResult:db_result, name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);

    format(query, sizeof(query), "SELECT * FROM `player_vehicles` \
    WHERE `owner` = '%q' AND slotid = %i LIMIT 1", name, slotid);

    db_result = DB_ExecuteQuery(db_handle, query);

    if(!DB_GetRowCount(db_result))
    {
        DB_FreeResultSet(db_result);
        return 0;
    }

    veh::Player[playerid][slotid][veh::modelid] = DB_GetFieldIntByName(db_result, "modelid"); 
    veh::Player[playerid][slotid][veh::pX]      = DB_GetFieldFloatByName(db_result, "pX"); 
    veh::Player[playerid][slotid][veh::pY]      = DB_GetFieldFloatByName(db_result, "pY"); 
    veh::Player[playerid][slotid][veh::pZ]      = DB_GetFieldFloatByName(db_result, "pZ"); 
    veh::Player[playerid][slotid][veh::pA]      = DB_GetFieldFloatByName(db_result, "pA"); 
    veh::Player[playerid][slotid][veh::color1]  = DB_GetFieldIntByName(db_result, "color1"); 
    veh::Player[playerid][slotid][veh::color2]  = DB_GetFieldIntByName(db_result, "color2"); 

    DB_FreeResultSet(db_result);
  
    return 1;
}
