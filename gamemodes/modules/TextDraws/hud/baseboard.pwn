#include <YSI\YSI_Coding\y_hooks>


stock Baseboard::UpdateTDForPlayer(playerid, textid, const text[], GLOBAL_TAG_TYPES:...)
{
	PlayerTextDrawSetString(playerid, Baseboard::PlayerTD[playerid][textid], text, ___(3));
}

stock Baseboard::ShowTDForPlayer(playerid)
{
    for(new i = 0; i < 5; i++)
        PlayerTextDrawShow(playerid, Baseboard::PlayerTD[playerid][i]);  
    for(new j = 0; j < 6; j++)
        TextDrawShowForPlayer(playerid, Baseboard::PublicTD[j]);
}

stock Baseboard::HideTDForPlayer(playerid)
{
    for(new i = 0; i < 5; i++)
        PlayerTextDrawHide(playerid, Baseboard::PlayerTD[playerid][i]); 
    for(new i = 0; i < 6; i++)
        TextDrawHideForPlayer(playerid, Baseboard::PublicTD[i]);   
}

stock Baseboard::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 5; i++)
        PlayerTextDrawDestroy(playerid, Baseboard::PlayerTD[playerid][i]);
}

stock Baseboard::CreatePublicTD()
{
	Baseboard::PublicTD[0] = TextDrawCreate(0.000000, 430.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[0], 640.000000, 18.000000);
	TextDrawSetOutline(Baseboard::PublicTD[0], true);
	TextDrawSetShadow(Baseboard::PublicTD[0], false);
	TextDrawAlignment(Baseboard::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[0], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[0], 255);
	TextDrawBoxColour(Baseboard::PublicTD[0], 50);
	TextDrawUseBox(Baseboard::PublicTD[0], true);
	TextDrawSetProportional(Baseboard::PublicTD[0], true);
	TextDrawSetSelectable(Baseboard::PublicTD[0], false);

	Baseboard::PublicTD[1] = TextDrawCreate(0.000000, 433.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[1], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[1], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[1], 640.000000, 18.000000);
	TextDrawSetOutline(Baseboard::PublicTD[1], true);
	TextDrawSetShadow(Baseboard::PublicTD[1], false);
	TextDrawAlignment(Baseboard::PublicTD[1], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[1], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[1], 255);
	TextDrawBoxColour(Baseboard::PublicTD[1], 50);
	TextDrawUseBox(Baseboard::PublicTD[1], true);
	TextDrawSetProportional(Baseboard::PublicTD[1], true);
	TextDrawSetSelectable(Baseboard::PublicTD[1], false);

	Baseboard::PublicTD[2] = TextDrawCreate(565.000000, 433.000000, "00:00~n~12_de_fevereiro_de_2026");
	TextDrawFont(Baseboard::PublicTD[2], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[2], 0.187500, 0.750000);
	TextDrawTextSize(Baseboard::PublicTD[2], 400.000000, 170.500000);
	TextDrawSetOutline(Baseboard::PublicTD[2], false);
	TextDrawSetShadow(Baseboard::PublicTD[2], false);
	TextDrawAlignment(Baseboard::PublicTD[2], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[2], 1157580031);
	TextDrawBackgroundColour(Baseboard::PublicTD[2], 255);
	TextDrawBoxColour(Baseboard::PublicTD[2], 50);
	TextDrawUseBox(Baseboard::PublicTD[2], false);
	TextDrawSetProportional(Baseboard::PublicTD[2], true);
	TextDrawSetSelectable(Baseboard::PublicTD[2], false);

	Baseboard::PublicTD[3] = TextDrawCreate(289.899993, 430.000000, "ld_dual:white");
	TextDrawFont(Baseboard::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Baseboard::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[3], 61.000000, 18.000000);
	TextDrawSetOutline(Baseboard::PublicTD[3], true);
	TextDrawSetShadow(Baseboard::PublicTD[3], false);
	TextDrawAlignment(Baseboard::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Baseboard::PublicTD[3], 872363007);
	TextDrawBackgroundColour(Baseboard::PublicTD[3], 255);
	TextDrawBoxColour(Baseboard::PublicTD[3], 50);
	TextDrawUseBox(Baseboard::PublicTD[3], true);
	TextDrawSetProportional(Baseboard::PublicTD[3], true);
	TextDrawSetSelectable(Baseboard::PublicTD[3], false);

	Baseboard::PublicTD[4] = TextDrawCreate(320.000000, 430.000000, "BPS");
	TextDrawFont(Baseboard::PublicTD[4], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[4], 0.500000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[4], 400.000000, 17.000000);
	TextDrawSetOutline(Baseboard::PublicTD[4], false);
	TextDrawSetShadow(Baseboard::PublicTD[4], false);
	TextDrawAlignment(Baseboard::PublicTD[4], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[4], 255);
	TextDrawBackgroundColour(Baseboard::PublicTD[4], 255);
	TextDrawBoxColour(Baseboard::PublicTD[4], 50);
	TextDrawUseBox(Baseboard::PublicTD[4], false);
	TextDrawSetProportional(Baseboard::PublicTD[4], true);
	TextDrawSetSelectable(Baseboard::PublicTD[4], false);

	Baseboard::PublicTD[5] = TextDrawCreate(319.000000, 431.000000, "BPS");
	TextDrawFont(Baseboard::PublicTD[5], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Baseboard::PublicTD[5], 0.500000, 2.000000);
	TextDrawTextSize(Baseboard::PublicTD[5], 400.000000, 17.000000);
	TextDrawSetOutline(Baseboard::PublicTD[5], false);
	TextDrawSetShadow(Baseboard::PublicTD[5], false);
	TextDrawAlignment(Baseboard::PublicTD[5], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Baseboard::PublicTD[5], -1);
	TextDrawBackgroundColour(Baseboard::PublicTD[5], 255);
	TextDrawBoxColour(Baseboard::PublicTD[5], 50);
	TextDrawUseBox(Baseboard::PublicTD[5], false);
	TextDrawSetProportional(Baseboard::PublicTD[5], true);
	TextDrawSetSelectable(Baseboard::PublicTD[5], false);
}

stock Baseboard::CreatePlayerTD(playerid)
{
	Baseboard::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 45.000000, 434.000000, "CPF: 0");
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

	Baseboard::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 473.333007, 433.000000, "~b~~h~~h~PAYDAY~n~~w~00~b~~h~~h~:~w~00");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][1], 0.187500, 0.750000);
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

	Baseboard::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 228.300003, 434.000000, "~g~~h~~h~R$: 0");
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

	Baseboard::PlayerTD[playerid][3] = CreatePlayerTextDraw(playerid, 401.660003, 434.000000, "L: 0");
	PlayerTextDrawFont(playerid, Baseboard::PlayerTD[playerid][3], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Baseboard::PlayerTD[playerid][3], 0.281250, 1.125000);
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

	Baseboard::PlayerTD[playerid][4] = CreatePlayerTextDraw(playerid, 136.600006, 434.000000, "~y~B$: 0");
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

	return 1;
}