#include <YSI\YSI_Coding\y_hooks>

#define PAYMENT_BASE (1000.0)

enum E_PLAYER_PAYDAY
{
    pdy::bonus,
    pdy::time_left, 
}

new pdy::Player[MAX_PLAYERS][E_PLAYER_PAYDAY];

forward OnPayDayReach(playerid);

hook OnPlayerLogin(playerid)
{
    DB::GetDataInt(db_entity, "players", "payday_tleft", pdy::Player[playerid][pdy::time_left], "name = '%q'", GetPlayerNameStr(playerid));

    new time_left = pdy::Player[playerid][pdy::time_left];
    Player::CreateTimer(playerid, pyr::TIMER_PAYDAY, "OnPayDayReach", time_left, false, "i", playerid);

    return 1;
}

public OnPayDayReach(playerid)
{
    if(!IsValidPlayer(playerid))
        return 1;
    
    new Float:payment = PAYMENT_BASE, Float:bonus, Float:total;

    Payday::GetPlayerBonus(playerid, bonus);

    total = payment + bonus;

    SendClientMessage(playerid, -1, "{33ff33}|__________________ PAYDAY BPS __________________|");
    SendClientMessage(playerid, -1, "Você recebeu seu pagamento por jogar 1 hora!");
    SendClientMessage(playerid, -1, "{33ff33}Salário Fixo: {ffffff}R$ %.2f | {33ff33}Bonus Org/Admin: {ffffff}R$ %.2f", payment, bonus);
    SendClientMessage(playerid, -1, "{00FF00}TOTAL RECEBIDO: R$ %.2f  |  +1 RESPECT (Nivel)", total);
    SendClientMessage(playerid, -1, "{33ff33}|________________________________________________|");
            
    Player::GiveMoney(playerid, total);

    Player[playerid][pyr::score]++;

    DB::SetDataInt(db_entity, "players", "score", Player[playerid][pyr::score], "name = '%q'", GetPlayerNameStr(playerid));

    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_LVL, "L: %d", Player[playerid][pyr::score]);
    
    new timerid = pyr::Timer[playerid][pyr::TIMER_PAYDAY];

    if(GetTimerInterval(timerid) == 3600000 && IsRepeatingTimer(timerid))
        return 1;

    Player::KillTimer(playerid, pyr::TIMER_PAYDAY);
    Player::CreateTimer(playerid, pyr::TIMER_PAYDAY, "OnPayDayReach", 3600000, true, "i", playerid);
    
    return 1; 
}

stock Payday::GetPlayerBonus(playerid, &Float:bonus)
{
    bonus = 0;

    // if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_ORG))
    //     bonus += 1200.0;
    if(GetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN))
        bonus += 250.0;

    return 1;
}

stock pdy::ClearData(playerid)
{
    pdy::Player[playerid][pdy::bonus]       = 0;
    pdy::Player[playerid][pdy::time_left]   = 0;
}
