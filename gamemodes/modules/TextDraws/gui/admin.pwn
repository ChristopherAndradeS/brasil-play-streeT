stock Adm::UpdatePTDText(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Adm::PlayerTD[playerid][textid], text, ___(3));
}

stock Adm::UpdatePTDBar(playerid, textid, Float:barsize, Float:percent)
{
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][textid], barsize * (percent / 100.0), 7.5);
	PlayerTextDrawShow(playerid, Adm::PlayerTD[playerid][textid]); 
}

stock Adm::UpdateTextDraw(playerid, targetid)
{
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_NAME, "JOGADOR: %s", GetPlayerNameEx(targetid));
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_ID, "ID: %d", targetid);
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_PING, "Ping: %d", GetPlayerPing(targetid));
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_WORLD, "int: %d VW: %d", GetPlayerInterior(targetid), GetPlayerVirtualWorld(targetid));
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_ORGNAME, "ORG: SEM ORG");
	Adm::UpdatePTDText(playerid, PTD_ADM_TXT_STATE, "STATE: %d", GetPlayerState(targetid));

	if(Admin[targetid][adm::lvl] > 0)
		Adm::UpdatePTDText(playerid, PTD_ADM_TXT_ROLE, "CARGO: %s", Adm::gRoleNames[Admin[targetid][adm::lvl]]);
	else
		Adm::UpdatePTDText(playerid, PTD_ADM_TXT_ROLE, "CARGO: %s", "Sem cargo");

	new Float:health;
	GetPlayerHealth(targetid, health);
	Adm::UpdatePTDBar(playerid, PTD_ADM_BAR_HEALTH, 67.5, floatclamp(health, 0.0, 100.0));

	new Float:armour;
	GetPlayerArmour(targetid, armour);
	Adm::UpdatePTDBar(playerid, PTD_ADM_BAR_ARMOUR, 67.5, floatclamp(armour, 0.0, 100.0));
}

stock Adm::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Adm::PublicTD[0]));

stock Adm::ShowTDForPlayer(playerid)
{ 
	Adm::CreatePlayerTD(playerid);

    for(new i = 0; i < 14; i++)
        TextDrawShowForPlayer(playerid, Adm::PublicTD[i]);
	for(new i = 0; i < 9; i++)
        PlayerTextDrawShow(playerid, Adm::PlayerTD[playerid][i]); 

    SelectTextDraw(playerid, 0xFFFF33FF);
}

stock Adm::HideTDForPlayer(playerid)
{
    for(new i = 0; i < 14; i++)
        TextDrawHideForPlayer(playerid, Adm::PublicTD[i]);
    for(new i = 0; i < 9; i++)
        PlayerTextDrawHide(playerid, Adm::PlayerTD[playerid][i]); 

	Adm::DestroyPlayerTD(playerid);

    CancelSelectTextDraw(playerid);    
}

stock Adm::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 9; i++)
	{
        PlayerTextDrawDestroy(playerid, Adm::PlayerTD[playerid][i]);
		Adm::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Adm::CreatePublicTD()
{
	Adm::PublicTD[0] = TextDrawCreate(380.000000, 345.000000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[0], 250.000000, 91.500000);
	TextDrawSetOutline(Adm::PublicTD[0], true);
	TextDrawSetShadow(Adm::PublicTD[0], false);
	TextDrawAlignment(Adm::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[0], 170);
	TextDrawBackgroundColour(Adm::PublicTD[0], 255);
	TextDrawBoxColour(Adm::PublicTD[0], 50);
	TextDrawUseBox(Adm::PublicTD[0], true);
	TextDrawSetProportional(Adm::PublicTD[0], true);
	TextDrawSetSelectable(Adm::PublicTD[0], false);

	Adm::PublicTD[1] = TextDrawCreate(380.000000, 318.000000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[1], 250.000000, 25.000000);
	TextDrawSetOutline(Adm::PublicTD[1], true);
	TextDrawSetShadow(Adm::PublicTD[1], false);
	TextDrawAlignment(Adm::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[1], 1097458175);
	TextDrawBackgroundColour(Adm::PublicTD[1], 255);
	TextDrawBoxColour(Adm::PublicTD[1], 50);
	TextDrawUseBox(Adm::PublicTD[1], true);
	TextDrawSetProportional(Adm::PublicTD[1], true);
	TextDrawSetSelectable(Adm::PublicTD[1], false);

	Adm::PublicTD[2] = TextDrawCreate(385.000000, 358.000000, "ld_beat:left");
	TextDrawFont(Adm::PublicTD[2], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[2], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[2], 45.000000, 70.000000);
	TextDrawSetOutline(Adm::PublicTD[2], true);
	TextDrawSetShadow(Adm::PublicTD[2], false);
	TextDrawAlignment(Adm::PublicTD[2], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[2], -1);
	TextDrawBackgroundColour(Adm::PublicTD[2], 255);
	TextDrawBoxColour(Adm::PublicTD[2], 50);
	TextDrawUseBox(Adm::PublicTD[2], true);
	TextDrawSetProportional(Adm::PublicTD[2], true);
	TextDrawSetSelectable(Adm::PublicTD[2], true);

	Adm::PublicTD[3] = TextDrawCreate(580.000000, 358.000000, "ld_beat:right");
	TextDrawFont(Adm::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[3], 45.000000, 70.000000);
	TextDrawSetOutline(Adm::PublicTD[3], true);
	TextDrawSetShadow(Adm::PublicTD[3], false);
	TextDrawAlignment(Adm::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[3], -1);
	TextDrawBackgroundColour(Adm::PublicTD[3], 255);
	TextDrawBoxColour(Adm::PublicTD[3], 50);
	TextDrawUseBox(Adm::PublicTD[3], true);
	TextDrawSetProportional(Adm::PublicTD[3], true);
	TextDrawSetSelectable(Adm::PublicTD[3], true);

	Adm::PublicTD[4] = TextDrawCreate(434.000000, 422.000000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[4], 67.500000, 7.500000);
	TextDrawSetOutline(Adm::PublicTD[4], true);
	TextDrawSetShadow(Adm::PublicTD[4], false);
	TextDrawAlignment(Adm::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[4], -1962934017);
	TextDrawBackgroundColour(Adm::PublicTD[4], 255);
	TextDrawBoxColour(Adm::PublicTD[4], 50);
	TextDrawUseBox(Adm::PublicTD[4], true);
	TextDrawSetProportional(Adm::PublicTD[4], true);
	TextDrawSetSelectable(Adm::PublicTD[4], false);

	Adm::PublicTD[5] = TextDrawCreate(510.000000, 422.000000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[5], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[5], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[5], 67.500000, 7.500000);
	TextDrawSetOutline(Adm::PublicTD[5], true);
	TextDrawSetShadow(Adm::PublicTD[5], false);
	TextDrawAlignment(Adm::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[5], 1296911871);
	TextDrawBackgroundColour(Adm::PublicTD[5], 255);
	TextDrawBoxColour(Adm::PublicTD[5], 50);
	TextDrawUseBox(Adm::PublicTD[5], true);
	TextDrawSetProportional(Adm::PublicTD[5], true);
	TextDrawSetSelectable(Adm::PublicTD[5], false);

	Adm::PublicTD[6] = TextDrawCreate(278.000000, 318.000000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[6], 100.000000, 38.500000);
	TextDrawSetOutline(Adm::PublicTD[6], true);
	TextDrawSetShadow(Adm::PublicTD[6], false);
	TextDrawAlignment(Adm::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[6], 9145343);
	TextDrawBackgroundColour(Adm::PublicTD[6], 255);
	TextDrawBoxColour(Adm::PublicTD[6], 50);
	TextDrawUseBox(Adm::PublicTD[6], true);
	TextDrawSetProportional(Adm::PublicTD[6], true);
	TextDrawSetSelectable(Adm::PublicTD[6], true);

	Adm::PublicTD[7] = TextDrawCreate(278.000000, 357.500000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[7], 100.000000, 38.500000);
	TextDrawSetOutline(Adm::PublicTD[7], true);
	TextDrawSetShadow(Adm::PublicTD[7], false);
	TextDrawAlignment(Adm::PublicTD[7], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[7], -764862721);
	TextDrawBackgroundColour(Adm::PublicTD[7], 255);
	TextDrawBoxColour(Adm::PublicTD[7], 50);
	TextDrawUseBox(Adm::PublicTD[7], true);
	TextDrawSetProportional(Adm::PublicTD[7], true);
	TextDrawSetSelectable(Adm::PublicTD[7], true);

	Adm::PublicTD[8] = TextDrawCreate(278.000000, 397.500000, "ld_dual:white");
	TextDrawFont(Adm::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Adm::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Adm::PublicTD[8], 100.000000, 38.500000);
	TextDrawSetOutline(Adm::PublicTD[8], 2);
	TextDrawSetShadow(Adm::PublicTD[8], false);
	TextDrawAlignment(Adm::PublicTD[8], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[8], 1296911871);
	TextDrawBackgroundColour(Adm::PublicTD[8], 255);
	TextDrawBoxColour(Adm::PublicTD[8], 50);
	TextDrawUseBox(Adm::PublicTD[8], true);
	TextDrawSetProportional(Adm::PublicTD[8], true);
	TextDrawSetSelectable(Adm::PublicTD[8], true);

	Adm::PublicTD[9] = TextDrawCreate(330.000000, 331.000000, "VER INVENTARIO");
	TextDrawFont(Adm::PublicTD[9], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Adm::PublicTD[9], 0.250000, 1.500000);
	TextDrawTextSize(Adm::PublicTD[9], 626.500000, 133.000000);
	TextDrawSetOutline(Adm::PublicTD[9], false);
	TextDrawSetShadow(Adm::PublicTD[9], false);
	TextDrawAlignment(Adm::PublicTD[9], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Adm::PublicTD[9], -1);
	TextDrawBackgroundColour(Adm::PublicTD[9], 255);
	TextDrawBoxColour(Adm::PublicTD[9], 50);
	TextDrawUseBox(Adm::PublicTD[9], false);
	TextDrawSetProportional(Adm::PublicTD[9], true);
	TextDrawSetSelectable(Adm::PublicTD[9], false);

	Adm::PublicTD[10] = TextDrawCreate(330.000000, 369.000000, "ABRIR PAINEL");
	TextDrawFont(Adm::PublicTD[10], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Adm::PublicTD[10], 0.250000, 1.500000);
	TextDrawTextSize(Adm::PublicTD[10], 626.500000, 133.000000);
	TextDrawSetOutline(Adm::PublicTD[10], false);
	TextDrawSetShadow(Adm::PublicTD[10], false);
	TextDrawAlignment(Adm::PublicTD[10], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Adm::PublicTD[10], -1);
	TextDrawBackgroundColour(Adm::PublicTD[10], 255);
	TextDrawBoxColour(Adm::PublicTD[10], 50);
	TextDrawUseBox(Adm::PublicTD[10], false);
	TextDrawSetProportional(Adm::PublicTD[10], true);
	TextDrawSetSelectable(Adm::PublicTD[10], false);

	Adm::PublicTD[11] = TextDrawCreate(330.000000, 409.000000, "ESCONDER HUD");
	TextDrawFont(Adm::PublicTD[11], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Adm::PublicTD[11], 0.250000, 1.500000);
	TextDrawTextSize(Adm::PublicTD[11], 626.500000, 133.000000);
	TextDrawSetOutline(Adm::PublicTD[11], false);
	TextDrawSetShadow(Adm::PublicTD[11], false);
	TextDrawAlignment(Adm::PublicTD[11], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Adm::PublicTD[11], -1);
	TextDrawBackgroundColour(Adm::PublicTD[11], 255);
	TextDrawBoxColour(Adm::PublicTD[11], 50);
	TextDrawUseBox(Adm::PublicTD[11], false);
	TextDrawSetProportional(Adm::PublicTD[11], true);
	TextDrawSetSelectable(Adm::PublicTD[11], false);

	Adm::PublicTD[12] = TextDrawCreate(435.000000, 410.000000, "VIDA");
	TextDrawFont(Adm::PublicTD[12], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Adm::PublicTD[12], 0.200000, 1.200000);
	TextDrawTextSize(Adm::PublicTD[12], 594.500000, 142.500000);
	TextDrawSetOutline(Adm::PublicTD[12], false);
	TextDrawSetShadow(Adm::PublicTD[12], false);
	TextDrawAlignment(Adm::PublicTD[12], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[12], -1);
	TextDrawBackgroundColour(Adm::PublicTD[12], 255);
	TextDrawBoxColour(Adm::PublicTD[12], 50);
	TextDrawUseBox(Adm::PublicTD[12], false);
	TextDrawSetProportional(Adm::PublicTD[12], true);
	TextDrawSetSelectable(Adm::PublicTD[12], false);

	Adm::PublicTD[13] = TextDrawCreate(509.000000, 410.000000, "COLETE");
	TextDrawFont(Adm::PublicTD[13], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Adm::PublicTD[13], 0.200000, 1.200000);
	TextDrawTextSize(Adm::PublicTD[13], 594.500000, 142.500000);
	TextDrawSetOutline(Adm::PublicTD[13], false);
	TextDrawSetShadow(Adm::PublicTD[13], false);
	TextDrawAlignment(Adm::PublicTD[13], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Adm::PublicTD[13], -1);
	TextDrawBackgroundColour(Adm::PublicTD[13], 255);
	TextDrawBoxColour(Adm::PublicTD[13], 50);
	TextDrawUseBox(Adm::PublicTD[13], false);
	TextDrawSetProportional(Adm::PublicTD[13], true);
	TextDrawSetSelectable(Adm::PublicTD[13], false);

	return 1;
}

stock Adm::CreatePlayerTD(playerid)
{
	Adm::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 384.000000, 324.000000, "JOGADOR: PLAYER_NAME");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][0], 0.250000, 1.500000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][0], 626.500000, 17.000000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][0], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][0], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][0], false);

	Adm::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 435.000000, 380.000000, "CARGO: APRENDIZ HELPER");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][1], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][1], 594.500000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][1], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][1], false);

	Adm::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 435.000000, 350.000000, "ID: 999");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][2], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][2], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][2], 595.000000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][2], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][2], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][2], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][2], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][2], false);

	Adm::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 434.000000, 422.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][3], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][3], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][3], 45.000000, 7.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][3], true);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][3], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][3], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][3], -16776961);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][3], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][3], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][3], true);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][3], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][3], false);

	Adm::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 510.000000, 422.000000, "ld_dual:white");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][4], TEXT_DRAW_FONT:4);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][4], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][4], 45.000000, 7.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][4], true);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][4], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][4], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][4], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][4], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][4], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][4], true);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][4], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][4], false);

	Adm::PlayerTD[playerid][5] = CreatePlayerTextDraw(playerid, 472.000000, 350.000000, "int: 99 VW: 99");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][5], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][5], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][5], 595.000000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][5], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][5], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][5], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][5], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][5], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][5], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][5], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][5], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][5], false);

	Adm::PlayerTD[playerid][6] = CreatePlayerTextDraw(playerid, 537.000000, 350.000000, "PING: 999");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][6], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][6], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][6], 595.000000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][6], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][6], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][6], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][6], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][6], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][6], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][6], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][6], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][6], false);

	Adm::PlayerTD[playerid][7] = CreatePlayerTextDraw(playerid, 435.000000, 395.000000, "State:");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][7], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][7], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][7], 594.500000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][7], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][7], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][7], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][7], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][7], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][7], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][7], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][7], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][7], false);

	Adm::PlayerTD[playerid][8] = CreatePlayerTextDraw(playerid, 435.000000, 365.000000, "ORG.: ORG_NAME");
	PlayerTextDrawFont(playerid, Adm::PlayerTD[playerid][8], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Adm::PlayerTD[playerid][8], 0.200000, 1.200000);
	PlayerTextDrawTextSize(playerid, Adm::PlayerTD[playerid][8], 594.500000, 142.500000);
	PlayerTextDrawSetOutline(playerid, Adm::PlayerTD[playerid][8], false);
	PlayerTextDrawSetShadow(playerid, Adm::PlayerTD[playerid][8], false);
	PlayerTextDrawAlignment(playerid, Adm::PlayerTD[playerid][8], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Adm::PlayerTD[playerid][8], -1);
	PlayerTextDrawBackgroundColour(playerid, Adm::PlayerTD[playerid][8], 255);
	PlayerTextDrawBoxColour(playerid, Adm::PlayerTD[playerid][8], 50);
	PlayerTextDrawUseBox(playerid, Adm::PlayerTD[playerid][8], false);
	PlayerTextDrawSetProportional(playerid, Adm::PlayerTD[playerid][8], true);
	PlayerTextDrawSetSelectable(playerid, Adm::PlayerTD[playerid][8], false);
}