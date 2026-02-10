new const Float:gJailBounds[4] = { 845.668, -3326.000, 1066.149, -3094.155 };

forward OnJailFinish(playerid);

public OnJailFinish(playerid)
{       
    GameTextForPlayer(playerid, "~r~~h~CADEIA ACABOU :)", 1000, 4);
    Punish::UnsetJail(playerid);      
    Player::KillTimer(playerid, pyr::TIMER_JAIL); 
    return 1;
}

stock Punish::VerifyPlayer(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    if(DB::Exists(db_entity, "punishments", "name", "name = '%q' AND level = 2", name))
    {
        new left_time;

        DB::GetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = '%q' AND level = 2", name);

        if(left_time <= gettime())
        {
            SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");

            DB::Delete(db_entity, "punishments", "name = '%q' AND level = 2", name);

            return 1;
        }

        new ip[16], reason[64], admin_name[MAX_PLAYER_NAME], date[16], level;

        DB::GetDataString(db_entity, "punishments", "name", ip, 16, "name = '%q' AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "reason", reason, 64, "name = '%q' AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "punished_by", admin_name, 24, "name = '%q' AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "date", date, 16, "name = '%q' AND level = 2", name);
        DB::GetDataInt(db_entity, "punishments", "level", level, "name = '%q' AND level = 2", name);

        new str[512], time_str[64];
        
        format(time_str, 64, "%s {ffffff}(%d dias)", date, floatround((left_time - gettime()) / 86400));
     
        format(str, sizeof(str), "{ff3333}Você foi banido!\n\n\
        {ffffff}Indentificamos uma atividade suspeita neste usuario e aplicamos um banimento!\n\n\
        Admin:     \t{ff3333}%s\n\
        {ffffff}Punição:   \t{ff3333}Banimento\n\
        {ffffff}Motivo:    \t{ff3333}%s{ffffff}\n\
        {ffffff}Expira em: \t{ff3333}%s\n\n\
        {ffffff}Você pode abrir uma revisão de BAN no nosso {7289da}discord:\n{ffffff}Link: {7289da}" DISCORD_LINK, 
        admin_name, reason, time_str);
        
        inline dialog(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, sresponse, slistitem, stext
            return 0;
        }

        Dialog_ShowCallback(playerid, using inline dialog, DIALOG_STYLE_MSGBOX, "{ffffff}BPS {ff3333}| {ffffff}Punições", str, "Fechar", "");
        
        return 0;
    }

    else if(DB::Exists(db_entity, "punishments", "name", "name = '%q' AND level = 1", name))
    {
        new left_time;

        DB::GetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = '%q' AND level = 1", name);

        if(left_time <= 0)
        {
            SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}da sua prisão na ilha deserta.");
            SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Esperamos {33ff33}bom \
            {ffffff}comportamento de agora em diante!");

            DB::Delete(db_entity, "punishments", "name = '%q' AND level = 1", name);

            printf("[ ILHA ] O jogador %s foi perdoado da cadeia staff", name);

            ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL);
        }

        else
        {
            SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL);
        }
    }

    return 1;
}

stock Punish::SendPlayerToJail(playerid, time)
{
    new skinid;
    DB::GetDataInt(db_entity, "players", "skinid", skinid, "name = '%q'", GetPlayerNameEx(playerid));
    
    SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_JAIL);
    
    SetSpawnInfo(playerid, NO_TEAM, skinid, 
    969.973876 + RandomFloatMinMax(-2.0, 2.0), -3210.220458 + RandomFloatMinMax(-2.0, 2.0), 13.347578, RandomFloat(360.0), 
    WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);

    SpawnPlayer(playerid);
    
    Player::CreateTimer(playerid, pyr::TIMER_JAIL, "OnJailFinish", time, false, "i", playerid);

    SetPlayerWeather(playerid, Server[srv::j_weatherid]);

    return 1;
}

stock Punish::SetJail(const name[], const admin[], const reason[], time)
{
    if(!DB::Exists(db_entity, "players", "name", "name = '%q'", name)) return 0;
    
    if(DB::Exists(db_entity, "punishments", "name, level", "name = '%q' AND level = 1", name))
    {
        new t_left;

        DB::GetDataInt(db_entity, "punishments", "left_tstamp", t_left, "name = '%q' AND level = 1", name);

        DB::Update(db_entity, "punishments", 
        "punished_by = '%q', reason = '%q', left_tstamp = %d WHERE name = '%q' AND level = 1",
        admin, reason, time, name);

        if(t_left < time)
            printf("[ PUNICOES ] O admin %s aumentou o tempo de cadeia de %s. Motivo: %s | Tempo: %i min(s)", 
            admin, name, reason, time / 60000);
        else if(t_left > time)
            printf("[ PUNICOES ] O admin %s diminuiu o tempo de cadeia de %s. Motivo: %s | Tempo: %i min(s)", 
            admin, name, reason, time / 60000);
        else
        {
            new old_reason[64];
            DB::GetDataString(db_entity, "punishments", "reason", old_reason, 64, "name = '%q' AND level = 1", name);

            printf("[ PUNICOES ] O admin %s atualizou o motivo de cadeia de %s. Motivo Antigo: %s | Motivo Novo %s", 
            admin, name, old_reason, reason);
        }
        
        return -1;
    }

    else
    {
        DB::Insert(db_entity, "punishments", "name, ip, punished_by, level, reason, left_tstamp", 
        "'%q', '%q', '%q', %i, '%q', %i", name, "NO_IP", admin, 1, reason, time);

        printf("[ PUNICOES ] O admin %s prendou %s. Motivo: %s | Tempo: %i min(s)", 
        admin, name, reason, time / 60000);
    }
    
    return 1;
}

stock Punish::UnsetJail(playerid)
{
    if(!IsValidPlayer(playerid)) return 0;

    if(!DB::Delete(db_entity, "punishments", "name = '%q' AND level = 1", GetPlayerNameEx(playerid)))
    {
        printf("[ DB (ERRO) ] Erro ao remover cadeia de %s", GetPlayerNameEx(playerid));
        return -1;
    }

    SendClientMessage(playerid, -1, "{ff3399}[ ILHA ] {ffffff}Você foi {ff3399}libertado \
    {ffffff}da ilha deserta. Esperamos {ff3399}bom {ffffff}comportamento de agora em diante!");

    SendClientMessage(playerid, -1, "{33ff33}[ KICK ] {ffffff}Precisamos que você faça login novamente para voltar como jogador!");
    
    Kick(playerid);

    printf("[ ILHA ] O jogador %s foi perdoado da cadeia staff", GetPlayerNameEx(playerid));

    return 1;
}

stock Punish::UpdatePlayerJail(playerid, time)
{
    if(!IsValidPlayer(playerid)) return 0;

    if(IsValidTimer(pyr::Timer[playerid][pyr::TIMER_JAIL]))
    {
        new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);
        Player::KillTimer(playerid, pyr::TIMER_JAIL);
        Player::CreateTimer(playerid, pyr::TIMER_JAIL, "OnJailFinish", time, false, "i", playerid);
        
        if(t_left > time)
            SendClientMessage(playerid, -1, 
            "{ff3399}[ ILHA ] {ffffff}Seu tempo de prisão diminiu {ff3399}%i {ffffff}minutos", (t_left - time)/60000);
        else
            SendClientMessage(playerid, -1, 
            "{ff3399}[ ILHA ] {ffffff}Seu tempo de prisão aumentou {ff3399}%i {ffffff}minutos", (time - t_left)/60000);
    }

    printf("[ CADEIA ] Erro: O código não poderia ter acançado essa parte!");
    
    return 1;
}