#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerDisconnect(playerid, reason)
{
    if(!Player::IsFlagSet(playerid, MASK_PLAYER_LOGGED))
        return 1;
        
    new Float:pX, Float:pY, Float:pZ, Float:pA;
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);

    Player::SaveFloatData(playerid, "pX", pX);
    Player::SaveFloatData(playerid, "pY", pY);
    Player::SaveFloatData(playerid, "pZ", pZ);
    Player::SaveFloatData(playerid, "pA", pA);

    if(IsValidTimer(pdy::Player[playerid][pdy::timerid]))
    {
        new left_time = GetTimerRemaining(pdy::Player[playerid][pdy::timerid]);
        printf("tempo que falta: %d", left_time);

        Player::SaveIntData(playerid, "payday_tleft", left_time);
    
        KillTimer(pdy::Player[playerid][pdy::timerid]);
    }

    if(IsValidTimer(lgn::Player[playerid][lgn::timerid]))
    {
        KillTimer(lgn::Player[playerid][lgn::timerid]);
        lgn::Player[playerid][lgn::timerid] = INVALID_TIMER; 
    }

    Player::ClearData(playerid);

    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]))
    {
        DestroyDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]);
        Player[playerid][pyr::cpf_tag] = INVALID_3DTEXT_ID;
    }

    return 1;
}