#include <YSI\YSI_Coding\y_hooks>

stock Acessory::GetStockCount()
{
    new query[128], count, DBResult:db_result;

    format(query, sizeof(query), "SELECT * FROM `acessorys`");

    db_result = DB_ExecuteQuery(db_stock, query);
        
    count = DB_GetRowCount(db_result);

    DB_FreeResultSet(db_result); 

    return count;
}

stock Acessory::InsertStock(GLOBAL_TAG_TYPES:...)
{
    new query[512];

    va_format(query, sizeof(query), "INSERT INTO `acessorys` (\
    uid, modelid, boneid, \
    pX, pY, pZ, \
    rX, rY, rZ, \
    sX, sY, sZ) \
    VALUES(%i, %i, '%i', %f, %f, %f, %f, %f, %f, %f, %f, %f);", Acessory::GetStockCount() + 1, ___(0));

    DB_FreeResultSet(DB_ExecuteQuery(db_stock, query));

    printf("[ DB ESTOQUE (ACESSORY) ] Acessório adicionado do banco de estoque\n"); 

    return 1;         
}

stock Acessory::DeletetStock(acessoryid)
{
    new query[128];

    va_format(query, sizeof(query), "DELETE FROM `acessorys` WHERE `uid` = %i", acessoryid);

    DB_FreeResultSet(DB_ExecuteQuery(db_stock, query));

    printf("[ DB ESTOQUE (ACESSORY) ] Acessório removido do banco de estoque\n"); 

    return 1;         
}