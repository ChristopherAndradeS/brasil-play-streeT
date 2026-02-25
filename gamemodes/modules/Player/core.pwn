
/*                  PLAYER PUBLICS                 */
public Player::Kick(playerid, timerid, const msg[]) 
{    
    Player::KillTimer(playerid, timerid);
    
    if(IsPlayerConnected(playerid))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}%s", msg);
        Kick(playerid);
    }
    
    return 1; 
}

/*                  PLAYER FUNCS                 */
stock IsValidPlayer(playerid)
{
    if(playerid == INVALID_PLAYER_ID)return 0;

    return (IsPlayerConnected(playerid) && GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED));
}

stock Player::ClearAllData(playerid)
{
    Player::ClearData(playerid);
    lgn::ClearData(playerid);
    pdy::ClearData(playerid);
    acs::ClearData(playerid);
}

stock Player::ClearData(playerid)
{
    Player[playerid][pyr::pass]          = '\0';
    Player[playerid][pyr::bitcoin]       = 0;
    Player[playerid][pyr::money]         = 0.0;
    Player[playerid][pyr::flags]         = 0x00000000;
    Player[playerid][pyr::score]         = 0;
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

stock Player::CreateTimer(playerid, timerid, const callback[] = "", time, bool:repeate, const specifiers[] = "", OPEN_MP_TAGS:...)
{
    if(IsValidTimer(KillTimer(pyr::Timer[playerid][timerid])))
        return printf("[ TIMER Player ] Erro ao tentar criar Timer #%d (%s [PID : %d]) %d pois já existia", timerid, callback, playerid, time);
    
    pyr::Timer[playerid][timerid] = SetTimerEx(callback, time, repeate, specifiers, ___(6));
    
    //return printf("[ TIMER Player ] Timer #%d (%s [PID : %d]) %d foi criado\n", timerid, callback, playerid, time);

    return 1;
}

stock Player::KillTimer(playerid, timerid)
{
    if(!IsValidTimer(pyr::Timer[playerid][timerid])) 
        return 0;
    
    KillTimer(pyr::Timer[playerid][timerid]);

    pyr::Timer[playerid][timerid] = INVALID_TIMER;
    //printf("[ TIMER Player ] Timer #%d ([PID : %d]) foi morto\n", timerid, playerid);
    
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

stock Player::SetCPF(playerid)
{
    new str[64];
    format(str, 64, "{99ff99}%s {ffffff}[ {99ff99}%d {ffffff}]", GetPlayerNameStr(playerid), playerid);
    Player[playerid][pyr::cpf_tag]  = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.0, 70.0, playerid, INVALID_VEHICLE_ID, 1);
}

stock Player::UpdateDamage(playerid, issuerid, Float:damage, WEAPON:weaponid, bodypart)
{
    if(!IsValidPlayer(playerid) && !IsValidPlayer(issuerid)) return 1;

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH))  
    {
        GameTextForPlayer(issuerid, "~r~~h~OVERKILL", 1000, 4);
        return 1;
    }

    if(bodypart == 9)
    {
        GameTextForPlayer(issuerid, "~r~H~h~E~h~~h~A~g~~h~~h~D~g~~h~S~b~~h~~h~H~b~O~b~O~p~T", 1000, 4);
        PlayerPlaySound(issuerid, 1139);
    }

    Player[playerid][pyr::health] = floatclamp(Player[playerid][pyr::health] - damage, 1.0, 200.0);
    
    SetPlayerHealth(playerid, floatclamp(Player[playerid][pyr::health], 1.0, 100.0));
    SetPlayerArmour(playerid, Player[playerid][pyr::health] <= 100.0 ? 0.0 : Player[playerid][pyr::health] - 100.0);

    if(Player[playerid][pyr::health] <= 1.0)
    {   
        GameTextForPlayer(issuerid, "~h~MATOU", 500, 4);
        GameTextForPlayer(playerid, "~r~~h~MORREU", 500, 4);
        SetPlayerHealth(playerid, 1.0);
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_DEATH);
        CallLocalFunction("OnPlayerDied", "iii", playerid, issuerid, WEAPON:weaponid);
    }

    return 1;
}


stock Player::AplyRandomDeathAnim(playerid, &time)
{
    switch(RandomMax(100))
    {
        case 0..33:     ApplyAnimation(playerid, "CRACK", "crckdeth1", 4.1, false, false, false, false, 2170, SYNC_ALL), time = 2170; 
        case 34..66:    ApplyAnimation(playerid, "CRACK", "crckdeth3", 4.1, false, false, false, false, 2170, SYNC_ALL), time = 2170;
        case 67..100:   ApplyAnimation(playerid, "CRACK", "crckdeth4", 4.1, false, false, false, false, 2170, SYNC_ALL), time = 1670;
        default: time = 2000;
    }
}

stock Player::DestroyCpfTag(playerid)
{
    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]))
        DestroyDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]);    

    Player[playerid][pyr::cpf_tag] = INVALID_3DTEXT_ID;
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

        printf("%d", orgid);
        
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
