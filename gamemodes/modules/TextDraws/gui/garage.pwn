stock Garage::UpdateTextDrawColor(playerid, textid, color)
{
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][textid], color);
	PlayerTextDrawShow(playerid, Garage::PlayerTD[playerid][textid]); 
    return 1;
}

stock Garage::UpdatePTDBar(playerid, textid, Float:barsize, Float:percent)
{
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][textid], barsize * (percent / 100.0), 5.5);
	PlayerTextDrawShow(playerid, Garage::PlayerTD[playerid][textid]); 
}

stock Garage::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Garage::PlayerTD[playerid][textid], text, ___(3));
}

stock Garage::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Garage::PublicTD[0]));

stock Garage::ShowTDForPlayer(playerid)
{
	if(Garage::IsVisibleTDForPlayer(playerid)) return;
	
	Garage::CreatePlayerTD(playerid);
	
	for(new i = 0; i < 12; i++)
        TextDrawShowForPlayer(playerid, Garage::PublicTD[i]);
    for(new i = 0; i < 7; i++)
        PlayerTextDrawShow(playerid, Garage::PlayerTD[playerid][i]);  

    SelectTextDraw(playerid, 0x33FF33FF);
}

stock Garage::HideTDForPlayer(playerid)
{
	if(!Garage::IsVisibleTDForPlayer(playerid)) return;

	for(new i = 0; i < 12; i++)
        TextDrawHideForPlayer(playerid, Garage::PublicTD[i]);   
    for(new i = 0; i < 7; i++)
        PlayerTextDrawHide(playerid, Garage::PlayerTD[playerid][i]); 

	Garage::DestroyPlayerTD(playerid);
}

stock Garage::DestroyPublicTD()
{
    for(new i = 0; i < 12; i++)
	{
    	TextDrawDestroy(Garage::PublicTD[i]);
		Garage::PublicTD[i] = INVALID_TEXT_DRAW;
	}
}

stock Garage::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 7; i++)
	{
        PlayerTextDrawDestroy(playerid, Garage::PlayerTD[playerid][i]);
		Garage::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Garage::CreatePublicTD()
{
	Garage::PublicTD[0] = TextDrawCreate(428.000000, 70.000000, "ld_dual:white");
	TextDrawFont(Garage::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[0], 190.000000, 317.000000);
	TextDrawSetOutline(Garage::PublicTD[0], true);
	TextDrawSetShadow(Garage::PublicTD[0], false);
	TextDrawAlignment(Garage::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[0], 170);
	TextDrawBackgroundColour(Garage::PublicTD[0], 255);
	TextDrawBoxColour(Garage::PublicTD[0], 50);
	TextDrawUseBox(Garage::PublicTD[0], true);
	TextDrawSetProportional(Garage::PublicTD[0], true);
	TextDrawSetSelectable(Garage::PublicTD[0], false);

	Garage::PublicTD[1] = TextDrawCreate(428.000000, 70.000000, "ld_dual:white");
	TextDrawFont(Garage::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[1], 190.000000, 30.000000);
	TextDrawSetOutline(Garage::PublicTD[1], true);
	TextDrawSetShadow(Garage::PublicTD[1], false);
	TextDrawAlignment(Garage::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[1], 1436155903);
	TextDrawBackgroundColour(Garage::PublicTD[1], 255);
	TextDrawBoxColour(Garage::PublicTD[1], 50);
	TextDrawUseBox(Garage::PublicTD[1], true);
	TextDrawSetProportional(Garage::PublicTD[1], true);
	TextDrawSetSelectable(Garage::PublicTD[1], false);

	Garage::PublicTD[2] = TextDrawCreate(525.000000, 74.000000, "GARAGEM");
	TextDrawFont(Garage::PublicTD[2], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Garage::PublicTD[2], 0.400000, 2.400000);
	TextDrawTextSize(Garage::PublicTD[2], 400.000000, 17.000000);
	TextDrawSetOutline(Garage::PublicTD[2], false);
	TextDrawSetShadow(Garage::PublicTD[2], true);
	TextDrawAlignment(Garage::PublicTD[2], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Garage::PublicTD[2], -1);
	TextDrawBackgroundColour(Garage::PublicTD[2], 255);
	TextDrawBoxColour(Garage::PublicTD[2], 50);
	TextDrawUseBox(Garage::PublicTD[2], false);
	TextDrawSetProportional(Garage::PublicTD[2], true);
	TextDrawSetSelectable(Garage::PublicTD[2], false);

	Garage::PublicTD[3] = TextDrawCreate(435.000000, 150.000000, "LATARIA:");
	TextDrawFont(Garage::PublicTD[3], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Garage::PublicTD[3], 0.300000, 1.799999);
	TextDrawTextSize(Garage::PublicTD[3], 610.000000, 17.000000);
	TextDrawSetOutline(Garage::PublicTD[3], false);
	TextDrawSetShadow(Garage::PublicTD[3], false);
	TextDrawAlignment(Garage::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[3], -1);
	TextDrawBackgroundColour(Garage::PublicTD[3], 255);
	TextDrawBoxColour(Garage::PublicTD[3], 50);
	TextDrawUseBox(Garage::PublicTD[3], false);
	TextDrawSetProportional(Garage::PublicTD[3], true);
	TextDrawSetSelectable(Garage::PublicTD[3], false);

	Garage::PublicTD[4] = TextDrawCreate(433.000000, 173.000000, "ld_dual:white");
	TextDrawFont(Garage::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[4], 180.000000, 15.500000);
	TextDrawSetOutline(Garage::PublicTD[4], true);
	TextDrawSetShadow(Garage::PublicTD[4], false);
	TextDrawAlignment(Garage::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[4], -1962934017);
	TextDrawBackgroundColour(Garage::PublicTD[4], 255);
	TextDrawBoxColour(Garage::PublicTD[4], 50);
	TextDrawUseBox(Garage::PublicTD[4], true);
	TextDrawSetProportional(Garage::PublicTD[4], true);
	TextDrawSetSelectable(Garage::PublicTD[4], false);

	Garage::PublicTD[5] = TextDrawCreate(435.000000, 195.000000, "COMBUSTIVEL:");
	TextDrawFont(Garage::PublicTD[5], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Garage::PublicTD[5], 0.300000, 1.799999);
	TextDrawTextSize(Garage::PublicTD[5], 610.000000, 17.000000);
	TextDrawSetOutline(Garage::PublicTD[5], false);
	TextDrawSetShadow(Garage::PublicTD[5], false);
	TextDrawAlignment(Garage::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[5], -1);
	TextDrawBackgroundColour(Garage::PublicTD[5], 255);
	TextDrawBoxColour(Garage::PublicTD[5], 50);
	TextDrawUseBox(Garage::PublicTD[5], false);
	TextDrawSetProportional(Garage::PublicTD[5], true);
	TextDrawSetSelectable(Garage::PublicTD[5], false);

	Garage::PublicTD[6] = TextDrawCreate(433.000000, 218.000000, "ld_dual:white");
	TextDrawFont(Garage::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[6], 180.000000, 15.500000);
	TextDrawSetOutline(Garage::PublicTD[6], true);
	TextDrawSetShadow(Garage::PublicTD[6], false);
	TextDrawAlignment(Garage::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[6], 35839);
	TextDrawBackgroundColour(Garage::PublicTD[6], 255);
	TextDrawBoxColour(Garage::PublicTD[6], 50);
	TextDrawUseBox(Garage::PublicTD[6], true);
	TextDrawSetProportional(Garage::PublicTD[6], true);
	TextDrawSetSelectable(Garage::PublicTD[6], false);

	Garage::PublicTD[7] = TextDrawCreate(435.000000, 240.000000, "BLINDAGEM:");
	TextDrawFont(Garage::PublicTD[7], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Garage::PublicTD[7], 0.300000, 1.799999);
	TextDrawTextSize(Garage::PublicTD[7], 610.000000, 17.000000);
	TextDrawSetOutline(Garage::PublicTD[7], false);
	TextDrawSetShadow(Garage::PublicTD[7], false);
	TextDrawAlignment(Garage::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[7], -1);
	TextDrawBackgroundColour(Garage::PublicTD[7], 255);
	TextDrawBoxColour(Garage::PublicTD[7], 50);
	TextDrawUseBox(Garage::PublicTD[7], false);
	TextDrawSetProportional(Garage::PublicTD[7], true);
	TextDrawSetSelectable(Garage::PublicTD[7], false);

	Garage::PublicTD[8] = TextDrawCreate(433.000000, 263.000000, "ld_dual:white");
	TextDrawFont(Garage::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[8], 180.000000, 15.500000);
	TextDrawSetOutline(Garage::PublicTD[8], true);
	TextDrawSetShadow(Garage::PublicTD[8], false);
	TextDrawAlignment(Garage::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[8], 1296911871);
	TextDrawBackgroundColour(Garage::PublicTD[8], 255);
	TextDrawBoxColour(Garage::PublicTD[8], 50);
	TextDrawUseBox(Garage::PublicTD[8], true);
	TextDrawSetProportional(Garage::PublicTD[8], true);
	TextDrawSetSelectable(Garage::PublicTD[8], false);

	Garage::PublicTD[9] = TextDrawCreate(430.000000, 327.000000, "ld_beat:left");
	TextDrawFont(Garage::PublicTD[9], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[9], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[9], 45.000000, 55.000000);
	TextDrawSetOutline(Garage::PublicTD[9], true);
	TextDrawSetShadow(Garage::PublicTD[9], false);
	TextDrawAlignment(Garage::PublicTD[9], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[9], -1);
	TextDrawBackgroundColour(Garage::PublicTD[9], 255);
	TextDrawBoxColour(Garage::PublicTD[9], 50);
	TextDrawUseBox(Garage::PublicTD[9], true);
	TextDrawSetProportional(Garage::PublicTD[9], true);
	TextDrawSetSelectable(Garage::PublicTD[9], true);

	Garage::PublicTD[10] = TextDrawCreate(570.000000, 327.000000, "ld_beat:right");
	TextDrawFont(Garage::PublicTD[10], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Garage::PublicTD[10], 0.600000, 2.000000);
	TextDrawTextSize(Garage::PublicTD[10], 45.000000, 55.000000);
	TextDrawSetOutline(Garage::PublicTD[10], true);
	TextDrawSetShadow(Garage::PublicTD[10], false);
	TextDrawAlignment(Garage::PublicTD[10], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[10], -1);
	TextDrawBackgroundColour(Garage::PublicTD[10], 255);
	TextDrawBoxColour(Garage::PublicTD[10], 50);
	TextDrawUseBox(Garage::PublicTD[10], true);
	TextDrawSetProportional(Garage::PublicTD[10], true);
	TextDrawSetSelectable(Garage::PublicTD[10], true);

	Garage::PublicTD[11] = TextDrawCreate(435.000000, 285.000000, "CORES:");
	TextDrawFont(Garage::PublicTD[11], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Garage::PublicTD[11], 0.300000, 1.799999);
	TextDrawTextSize(Garage::PublicTD[11], 610.000000, 17.000000);
	TextDrawSetOutline(Garage::PublicTD[11], false);
	TextDrawSetShadow(Garage::PublicTD[11], false);
	TextDrawAlignment(Garage::PublicTD[11], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Garage::PublicTD[11], -1);
	TextDrawBackgroundColour(Garage::PublicTD[11], 255);
	TextDrawBoxColour(Garage::PublicTD[11], 50);
	TextDrawUseBox(Garage::PublicTD[11], false);
	TextDrawSetProportional(Garage::PublicTD[11], true);
	TextDrawSetSelectable(Garage::PublicTD[11], false);
}

stock Garage::CreatePlayerTD(playerid)
{
	Garage::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 435.000000, 125.000000, "VEICULO: ~b~~h~~h~(vehicle_name)");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][0], 0.300000, 1.799999);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][0], 610.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][0], -1);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][0], false);

	Garage::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 433.000000, 173.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][1], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][1], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][1], 118.500000, 15.500000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][1], true);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][1], -16776961);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][1], true);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][1], false);

	Garage::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 433.000000, 218.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][2], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][2], 118.500000, 15.500000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][2], true);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][2], 1687547391);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][2], true);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][2], false);

	Garage::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 433.000000, 263.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][3], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][3], 141.000000, 15.500000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][3], true);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][3], -1);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][3], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][3], true);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][3], false);

	Garage::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 521.000000, 345.000000, "0/0");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][4], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][4], 0.300000, 1.799999);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][4], 610.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][4], false);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][4], -1);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][4], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][4], false);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][4], false);

	Garage::PlayerTD[playerid][5] = CreatePlayerTextDraw(playerid, 433.000000, 305.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][5], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][5], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][5], 90.000000, 15.500000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][5], true);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][5], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][5], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][5], -1);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][5], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][5], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][5], true);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][5], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][5], false);

	Garage::PlayerTD[playerid][6] = CreatePlayerTextDraw(playerid, 523.000000, 305.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Garage::PlayerTD[playerid][6], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Garage::PlayerTD[playerid][6], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Garage::PlayerTD[playerid][6], 90.000000, 15.500000);
	PlayerTextDrawSetOutline(playerid, Garage::PlayerTD[playerid][6], true);
	PlayerTextDrawSetShadow(playerid, Garage::PlayerTD[playerid][6], false);
	PlayerTextDrawAlignment(playerid, Garage::PlayerTD[playerid][6], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Garage::PlayerTD[playerid][6], 255);
	PlayerTextDrawBackgroundColour(playerid, Garage::PlayerTD[playerid][6], 255);
	PlayerTextDrawBoxColour(playerid, Garage::PlayerTD[playerid][6], 50);
	PlayerTextDrawUseBox(playerid, Garage::PlayerTD[playerid][6], true);
	PlayerTextDrawSetProportional(playerid, Garage::PlayerTD[playerid][6], true);
	PlayerTextDrawSetSelectable(playerid, Garage::PlayerTD[playerid][6], false);
}
