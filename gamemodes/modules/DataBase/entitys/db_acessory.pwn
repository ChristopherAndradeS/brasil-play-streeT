#include <YSI\YSI_Coding\y_hooks>

stock Acessory::Exist(playerid, slotid)
{
    new query[128], name[MAX_PLAYER_NAME], DBResult:db_result, count;

    GetPlayerName(playerid, name);
    format(query, sizeof(query), "SELECT * FROM `player_acessorys` WHERE `owner` = '%q' AND \
    `slotid` = %i LIMIT 1", name, slotid);

    db_result = DB_ExecuteQuery(db_entity, query);
        
    count = DB_GetRowCount(db_result);

    DB_FreeResultSet(db_result); 

    return count;
}

stock Acessory::GetRow(playerid, slotid, &DBResult:db_result)
{
    new query[128], name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);

    format(query, sizeof(query), "SELECT * FROM `player_acessorys` WHERE `owner` = '%q' AND \
    `slotid` = %i LIMIT 1", name, slotid);

    db_result = DB_ExecuteQuery(db_entity, query);
    
    return DB_GetRowCount(db_result);
}

stock Acessory::GetFreeSlot(playerid)
{
    new query[128], name[MAX_PLAYER_NAME], DBResult:db_result, count, slotid = -1;

    GetPlayerName(playerid, name);

    for(new i = 0; i < MAX_ACESSORYS; i++)
    {
        if(!Acessory::Exist(playerid, i))
        {
            slotid = i;
            break;
        }
    }

    return slotid;
}

stock Acessory::InsertData(playerid, GLOBAL_TAG_TYPES:...)
{
    new name[MAX_PLAYER_NAME], query[512], DBResult:db_result;

    GetPlayerName(playerid, name);

    new slotid = Acessory::GetFreeSlot(playerid);

    if(slotid == -1)
        return 0;
    
    va_format(query, sizeof(query), "INSERT INTO `player_acessorys` (\
    owner, slotid, modelid, boneid, \
    pX, pY, pZ, \
    rX, rY, rZ, \
    sX, sY, sZ) \
    VALUES('%q', '%i', %i, '%i', %f, %f, %f, %f, %f, %f, %f, %f, %f);",
    name, slotid, ___(1));

    DB_FreeResultSet(DB_ExecuteQuery(db_entity, query));

    printf("[ DB (ACESSORY) ] Acessório #%d do jogador %s, adicionada ao banco", slotid, name);  

    return 1;
}

stock Acessory::SaveData(playerid, slotid, GLOBAL_TAG_TYPES:...)
{
    new query[256], name[MAX_PLAYER_NAME], DBResult:db_result;

    GetPlayerName(playerid, name);

    if(Acessory::Exist(playerid, slotid))
    {
        va_format(query, sizeof(query), "UPDATE `player_acessorys` \
        SET modelid = %i, boneid = %i, \
        pX = %f, pY = %f, pZ = %f \
        rX = %f, rY = %f, rZ = %f \
        sX = %f, sY = %f, sZ = %f \
        WHERE `owner` = '%q' AND slotid = %i;",
        ___(2), name, slotid);

        DB_FreeResultSet(DB_ExecuteQuery(db_entity, query));
        return 1;
    }

    return 0;
}

stock Acessory::LoadData(playerid, slotid)
{
    new query[256];

    if(!Acessory::Exist(playerid, slotid))
    {
        DB_FreeResultSet(db_result);
        return 0;
    }

    new DBResult:db_result;

    Acessory::GetRow(playerid, slotid, db_result);

    acs::Player[playerid][slotid][acs::modelid] = DB_GetFieldIntByName(db_result, "modelid"); 
    acs::Player[playerid][slotid][acs::boneid]  = DB_GetFieldIntByName(db_result, "boneid"); 
    acs::Player[playerid][slotid][acs::pX]      = DB_GetFieldFloatByName(db_result, "pX"); 
    acs::Player[playerid][slotid][acs::pY]      = DB_GetFieldFloatByName(db_result, "pY"); 
    acs::Player[playerid][slotid][acs::pZ]      = DB_GetFieldFloatByName(db_result, "pZ"); 
    acs::Player[playerid][slotid][acs::rX]      = DB_GetFieldFloatByName(db_result, "rX"); 
    acs::Player[playerid][slotid][acs::rY]      = DB_GetFieldFloatByName(db_result, "rY"); 
    acs::Player[playerid][slotid][acs::rZ]      = DB_GetFieldFloatByName(db_result, "rZ"); 
    acs::Player[playerid][slotid][acs::sX]      = DB_GetFieldFloatByName(db_result, "sX"); 
    acs::Player[playerid][slotid][acs::sY]      = DB_GetFieldFloatByName(db_result, "sY"); 
    acs::Player[playerid][slotid][acs::sZ]      = DB_GetFieldFloatByName(db_result, "sZ"); 

    DB_FreeResultSet(db_result);
  
    return 1;
}

stock Acessory::LoadDataInt(playerid, slotid, const field[])
{
    new name[MAX_PLAYER_NAME], DBResult:db_result;

    GetPlayerName(playerid, name);

    if(!Acessory::GetRow(playerid, slotid, db_result))
    {
        DB_FreeResultSet(db_result);
        printf("[ DB (ERRO) ] Falha ao tentar carregar um valor int na table `player_acessorys` > %s, pois não existia\n", name);
        return 0;
    }

    new result = DB_GetFieldIntByName(db_result, field); 
    
    DB_FreeResultSet(db_result);

    return result;
} 
