stock Punish::InsertData(playerid, GLOBAL_TAG_TYPES:...)
{
    new name[MAX_PLAYER_NAME], query[256], DBResult:db_result;

    GetPlayerName(playerid, name);

    if(!Database::GetRowCountByName(name, db_result))
    {
        DB_FreeResultSet(db_result);

        va_format(query, sizeof(query), "INSERT INTO `player_punisheds` (\
        name, ip, punished_by, level, reason, left_tstamp) \
        VALUES('%q', '%q', '%q', %i, '%q', %i);",
        name, ___(1));

        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));

         printf("[ DB (BANIDOS) ] Jogador %s, adicionado à tabela de banidos\n", name);
        return 1;
    }

    DB_FreeResultSet(db_result);
    return 0;
}

stock Player::VerifyPunish(const name[], ip[16], reason[64], admin[24], &level, &left_time, &is_pardon)
{
    new query[256], DBResult:db_result;

    format(query, sizeof(query), "SELECT * FROM `player_punisheds` WHERE `name` = '%q' LIMIT 1", name);

    db_result = DB_ExecuteQuery(db_handle, query);

    if(!DB_GetRowCount(db_result))
    {
        DB_FreeResultSet(db_result);
        return 0;
    }

    DB_GetFieldStringByName(db_result, "ip", ip);
    DB_GetFieldStringByName(db_result, "reason", reason);
    DB_GetFieldStringByName(db_result, "punished_by", admin);
    level      = DB_GetFieldIntByName(db_result, "level"); 
    left_time  = DB_GetFieldIntByName(db_result, "left_tstamp");
    is_pardon  = 0;

    DB_FreeResultSet(db_result);

    if(left_time == -1)
        return 1;
        
    if(gettime() > left_time)
    {
        format(query, sizeof(query), "DELETE FROM `player_punisheds` WHERE `name` = '%q'", name);
        DB_FreeResultSet(DB_ExecuteQuery(db_handle, query));
        is_pardon = 1;
        printf("[ DB (BANIDOS) ] O jogador %s foi removido da lista de banidos, banimento expirou!", name);
        return 1;
    }

    return 1;
}