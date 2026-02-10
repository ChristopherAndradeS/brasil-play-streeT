stock Acessory::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Acessory::PlayerTD[playerid][textid], text, ___(3));
}

stock Acessory::UpdateColorPTD(playerid, textid, color)
{
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][textid], color);
	PlayerTextDrawShow(playerid, Acessory::PlayerTD[playerid][textid]); 
}

stock Acessory::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Acessory::PublicTD[0]));

stock Acessory::ShowTDForPlayer(playerid)
{ 
	Acessory::CreatePlayerTD(playerid);

    for(new i = 0; i < 21; i++)
        TextDrawShowForPlayer(playerid, Acessory::PublicTD[i]);
	for(new i = 0; i < 14; i++)
        PlayerTextDrawShow(playerid, Acessory::PlayerTD[playerid][i]); 

    SelectTextDraw(playerid, 0xFFFF33FF);
}

stock Acessory::HideTDForPlayer(playerid)
{
    for(new i = 0; i < 21; i++)
        TextDrawHideForPlayer(playerid, Acessory::PublicTD[i]);
    for(new i = 0; i < 14; i++)
        PlayerTextDrawHide(playerid, Acessory::PlayerTD[playerid][i]); 

	Acessory::DestroyPlayerTD(playerid);

    CancelSelectTextDraw(playerid);    
}

stock Acessory::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 14; i++)
	{
        PlayerTextDrawDestroy(playerid, Acessory::PlayerTD[playerid][i]);
		Acessory::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Acessory::CreatePublicTD()
{
	Acessory::PublicTD[0] = TextDrawCreate(315.000000, 105.000000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[0], 310.000000, 280.000000);
	TextDrawSetOutline(Acessory::PublicTD[0], true);
	TextDrawSetShadow(Acessory::PublicTD[0], false);
	TextDrawAlignment(Acessory::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[0], 170);
	TextDrawBackgroundColour(Acessory::PublicTD[0], 255);
	TextDrawBoxColour(Acessory::PublicTD[0], 50);
	TextDrawUseBox(Acessory::PublicTD[0], true);
	TextDrawSetProportional(Acessory::PublicTD[0], true);
	TextDrawSetSelectable(Acessory::PublicTD[0], false);

	Acessory::PublicTD[1] = TextDrawCreate(315.000000, 105.000000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[1], 310.000000, 30.000000);
	TextDrawSetOutline(Acessory::PublicTD[1], true);
	TextDrawSetShadow(Acessory::PublicTD[1], false);
	TextDrawAlignment(Acessory::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[1], 1097458175);
	TextDrawBackgroundColour(Acessory::PublicTD[1], 255);
	TextDrawBoxColour(Acessory::PublicTD[1], 50);
	TextDrawUseBox(Acessory::PublicTD[1], true);
	TextDrawSetProportional(Acessory::PublicTD[1], true);
	TextDrawSetSelectable(Acessory::PublicTD[1], false);

	Acessory::PublicTD[2] = TextDrawCreate(480.000000, 111.000000, "EDITOR DE ACESSORIOS");
	TextDrawFont(Acessory::PublicTD[2], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[2], 0.449999, 1.799998);
	TextDrawTextSize(Acessory::PublicTD[2], 400.000000, 319.500000);
	TextDrawSetOutline(Acessory::PublicTD[2], false);
	TextDrawSetShadow(Acessory::PublicTD[2], false);
	TextDrawAlignment(Acessory::PublicTD[2], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[2], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[2], 255);
	TextDrawBoxColour(Acessory::PublicTD[2], 50);
	TextDrawUseBox(Acessory::PublicTD[2], false);
	TextDrawSetProportional(Acessory::PublicTD[2], true);
	TextDrawSetSelectable(Acessory::PublicTD[2], false);

	Acessory::PublicTD[3] = TextDrawCreate(375.000000, 150.000000, "ld_beat:left");
	TextDrawFont(Acessory::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[3], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[3], true);
	TextDrawSetShadow(Acessory::PublicTD[3], false);
	TextDrawAlignment(Acessory::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[3], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[3], 255);
	TextDrawBoxColour(Acessory::PublicTD[3], 50);
	TextDrawUseBox(Acessory::PublicTD[3], true);
	TextDrawSetProportional(Acessory::PublicTD[3], true);
	TextDrawSetSelectable(Acessory::PublicTD[3], true);

	Acessory::PublicTD[4] = TextDrawCreate(375.000000, 210.000000, "ld_beat:left");
	TextDrawFont(Acessory::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[4], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[4], true);
	TextDrawSetShadow(Acessory::PublicTD[4], false);
	TextDrawAlignment(Acessory::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[4], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[4], 255);
	TextDrawBoxColour(Acessory::PublicTD[4], 50);
	TextDrawUseBox(Acessory::PublicTD[4], true);
	TextDrawSetProportional(Acessory::PublicTD[4], true);
	TextDrawSetSelectable(Acessory::PublicTD[4], true);

	Acessory::PublicTD[5] = TextDrawCreate(375.000000, 270.000000, "ld_beat:left");
	TextDrawFont(Acessory::PublicTD[5], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[5], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[5], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[5], true);
	TextDrawSetShadow(Acessory::PublicTD[5], false);
	TextDrawAlignment(Acessory::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[5], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[5], 255);
	TextDrawBoxColour(Acessory::PublicTD[5], 50);
	TextDrawUseBox(Acessory::PublicTD[5], true);
	TextDrawSetProportional(Acessory::PublicTD[5], true);
	TextDrawSetSelectable(Acessory::PublicTD[5], true);

	Acessory::PublicTD[6] = TextDrawCreate(565.000000, 150.000000, "ld_beat:right");
	TextDrawFont(Acessory::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[6], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[6], true);
	TextDrawSetShadow(Acessory::PublicTD[6], false);
	TextDrawAlignment(Acessory::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[6], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[6], 255);
	TextDrawBoxColour(Acessory::PublicTD[6], 50);
	TextDrawUseBox(Acessory::PublicTD[6], true);
	TextDrawSetProportional(Acessory::PublicTD[6], true);
	TextDrawSetSelectable(Acessory::PublicTD[6], true);

	Acessory::PublicTD[7] = TextDrawCreate(565.000000, 210.000000, "ld_beat:right");
	TextDrawFont(Acessory::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[7], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[7], true);
	TextDrawSetShadow(Acessory::PublicTD[7], false);
	TextDrawAlignment(Acessory::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[7], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[7], 255);
	TextDrawBoxColour(Acessory::PublicTD[7], 50);
	TextDrawUseBox(Acessory::PublicTD[7], true);
	TextDrawSetProportional(Acessory::PublicTD[7], true);
	TextDrawSetSelectable(Acessory::PublicTD[7], true);

	Acessory::PublicTD[8] = TextDrawCreate(565.000000, 270.000000, "ld_beat:right");
	TextDrawFont(Acessory::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[8], 50.000000, 50.000000);
	TextDrawSetOutline(Acessory::PublicTD[8], true);
	TextDrawSetShadow(Acessory::PublicTD[8], false);
	TextDrawAlignment(Acessory::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[8], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[8], 255);
	TextDrawBoxColour(Acessory::PublicTD[8], 50);
	TextDrawUseBox(Acessory::PublicTD[8], true);
	TextDrawSetProportional(Acessory::PublicTD[8], true);
	TextDrawSetSelectable(Acessory::PublicTD[8], true);

	Acessory::PublicTD[9] = TextDrawCreate(500.000000, 335.000000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[9], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[9], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[9], 115.000000, 40.000000);
	TextDrawSetOutline(Acessory::PublicTD[9], true);
	TextDrawSetShadow(Acessory::PublicTD[9], false);
	TextDrawAlignment(Acessory::PublicTD[9], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[9], 852308735);
	TextDrawBackgroundColour(Acessory::PublicTD[9], 255);
	TextDrawBoxColour(Acessory::PublicTD[9], 50);
	TextDrawUseBox(Acessory::PublicTD[9], true);
	TextDrawSetProportional(Acessory::PublicTD[9], true);
	TextDrawSetSelectable(Acessory::PublicTD[9], true);

	Acessory::PublicTD[10] = TextDrawCreate(375.000000, 335.000000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[10], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[10], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[10], 115.000000, 40.000000);
	TextDrawSetOutline(Acessory::PublicTD[10], true);
	TextDrawSetShadow(Acessory::PublicTD[10], false);
	TextDrawAlignment(Acessory::PublicTD[10], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[10], -764862721);
	TextDrawBackgroundColour(Acessory::PublicTD[10], 255);
	TextDrawBoxColour(Acessory::PublicTD[10], 50);
	TextDrawUseBox(Acessory::PublicTD[10], true);
	TextDrawSetProportional(Acessory::PublicTD[10], true);
	TextDrawSetSelectable(Acessory::PublicTD[10], true);

	Acessory::PublicTD[11] = TextDrawCreate(315.000000, 73.000000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[11], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[11], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[11], 32.000000, 32.000000);
	TextDrawSetOutline(Acessory::PublicTD[11], true);
	TextDrawSetShadow(Acessory::PublicTD[11], false);
	TextDrawAlignment(Acessory::PublicTD[11], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[11], -13421569);
	TextDrawBackgroundColour(Acessory::PublicTD[11], 255);
	TextDrawBoxColour(Acessory::PublicTD[11], 50);
	TextDrawUseBox(Acessory::PublicTD[11], true);
	TextDrawSetProportional(Acessory::PublicTD[11], true);
	TextDrawSetSelectable(Acessory::PublicTD[11], true);

	Acessory::PublicTD[12] = TextDrawCreate(331.500000, 80.000000, "X");
	TextDrawFont(Acessory::PublicTD[12], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[12], 0.449999, 1.799998);
	TextDrawTextSize(Acessory::PublicTD[12], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[12], false);
	TextDrawSetShadow(Acessory::PublicTD[12], false);
	TextDrawAlignment(Acessory::PublicTD[12], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[12], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[12], 255);
	TextDrawBoxColour(Acessory::PublicTD[12], 50);
	TextDrawUseBox(Acessory::PublicTD[12], false);
	TextDrawSetProportional(Acessory::PublicTD[12], true);
	TextDrawSetSelectable(Acessory::PublicTD[12], false);

	Acessory::PublicTD[13] = TextDrawCreate(495.000000, 190.000000, "- posicao +");
	TextDrawFont(Acessory::PublicTD[13], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[13], 0.300000, 1.200000);
	TextDrawTextSize(Acessory::PublicTD[13], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[13], false);
	TextDrawSetShadow(Acessory::PublicTD[13], false);
	TextDrawAlignment(Acessory::PublicTD[13], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[13], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[13], 255);
	TextDrawBoxColour(Acessory::PublicTD[13], 50);
	TextDrawUseBox(Acessory::PublicTD[13], false);
	TextDrawSetProportional(Acessory::PublicTD[13], true);
	TextDrawSetSelectable(Acessory::PublicTD[13], false);

	Acessory::PublicTD[14] = TextDrawCreate(500.000000, 157.500000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[14], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[14], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[14], 60.000000, 30.000000);
	TextDrawSetOutline(Acessory::PublicTD[14], true);
	TextDrawSetShadow(Acessory::PublicTD[14], false);
	TextDrawAlignment(Acessory::PublicTD[14], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[14], 144);
	TextDrawBackgroundColour(Acessory::PublicTD[14], 255);
	TextDrawBoxColour(Acessory::PublicTD[14], 50);
	TextDrawUseBox(Acessory::PublicTD[14], true);
	TextDrawSetProportional(Acessory::PublicTD[14], true);
	TextDrawSetSelectable(Acessory::PublicTD[14], true);

	Acessory::PublicTD[15] = TextDrawCreate(500.000000, 217.500000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[15], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[15], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[15], 60.000000, 30.000000);
	TextDrawSetOutline(Acessory::PublicTD[15], true);
	TextDrawSetShadow(Acessory::PublicTD[15], false);
	TextDrawAlignment(Acessory::PublicTD[15], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[15], 144);
	TextDrawBackgroundColour(Acessory::PublicTD[15], 255);
	TextDrawBoxColour(Acessory::PublicTD[15], 50);
	TextDrawUseBox(Acessory::PublicTD[15], true);
	TextDrawSetProportional(Acessory::PublicTD[15], true);
	TextDrawSetSelectable(Acessory::PublicTD[15], true);

	Acessory::PublicTD[16] = TextDrawCreate(500.000000, 277.500000, "ld_dual:white");
	TextDrawFont(Acessory::PublicTD[16], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Acessory::PublicTD[16], 0.600000, 2.000000);
	TextDrawTextSize(Acessory::PublicTD[16], 60.000000, 30.000000);
	TextDrawSetOutline(Acessory::PublicTD[16], true);
	TextDrawSetShadow(Acessory::PublicTD[16], false);
	TextDrawAlignment(Acessory::PublicTD[16], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Acessory::PublicTD[16], 144);
	TextDrawBackgroundColour(Acessory::PublicTD[16], 255);
	TextDrawBoxColour(Acessory::PublicTD[16], 50);
	TextDrawUseBox(Acessory::PublicTD[16], true);
	TextDrawSetProportional(Acessory::PublicTD[16], true);
	TextDrawSetSelectable(Acessory::PublicTD[16], true);

	Acessory::PublicTD[17] = TextDrawCreate(495.000000, 250.000000, "- ROTACAO +");
	TextDrawFont(Acessory::PublicTD[17], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[17], 0.300000, 1.200000);
	TextDrawTextSize(Acessory::PublicTD[17], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[17], false);
	TextDrawSetShadow(Acessory::PublicTD[17], false);
	TextDrawAlignment(Acessory::PublicTD[17], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[17], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[17], 255);
	TextDrawBoxColour(Acessory::PublicTD[17], 50);
	TextDrawUseBox(Acessory::PublicTD[17], false);
	TextDrawSetProportional(Acessory::PublicTD[17], true);
	TextDrawSetSelectable(Acessory::PublicTD[17], false);

	Acessory::PublicTD[18] = TextDrawCreate(495.000000, 310.000000, "- ESCALA +");
	TextDrawFont(Acessory::PublicTD[18], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[18], 0.300000, 1.200000);
	TextDrawTextSize(Acessory::PublicTD[18], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[18], false);
	TextDrawSetShadow(Acessory::PublicTD[18], false);
	TextDrawAlignment(Acessory::PublicTD[18], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[18], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[18], 255);
	TextDrawBoxColour(Acessory::PublicTD[18], 50);
	TextDrawUseBox(Acessory::PublicTD[18], false);
	TextDrawSetProportional(Acessory::PublicTD[18], true);
	TextDrawSetSelectable(Acessory::PublicTD[18], false);

	Acessory::PublicTD[19] = TextDrawCreate(557.500000, 349.500000, "SALVAR");
	TextDrawFont(Acessory::PublicTD[19], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[19], 0.300000, 1.200000);
	TextDrawTextSize(Acessory::PublicTD[19], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[19], false);
	TextDrawSetShadow(Acessory::PublicTD[19], false);
	TextDrawAlignment(Acessory::PublicTD[19], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[19], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[19], 255);
	TextDrawBoxColour(Acessory::PublicTD[19], 50);
	TextDrawUseBox(Acessory::PublicTD[19], false);
	TextDrawSetProportional(Acessory::PublicTD[19], true);
	TextDrawSetSelectable(Acessory::PublicTD[19], false);

	Acessory::PublicTD[20] = TextDrawCreate(432.500000, 349.500000, "ALTERAR VISAO");
	TextDrawFont(Acessory::PublicTD[20], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Acessory::PublicTD[20], 0.300000, 1.200000);
	TextDrawTextSize(Acessory::PublicTD[20], 400.000000, 183.000000);
	TextDrawSetOutline(Acessory::PublicTD[20], false);
	TextDrawSetShadow(Acessory::PublicTD[20], false);
	TextDrawAlignment(Acessory::PublicTD[20], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Acessory::PublicTD[20], -1);
	TextDrawBackgroundColour(Acessory::PublicTD[20], 255);
	TextDrawBoxColour(Acessory::PublicTD[20], 50);
	TextDrawUseBox(Acessory::PublicTD[20], false);
	TextDrawSetProportional(Acessory::PublicTD[20], true);
	TextDrawSetSelectable(Acessory::PublicTD[20], false);
}

stock Acessory::CreatePlayerTD(playerid)
{
	Acessory::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 315.000000, 185.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][0], TEXT_DRAW_FONT:5);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][0], 50.000000, 50.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][0], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][0], -131);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][0], 255);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][0], true);
	PlayerTextDrawSetPreviewModel(playerid, Acessory::PlayerTD[playerid][0], 18631);
	PlayerTextDrawSetPreviewRot(playerid, Acessory::PlayerTD[playerid][0], 0.000000, 0.000000, 90.000000, 0.750000);

	Acessory::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 315.000000, 135.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][1], TEXT_DRAW_FONT:5);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][1], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][1], 50.000000, 50.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][1], -131);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][1], 255);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][1], true);
	PlayerTextDrawSetPreviewModel(playerid, Acessory::PlayerTD[playerid][1], 18631);
	PlayerTextDrawSetPreviewRot(playerid, Acessory::PlayerTD[playerid][1], 0.000000, 0.000000, 90.000000, 0.750000);

	Acessory::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 315.000000, 235.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][2], TEXT_DRAW_FONT:5);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][2], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][2], 50.000000, 50.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][2], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][2], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][2], -131);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][2], 255);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][2], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][2], true);
	PlayerTextDrawSetPreviewModel(playerid, Acessory::PlayerTD[playerid][2], 18631);
	PlayerTextDrawSetPreviewRot(playerid, Acessory::PlayerTD[playerid][2], 0.000000, 0.000000, 90.000000, 0.750000);

	Acessory::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 315.000000, 285.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][3], TEXT_DRAW_FONT:5);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][3], 50.000000, 50.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][3], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][3], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][3], -131);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][3], 255);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][3], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][3], true);
	PlayerTextDrawSetPreviewModel(playerid, Acessory::PlayerTD[playerid][3], 18631);
	PlayerTextDrawSetPreviewRot(playerid, Acessory::PlayerTD[playerid][3], 0.000000, 0.000000, 90.000000, 0.750000);

	Acessory::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 315.000000, 335.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][4], TEXT_DRAW_FONT:5);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][4], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][4], 50.000000, 50.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][4], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][4], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][4], -131);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][4], 255);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][4], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][4], true);
	PlayerTextDrawSetPreviewModel(playerid, Acessory::PlayerTD[playerid][4], 18631);
	PlayerTextDrawSetPreviewRot(playerid, Acessory::PlayerTD[playerid][4], 0.000000, 0.000000, 90.000000, 0.750000);

	Acessory::PlayerTD[playerid][5] = CreatePlayerTextDraw(playerid, 530.000000, 162.500000, "OFFSET:~n~9.9999");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][5], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][5], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][5], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][5], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][5], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][5], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][5], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][5], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][5], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][5], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][5], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][5], false);

	Acessory::PlayerTD[playerid][6] = CreatePlayerTextDraw(playerid, 530.000000, 222.500000, "OFFSET:~n~9.9999");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][6], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][6], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][6], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][6], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][6], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][6], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][6], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][6], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][6], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][6], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][6], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][6], false);

	Acessory::PlayerTD[playerid][7] = CreatePlayerTextDraw(playerid, 530.000000, 282.500000, "OFFSET:~n~9.9999");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][7], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][7], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][7], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][7], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][7], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][7], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][7], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][7], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][7], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][7], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][7], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][7], false);

	Acessory::PlayerTD[playerid][8] = CreatePlayerTextDraw(playerid, 430.000000, 157.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][8], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][8], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][8], 60.000000, 30.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][8], true);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][8], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][8], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][8], -16777072);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][8], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][8], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][8], true);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][8], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][8], true);

	Acessory::PlayerTD[playerid][9] = CreatePlayerTextDraw(playerid, 430.000000, 217.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][9], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][9], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][9], 60.000000, 30.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][9], true);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][9], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][9], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][9], 16711824);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][9], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][9], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][9], true);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][9], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][9], true);

	Acessory::PlayerTD[playerid][10] = CreatePlayerTextDraw(playerid, 430.000000, 277.500000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][10], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][10], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][10], 60.000000, 30.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][10], true);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][10], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][10], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][10], 65424);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][10], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][10], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][10], true);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][10], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][10], true);

	Acessory::PlayerTD[playerid][11] = CreatePlayerTextDraw(playerid, 460.000000, 167.500000, "EIXO X");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][11], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][11], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][11], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][11], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][11], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][11], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][11], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][11], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][11], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][11], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][11], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][11], false);

	Acessory::PlayerTD[playerid][12] = CreatePlayerTextDraw(playerid, 460.000000, 227.500000, "EIXO Y");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][12], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][12], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][12], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][12], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][12], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][12], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][12], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][12], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][12], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][12], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][12], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][12], false);

	Acessory::PlayerTD[playerid][13] = CreatePlayerTextDraw(playerid, 460.000000, 287.500000, "EIXO Z");
	PlayerTextDrawFont(playerid, Acessory::PlayerTD[playerid][13], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Acessory::PlayerTD[playerid][13], 0.250000, 1.000000);
	PlayerTextDrawTextSize(playerid, Acessory::PlayerTD[playerid][13], 400.000000, 183.000000);
	PlayerTextDrawSetOutline(playerid, Acessory::PlayerTD[playerid][13], false);
	PlayerTextDrawSetShadow(playerid, Acessory::PlayerTD[playerid][13], false);
	PlayerTextDrawAlignment(playerid, Acessory::PlayerTD[playerid][13], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Acessory::PlayerTD[playerid][13], -1);
	PlayerTextDrawBackgroundColour(playerid, Acessory::PlayerTD[playerid][13], 255);
	PlayerTextDrawBoxColour(playerid, Acessory::PlayerTD[playerid][13], 50);
	PlayerTextDrawUseBox(playerid, Acessory::PlayerTD[playerid][13], false);
	PlayerTextDrawSetProportional(playerid, Acessory::PlayerTD[playerid][13], true);
	PlayerTextDrawSetSelectable(playerid, Acessory::PlayerTD[playerid][13], false);
}