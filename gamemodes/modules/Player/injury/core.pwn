forward OnPlayerReviveFinished(playerid, targetid);

stock Player::UpdateDamage(playerid, issuerid, Float:damage, WEAPON:weaponid, bodypart)
{
    if(!IsValidPlayer(issuerid)) return 1;

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
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
        SetPlayerInjury(playerid, issuerid, WEAPON:weaponid);
    }

    return 1;
}

stock Player::CanStartResuscitation(playerid, targetid, bool:notify = true)
{
    if(!IsValidPlayer(playerid) || !IsValidPlayer(targetid)) return 0;

    if(playerid == targetid)
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}Você não pode se reviver.");
        return 0;
    }

    if(!GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED))
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}Esse jogador não está ferido.");
        return 0;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED))
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}Você está ferido e não pode reavivar alguém.");
        return 0;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION))
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}Você já está em um reavivamento.");
        return 0;
    }

    if(GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION))
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}Esse jogador já está sendo reanimado.");
        return 0;
    }

    new tick = Player[targetid][pyr::death_tick] - GetTickCount();
    if(tick <= 9000)
    {
        if(notify)
            SendClientMessage(playerid, -1, "{ff5533}[ SOCORRO ] {ffffff}O serviço de emergencia já está chegando, não é possível revive-lo");
        return 0;
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

stock Player::AplyRandomInjuryAnim(playerid, &time)
{
    switch(RandomMax(100))
    {
        case 0..33:     ApplyAnimation(playerid, "ped", "KO_skid_front", 4.1, false, false, false, false, 1930, SYNC_ALL), time = 1930;
        case 34..66:    ApplyAnimation(playerid, "ped", "KO_shot_face", 4.1, false, false, false, false, 2100, SYNC_ALL), time = 2100;
        case 67..100:   ApplyAnimation(playerid, "ped", "KO_shot_stom", 4.1, false, false, false, false, 3170, SYNC_ALL), time = 3170;
    }
}

stock SetPlayerInjury(playerid, killerid, WEAPON:reason)
{
    #pragma unused reason
    
    if(!IsValidPlayer(playerid) && !IsValidPlayer(killerid)) return 1;

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))return 1;

    TogglePlayerControllable(playerid, false);

    ClearAnimations(playerid, SYNC_ALL);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_OTHER);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_ALL);

    new time_sos = floatround(GetPlayerDistanceFromPoint(playerid, 1182.2079, -1323.2695, 13.5798) / 0.012);
    
    Player[playerid][pyr::death_tick] = GetTickCount() + time_sos;

    Player::CreateTimer(playerid, pyr::TIMER_INJURY, "OnPlayerInjury", 1000, true, "i", playerid);

    return 1;
}

stock Player::StartResuscitation(playerid, targetid)
{
    if(!Player::CanStartResuscitation(playerid, targetid)) return 0;

    new Float:tX, Float:tY, Float:tZ, Float:tA;
    GetPlayerPos(targetid, tX, tY, tZ);
    GetPlayerFacingAngle(targetid, tA);

    new Float:revive_x = tX - 0.28894;
    new Float:revive_y = tY - 0.017823;
    new Float:revive_z = 13.332237;
    new Float:revive_a = tA - (-160.970307);

    SetPlayerPos(targetid, tX, tY, revive_z);
    SetPlayerPos(playerid, revive_x, revive_y, revive_z);

    SetPlayerFacingAngle(playerid, revive_a);

    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
    SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

    Player[playerid][pyr::resuscitation_targetid] = targetid;
    Player[targetid][pyr::resuscitation_targetid] = playerid;

    TogglePlayerControllable(playerid, false);
    TogglePlayerControllable(targetid, false);

    ClearAnimations(playerid, SYNC_ALL);
    ClearAnimations(targetid, SYNC_ALL);

    ApplyAnimation(targetid, "CRACK", "crckidle4", 4.1, true, false, false, false, 0, SYNC_ALL);
    ApplyAnimation(playerid, "MEDIC", "CPR", 4.1, true, false, false, false, 8330, SYNC_ALL);

    SendClientMessage(playerid, -1, "{33ff99}[ SOCORRO ] {ffffff}Você iniciou o reavivamento.");
    SendClientMessage(targetid, -1, "{33ff99}[ SOCORRO ] {ffffff}Você está sendo reanimado.");

    Player::CreateTimer(playerid, pyr::TIMER_RESUSCITATION, "OnPlayerReviveFinished", 8330, false, "ii", playerid, targetid);

    return 1;
}

stock Player::HandleResuscitationAction(playerid)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 0;
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED)) return 0;
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION)) return 0;

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    new near_players[MAX_PLAYERS];
    for(new i = 0; i < MAX_PLAYERS; i++)
        near_players[i] = INVALID_PLAYER_ID;

    Player::GetPlayersFlaggedInRange(pX, pY, pZ, FLAG_PLAYER_INJURED, 2.25, near_players);

    new targetid = near_players[0];

    if(targetid == INVALID_PLAYER_ID) return 0;

    if(targetid == playerid)
    {
        for(new i = 1; i < MAX_PLAYERS; i++)
        {
            if(near_players[i] != INVALID_PLAYER_ID)
            {
                targetid = near_players[i];
                break;
            }
        }
    }

    if(targetid == INVALID_PLAYER_ID || targetid == playerid) return 0;

    return Player::StartResuscitation(playerid, targetid);
}
