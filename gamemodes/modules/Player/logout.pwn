#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerDisconnect(playerid, reason)
{
    if(!Player::IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
        return 1;
        
    new Float:pX, Float:pY, Float:pZ, Float:pA, name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);
    DB::SaveDataFloat(db_entity, "players", "name", name, "pX", pX);
    DB::SaveDataFloat(db_entity, "players", "name", name, "pY", pY);
    DB::SaveDataFloat(db_entity, "players", "name", name, "pZ", pZ);
    DB::SaveDataFloat(db_entity, "players", "name", name, "pA", pA);

    for(new i = 0; i < E_PLAYER_TIMERS; i++)
    {
        if(!IsValidTimer(pyr::Timer[playerid][i]))
            continue;

        if(pyr::Timer[playerid][i] == pyr::Timer[playerid][pyr::TIMER_PAYDAY])
        {
            new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);
            DB::SaveDataInt(db_entity, "players", "name", name, "payday_tleft", t_left);
        }

        KillTimer(pyr::Timer[playerid][i]);
        pyr::Timer[playerid][i] = INVALID_TIMER;
    }

    Player::ClearData(playerid);

    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]))
    {
        DestroyDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]);
        Player[playerid][pyr::cpf_tag] = INVALID_3DTEXT_ID;
    }

    return 1;
}