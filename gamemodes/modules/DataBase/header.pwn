#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    if(!fexist("entitys.db"))
    {
        printf("[ DATABASE ] Arquivo \"entitys.db\" não encontrado, gerando um novo...\n");

        db_entity = DB_Open("entitys.db");
        pyr::CreateEntityTable();
        //adm::CreateEntityTable();
        //grg::CreateEntityTable();
        //org::CreateEntityTable();
        //ofc::CreateEntityTable();
        //dsp::CreateEntityTable();
    }

    else db_entity = DB_Open("entitys.db");

    if(!fexist("stocks.db"))
    {
        printf("[ DATABASE ] Arquivo \"stocks.db\" não encontrado, gerando um novo...\n");

        db_stock = DB_Open("stocks.db");

        acs::CreateStockTable();
    }

    else db_stock = DB_Open("entitys.db");

    Acessory::InsertStock(11738, 5, 
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)), 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

    Acessory::InsertStock(18638, 2, 
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)), 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

    Acessory::InsertStock(19078, 3, 
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)),
    (RandomFloatMinMax(-0.5, 0.5)), 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);

    return 1;
}

stock DB::GetRowCount(DB:db, const table[], const uid_field[], const uid[], &DBResult:db_result = DBResult:0)
{
    new query[128];
    format(query, sizeof(query), "SELECT * FROM `%q` WHERE `%q` = '%q' LIMIT 1", table, uid_field, uid);
    db_result = DB_ExecuteQuery(db, query);
    return DB_GetRowCount(db_result);
}

stock DB::SaveDataInt(DB:db, const table[], const uid_field[], const uid[], const field[], data)
{
    new query[128], DBResult:db_result;

    if(DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = %i WHERE `%q` = '%q';", table, field, data, 
        uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    printf("[ DB ] ERRO ao salvar valor inteiro em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);

    return 0;
}

stock DB::SaveDataFloat(DB:db, const table[], const uid_field[], const uid[], const field[], Float:data)
{
    new query[256], DBResult:db_result;

    if(DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = %f WHERE `%q` = '%q';", 
        table, field, data, uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    printf("[ DB ] ERRO ao salvar valor float em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);

    return 0;
}

stock DB::SaveDataString(DB:db, const table[], const uid_field[], const uid[], const field[], const data[])
{
    new query[256], DBResult:db_result;

    if(DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = '%q' WHERE `%q` = '%q';", 
        table, field, data, uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    printf("[ DB ] ERRO ao salvar string em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);

    return 0;
}

stock DB::LoadDataInt(DB:db, const table[], const uid_field[], const uid[], const field[])
{
    new DBResult:db_result;

    if(!DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        printf("[ DB ] ERRO ao carregar valor inteiro em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);
        return 0;
    }

    new result;
    result = DB_GetFieldIntByName(db_result, field); 
    DB_FreeResultSet(db_result);

    return result;
}

stock Float:DB::LoadDataFloat(DB:db, const table[], const uid_field[], const uid[], const field[])
{
    new DBResult:db_result;

    if(!DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        printf("[ DB ] ERRO ao carregar valor float em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);
        return 0;
    }

    new Float:result;
    result = DB_GetFieldFloatByName(db_result, field); 
    DB_FreeResultSet(db_result);

    return result;
}

stock DB::LoadDataString(DB:db, const table[], const uid_field[], const uid[], const field[], data[], len = sizeof data)
{
    new DBResult:db_result;

    if(!DB::GetRowCount(db, table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        printf("[ DB ] ERRO ao carregar string em \"%s\" > `%s` > %s, pois não existia\n", db, table, uid);
        return 0;
    }

    DB_GetFieldStringByName(db_result, field, data, len);
    DB_FreeResultSet(db_result);

    return 1;
}

stock pyr::CreateEntityTable()
{
    DB_FreeResultSet(DB_ExecuteQuery(db_entity,
    "CREATE TABLE IF NOT EXISTS `players` (\
    uid INTEGER PRIMARY KEY AUTOINCREMENT,\
    name VARCHAR(24) NOT NULL UNIQUE,\
    pass VARCHAR(16) NOT NULL,\
    payday_tleft INTEGER,\
    bitcoin INTEGER,\
    money FLOAT,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT,\
    pA FLOAT,\
    score INTEGER,\
    skinid INTEGER,\
    orgid INTEGER);"));

    printf("[ DATABASE ] Tabela 'players' criada com sucesso\n"); 
}

stock pnh::CreateEntityTable()
{  
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `punishments` (\
    name VARCHAR(24) NOT NULL UNIQUE,\
    ip VARCHAR(16),\
    punished_by VARCHAR(24),\
    level INTEGER,\
    reason VARCHAR(64),\
    left_tstamp INTEGER);" )); 
    
    printf("[ DATABASE ] Tabela 'punishments' criada com sucesso\n");  
}

stock veh::CreateEntityTable()
{
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    
    "CREATE TABLE IF NOT EXISTS `vehicles` (\
    owner VARCHAR(24),\
    owner_type INTEGER, \
    slotid INTEGER,\
    modelid INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT,\
    pA FLOAT,\
    color1 INTEGER,\
    color2 INTEGER);" )); 
    
    printf("[ DATABASE ] Tabela 'vehicles' criada com sucesso\n");  
}

stock acs::CreateEntityTable()
{
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `acessorys` (\
    owner VARCHAR(24), \
    owner_type INTEGER, \
    slotid INTEGER,\
    modelid INTEGER,\
    boneid INTEGER,\
    pX FLOAT, pY FLOAT, pZ FLOAT,\
    rX FLOAT, rY FLOAT, rZ FLOAT,\
    sX FLOAT, sY FLOAT, sZ FLOAT);" )); 
    
    printf("[ DATABASE ] Tabela 'acessorys' criada com sucesso\n");  
} 

stock adm::CreateEntityTable() 
{
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, "CREATE TABLE IF NOT EXISTS `admins` (\
    name VARCHAR(24),\
    level INTEGER,\
    promoted_by VARCHAR(24),\
    promote_tstamp INTEGER DEFAULT 0);" )); 
    
    printf("[ DATABASE ] Tabela 'admins' criada com sucesso\n"); 
} 

stock grg::CreateEntityTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `garages` (\
    created_by VARCHAR(24),\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);")); 
    
    printf("[ DATABASE ] Tabela 'garages' criada com sucesso\n"); 
} 

stock org::CreateEntityTable()
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `orgs` (\
    name VARCHAR(24),\
    leader_name VARCHAR(24),\
    color INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" )); 
    
    printf("[ DATABASE ] Tabela 'orgs' criada com sucesso\n"); 
} 

stock ofc::CreateEntityTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `officines` (\
    type INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" ));

    printf("[ DATABASE ] Tabela 'officines' criada com sucesso\n"); 
} 

stock dsp::CreateEntityTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_entity, 
    "CREATE TABLE IF NOT EXISTS `dealerships` (\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" )); 
    
    printf("[ DATABASE ] Tabela 'dealerships' criada com sucesso\n");
}

stock dsp::CreateStockTable() 
{
    DB_FreeResultSet(DB_ExecuteQuery(db_stock, "CREATE TABLE IF NOT EXISTS `vehicles` (\
    modelid INTEGER,\
    name VARCHAR(16),\
    price INTEGER);" )); 
    
    printf("[ DATABASE ] Estoque 'vehicles' criada com sucesso\n");
}

stock acs::CreateStockTable() 
{
    DB_FreeResultSet(DB_ExecuteQuery(db_stock, 
    "CREATE TABLE IF NOT EXISTS `acessorys` (\
    uid NOT NULL UNIQUE,\
    modelid INTEGER,\
    boneid INTEGER,\
    pX FLOAT, pY FLOAT, pZ FLOAT,\
    rX FLOAT, rY FLOAT, rZ FLOAT,\
    sX FLOAT, sY FLOAT, sZ FLOAT);" ));
    
    printf("[ DATABASE ] Estoque 'acessorys' criada com sucesso\n");
}