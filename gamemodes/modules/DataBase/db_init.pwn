#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    if (!fexist(DB_NAME))
    {
        printf("[ DATABASE ] Arquivo \"%s\" não encontrado, gerando tabelas...\n", DB_NAME);

        db_handle = DB_Open(DB_NAME);
        Player::CreateTable();
        Admin::CreateTable();
        Garage::CreateTable();
        Org::CreateTable();
        Officine::CreateTable();
        Dealership::CreateTable();
    }

    else db_handle = DB_Open(DB_NAME);
    
    return 1;
}

stock Database::GetRowCount(const table[], const uid_field[], const uid[], &DBResult:db_result)
{
    new query[128];

    format(query, sizeof(query), "SELECT * FROM `%q` WHERE `%q` = '%q' LIMIT 1", table, uid_field, uid);

    db_result = DB_ExecuteQuery(db_handle, query);

    new rows = DB_GetRowCount(db_result);
    
    DB_FreeResultSet(db_result);

    return rows;
}

stock Database::SaveDataInt(const table[], const field[], data, const uid_field[], const uid[])
{
    new query[128], DBResult:db_result;

    if(Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = %i WHERE `%q` = '%q';", 
        table, field, data, uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    print("[ DB (ERRO) ] Falha ao salvar valor int na table `%s` > %s, pois não existia\n", table, name);

    return 0;
}

stock Database::SaveDataFloat(const table[], const field[], Float:data, const uid_field[], const uid[])
{
    new query[256], DBResult:db_result;

    if(Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = %f WHERE `%q` = '%q';", 
        table, field, data, uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    print("[ DB (ERRO) ] Falha ao salvar valor float na table `%s` > %s, pois não existia\n", table, name);

    return 0;
}

stock Database::SaveDataString(const table[], const field[], const data[], const uid_field[], const uid[])
{
    new query[256], DBResult:db_result;

    if(Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);

        format(query, sizeof(query), "UPDATE `%q` SET `%q` = '%q' WHERE `%q` = '%q';", 
        table, field, data, uid_field, uid);

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

        return 1;
    }

    DB_FreeResultSet(db_result);

    print("[ DB (ERRO) ] Falha ao salvar string na table `%s` > %s, pois não existia\n", table, name);

    return 0;
}

stock Database::LoadDataInt(const table[], const uid_field[], const uid[], const field[])
{
    new DBResult:db_result;

    if(!Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        print("[ DB (ERRO) ] Falha ao tentar carregar um valor int na table `%s` > %s, pois não existia\n", table, name);
        return 0;
    }

    new result;
    result = DB_GetFieldIntByName(db_result, field); 
    DB_FreeResultSet(db_result);

    return result;
}

stock Float:Database::LoadDataFloat(const table[], const uid_field[], const uid[], const field[])
{
    new DBResult:db_result;

    if(!Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        print("[ DB (ERRO) ] Falha ao tentar carregar um valor float na table `%s` > %s, pois não existia\n", table, name);
        return 0;
    }

    new Float:result;
    result = DB_GetFieldFloatByName(db_result, field); 
    DB_FreeResultSet(db_result);

    return result;
}

stock Database::LoadDataString(const table[], const uid_field[], const uid[], const field[], data[], len = sizeof data)
{
    new DBResult:db_result;

    if(!Database::GetRowCount(table, uid_field, uid, db_result))
    {
        DB_FreeResultSet(db_result);
        print("[ DB (ERRO) ] Falha ao tentar carregar string na table `%s` > %s, pois não existia\n", table, name);
        return 0;
    }

    DB_GetFieldStringByName(db_result, field, data, len);
    DB_FreeResultSet(db_result);

    return 1;
}

stock Player::CreateTable()
{
    // PLAYERs

    DB_FreeResultSet(DB_ExecuteQuery(db_handle,
    "CREATE TABLE IF NOT EXISTS players (\
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

    printf("[ DATABASE ] Criando tabela 'players' no banco \"%s\"\n", DB_NAME); 
    
    // PLAYER -> PUNISHEDs 
    
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS player_punisheds (\
    name VARCHAR(24) NOT NULL UNIQUE,\
    ip VARCHAR(16),\
    punished_by VARCHAR(24),\
    level INTEGER,\
    reason VARCHAR(64),\
    left_tstamp INTEGER);" )); 
    
    printf("[ DATABASE ] Criando tabela 'player_punisheds' no banco \"%s\"\n", DB_NAME); 
    
    // PLAYER -> VEHICLEs 
    
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    
    "CREATE TABLE IF NOT EXISTS player_vehicles (\
    owner VARCHAR(24),\
    slotid INTEGER,\
    modelid INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT,\
    pA FLOAT,\
    color1 INTEGER,\
    color2 INTEGER);" )); 
    
    printf("[ DATABASE ] Criando tabela 'player_vehicles' no banco \"%s\"\n", DB_NAME); 
    
    // PLAYER -> ACESSORYs 
    
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS player_acessorys (\
    owner VARCHAR(24),\
    slotid INTEGER,\
    modelid INTEGER,\
    boneid INTEGER,\
    pX FLOAT, pY FLOAT, pZ FLOAT,\
    rX FLOAT, rY FLOAT, rZ FLOAT,\
    sX FLOAT, sY FLOAT, sZ FLOAT);" )); 
    
    printf("[ DATABASE ] Criando tabela 'player_acessorys' no banco \"%s\"\n", DB_NAME); 
} 

stock Admin::CreateTable() 
{
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, "CREATE TABLE IF NOT EXISTS admins (\
    name VARCHAR(24),\
    level INTEGER,\
    promoted_by VARCHAR(24),\
    promote_tstamp INTEGER DEFAULT 0);" )); 
    
    printf("[ DATABASE ] Criando tabela 'admins' no banco \"%s\"\n", DB_NAME); 
} 
stock Garage::CreateTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS garages (\
    created_by VARCHAR(24),\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);")); 
    
    printf("[ DATABASE ] Criando tabela 'garages' no banco \"%s\"\n", DB_NAME); 
} 

stock Org::CreateTable()
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS orgs (\
    name VARCHAR(24),\
    leader_name VARCHAR(24),\
    color INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" )); 
    
    printf("[ DATABASE ] Criando tabela 'orgs' no banco \"%s\"\n", DB_NAME); 
} 

stock Officine::CreateTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS officines (\
    type INTEGER,\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" ));
    printf("[ DATABASE ] Criando tabela 'officines' no banco \"%s\"\n", DB_NAME); 
} 

stock Dealership::CreateTable() 
{ 
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, 
    "CREATE TABLE IF NOT EXISTS dealerships (\
    pX FLOAT,\
    pY FLOAT,\
    pZ FLOAT);" )); 
    
    printf("[ DATABASE ] Criando tabela 'dealerships' no banco \"%s\"\n", DB_NAME); 
    
    DB_FreeResultSet(DB_ExecuteQuery(db_handle, "CREATE TABLE IF NOT EXISTS dealerships_vehicles (\
    modelid INTEGER,\
    name VARCHAR(16),\
    price INTEGER);" )); 
    
    printf("[ DATABASE ] Criando tabela 'dealerships_vehicles' no banco \"%s\"\n", DB_NAME); 
}