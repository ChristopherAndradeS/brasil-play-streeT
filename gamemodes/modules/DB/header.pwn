new DB:db_entity;
new DB:db_stock;

stock DB::CreateTable(DB:db, const table[], const definition[])
{
    new DBResult:result = DB_ExecuteQuery(db, "CREATE TABLE IF NOT EXISTS %q (%q);", table, definition);

    new name[16];
    DB::GetNameByID(db, name);

    if(!result)
    {
        printf("[ DB ] Erro: Ao criar tabela %s > %s\n", name, table);
        return 0;
    }

    DB_FreeResultSet(result);

    printf("[ DB ] Tabela %s > '%s' criada com sucesso\n", name, table);

    return 1;
}

stock DB::GetCount(DB:db, const table[], const field[], const where[], OPEN_MP_TAGS:...)
{
    new DBResult:result;

    if(isnull(where))
    {
        result = DB_ExecuteQuery(db, "SELECT %q FROM %q", field, table);
    }
    else
    {
        new str[128];
        va_format(str, 128, where, ___(4));
        result = DB_ExecuteQuery(db, "SELECT %q FROM %q WHERE %s;", field, table, str);
    }

    if(!result)
        return 0;
    
    new count = DB_GetRowCount(result);

    DB_FreeResultSet(result);

    return count;
}

stock DB::Exists(DB:db, const table[], const field[], const where[], OPEN_MP_TAGS:...)
    return (DB::GetCount(db, table, field, where, ___(4)) >= 1);

stock DB::Insert(DB:db, const table[], const fields[], const values[], OPEN_MP_TAGS:...)
{
    new str[512];
    va_format(str, 512, values, ___(4));
    new DBResult:result = DB_ExecuteQuery(db, "INSERT INTO %q (%q) VALUES(%s);", table, fields, str);

    new name[16];
    DB::GetNameByID(db, name);

    if(!result)
    {
        printf("[ DB ] Erro: Ao inserir dados query: INSERT INTO %q (%q) VALUES(%s);\n", table, fields, str);
        return 0;
    }

    printf("[ DB ] Elementos %s > %s > %s inseridos com sucesso\n", name, table, str);

    DB_FreeResultSet(result);

    return 1;
}

stock DB::Update(DB:db, const table[], const clause[], OPEN_MP_TAGS:...)
{
    new str[512];
    va_format(str, 512, clause, ___(3));
    new DBResult:result = DB_ExecuteQuery(db, "UPDATE %q SET %s;", table, clause);

    if(!result)
    {
        new name[16];
        DB::GetNameByID(db, name);
        printf("[ DB ] Erro: Ao atualizar dados %s > %s\n", name, table);
        return 0;
    }

    new affected = DB_GetRowCount(result);
    DB_FreeResultSet(result);

    return affected;
}

stock DB::Delete(DB:db, const table[], const where[], OPEN_MP_TAGS:...)
{
    if(isnull(where)) return 0;

    new str[128];
    va_format(str, 128, where, ___(3));
    new DBResult:result = DB_ExecuteQuery(db, "DELETE FROM %q WHERE %s;", table, str);

    new name[16];
    DB::GetNameByID(db, name);

    if(!result)
    {
        printf("[ DB ] Erro: Ao deletar %s > %s ONDE %s\n", name, table, str);
        return 0;
    }

    new affected = DB_GetRowCount(result);
    DB_FreeResultSet(result);

    printf("[ DB ] Elemento %s > %s removido da tabela com sucesso\n", name, str);

    return affected;
}

stock DB::GetDataInt(DB:db, const table[], const field[], &output, const where[], OPEN_MP_TAGS:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    new DBResult:result = DB_ExecuteQuery(db, "SELECT %q FROM %q WHERE %s LIMIT 1;", field, table, str);

    if(!result || !DB_GetRowCount(result))
    {
        if(result) DB_FreeResultSet(result);
        
        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao carregar dado 'int' %s > %s > %s\n", name, table, field);
        return 0;
    }

    output = DB_GetFieldInt(result);

    DB_FreeResultSet(result);

    return 1;
}

stock DB::GetDataFloat(DB:db, const table[], const field[], &Float:output, const where[], OPEN_MP_TAGS:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    new DBResult:result = DB_ExecuteQuery(db, "SELECT %q FROM %q WHERE %s;", field, table, str);

    if(!result || !DB_GetRowCount(result))
    {
        if(result) DB_FreeResultSet(result);

        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao carregar dado 'float' %s > %s > %s\n", name, table, field);
        return 0;
    }

    output = DB_GetFieldFloat(result);

    DB_FreeResultSet(result);

    return 1;
}

stock DB::GetDataString(DB:db, const table[], const field[], output[], len, const where[], OPEN_MP_TAGS:...)
{
    new str[128];
    va_format(str, 128, where, ___(6));
    new DBResult:result = DB_ExecuteQuery(db, "SELECT %q FROM %q WHERE %s;", field, table, str);

    if(!result || !DB_GetRowCount(result))
    {
        if(result) DB_FreeResultSet(result);
        
        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao carregar dado 'string' %s > %s > %s\n", name, table, field);
        return 0;
    }

    DB_GetFieldString(result, 0, output, len);

    DB_FreeResultSet(result);

    return 1;
}

stock DB::SetDataInt(DB:db, const table[], const field[], data, const where[], GLOBAL_TAG_TYPES:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    DB_FreeResultSet(DB_ExecuteQuery(db, "UPDATE %q SET %s = %i WHERE %s", table, field, data, str));

    return 1;
}

stock DB::SetDataFloat(DB:db, const table[], const field[], Float:data, const where[], GLOBAL_TAG_TYPES:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    DB_FreeResultSet(DB_ExecuteQuery(db, "UPDATE %q SET %s = %f WHERE %s", table, field, data, str));

    return 1;
}

stock DB::SetDataString(DB:db, const table[], const field[], const data[], const where[], GLOBAL_TAG_TYPES:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    DB_FreeResultSet(DB_ExecuteQuery(db, "UPDATE %q SET %s = '%s' WHERE %s", table, field, data, str));

    return 1;
}

stock DB::GetNameByID(DB:db, name[])
{
    if(db == db_entity)
        format(name, 16, "db_entity");
    else if(db_stock)
        format(name, 16, "db_stock");
    else
        format(name, 16, "db_invalid");
    return 1;
}