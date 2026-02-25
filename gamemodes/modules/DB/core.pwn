
stock DB::CreateTable(DB:db, const table[], const definition[])
{
    new DBResult:result = DB_ExecuteQuery(db, "CREATE TABLE IF NOT EXISTS %s (%s);", table, definition);

    new name[16];
    DB::GetNameByID(db, name);

    if(!result)
    {
        printf("[ DB ] Erro: Ao criar tabela %s > %s\n", name, table);
        return 0;
    }

    DB_FreeResultSet(result);

    printf("[ DB ] Tabela %s > %s criada/carregada com sucesso\n", name, table);

    return 1;
}

stock DB::GetCount(DB:db, const table[], const where[], OPEN_MP_TAGS:...)
{
    new DBResult:result;

    if(isnull(where))
        result = DB_ExecuteQuery(db, "SELECT COUNT(*) FROM %q", table);
    
    else
    {
        new str[128];
        va_format(str, 128, where, ___(3));
        result = DB_ExecuteQuery(db, "SELECT COUNT(*) FROM %q WHERE %s;", table, str);
    }

    if(!result)
    {
        new wher_str[128];
        va_format(wher_str, 128, where, ___(3));
        printf("[ ERRO ] DB::GetCount: SELECT COUNT(*) FROM %q WHERE %s;", table, wher_str);
        return 0;
    }

    new count = DB_GetFieldInt(result);
    
    DB_FreeResultSet(result);

    return count;
}

stock DB::Exists(DB:db, const table[], const where[] = "", OPEN_MP_TAGS:...)
    return (DB::GetCount(db, table, where, ___(3)) >= 1);

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

    printf("[ DB ] Elementos %q > %q > inseridos com sucesso\n", name, table);

    DB_FreeResultSet(result);

    return 1;
}

stock DB::Update(DB:db, const table[], const clause[], OPEN_MP_TAGS:...)
{
    new str[512];
    va_format(str, 512, clause, ___(3));
    new DBResult:result = DB_ExecuteQuery(db, "UPDATE %q SET %s;", table, str);

    new name[16];
    DB::GetNameByID(db, name);

    if(!result)
    {
        printf("[ DB ] Erro: Ao atualizar dados. query: %q > %q\n", "UPDATE %q SET %s;", name, table, table, str);
        return 0;
    }

    new affected = DB_GetRowCount(result);

    printf("[ DB ] Elementos %q > %q > atualizados com sucesso\n", name, table);
    
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
        printf("[ DB ] Erro: Ao deletar %q > %q ONDE %s\n", name, table, str);
        return 0;
    }

    DB_FreeResultSet(result);

    printf("[ DB ] Elemento %q > %q removido da tabela com sucesso\n", name, table);

    return 1;
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

        printf("[ DB ] Erro: Ao carregar dado 'int' %q > %q > %q\n", name, table, field);
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

        printf("[ DB ] Erro: Ao carregar dado 'float' %q > %q > %q\n", name, table, field);
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

        printf("[ DB ] Erro: Ao carregar dado 'string' %q > %q > %q\n", name, table, field);
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

    new DBResult:result = DB_ExecuteQuery(db, "UPDATE %q SET %s = %i WHERE %s;", table, field, data, str);

    if(!result)
    {
        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao setar valor 'int' %q > %q ONDE %s\n", name, table, str);
        return 0;
    }
    
    DB_FreeResultSet(result);

    return 1;
}

stock DB::SetDataFloat(DB:db, const table[], const field[], Float:data, const where[], GLOBAL_TAG_TYPES:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
        
    new DBResult:result = DB_ExecuteQuery(db, "UPDATE %q SET %s = %f WHERE %s;", table, field, data, str);

    if(!result)
    {
        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao setar valor 'float' %q > %q ONDE %s\n", name, table, str);
        return 0;
    }

    DB_FreeResultSet(result);

    return 1;
}

stock DB::SetDataString(DB:db, const table[], const field[], const data[], const where[], GLOBAL_TAG_TYPES:...)
{
    new str[128];
    va_format(str, 128, where, ___(5));
    
    new DBResult:result = DB_ExecuteQuery(db, "UPDATE %q SET %s = '%q' WHERE %s;", table, field, data, str);

    if(!result)
    {
        new name[16];
        DB::GetNameByID(db, name);

        printf("[ DB ] Erro: Ao setar valor 'string' %q > %q ONDE %s\n", name, table, str);
        return 0;
    }

    DB_FreeResultSet(result);

    return 1;
}

stock DB::GetNameByID(DB:db, name[])
{
    if(db == db_entity) return format(name, 16, "db_entity");
    if(db == db_stock)  return format(name, 16, "db_stock");
    else                return format(name, 16, "db_invalid");
}
