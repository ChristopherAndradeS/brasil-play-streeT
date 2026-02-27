stock Travel::UpdateTextDrawColor(playerid, Float:pX, Float:pY, Float:pZ, Float:pA, interiorid = 0, worldid = 0)
{
    new transparency = -256, tick = GetTickCount() + 6000;

    inline update()
    {
        if(tick <= GetTickCount())
        {
            Travel::HideTDForPlayer(playerid);
            Timer_KillCallback(pyr::Timer[playerid][pyr::TIMER_TRAVEL]);
            print("timer morto!!!!");
            pyr::Timer[playerid][pyr::TIMER_TRAVEL] = 0;
            TogglePlayerSpectating(playerid, false);

            SetPlayerPos(playerid, pX, pY, pZ);
            SetPlayerFacingAngle(playerid, pA);
            SetCameraBehindPlayer(playerid);
            SetPlayerInterior(playerid, interiorid);
            SetPlayerVirtualWorld(playerid, worldid);
            TogglePlayerControllable(playerid, true);
            ClearAnimations(playerid, SYNC_ALL);
            return 1;
        }

        if(transparency >= -1)
        {
            TogglePlayerSpectating(playerid, true);
            PlayerTextDrawColour(playerid, Travel::PlayerTD[playerid][0], -1);
            PlayerTextDrawShow(playerid, Travel::PlayerTD[playerid][0]); 
            PlayerTextDrawShow(playerid, Travel::PlayerTD[playerid][1]); 
        }

        else
        {
            PlayerTextDrawColour(playerid, Travel::PlayerTD[playerid][0], transparency);
            PlayerTextDrawShow(playerid, Travel::PlayerTD[playerid][0]);  
            PlayerTextDrawShow(playerid, Travel::PlayerTD[playerid][1]); 
            transparency += 8;
        }
    }

    pyr::Timer[playerid][pyr::TIMER_TRAVEL] = Timer_CreateCallback(using inline update, 32, 188);

    return 1;
}

stock Travel::IsVisibleTDForPlayer(playerid)
	return (IsPlayerTextDrawVisible(playerid, Travel::PlayerTD[playerid][0]));

stock Travel::ShowTDForPlayer(playerid, const text[], Float:pX, Float:pY, Float:pZ, Float:pA, interiorid = 0, worldid = 0)
{
	if(Travel::IsVisibleTDForPlayer(playerid)) return;
	
	Travel::CreatePlayerTD(playerid);

    PlayerTextDrawShow(playerid, Travel::PlayerTD[playerid][1]);  
    PlayerTextDrawSetString(playerid, Travel::PlayerTD[playerid][1], text);

    Travel::UpdateTextDrawColor(playerid, pX, pY, pZ, pA, interiorid, worldid);
}

stock Travel::HideTDForPlayer(playerid)
{
	if(!Travel::IsVisibleTDForPlayer(playerid)) return;

    PlayerTextDrawHide(playerid, Travel::PlayerTD[playerid][1]); 
    PlayerTextDrawHide(playerid, Travel::PlayerTD[playerid][0]);

	Travel::DestroyPlayerTD(playerid);
}

stock Travel::DestroyPlayerTD(playerid)
{
    PlayerTextDrawDestroy(playerid, Travel::PlayerTD[playerid][1]);
    PlayerTextDrawDestroy(playerid, Travel::PlayerTD[playerid][0]);
	Travel::PlayerTD[playerid][1] = INVALID_PLAYER_TEXT_DRAW;
    Travel::PlayerTD[playerid][0] = INVALID_PLAYER_TEXT_DRAW;
}

stock Travel::CreatePlayerTD(playerid)
{
	Travel::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "ld_dual:black");
	PlayerTextDrawFont(playerid, Travel::PlayerTD[playerid][0], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Travel::PlayerTD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Travel::PlayerTD[playerid][0], 645.000000, 455.000000);
	PlayerTextDrawSetOutline(playerid, Travel::PlayerTD[playerid][0], true);
	PlayerTextDrawSetShadow(playerid, Travel::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Travel::PlayerTD[playerid][0],  TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Travel::PlayerTD[playerid][0], -1);
	PlayerTextDrawBackgroundColour(playerid, Travel::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Travel::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Travel::PlayerTD[playerid][0], true);
	PlayerTextDrawSetProportional(playerid, Travel::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Travel::PlayerTD[playerid][0], false);

	Travel::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 320.000000, 200.000000, "");
	PlayerTextDrawFont(playerid, Travel::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Travel::PlayerTD[playerid][1], 0.349999, 2.099999);
	PlayerTextDrawTextSize(playerid, Travel::PlayerTD[playerid][1], 400.000000, 491.000000);
	PlayerTextDrawSetOutline(playerid, Travel::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Travel::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Travel::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Travel::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Travel::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Travel::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Travel::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Travel::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Travel::PlayerTD[playerid][1], false);
}
