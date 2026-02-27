#define PAYMENT_BASE (1000.0)

enum E_PLAYER_PAYDAY
{
    pdy::bonus,
    pdy::time_left, 
}

new pdy::Player[MAX_PLAYERS][E_PLAYER_PAYDAY];

forward OnPayDayReach(playerid);

stock Payday::GetPlayerBonus(playerid, &Float:bonus)
{
    bonus = 0;

    if(org::Player[playerid][pyr::orgid] != INVALID_ORG_ID)
        bonus += 250.0;
    if(GetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN))
        bonus += 350.0;

    return 1;
}

stock pdy::ClearData(playerid)
{
    pdy::Player[playerid][pdy::bonus]       = 0;
    pdy::Player[playerid][pdy::time_left]   = 0;
}
