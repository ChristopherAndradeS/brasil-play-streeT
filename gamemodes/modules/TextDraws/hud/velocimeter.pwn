stock Veh::UpdatePTDBar(playerid, textid, Float:barsize, Float:percent)
{
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][textid], barsize * (percent / 100.0), 5.5);
	PlayerTextDrawShow(playerid, Veh::PlayerTD[playerid][textid]); 
}

stock Veh::UpdateTextDrawColor(playerid, textid, color)
{
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][textid], color);
	PlayerTextDrawShow(playerid, Veh::PlayerTD[playerid][textid]); 
    return 1;
}

stock Veh::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Veh::PlayerTD[playerid][textid], text, ___(3));
}

stock Veh::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Veh::PublicTD[0]));

stock Veh::ShowTDForPlayer(playerid)
{
	if(Veh::IsVisibleTDForPlayer(playerid)) return;
	
	Veh::CreatePlayerTD(playerid);
	
	for(new i = 0; i < 11; i++)
        TextDrawShowForPlayer(playerid, Veh::PublicTD[i]);
    for(new i = 0; i < 18; i++)
        PlayerTextDrawShow(playerid, Veh::PlayerTD[playerid][i]);  
    
    new vehicleid = GetPlayerVehicleID(playerid), vehname[64];
    GetVehicleNameByModel(GetVehicleModel(vehicleid), vehname);
    Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_SPEED, "0");
    Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_NAME, "Veiculo: ~g~~h~~h~%s", vehname);
	Veh::UpdatePTDBar(playerid, PTD_VEH_BAR_FUEL, 100.0, 100.0);
}

stock Veh::HideTDForPlayer(playerid)
{
	for(new i = 0; i < 11; i++)
        TextDrawHideForPlayer(playerid, Veh::PublicTD[i]);   
    for(new i = 0; i < 18; i++)
        PlayerTextDrawHide(playerid, Veh::PlayerTD[playerid][i]); 

	Veh::DestroyPlayerTD(playerid);
}

stock Veh::DestroyPublicTD()
{
    for(new i = 0; i < 11; i++)
	{
    	TextDrawDestroy(playerid, Veh::PublicTD[i]);
		Veh::PublicTD[i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Veh::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 18; i++)
	{
        PlayerTextDrawDestroy(playerid, Veh::PlayerTD[playerid][i]);
		Veh::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Veh::CreatePublicTD()
{
	Veh::PublicTD[0] = TextDrawCreate(215.000000, 385.000000, "ld_dual:white");
	TextDrawFont(Veh::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[0], 210.000000, 59.000000);
	TextDrawSetOutline(Veh::PublicTD[0], true);
	TextDrawSetShadow(Veh::PublicTD[0], false);
	TextDrawAlignment(Veh::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[0], 216);
	TextDrawBackgroundColour(Veh::PublicTD[0], 255);
	TextDrawBoxColour(Veh::PublicTD[0], 50);
	TextDrawUseBox(Veh::PublicTD[0], true);
	TextDrawSetProportional(Veh::PublicTD[0], true);
	TextDrawSetSelectable(Veh::PublicTD[0], false);

	Veh::PublicTD[1] = TextDrawCreate(215.000000, 381.000000, "ld_dual:white");
	TextDrawFont(Veh::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[1], 210.000000, 4.500000);
	TextDrawSetOutline(Veh::PublicTD[1], true);
	TextDrawSetShadow(Veh::PublicTD[1], false);
	TextDrawAlignment(Veh::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[1], 9109759);
	TextDrawBackgroundColour(Veh::PublicTD[1], 255);
	TextDrawBoxColour(Veh::PublicTD[1], 50);
	TextDrawUseBox(Veh::PublicTD[1], true);
	TextDrawSetProportional(Veh::PublicTD[1], true);
	TextDrawSetSelectable(Veh::PublicTD[1], false);

	Veh::PublicTD[2] = TextDrawCreate(215.000000, 444.000000, "");//"ld_dual:white");
	TextDrawFont(Veh::PublicTD[2], TEXT_DRAW_FONT:1);
	TextDrawLetterSize(Veh::PublicTD[2], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[2], 210.000000, 4.000000);
	TextDrawSetOutline(Veh::PublicTD[2], true);
	TextDrawSetShadow(Veh::PublicTD[2], false);
	TextDrawAlignment(Veh::PublicTD[2], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[2], 9109759);
	TextDrawBackgroundColour(Veh::PublicTD[2], 255);
	TextDrawBoxColour(Veh::PublicTD[2], 50);
	TextDrawUseBox(Veh::PublicTD[2], true);
	TextDrawSetProportional(Veh::PublicTD[2], true);
	TextDrawSetSelectable(Veh::PublicTD[2], false);

	Veh::PublicTD[3] = TextDrawCreate(427.000000, 395.000000, "");//"ld_beat:right");
	TextDrawFont(Veh::PublicTD[3], TEXT_DRAW_FONT:1);
	TextDrawLetterSize(Veh::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[3], 40.000000, 40.000000);
	TextDrawSetOutline(Veh::PublicTD[3], true);
	TextDrawSetShadow(Veh::PublicTD[3], false);
	TextDrawAlignment(Veh::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[3], -1);
	TextDrawBackgroundColour(Veh::PublicTD[3], 255);
	TextDrawBoxColour(Veh::PublicTD[3], 50);
	TextDrawUseBox(Veh::PublicTD[3], true);
	TextDrawSetProportional(Veh::PublicTD[3], true);
	TextDrawSetSelectable(Veh::PublicTD[3], true);

	Veh::PublicTD[4] = TextDrawCreate(290.000000, 430.000000, "ld_dual:white");
	TextDrawFont(Veh::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[4], 100.000000, 5.500000);
	TextDrawSetOutline(Veh::PublicTD[4], true);
	TextDrawSetShadow(Veh::PublicTD[4], false);
	TextDrawAlignment(Veh::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[4], 1296911832);
	TextDrawBackgroundColour(Veh::PublicTD[4], 255);
	TextDrawBoxColour(Veh::PublicTD[4], 50);
	TextDrawUseBox(Veh::PublicTD[4], true);
	TextDrawSetProportional(Veh::PublicTD[4], true);
	TextDrawSetSelectable(Veh::PublicTD[4], false);

	Veh::PublicTD[5] = TextDrawCreate(290.000000, 417.500000, "ld_dual:white");
	TextDrawFont(Veh::PublicTD[5],TEXT_DRAW_FONT: 4);
	TextDrawLetterSize(Veh::PublicTD[5], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[5], 100.000000, 5.500000);
	TextDrawSetOutline(Veh::PublicTD[5], true);
	TextDrawSetShadow(Veh::PublicTD[5], false);
	TextDrawAlignment(Veh::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[5], 859019775);
	TextDrawBackgroundColour(Veh::PublicTD[5], 255);
	TextDrawBoxColour(Veh::PublicTD[5], 50);
	TextDrawUseBox(Veh::PublicTD[5], true);
	TextDrawSetProportional(Veh::PublicTD[5], true);
	TextDrawSetSelectable(Veh::PublicTD[5], false);

	Veh::PublicTD[6] = TextDrawCreate(290.000000, 405.000000, "ld_dual:white");
	TextDrawFont(Veh::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[6], 100.000000, 5.500000);
	TextDrawSetOutline(Veh::PublicTD[6], true);
	TextDrawSetShadow(Veh::PublicTD[6], false);
	TextDrawAlignment(Veh::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[6], 861221887);
	TextDrawBackgroundColour(Veh::PublicTD[6], 255);
	TextDrawBoxColour(Veh::PublicTD[6], 50);
	TextDrawUseBox(Veh::PublicTD[6], true);
	TextDrawSetProportional(Veh::PublicTD[6], true);
	TextDrawSetSelectable(Veh::PublicTD[6], false);

	Veh::PublicTD[7] = TextDrawCreate(275.000000, 402.000000, "HUD:radar_modgarage");
	TextDrawFont(Veh::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[7], 10.000000, 10.000000);
	TextDrawSetOutline(Veh::PublicTD[7], true);
	TextDrawSetShadow(Veh::PublicTD[7], false);
	TextDrawAlignment(Veh::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[7], -1);
	TextDrawBackgroundColour(Veh::PublicTD[7], 255);
	TextDrawBoxColour(Veh::PublicTD[7], 50);
	TextDrawUseBox(Veh::PublicTD[7], true);
	TextDrawSetProportional(Veh::PublicTD[7], true);
	TextDrawSetSelectable(Veh::PublicTD[7], false);

	Veh::PublicTD[8] = TextDrawCreate(275.000000, 414.500000, "HUD:radar_centre");
	TextDrawFont(Veh::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[8], 10.000000, 10.000000);
	TextDrawSetOutline(Veh::PublicTD[8], true);
	TextDrawSetShadow(Veh::PublicTD[8], false);
	TextDrawAlignment(Veh::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[8], -764862721);
	TextDrawBackgroundColour(Veh::PublicTD[8], 255);
	TextDrawBoxColour(Veh::PublicTD[8], 50);
	TextDrawUseBox(Veh::PublicTD[8], true);
	TextDrawSetProportional(Veh::PublicTD[8], true);
	TextDrawSetSelectable(Veh::PublicTD[8], false);

	Veh::PublicTD[9] = TextDrawCreate(275.000000, 427.000000, "HUD:radar_gym");
	TextDrawFont(Veh::PublicTD[9], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Veh::PublicTD[9], 0.600000, 2.000000);
	TextDrawTextSize(Veh::PublicTD[9], 10.000000, 10.000000);
	TextDrawSetOutline(Veh::PublicTD[9], true);
	TextDrawSetShadow(Veh::PublicTD[9], false);
	TextDrawAlignment(Veh::PublicTD[9], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Veh::PublicTD[9], -1);
	TextDrawBackgroundColour(Veh::PublicTD[9], 255);
	TextDrawBoxColour(Veh::PublicTD[9], 50);
	TextDrawUseBox(Veh::PublicTD[9], true);
	TextDrawSetProportional(Veh::PublicTD[9], true);
	TextDrawSetSelectable(Veh::PublicTD[9], false);

	Veh::PublicTD[10] = TextDrawCreate(231.000000, 422.500000, "KM/H");
	TextDrawFont(Veh::PublicTD[10], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Veh::PublicTD[10], 0.150000, 0.899999);
	TextDrawTextSize(Veh::PublicTD[10], 400.000000, 17.000000);
	TextDrawSetOutline(Veh::PublicTD[10], false);
	TextDrawSetShadow(Veh::PublicTD[10], false);
	TextDrawAlignment(Veh::PublicTD[10], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Veh::PublicTD[10], -1);
	TextDrawBackgroundColour(Veh::PublicTD[10], 255);
	TextDrawBoxColour(Veh::PublicTD[10], 50);
	TextDrawUseBox(Veh::PublicTD[10], false);
	TextDrawSetProportional(Veh::PublicTD[10], true);
	TextDrawSetSelectable(Veh::PublicTD[10], false);
}

stock Veh::CreatePlayerTD(playerid)
{
	Veh::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 290.000000, 417.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][0], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][0], 75.000000, 5.500000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][0], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][0], -1717960705);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][0], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][0], false);

	Veh::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 245.000000, 407.500000, "999");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][1], 0.250000, 1.500000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][1], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][1], false);

	Veh::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 290.000000, 405.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][2], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][2], 75.000000, 5.500000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][2], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][2], 16711896);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][2], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][2], false);

	Veh::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 290.000000, 430.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][3], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][3], 61.500000, 5.500000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][3], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][3], -1);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][3], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][3], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][3], false);

	Veh::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 220.000000, 410.000000, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][4], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][4], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][4], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][4], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][4], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][4], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][4], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][4], false);

	Veh::PlayerTD[playerid][5] = CreatePlayerTextDraw(playerid, 221.522399, 402.346313, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][5], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][5], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][5], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][5], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][5], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][5], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][5], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][5], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][5], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][5], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][5], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][5], false);

	Veh::PlayerTD[playerid][6] = CreatePlayerTextDraw(playerid, 225.857894, 395.857910, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][6], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][6], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][6], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][6], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][6], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][6], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][6], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][6], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][6], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][6], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][6], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][6], false);

	Veh::PlayerTD[playerid][7] = CreatePlayerTextDraw(playerid, 232.346298, 391.522399, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][7], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][7], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][7], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][7], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][7], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][7], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][7], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][7], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][7], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][7], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][7], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][7], false);

	Veh::PlayerTD[playerid][8] = CreatePlayerTextDraw(playerid, 240.000000, 390.000000, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][8], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][8], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][8], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][8], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][8], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][8], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][8], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][8], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][8], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][8], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][8], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][8], false);

	Veh::PlayerTD[playerid][9] = CreatePlayerTextDraw(playerid, 247.653701, 391.522399, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][9], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][9], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][9], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][9], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][9], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][9], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][9], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][9], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][9], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][9], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][9], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][9], false);

	Veh::PlayerTD[playerid][10] = CreatePlayerTextDraw(playerid, 254.142105, 395.857910, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][10], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][10], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][10], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][10], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][10], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][10], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][10], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][10], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][10], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][10], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][10], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][10], false);

	Veh::PlayerTD[playerid][11] = CreatePlayerTextDraw(playerid, 258.477600, 402.346313, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][11], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][11], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][11], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][11], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][11], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][11], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][11], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][11], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][11], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][11], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][11], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][11], false);

	Veh::PlayerTD[playerid][12] = CreatePlayerTextDraw(playerid, 260.000000, 410.000000, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][12], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][12], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][12], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][12], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][12], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][12], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][12], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][12], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][12], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][12], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][12], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][12], false);

	Veh::PlayerTD[playerid][13] = CreatePlayerTextDraw(playerid, 258.477600, 417.653686, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][13], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][13], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][13], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][13], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][13], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][13], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][13], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][13], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][13], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][13], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][13], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][13], false);

	Veh::PlayerTD[playerid][14] = CreatePlayerTextDraw(playerid, 254.142105, 424.142089, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][14], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][14], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][14], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][14], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][14], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][14], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][14], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][14], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][14], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][14], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][14], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][14], false);

	Veh::PlayerTD[playerid][15] = CreatePlayerTextDraw(playerid, 247.653701, 428.477600, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][15], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][15], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][15], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][15], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][15], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][15], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][15], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][15], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][15], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][15], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][15], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][15], false);

	Veh::PlayerTD[playerid][16] = CreatePlayerTextDraw(playerid, 240.000000, 430.000000, "ld_beat:chit");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][16], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][16], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][16], 10.000000, 10.000000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][16], true);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][16], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][16], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][16], 255);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][16], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][16], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][16], true);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][16], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][16], false);

	Veh::PlayerTD[playerid][17] = CreatePlayerTextDraw(playerid, 343.000000, 387.500000, "<VEHICLE_NAME>");
	PlayerTextDrawFont(playerid, Veh::PlayerTD[playerid][17], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Veh::PlayerTD[playerid][17], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Veh::PlayerTD[playerid][17], 400.000000, 145.500000);
	PlayerTextDrawSetOutline(playerid, Veh::PlayerTD[playerid][17], false);
	PlayerTextDrawSetShadow(playerid, Veh::PlayerTD[playerid][17], false);
	PlayerTextDrawAlignment(playerid, Veh::PlayerTD[playerid][17], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Veh::PlayerTD[playerid][17], -1);
	PlayerTextDrawBackgroundColour(playerid, Veh::PlayerTD[playerid][17], 255);
	PlayerTextDrawBoxColour(playerid, Veh::PlayerTD[playerid][17], 50);
	PlayerTextDrawUseBox(playerid, Veh::PlayerTD[playerid][17], false);
	PlayerTextDrawSetProportional(playerid, Veh::PlayerTD[playerid][17], true);
	PlayerTextDrawSetSelectable(playerid, Veh::PlayerTD[playerid][17], false);
}