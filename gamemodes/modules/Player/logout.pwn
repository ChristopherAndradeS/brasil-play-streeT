#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerDisconnect(playerid, reason)
{
    if(!Player::IsFlagSet(playerid, MASK_PLAYER_LOGGED))
        return 1;
        
    new Float:pX, Float:pY, Float:pZ, Float:pA, name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);
    Database::SaveDataFloat("players", "name", name, "pX", pX);
    Database::SaveDataFloat("players", "name", name, "pY", pY);
    Database::SaveDataFloat("players", "name", name, "pZ", pZ);
    Database::SaveDataFloat("players", "name", name, "pA", pA);

    if(IsValidTimer(pdy::Player[playerid][pdy::timerid]))
    {
        new left_time = GetTimerRemaining(pdy::Player[playerid][pdy::timerid]);
    
        Database::SaveDataInt("players", "name", name, "payday_tleft", left_time);
    
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