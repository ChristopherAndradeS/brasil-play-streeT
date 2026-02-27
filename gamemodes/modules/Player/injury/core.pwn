
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
        CallLocalFunction("OnPlayerInjury", "iii", playerid, issuerid, WEAPON:weaponid);
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