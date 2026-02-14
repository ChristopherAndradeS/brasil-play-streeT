#include <YSI\YSI_Coding\y_hooks>

stock Login::ShowTDForPlayer(playerid, bool:in_login)
{ 
	if(Login::IsVisibleTDForPlayer(playerid)) return;

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

	Login::CreatePlayerTD(playerid);

    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_TITLE], in_login ? "Login" : "Registro");
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_NAME], name);
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_PASS], in_login ? "Digite sua senha" : "Digite uma senha");

    for(new i = 0; i < 7; i++)
        TextDrawShowForPlayer(playerid, Login::PublicTD[i]);
	for(new i = 0; i < 3; i++)
        PlayerTextDrawShow(playerid, Login::PlayerTD[playerid][i]); 

    SelectTextDraw(playerid, 0xFFFF33FF);
}

stock Login::IsVisibleTDForPlayer(playerid)
	return (IsTextDrawVisibleForPlayer(playerid, Login::PublicTD[0]));

stock Login::HideTDForPlayer(playerid)
{
    for(new i = 0; i < 7; i++)
        TextDrawHideForPlayer(playerid, Login::PublicTD[i]);
    for(new i = 0; i < 3; i++)
        PlayerTextDrawHide(playerid, Login::PlayerTD[playerid][i]); 

	Login::DestroyPlayerTD(playerid);

    CancelSelectTextDraw(playerid);    
}

stock Login::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 3; i++)
	{
        PlayerTextDrawDestroy(playerid, Login::PlayerTD[playerid][i]);
		Login::PlayerTD[playerid][i] = INVALID_PLAYER_TEXT_DRAW;
	}
}

stock Login::CreatePublicTD()
{
	Login::PublicTD[0] = TextDrawCreate(220.000000, 100.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[0], 200.000000, 276.000000);
	TextDrawSetOutline(Login::PublicTD[0], true);
	TextDrawSetShadow(Login::PublicTD[0], false);
	TextDrawAlignment(Login::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[0], 170);
	TextDrawBackgroundColour(Login::PublicTD[0], 255);
	TextDrawBoxColour(Login::PublicTD[0], 50);
	TextDrawUseBox(Login::PublicTD[0], true);
	TextDrawSetProportional(Login::PublicTD[0], true);
	TextDrawSetSelectable(Login::PublicTD[0], false);

	Login::PublicTD[1] = TextDrawCreate(320.000000, 154.500000, "~g~~h~~h~Brasil ~w~Player ~g~~h~~h~Street~n~~n~~g~~h~LOG-IN:");
	TextDrawFont(Login::PublicTD[1], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Login::PublicTD[1], 0.300000, 1.600000);
	TextDrawTextSize(Login::PublicTD[1], 298.500000, 187.500000);
	TextDrawSetOutline(Login::PublicTD[1], false);
	TextDrawSetShadow(Login::PublicTD[1], false);
	TextDrawAlignment(Login::PublicTD[1], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[1], -1);
	TextDrawBackgroundColour(Login::PublicTD[1], 255);
	TextDrawBoxColour(Login::PublicTD[1], 135);
	TextDrawUseBox(Login::PublicTD[1], false);
	TextDrawSetProportional(Login::PublicTD[1], true);
	TextDrawSetSelectable(Login::PublicTD[1], false);

	Login::PublicTD[2] = TextDrawCreate(220.000000, 100.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[2], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[2], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[2], 200.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[2], true);
	TextDrawSetShadow(Login::PublicTD[2], false);
	TextDrawAlignment(Login::PublicTD[2], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[2], 872363007);
	TextDrawBackgroundColour(Login::PublicTD[2], 255);
	TextDrawBoxColour(Login::PublicTD[2], 50);
	TextDrawUseBox(Login::PublicTD[2], true);
	TextDrawSetProportional(Login::PublicTD[2], true);
	TextDrawSetSelectable(Login::PublicTD[2], false);

	Login::PublicTD[3] = TextDrawCreate(230.000000, 217.000000, "USUARIO:");
	TextDrawFont(Login::PublicTD[3], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Login::PublicTD[3], 0.300000, 1.600000);
	TextDrawTextSize(Login::PublicTD[3], 298.500000, 184.500000);
	TextDrawSetOutline(Login::PublicTD[3], false);
	TextDrawSetShadow(Login::PublicTD[3], false);
	TextDrawAlignment(Login::PublicTD[3], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[3], -1);
	TextDrawBackgroundColour(Login::PublicTD[3], 255);
	TextDrawBoxColour(Login::PublicTD[3], 135);
	TextDrawUseBox(Login::PublicTD[3], false);
	TextDrawSetProportional(Login::PublicTD[3], true);
	TextDrawSetSelectable(Login::PublicTD[3], false);

	Login::PublicTD[4] = TextDrawCreate(230.000000, 286.000000, "SENHA:");
	TextDrawFont(Login::PublicTD[4], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Login::PublicTD[4], 0.300000, 1.600000);
	TextDrawTextSize(Login::PublicTD[4], 298.500000, 184.500000);
	TextDrawSetOutline(Login::PublicTD[4], false);
	TextDrawSetShadow(Login::PublicTD[4], false);
	TextDrawAlignment(Login::PublicTD[4], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[4], -1);
	TextDrawBackgroundColour(Login::PublicTD[4], 255);
	TextDrawBoxColour(Login::PublicTD[4], 135);
	TextDrawUseBox(Login::PublicTD[4], false);
	TextDrawSetProportional(Login::PublicTD[4], true);
	TextDrawSetSelectable(Login::PublicTD[4], false);

	Login::PublicTD[5] = TextDrawCreate(230.000000, 302.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[5], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[5], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[5], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[5], true);
	TextDrawSetShadow(Login::PublicTD[5], false);
	TextDrawAlignment(Login::PublicTD[5], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[5], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[5], 255);
	TextDrawBoxColour(Login::PublicTD[5], 50);
	TextDrawUseBox(Login::PublicTD[5], true);
	TextDrawSetProportional(Login::PublicTD[5], true);
	TextDrawSetSelectable(Login::PublicTD[5], true);

	Login::PublicTD[6] = TextDrawCreate(230.000000, 234.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[6], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[6], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[6], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[6], true);
	TextDrawSetShadow(Login::PublicTD[6], false);
	TextDrawAlignment(Login::PublicTD[6], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[6], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[6], 255);
	TextDrawBoxColour(Login::PublicTD[6], 50);
	TextDrawUseBox(Login::PublicTD[6], true);
	TextDrawSetProportional(Login::PublicTD[6], true);
	TextDrawSetSelectable(Login::PublicTD[6], false);
}

stock Login::CreatePlayerTD(playerid)
{
	Login::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 320.000000, 107.000000, "<TITLE>");
	PlayerTextDrawFont(playerid,Login::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid,Login::PlayerTD[playerid][0], 0.449999, 2.400000);
	PlayerTextDrawTextSize(playerid,Login::PlayerTD[playerid][0], 298.500000, 75.000000);
	PlayerTextDrawSetOutline(playerid,Login::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid,Login::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid,Login::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid,Login::PlayerTD[playerid][0], 255);
	PlayerTextDrawBackgroundColour(playerid,Login::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid,Login::PlayerTD[playerid][0], 135);
	PlayerTextDrawUseBox(playerid,Login::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid,Login::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid,Login::PlayerTD[playerid][0], false);
	
	Login::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 235.000000, 242.000000, "<PLAYER_NAME>");
	PlayerTextDrawFont(playerid,Login::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid,Login::PlayerTD[playerid][1], 0.300000, 1.600000);
	PlayerTextDrawTextSize(playerid,Login::PlayerTD[playerid][1], 298.500000, 184.500000);
	PlayerTextDrawSetOutline(playerid,Login::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid,Login::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid,Login::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid,Login::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid,Login::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid,Login::PlayerTD[playerid][1], 135);
	PlayerTextDrawUseBox(playerid,Login::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid,Login::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid,Login::PlayerTD[playerid][1], false);

	Login::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 235.000000, 312.000000, "<PLAYER_PASS>");
	PlayerTextDrawFont(playerid,Login::PlayerTD[playerid][2], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid,Login::PlayerTD[playerid][2], 0.300000, 1.600000);
	PlayerTextDrawTextSize(playerid,Login::PlayerTD[playerid][2], 400.0, 184.500000);
	PlayerTextDrawSetOutline(playerid,Login::PlayerTD[playerid][2], false);
	PlayerTextDrawSetShadow(playerid,Login::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid,Login::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid,Login::PlayerTD[playerid][2], -1);
	PlayerTextDrawBackgroundColour(playerid,Login::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid,Login::PlayerTD[playerid][2], 135);
	PlayerTextDrawUseBox(playerid,Login::PlayerTD[playerid][2], false);
	PlayerTextDrawSetProportional(playerid,Login::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid,Login::PlayerTD[playerid][2], false);
}