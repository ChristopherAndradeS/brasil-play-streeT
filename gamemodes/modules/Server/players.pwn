#include <YSI\YSI_Coding\y_hooks>

hook OnServerUpdateSeconds()
{
    TextDrawSetString(Baseboard::PublicTD[TD_BASEBOARD_CLOCK], "%02d:%02d:%02d~n~~g~~h~~h~%s - %02d_de_%s_de_%04d", 
    Server[srv::hour], Server[srv::minute], Server[srv::seconds],
    gWeekDays[Server[srv::weekday]], Server[srv::day], gMonths[Server[srv::month]], Server[srv::year]);

    Server::UpdatePlayerSeconds();
}

stock Server::UpdatePlayerSeconds()
{
    foreach (new i : Player)
    {
        Player::UpdatePayday(i);
        Player::UpdateJail(i);

        if(GetFlag(Player[i][pyr::flags], FLAG_PLAYER_IN_PVP))
            SetPlayerTime(i, 12, 0);
        else
            SetPlayerTime(i, Server[srv::hour], Server[srv::minute]);
    }

    foreach(new i : Adm_Iter)
    {
        Adm::Update(i);
    }
}

stock Player::UpdatePayday(playerid)
{
    if(IsValidTimer(pyr::Timer[playerid][pyr::TIMER_PAYDAY]) && Baseboard::IsVisibleTDForPlayer(playerid))
    {
        new left_time = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);
    
        if(Baseboard::IsVisibleTDForPlayer(playerid))
        Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_PAYDAY, 
        "~b~~h~~h~PAYDAY~w~ %02d~b~~h~~h~:~w~%02d", 
        floatround((left_time / 60000)), floatround((left_time % 60000) / 1000));
    }
}

stock Player::UpdateJail(playerid)
{
    if(IsValidTimer(pyr::Timer[playerid][pyr::TIMER_JAIL]))
    {
        new left_time = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_JAIL]);

        GameTextForPlayer(playerid, "~r~~h~CADEIA: ~w~%02d~r~:~w~%02d", left_time <= 10000 ? 500 : 1000, 4,
        floatround((left_time / 60000)), floatround((left_time % 60000) / 1000));
    }
}

stock Adm::Update(playerid)
{
    if(!Adm::IsVisibleTDForPlayer(playerid)) return;

    if(Adm::IsSpectating(playerid) && Admin[playerid][adm::spectateid] != INVALID_PLAYER_ID) 
    {
        if(!list_valid(gAdminSpectates)) return;
        Adm::UpdateTextDraw(playerid, Admin[playerid][adm::spectateid]);
    }
}