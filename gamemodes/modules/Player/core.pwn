stock IsValidPlayer(playerid)
{
    if(playerid == INVALID_PLAYER_ID)return 0;

    return (IsPlayerConnected(playerid) && GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED));
}

stock Player::ClearData(playerid)
{
    Player[playerid][pyr::pass]          = '\0';
    Player[playerid][pyr::bitcoin]       = 0;
    Player[playerid][pyr::vipcoin]       = 0;
    Player[playerid][pyr::money]         = 0.0;
    Player[playerid][pyr::health]        = 0.0;
    Player[playerid][pyr::skinid]        = -1;
    Player[playerid][pyr::flags]         = 0;
    Player[playerid][pyr::score]         = 0;
    Player[playerid][pyr::regionid]      = INVALID_RECORD_ID;
    Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
    
    if(IsValidVehicle(Player[playerid][pyr::vehicleid]))
        Veh::Destroy(Player[playerid][pyr::vehicleid]);

    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::nametag]))
        DestroyDynamic3DTextLabel(Player[playerid][pyr::nametag]);    

    Player[playerid][pyr::nametag] = INVALID_3DTEXT_ID;
}

stock Player::Exists(const name[])
    return (DB::Exists(db_entity, "players", "name = '%q'", name));

stock Player::LoadData(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    DB::GetDataInt(db_entity, "players", "bitcoin", Player[playerid][pyr::bitcoin], "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);
    DB::GetDataInt(db_entity, "players", "skinid", Player[playerid][pyr::skinid], "name = '%q'", name);
    DB::GetDataInt(db_entity, "players", "score", Player[playerid][pyr::score], "name = '%q'", name);
    
    return 1;
}

stock Player::CreateTimer(playerid, E_PLAYER_TIMERS:pyr::timerid, const callback[] = "", time, bool:repeate, const specifiers[] = "", OPEN_MP_TAGS:...)
{
    if(IsValidTimer(KillTimer(pyr::Timer[playerid][pyr::timerid])))
        return printf("[ TIMER (Player) ] Erro ao tentar criar Timer #%d (%s [PID : %d]) %d pois já existia", _:pyr::timerid, callback, playerid, time);
    
    new timerid = SetTimerEx(callback, time, repeate, specifiers, ___(6));
    pyr::Timer[playerid][pyr::timerid] = timerid;
    
    printf("[ TIMER (Player) ] ( Timer ID: %d ) [ PLAYER_TIMER #%d ] (%s [PID : %d]) %d ms (%s) foi criado\n", timerid, _:pyr::timerid, callback, playerid, time, repeate ? "repeating" : "one shoot");

    return 1;
}

stock Player::KillTimer(playerid, E_PLAYER_TIMERS:pyr::timerid)
{
    if(!IsValidTimer(pyr::Timer[playerid][pyr::timerid])) return 0;
    
    switch(pyr::timerid)
    {
        case pyr::TIMER_PAYDAY:
        {   
            new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);

            t_left = t_left <= 0 ? 3600000 : t_left;
            printf("payday salvo %d", t_left);
            
            DB::SetDataInt(db_entity, "players", "payday_tleft", t_left, "name = '%q'", GetPlayerNameStr(playerid));      
        }

        case pyr::TIMER_JAIL:
        {
            new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);
            DB::SetDataInt(db_entity, "punishments", "left_tstamp", t_left, "name = '%q' AND level = 1", GetPlayerNameStr(playerid));
        }

        default:
        {
        }
    }

    new timerid = pyr::Timer[playerid][pyr::timerid];

    KillTimer(pyr::Timer[playerid][pyr::timerid]);

    pyr::Timer[playerid][pyr::timerid] = INVALID_TIMER;
    
    printf("[ TIMER (Player) ] ( Timer ID: %d ) [ PLAYER_TIMER #%d ] [PID : %d]) foi morto\n", timerid, _:pyr::timerid, playerid);
    
    return 1;
}

stock Player::RemoveMoney(playerid, Float:price, bool:takeout = true)
{
    if(floatcmp(Player[playerid][pyr::money], price) >= 0)
    {
        Player[playerid][pyr::money] = takeout ? Player[playerid][pyr::money] - price : Player[playerid][pyr::money];
        
        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name);

        DB::SetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);

        Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %2.f", Player[playerid][pyr::money]);

        PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);

        return 1;
    }

    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);

    return 0;
}

stock Player::GiveMoney(playerid, Float:price)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    Player[playerid][pyr::money] += price;
    
    DB::SetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);
    
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %.2f", Player[playerid][pyr::money]);
    
    SendClientMessage(playerid, -1, "{339933} [ R$ ] {ffffff}Voce recebeu {339933}%.2f {ffffff}R$\n", price);
    
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
    
    return 1;   
}

stock Player::SetNameTag(playerid)
{
    new str[64];
    format(str, 64, "{99ff99}%s {ffffff}[ {99ff99}%d {ffffff}]", GetPlayerNameStr(playerid), playerid);
    Player[playerid][pyr::nametag]  = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.0, 70.0, playerid, INVALID_VEHICLE_ID, 1);
}

stock Player::DestroyNameTag(playerid)
{
    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::nametag]))
        DestroyDynamic3DTextLabel(Player[playerid][pyr::nametag]);    

    Player[playerid][pyr::nametag] = INVALID_3DTEXT_ID;
}

stock Player::Spawn(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "players", "name = '%q'", name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ERRO FATAL ] {ffffff}Sua conta {ff3333}nao esta registrada {ffffff}houve um erro grave ao spawnar, avise um {ff3333}moderador!");
        Kick(playerid);
        printf("[ DB (ERRO) ] Erro ao tentar carregar posições de spawn do jogador!");
        return 0;
    }

    if(DB::Exists(db_entity, "members", "name = '%q'", GetPlayerNameStr(playerid)))
    {
        new orgid, flag;

        DB::GetDataInt(db_entity, "members", "orgid", orgid, "name = '%q'", GetPlayerNameStr(playerid));
        DB::GetDataInt(db_entity, "members", "flags", flag, "name = '%q'", GetPlayerNameStr(playerid));
        DB::GetDataInt(db_entity, "members", "skinid", org::Player[playerid][pyr::skinid], "name = '%q'", GetPlayerNameStr(playerid));
        
        if(GetFlag(flag, FLAG_PLAYER_ON_WORK))
        {
            SetSpawnInfo(playerid, 1, org::Player[playerid][pyr::skinid], 
            Org[orgid][org::sX] + RandomFloat(2.0), 
            Org[orgid][org::sY] + RandomFloat(2.0), 
            Org[orgid][org::sZ] + RandomFloat(2.0), 
            Org[orgid][org::sA], WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);

            SendClientMessage(playerid, -1, "{99ff99}[ ORG ] {ffffff}Você estava em {99ff99}modo de trabalho {ffffff}antes de sair!");
        }

        else
        {
            SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], 
            Org[orgid][org::sX] + RandomFloat(2.0), 
            Org[orgid][org::sY] + RandomFloat(2.0), 
            Org[orgid][org::sZ] + RandomFloat(2.0), 
            Org[orgid][org::sA], WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);
        }
    }

    else
        SetSpawnInfo(playerid, 1, Player[playerid][pyr::skinid], 834.28 + RandomFloat(2.0), -1834.89 + RandomFloat(2.0), 12.502, 180.0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);
    
    SpawnPlayer(playerid);

    return 1;
}
