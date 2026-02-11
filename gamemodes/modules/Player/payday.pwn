#include <YSI\YSI_Coding\y_hooks>

#define PAYMENT_BASE (1500.0)

forward OnPayDayReach(playerid);

hook OnPlayerLogin(playerid)
{
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

    SendClientMessage(playerid, COLOR_THEME_BPS, "|__________________ PAYDAY BPS __________________|");
    SendClientMessage(playerid, -1, "Você recebeu seu pagamento por jogar 1 hora!");
    SendClientMessage(playerid, -1, "{33ff33}Salário Fixo: {ffffff}R$ %.2f | {33ff33}Bonus Org/Admin: {ffffff}R$ %.2f", payment, bonus);
    SendClientMessage(playerid, -1, "{00FF00}TOTAL RECEBIDO: R$ %.2f  |  +1 RESPECT (Nivel)", total);
    SendClientMessage(playerid, COLOR_THEME_BPS, "|________________________________________________|");
            
    Player::GiveMoney(playerid, total);

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

    // if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_ORG))
    //     bonus += 1200.0;
    if(IsFlagSet(Admin[playerid][adm::flags], FLAG_IS_ADMIN))
        bonus += 500.0;

    return 1;
}
