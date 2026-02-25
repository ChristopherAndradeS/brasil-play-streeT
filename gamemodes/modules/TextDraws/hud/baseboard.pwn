stock Baseboard::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	if(!Baseboard::IsVisibleTDForPlayer(playerid)) return;
	PlayerTextDrawSetString(playerid, Baseboard::PlayerTD[playerid][textid], text, ___(3));
}

stock Baseboard::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Baseboard::PublicTD[0]));

stock Baseboard::ShowTDForPlayer(playerid)
{
	if(Baseboard::IsVisibleTDForPlayer(playerid)) return;

	Baseboard::CreatePlayerTD(playerid);
	
	for(new i = 0; i < 13; i++)
        TextDrawShowForPlayer(playerid, Baseboard::PublicTD[i]);
    for(new i = 0; i < 5; i++)
        PlayerTextDrawShow(playerid, Baseboard::PlayerTD[playerid][i]);  
	
	Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_CPF, "CPF: %d", playerid);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %.2f", Player[playerid][pyr::money]);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_LVL, "L: %d", Player[playerid][pyr::score]);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_BITCOIN, "~y~B$: %d", Player[playerid][pyr::bitcoin]);
}

stock Baseboard::HideTDForPlayer(playerid)
{
	for(new i = 0; i < 13; i++)
        TextDrawHideForPlayer(playerid, Baseboard::PublicTD[i]);   
    for(new i = 0; i < 5; i++)
        PlayerTextDrawHide(playerid, Baseboard::PlayerTD[playerid][i]); 

	Baseboard::DestroyPlayerTD(playerid);
}

stock Baseboard::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 5; i++)
	{
        PlayerTextDrawDestroy(playerid, Baseboard::PlayerTD[playerid][i]);
		Baseboard::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Baseboard::DestroyPublicTD()
{
    for(new i = 0; i < 13; i++)
	{
    	TextDrawDestroy(Baseboard::PublicTD[i]);
		Baseboard::PublicTD[i] = INVALID_TEXT_DRAW;
	}
}

stock Baseboard::CreatePublicTD()
{
	Baseboard::PublicTD[0] = TextDrawCreate(341.000000, 415.500000, "ld_beat:chit");
	TextDrawFont(Baseboard::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[0], 33.000000, 33.000000);
	TextDrawSetOutline(Baseboard::PublicTD[0], true);
	TextDrawSetShadow(Baseboard::PublicTD[0], false);
	TextDrawAlignment(Baseboard::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[0], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[0], 255);
	TextDrawBoxColour(Baseboard::PublicTD[0], 50);
	TextDrawUseBox(Baseboard::PublicTD[0], true);
	TextDrawSetProportional(Baseboard::PublicTD[0], true);
	TextDrawSetSelectable(Baseboard::PublicTD[0], false);

	Baseboard::PublicTD[1] = TextDrawCreate(265.000000, 415.500000, "ld_beat:chit");
	TextDrawFont(Baseboard::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[1], 33.000000, 33.000000);
	TextDrawSetOutline(Baseboard::PublicTD[1], true);
	TextDrawSetShadow(Baseboard::PublicTD[1], false);
	TextDrawAlignment(Baseboard::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[1], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[1], 255);
	TextDrawBoxColour(Baseboard::PublicTD[1], 50);
	TextDrawUseBox(Baseboard::PublicTD[1], true);
	TextDrawSetProportional(Baseboard::PublicTD[1], true);
	TextDrawSetSelectable(Baseboard::PublicTD[1], false);

	Baseboard::PublicTD[2] = TextDrawCreate(0.000000, 430.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[2], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[2], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[2], 640.000000, 18.000000);
	TextDrawSetOutline(Baseboard::PublicTD[2], true);
	TextDrawSetShadow(Baseboard::PublicTD[2], false);
	TextDrawAlignment(Baseboard::PublicTD[2], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[2], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[2], 255);
	TextDrawBoxColour(Baseboard::PublicTD[2], 50);
	TextDrawUseBox(Baseboard::PublicTD[2], true);
	TextDrawSetProportional(Baseboard::PublicTD[2], true);
	TextDrawSetSelectable(Baseboard::PublicTD[2], false);

	Baseboard::PublicTD[3] = TextDrawCreate(0.000000, 433.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[3], 640.000000, 18.000000);
	TextDrawSetOutline(Baseboard::PublicTD[3], true);
	TextDrawSetShadow(Baseboard::PublicTD[3], false);
	TextDrawAlignment(Baseboard::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[3], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[3], 255);
	TextDrawBoxColour(Baseboard::PublicTD[3], 50);
	TextDrawUseBox(Baseboard::PublicTD[3], true);
	TextDrawSetProportional(Baseboard::PublicTD[3], true);
	TextDrawSetSelectable(Baseboard::PublicTD[3], false);

	Baseboard::PublicTD[4] = TextDrawCreate(550.000000, 434.000000, "DOMINGO   -   00:00:00~n~1 de janeiro de 1970");
	TextDrawFont(Baseboard::PublicTD[4], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[4], 0.187500, 0.750000);
	TextDrawTextSize(Baseboard::PublicTD[4], 400.000000, 170.500000);
	TextDrawSetOutline(Baseboard::PublicTD[4], false);
	TextDrawSetShadow(Baseboard::PublicTD[4], false);
	TextDrawAlignment(Baseboard::PublicTD[4], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[4], 1157580031);
	TextDrawBackgroundColour(Baseboard::PublicTD[4], 255);
	TextDrawBoxColour(Baseboard::PublicTD[4], 50);
	TextDrawUseBox(Baseboard::PublicTD[4], false);
	TextDrawSetProportional(Baseboard::PublicTD[4], true);
	TextDrawSetSelectable(Baseboard::PublicTD[4], false);

	Baseboard::PublicTD[5] = TextDrawCreate(280.000000, 420.950012, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[5], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[5], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[5], 80.000000, 19.500000);
	TextDrawSetOutline(Baseboard::PublicTD[5], true);
	TextDrawSetShadow(Baseboard::PublicTD[5], false);
	TextDrawAlignment(Baseboard::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[5], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[5], 255);
	TextDrawBoxColour(Baseboard::PublicTD[5], 50);
	TextDrawUseBox(Baseboard::PublicTD[5], true);
	TextDrawSetProportional(Baseboard::PublicTD[5], true);
	TextDrawSetSelectable(Baseboard::PublicTD[5], false);

	Baseboard::PublicTD[6] = TextDrawCreate(267.000000, 418.500000, "ld_beat:chit");
	TextDrawFont(Baseboard::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[6], 33.000000, 33.000000);
	TextDrawSetOutline(Baseboard::PublicTD[6], true);
	TextDrawSetShadow(Baseboard::PublicTD[6], false);
	TextDrawAlignment(Baseboard::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[6], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[6], 255);
	TextDrawBoxColour(Baseboard::PublicTD[6], 50);
	TextDrawUseBox(Baseboard::PublicTD[6], true);
	TextDrawSetProportional(Baseboard::PublicTD[6], true);
	TextDrawSetSelectable(Baseboard::PublicTD[6], false);

	Baseboard::PublicTD[7] = TextDrawCreate(283.000000, 424.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[7], 74.000000, 19.500000);
	TextDrawSetOutline(Baseboard::PublicTD[7], true);
	TextDrawSetShadow(Baseboard::PublicTD[7], false);
	TextDrawAlignment(Baseboard::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[7], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[7], 255);
	TextDrawBoxColour(Baseboard::PublicTD[7], 50);
	TextDrawUseBox(Baseboard::PublicTD[7], true);
	TextDrawSetProportional(Baseboard::PublicTD[7], true);
	TextDrawSetSelectable(Baseboard::PublicTD[7], false);

	Baseboard::PublicTD[8] = TextDrawCreate(339.000000, 418.500000, "ld_beat:chit");
	TextDrawFont(Baseboard::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[8], 33.000000, 33.000000);
	TextDrawSetOutline(Baseboard::PublicTD[8], true);
	TextDrawSetShadow(Baseboard::PublicTD[8], false);
	TextDrawAlignment(Baseboard::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[8], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[8], 255);
	TextDrawBoxColour(Baseboard::PublicTD[8], 50);
	TextDrawUseBox(Baseboard::PublicTD[8], true);
	TextDrawSetProportional(Baseboard::PublicTD[8], true);
	TextDrawSetSelectable(Baseboard::PublicTD[8], false);

	Baseboard::PublicTD[9] = TextDrawCreate(320.000000, 426.000000, "BRASIL PLAY");
	TextDrawFont(Baseboard::PublicTD[9], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[9], 0.250000, 1.000000);
	TextDrawTextSize(Baseboard::PublicTD[9], 400.000000, 121.000000);
	TextDrawSetOutline(Baseboard::PublicTD[9], false);
	TextDrawSetShadow(Baseboard::PublicTD[9], false);
	TextDrawAlignment(Baseboard::PublicTD[9], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[9], -1);
	TextDrawBackgroundColour(Baseboard::PublicTD[9], 255);
	TextDrawBoxColour(Baseboard::PublicTD[9], 50);
	TextDrawUseBox(Baseboard::PublicTD[9], false);
	TextDrawSetProportional(Baseboard::PublicTD[9], true);
	TextDrawSetSelectable(Baseboard::PublicTD[9], false);

	Baseboard::PublicTD[10] = TextDrawCreate(333.750000, 435.649993, "t");
	TextDrawFont(Baseboard::PublicTD[10], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[10], 0.300000, 1.200000);
	TextDrawTextSize(Baseboard::PublicTD[10], 400.000000, 17.000000);
	TextDrawSetOutline(Baseboard::PublicTD[10], false);
	TextDrawSetShadow(Baseboard::PublicTD[10], false);
	TextDrawAlignment(Baseboard::PublicTD[10], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[10], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[10], 255);
	TextDrawBoxColour(Baseboard::PublicTD[10], 50);
	TextDrawUseBox(Baseboard::PublicTD[10], false);
	TextDrawSetProportional(Baseboard::PublicTD[10], true);
	TextDrawSetSelectable(Baseboard::PublicTD[10], false);

	Baseboard::PublicTD[11] = TextDrawCreate(320.000000, 439.000000, "tree");
	TextDrawFont(Baseboard::PublicTD[11], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[11], 0.200000, 0.800000);
	TextDrawTextSize(Baseboard::PublicTD[11], 400.000000, 17.000000);
	TextDrawSetOutline(Baseboard::PublicTD[11], false);
	TextDrawSetShadow(Baseboard::PublicTD[11], false);
	TextDrawAlignment(Baseboard::PublicTD[11], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[11], -1);
	TextDrawBackgroundColour(Baseboard::PublicTD[11], 255);
	TextDrawBoxColour(Baseboard::PublicTD[11], 50);
	TextDrawUseBox(Baseboard::PublicTD[11], false);
	TextDrawSetProportional(Baseboard::PublicTD[11], true);
	TextDrawSetSelectable(Baseboard::PublicTD[11], false);

	Baseboard::PublicTD[12] = TextDrawCreate(305.850006, 435.649993, "S");
	TextDrawFont(Baseboard::PublicTD[12], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[12], 0.300000, 1.200000);
	TextDrawTextSize(Baseboard::PublicTD[12], 400.000000, 17.000000);
	TextDrawSetOutline(Baseboard::PublicTD[12], false);
	TextDrawSetShadow(Baseboard::PublicTD[12], false);
	TextDrawAlignment(Baseboard::PublicTD[12], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[12], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[12], 255);
	TextDrawBoxColour(Baseboard::PublicTD[12], 50);
	TextDrawUseBox(Baseboard::PublicTD[12], false);
	TextDrawSetProportional(Baseboard::PublicTD[12], true);
	TextDrawSetSelectable(Baseboard::PublicTD[12], false);
}

stock Baseboard::CreatePlayerTD(playerid)
{
	Baseboard::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 45.000000, 437.500000, "CPF: 999");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][0], 0.281250, 1.125000);
	PlayerTextDrawTextSize(playerid, Baseboard::PlayerTD[playerid][0], 400.000000, 170.500000);
	PlayerTextDrawSetOutline(playerid, Baseboard::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Baseboard::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Baseboard::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Baseboard::PlayerTD[playerid][0], 1157580031);
	PlayerTextDrawBackgroundColour(playerid, Baseboard::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Baseboard::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Baseboard::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Baseboard::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Baseboard::PlayerTD[playerid][0], false);

	Baseboard::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 415.0, 437.500000, "~b~~h~~h~PAYDAY~w~ ...");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][1], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Baseboard::PlayerTD[playerid][1], 400.000000, 170.500000);
	PlayerTextDrawSetOutline(playerid, Baseboard::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Baseboard::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Baseboard::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Baseboard::PlayerTD[playerid][1], 1157580031);
	PlayerTextDrawBackgroundColour(playerid, Baseboard::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Baseboard::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Baseboard::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Baseboard::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Baseboard::PlayerTD[playerid][1], false);

	Baseboard::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 227.50, 437.500000, "~g~~h~~h~R$: 999.999");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][2], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][2], 0.281250, 1.125000);
	PlayerTextDrawTextSize(playerid, Baseboard::PlayerTD[playerid][2], 400.000000, 170.500000);
	PlayerTextDrawSetOutline(playerid, Baseboard::PlayerTD[playerid][2], false);
	PlayerTextDrawSetShadow(playerid, Baseboard::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Baseboard::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Baseboard::PlayerTD[playerid][2], 1157580031);
	PlayerTextDrawBackgroundColour(playerid, Baseboard::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Baseboard::PlayerTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, Baseboard::PlayerTD[playerid][2], false);
	PlayerTextDrawSetProportional(playerid, Baseboard::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Baseboard::PlayerTD[playerid][2], false);

	//391.660003, 437.500000 -> L

	Baseboard::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 105.83, 437.500000, "L: 999");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][3], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][3], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Baseboard::PlayerTD[playerid][3], 400.000000, 170.500000);
	PlayerTextDrawSetOutline(playerid, Baseboard::PlayerTD[playerid][3], false);
	PlayerTextDrawSetShadow(playerid, Baseboard::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Baseboard::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Baseboard::PlayerTD[playerid][3], 1157580031);
	PlayerTextDrawBackgroundColour(playerid, Baseboard::PlayerTD[playerid][3], 255);
	PlayerTextDrawBoxColour(playerid, Baseboard::PlayerTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, Baseboard::PlayerTD[playerid][3], false);
	PlayerTextDrawSetProportional(playerid, Baseboard::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Baseboard::PlayerTD[playerid][3], false);

	Baseboard::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 166.66, 437.500000, "~y~B$: sem conta");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][4], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][4], 0.281250, 1.125000);
	PlayerTextDrawTextSize(playerid, Baseboard::PlayerTD[playerid][4], 400.000000, 170.500000);
	PlayerTextDrawSetOutline(playerid, Baseboard::PlayerTD[playerid][4], false);
	PlayerTextDrawSetShadow(playerid, Baseboard::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Baseboard::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Baseboard::PlayerTD[playerid][4], 1157580031);
	PlayerTextDrawBackgroundColour(playerid, Baseboard::PlayerTD[playerid][4], 255);
	PlayerTextDrawBoxColour(playerid, Baseboard::PlayerTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, Baseboard::PlayerTD[playerid][4], false);
	PlayerTextDrawSetProportional(playerid, Baseboard::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Baseboard::PlayerTD[playerid][4], false);
}
