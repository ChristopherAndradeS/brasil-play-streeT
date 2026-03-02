stock Dealership::UpdateTextDrawColor(playerid, textid, color)
{
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][textid], color);
	PlayerTextDrawShow(playerid, Dealership::PlayerTD[playerid][textid]); 
    return 1;
}

stock Dealership::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Dealership::PlayerTD[playerid][textid], text, ___(3));
}

stock Dealership::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Dealership::PublicTD[0]));

stock Dealership::ShowTDForPlayer(playerid)
{
	if(Dealership::IsVisibleTDForPlayer(playerid)) return;
	
	Dealership::CreatePlayerTD(playerid);
	
	for(new i = 0; i < 13; i++)
        TextDrawShowForPlayer(playerid, Dealership::PublicTD[i]);
    for(new i = 0; i < 5; i++)
        PlayerTextDrawShow(playerid, Dealership::PlayerTD[playerid][i]);  

    SelectTextDraw(playerid, 0x33FF33FF);
}

stock Dealership::HideTDForPlayer(playerid)
{
	if(!Dealership::IsVisibleTDForPlayer(playerid)) return;

	for(new i = 0; i < 13; i++)
        TextDrawHideForPlayer(playerid, Dealership::PublicTD[i]);   
    for(new i = 0; i < 5; i++)
        PlayerTextDrawHide(playerid, Dealership::PlayerTD[playerid][i]); 

	Dealership::DestroyPlayerTD(playerid);

    CancelSelectTextDraw(playerid);   
}

stock Dealership::DestroyPublicTD()
{
    for(new i = 0; i < 13; i++)
	{
    	TextDrawDestroy(Dealership::PublicTD[i]);
		Dealership::PublicTD[i] = INVALID_TEXT_DRAW;
	}
}

stock Dealership::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 5; i++)
	{
        PlayerTextDrawDestroy(playerid, Dealership::PlayerTD[playerid][i]);
		Dealership::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Dealership::CreatePublicTD()
{
	Dealership::PublicTD[0] = TextDrawCreate(175.000000, 332.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[0], 290.000000, 106.000000);
	TextDrawSetOutline(Dealership::PublicTD[0], true);
	TextDrawSetShadow(Dealership::PublicTD[0], false);
	TextDrawAlignment(Dealership::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[0], 170);
	TextDrawBackgroundColour(Dealership::PublicTD[0], 255);
	TextDrawBoxColour(Dealership::PublicTD[0], 50);
	TextDrawUseBox(Dealership::PublicTD[0], true);
	TextDrawSetProportional(Dealership::PublicTD[0], true);
	TextDrawSetSelectable(Dealership::PublicTD[0], false);

	Dealership::PublicTD[1] = TextDrawCreate(175.000000, 332.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[1], 290.000000, 23.000000);
	TextDrawSetOutline(Dealership::PublicTD[1], true);
	TextDrawSetShadow(Dealership::PublicTD[1], false);
	TextDrawAlignment(Dealership::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[1], -15623681);
	TextDrawBackgroundColour(Dealership::PublicTD[1], 255);
	TextDrawBoxColour(Dealership::PublicTD[1], 50);
	TextDrawUseBox(Dealership::PublicTD[1], true);
	TextDrawSetProportional(Dealership::PublicTD[1], true);
	TextDrawSetSelectable(Dealership::PublicTD[1], false);

	Dealership::PublicTD[2] = TextDrawCreate(320.000000, 335.000000, "CONCESSIONARIA");
	TextDrawFont(Dealership::PublicTD[2], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Dealership::PublicTD[2], 0.300000, 1.799998);
	TextDrawTextSize(Dealership::PublicTD[2], 400.000000, 17.000000);
	TextDrawSetOutline(Dealership::PublicTD[2], false);
	TextDrawSetShadow(Dealership::PublicTD[2], false);
	TextDrawAlignment(Dealership::PublicTD[2], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Dealership::PublicTD[2], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[2], 255);
	TextDrawBoxColour(Dealership::PublicTD[2], 50);
	TextDrawUseBox(Dealership::PublicTD[2], false);
	TextDrawSetProportional(Dealership::PublicTD[2], true);
	TextDrawSetSelectable(Dealership::PublicTD[2], false);

	Dealership::PublicTD[3] = TextDrawCreate(185.000000, 366.000000, "ld_beat:left");
	TextDrawFont(Dealership::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[3], 55.000000, 65.000000);
	TextDrawSetOutline(Dealership::PublicTD[3], true);
	TextDrawSetShadow(Dealership::PublicTD[3], false);
	TextDrawAlignment(Dealership::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[3], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[3], 255);
	TextDrawBoxColour(Dealership::PublicTD[3], 50);
	TextDrawUseBox(Dealership::PublicTD[3], true);
	TextDrawSetProportional(Dealership::PublicTD[3], true);
	TextDrawSetSelectable(Dealership::PublicTD[3], true);

	Dealership::PublicTD[4] = TextDrawCreate(400.000000, 366.000000, "ld_beat:right");
	TextDrawFont(Dealership::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[4], 55.000000, 65.000000);
	TextDrawSetOutline(Dealership::PublicTD[4], true);
	TextDrawSetShadow(Dealership::PublicTD[4], false);
	TextDrawAlignment(Dealership::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[4], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[4], 255);
	TextDrawBoxColour(Dealership::PublicTD[4], 50);
	TextDrawUseBox(Dealership::PublicTD[4], true);
	TextDrawSetProportional(Dealership::PublicTD[4], true);
	TextDrawSetSelectable(Dealership::PublicTD[4], true);

	Dealership::PublicTD[5] = TextDrawCreate(245.000000, 400.000000, "CORES:");
	TextDrawFont(Dealership::PublicTD[5], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Dealership::PublicTD[5], 0.250000, 1.500000);
	TextDrawTextSize(Dealership::PublicTD[5], 400.000000, 17.000000);
	TextDrawSetOutline(Dealership::PublicTD[5], false);
	TextDrawSetShadow(Dealership::PublicTD[5], false);
	TextDrawAlignment(Dealership::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[5], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[5], 255);
	TextDrawBoxColour(Dealership::PublicTD[5], 50);
	TextDrawUseBox(Dealership::PublicTD[5], false);
	TextDrawSetProportional(Dealership::PublicTD[5], true);
	TextDrawSetSelectable(Dealership::PublicTD[5], false);

	Dealership::PublicTD[6] = TextDrawCreate(470.000000, 388.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[6], 120.000000, 50.000000);
	TextDrawSetOutline(Dealership::PublicTD[6], true);
	TextDrawSetShadow(Dealership::PublicTD[6], false);
	TextDrawAlignment(Dealership::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[6], -12303105);
	TextDrawBackgroundColour(Dealership::PublicTD[6], 255);
	TextDrawBoxColour(Dealership::PublicTD[6], 50);
	TextDrawUseBox(Dealership::PublicTD[6], true);
	TextDrawSetProportional(Dealership::PublicTD[6], true);
	TextDrawSetSelectable(Dealership::PublicTD[6], true);

	Dealership::PublicTD[7] = TextDrawCreate(470.000000, 332.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[7], 120.000000, 50.000000);
	TextDrawSetOutline(Dealership::PublicTD[7], true);
	TextDrawSetShadow(Dealership::PublicTD[7], false);
	TextDrawAlignment(Dealership::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[7], 852308735);
	TextDrawBackgroundColour(Dealership::PublicTD[7], 255);
	TextDrawBoxColour(Dealership::PublicTD[7], 50);
	TextDrawUseBox(Dealership::PublicTD[7], true);
	TextDrawSetProportional(Dealership::PublicTD[7], true);
	TextDrawSetSelectable(Dealership::PublicTD[7], true);

	Dealership::PublicTD[8] = TextDrawCreate(50.000000, 332.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[8], 120.000000, 50.000000);
	TextDrawSetOutline(Dealership::PublicTD[8], true);
	TextDrawSetShadow(Dealership::PublicTD[8], false);
	TextDrawAlignment(Dealership::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[8], 1097458175);
	TextDrawBackgroundColour(Dealership::PublicTD[8], 255);
	TextDrawBoxColour(Dealership::PublicTD[8], 50);
	TextDrawUseBox(Dealership::PublicTD[8], true);
	TextDrawSetProportional(Dealership::PublicTD[8], true);
	TextDrawSetSelectable(Dealership::PublicTD[8], true);

	Dealership::PublicTD[9] = TextDrawCreate(50.000000, 388.000000, "ld_dual:white");
	TextDrawFont(Dealership::PublicTD[9], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Dealership::PublicTD[9], 0.600000, 2.000000);
	TextDrawTextSize(Dealership::PublicTD[9], 120.000000, 50.000000);
	TextDrawSetOutline(Dealership::PublicTD[9], true);
	TextDrawSetShadow(Dealership::PublicTD[9], false);
	TextDrawAlignment(Dealership::PublicTD[9], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Dealership::PublicTD[9], 1296911871);
	TextDrawBackgroundColour(Dealership::PublicTD[9], 255);
	TextDrawBoxColour(Dealership::PublicTD[9], 50);
	TextDrawUseBox(Dealership::PublicTD[9], true);
	TextDrawSetProportional(Dealership::PublicTD[9], true);
	TextDrawSetSelectable(Dealership::PublicTD[9], true);

	Dealership::PublicTD[10] = TextDrawCreate(111.000000, 347.000000, "CATEGORIA");
	TextDrawFont(Dealership::PublicTD[10], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Dealership::PublicTD[10], 0.300000, 1.799998);
	TextDrawTextSize(Dealership::PublicTD[10], 400.000000, 173.500000);
	TextDrawSetOutline(Dealership::PublicTD[10], false);
	TextDrawSetShadow(Dealership::PublicTD[10], false);
	TextDrawAlignment(Dealership::PublicTD[10], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Dealership::PublicTD[10], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[10], 255);
	TextDrawBoxColour(Dealership::PublicTD[10], 50);
	TextDrawUseBox(Dealership::PublicTD[10], false);
	TextDrawSetProportional(Dealership::PublicTD[10], true);
	TextDrawSetSelectable(Dealership::PublicTD[10], false);

	Dealership::PublicTD[11] = TextDrawCreate(529.000000, 404.000000, "SAIR");
	TextDrawFont(Dealership::PublicTD[11], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Dealership::PublicTD[11], 0.300000, 1.799998);
	TextDrawTextSize(Dealership::PublicTD[11], 400.000000, 173.500000);
	TextDrawSetOutline(Dealership::PublicTD[11], false);
	TextDrawSetShadow(Dealership::PublicTD[11], false);
	TextDrawAlignment(Dealership::PublicTD[11], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Dealership::PublicTD[11], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[11], 255);
	TextDrawBoxColour(Dealership::PublicTD[11], 50);
	TextDrawUseBox(Dealership::PublicTD[11], false);
	TextDrawSetProportional(Dealership::PublicTD[11], true);
	TextDrawSetSelectable(Dealership::PublicTD[11], false);

	Dealership::PublicTD[12] = TextDrawCreate(529.000000, 348.000000, "COMPRAR");
	TextDrawFont(Dealership::PublicTD[12], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Dealership::PublicTD[12], 0.300000, 1.799998);
	TextDrawTextSize(Dealership::PublicTD[12], 400.000000, 173.500000);
	TextDrawSetOutline(Dealership::PublicTD[12], false);
	TextDrawSetShadow(Dealership::PublicTD[12], false);
	TextDrawAlignment(Dealership::PublicTD[12], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Dealership::PublicTD[12], -1);
	TextDrawBackgroundColour(Dealership::PublicTD[12], 255);
	TextDrawBoxColour(Dealership::PublicTD[12], 50);
	TextDrawUseBox(Dealership::PublicTD[12], false);
	TextDrawSetProportional(Dealership::PublicTD[12], true);
	TextDrawSetSelectable(Dealership::PublicTD[12], false);

	return 1;
}

stock Dealership::CreatePlayerTD(playerid)
{
	Dealership::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 320.000000, 360.000000, "NOME: ~p~~h~INFERNUS");
	PlayerTextDrawFont(playerid, Dealership::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Dealership::PlayerTD[playerid][0], 0.250000, 1.500000);
	PlayerTextDrawTextSize(playerid, Dealership::PlayerTD[playerid][0], 400.000000, 188.000000);
	PlayerTextDrawSetOutline(playerid, Dealership::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Dealership::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Dealership::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][0], -1);
	PlayerTextDrawBackgroundColour(playerid, Dealership::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Dealership::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Dealership::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Dealership::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Dealership::PlayerTD[playerid][0], false);

	Dealership::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 320.000000, 380.000000, "PRECO: ~g~~h~99.999 R$ ~w~ou ~y~999 B$");
	PlayerTextDrawFont(playerid, Dealership::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Dealership::PlayerTD[playerid][1], 0.250000, 1.500000);
	PlayerTextDrawTextSize(playerid, Dealership::PlayerTD[playerid][1], 400.000000, 187.000000);
	PlayerTextDrawSetOutline(playerid, Dealership::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Dealership::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Dealership::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Dealership::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Dealership::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Dealership::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Dealership::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Dealership::PlayerTD[playerid][1], false);

	Dealership::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 284.000000, 402.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Dealership::PlayerTD[playerid][2], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Dealership::PlayerTD[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Dealership::PlayerTD[playerid][2], 45.000000, 30.000000);
	PlayerTextDrawSetOutline(playerid, Dealership::PlayerTD[playerid][2], true);
	PlayerTextDrawSetShadow(playerid, Dealership::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Dealership::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][2], -15623681);
	PlayerTextDrawBackgroundColour(playerid, Dealership::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Dealership::PlayerTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, Dealership::PlayerTD[playerid][2], true);
	PlayerTextDrawSetProportional(playerid, Dealership::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Dealership::PlayerTD[playerid][2], true);

	Dealership::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 329.000000, 402.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Dealership::PlayerTD[playerid][3], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Dealership::PlayerTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Dealership::PlayerTD[playerid][3], 45.000000, 30.000000);
	PlayerTextDrawSetOutline(playerid, Dealership::PlayerTD[playerid][3], true);
	PlayerTextDrawSetShadow(playerid, Dealership::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Dealership::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][3], -1378294017);
	PlayerTextDrawBackgroundColour(playerid, Dealership::PlayerTD[playerid][3], 255);
	PlayerTextDrawBoxColour(playerid, Dealership::PlayerTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, Dealership::PlayerTD[playerid][3], true);
	PlayerTextDrawSetProportional(playerid, Dealership::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Dealership::PlayerTD[playerid][3], true);

	Dealership::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 111.000000, 404.000000, "ESCONDER");
	PlayerTextDrawFont(playerid, Dealership::PlayerTD[playerid][4], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Dealership::PlayerTD[playerid][4], 0.300000, 1.799998);
	PlayerTextDrawTextSize(playerid, Dealership::PlayerTD[playerid][4], 400.000000, 173.500000);
	PlayerTextDrawSetOutline(playerid, Dealership::PlayerTD[playerid][4], false);
	PlayerTextDrawSetShadow(playerid, Dealership::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Dealership::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Dealership::PlayerTD[playerid][4], -1);
	PlayerTextDrawBackgroundColour(playerid, Dealership::PlayerTD[playerid][4], 255);
	PlayerTextDrawBoxColour(playerid, Dealership::PlayerTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, Dealership::PlayerTD[playerid][4], false);
	PlayerTextDrawSetProportional(playerid, Dealership::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Dealership::PlayerTD[playerid][4], false);

	return 1;
}
