#include <YSI\YSI_Coding\y_hooks>

#define PAYMENT_BASE (1500.0)

forward OnPayDayReach(playerid);

hook OnPlayerLogin(playerid)
{
    new time_left = Player[playerid][pyr::payday_tleft];

    pdy::Player[playerid][pdy::timerid] = SetTimerEx("OnPayDayReach", time_left, false, "i", playerid);
    
    return 1;
}

stock Payday::GetPlayerBonus(playerid, &Float:bonus)
{
    bonus = 0;

    if(Player::IsFlagSet(playerid, MASK_PLAYER_IN_ORG))
        bonus += 1200.0;
    if(Player::IsFlagSet(playerid, MASK_PLAYER_IS_ADM))
        bonus += 500.0;

    return 1;
}

public OnPayDayReach(playerid)
{
    if(!IsValidPlayer(playerid))
    {
        printf("INVALIDO");
        return 1;
    }

    new Float:payment = PAYMENT_BASE, Float:bonus, Float:total;

    Payday::GetPlayerBonus(playerid, bonus);

    total = payment + bonus;

    SendClientMessage(playerid, COLOR_THEME_BPS, "|__________________ PAYDAY BPS __________________|");
    SendClientMessage(playerid, -1, "Você recebeu seu pagamento por jogar 1 hora!");
    SendClientMessage(playerid, -1, "{33ff33}Salário Fixo: {ffffff}R$ %.2f | {33ff33}Bonus Org/Admin: {ffffff}R$ %.2f", payment, bonus);
    SendClientMessage(playerid, -1, "{00FF00}TOTAL RECEBIDO: R$ %.2f  |  +1 RESPECT (Nivel)", total);
    SendClientMessage(playerid, COLOR_THEME_BPS, "|________________________________________________|");
            
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

    Player[playerid][pyr::money] += total;

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    Database::SaveDataFloat("players", "name", name, "money", total);

    KillTimer(pdy::Player[playerid][pdy::timerid]);
    pdy::Player[playerid][pdy::timerid] = SetTimerEx("OnPayDayReach", 60 * 60 * 1000, false, "i", playerid);
    
    Player[playerid][pyr::payday_tleft] = 60 * 60 * 1000;

    return 1; 
}