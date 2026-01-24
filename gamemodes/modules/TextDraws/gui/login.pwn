#include <YSI\YSI_Coding\y_hooks>

stock Login::UpdateTDForPlayer(playerid, const title[], const pass[])
{
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_TITLE], title);
    
    if(isnull(pass)) return;

    new str_pass[32];

    for(new i = 0; i < strlen(pass); i++)
        format(str_pass, 32, "%s%c", str_pass, '.');

    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_PASS], str_pass);
}

stock Login::ShowTDForPlayer(playerid, bool:in_login)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    for(new i = 0; i < 3; i++)
        PlayerTextDrawShow(playerid, Login::PlayerTD[playerid][i]);  
    for(new j = 0; j < 14; j++)
        TextDrawShowForPlayer(playerid, Login::PublicTD[j]);

    Login::UpdateTDForPlayer(playerid, in_login ? "Login" : "Registro", "/0");

    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_NAME], name);
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][PTD_LOGIN_PASS], in_login ? "Digite sua senha" : "Digite uma senha");

    SelectTextDraw(playerid, 0xFFFF33FF);
}

stock Login::HideTDForPlayer(playerid)
{
    for(new i = 0; i < 14; i++)
        TextDrawHideForPlayer(playerid, Login::PublicTD[i]);
    for(new i = 0; i < 3; i++)
        PlayerTextDrawHide(playerid, Login::PlayerTD[playerid][i]); 

    CancelSelectTextDraw(playerid);    
}

stock Login::DestroyPlayerTD(playerid)
{
    for(new i = 0; i < 3; i++)
        PlayerTextDrawDestroy(playerid, Login::PlayerTD[playerid][i]);
}

stock Login::CreatePublicTD()
{
	Login::PublicTD[0] = TextDrawCreate(220.000000, 48.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[0], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[0], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[0], 200.000000, 276.000000);
	TextDrawSetOutline(Login::PublicTD[0],true);
	TextDrawSetShadow(Login::PublicTD[0], false);
	TextDrawAlignment(Login::PublicTD[0], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[0], 170);
	TextDrawBackgroundColour(Login::PublicTD[0], 255);
	TextDrawBoxColour(Login::PublicTD[0], 50);
	TextDrawUseBox(Login::PublicTD[0], false);
	TextDrawSetProportional(Login::PublicTD[0], true);
	TextDrawSetSelectable(Login::PublicTD[0], false);
	
	Login::PublicTD[1] = TextDrawCreate(320.000000, 102.500000, "~g~~h~~h~Brasil ~w~Player ~g~~h~~h~Street~n~~n~~g~~h~LOG-IN:");
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

	Login::PublicTD[2] = TextDrawCreate(220.000000, 48.000000, "ld_dual:white");
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

	Login::PublicTD[3] = TextDrawCreate(230.000000, 182.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[3], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[3], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[3], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[3], true);
	TextDrawSetShadow(Login::PublicTD[3], false);
	TextDrawAlignment(Login::PublicTD[3], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[3], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[3], 255);
	TextDrawBoxColour(Login::PublicTD[3], 50);
	TextDrawUseBox(Login::PublicTD[3], true);
	TextDrawSetProportional(Login::PublicTD[3], true);
	TextDrawSetSelectable(Login::PublicTD[3], false);

	Login::PublicTD[4] = TextDrawCreate(220.000000, 48.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[4], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[4], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[4], 200.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[4], true);
	TextDrawSetShadow(Login::PublicTD[4], false);
	TextDrawAlignment(Login::PublicTD[4], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[4], 872363007);
	TextDrawBackgroundColour(Login::PublicTD[4], 255);
	TextDrawBoxColour(Login::PublicTD[4], 50);
	TextDrawUseBox(Login::PublicTD[4], true);
	TextDrawSetProportional(Login::PublicTD[4], true);
	TextDrawSetSelectable(Login::PublicTD[4], false);

	Login::PublicTD[5] = TextDrawCreate(230.000000, 165.000000, "USUARIO:");
	TextDrawFont(Login::PublicTD[5], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Login::PublicTD[5], 0.300000, 1.600000);
	TextDrawTextSize(Login::PublicTD[5], 298.500000, 184.500000);
	TextDrawSetOutline(Login::PublicTD[5], false);
	TextDrawSetShadow(Login::PublicTD[5], false);
	TextDrawAlignment(Login::PublicTD[5], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[5], -1);
	TextDrawBackgroundColour(Login::PublicTD[5], 255);
	TextDrawBoxColour(Login::PublicTD[5], 135);
	TextDrawUseBox(Login::PublicTD[5], false);
	TextDrawSetProportional(Login::PublicTD[5], true);
	TextDrawSetSelectable(Login::PublicTD[5], false);

	Login::PublicTD[6] = TextDrawCreate(230.000000, 234.000000, "SENHA:");
	TextDrawFont(Login::PublicTD[6], TEXT_DRAW_FONT:2);
	TextDrawLetterSize(Login::PublicTD[6], 0.300000, 1.600000);
	TextDrawTextSize(Login::PublicTD[6], 298.500000, 184.500000);
	TextDrawSetOutline(Login::PublicTD[6], false);
	TextDrawSetShadow(Login::PublicTD[6], false);
	TextDrawAlignment(Login::PublicTD[6], TEXT_DRAW_ALIGN:1);
	TextDrawColour(Login::PublicTD[6], -1);
	TextDrawBackgroundColour(Login::PublicTD[6], 255);
	TextDrawBoxColour(Login::PublicTD[6], 135);
	TextDrawUseBox(Login::PublicTD[6], false);
	TextDrawSetProportional(Login::PublicTD[6], true);
	TextDrawSetSelectable(Login::PublicTD[6], false);

	Login::PublicTD[7] = TextDrawCreate(230.000000, 250.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[7], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[7], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[7], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[7], true);
	TextDrawSetShadow(Login::PublicTD[7], false);
	TextDrawAlignment(Login::PublicTD[7], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[7], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[7], 255);
	TextDrawBoxColour(Login::PublicTD[7], 50);
	TextDrawUseBox(Login::PublicTD[7], true);
	TextDrawSetProportional(Login::PublicTD[7], true);
	TextDrawSetSelectable(Login::PublicTD[7], false);

	Login::PublicTD[8] = TextDrawCreate(230.000000, 250.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[8], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[8], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[8], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[8], true);
	TextDrawSetShadow(Login::PublicTD[8], false);
	TextDrawAlignment(Login::PublicTD[8], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[8], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[8], 255);
	TextDrawBoxColour(Login::PublicTD[8], 50);
	TextDrawUseBox(Login::PublicTD[8], true);
	TextDrawSetProportional(Login::PublicTD[8], true);
	TextDrawSetSelectable(Login::PublicTD[8], false);

	Login::PublicTD[9] = TextDrawCreate(230.000000, 182.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[9], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[9], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[9], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[9], true);
	TextDrawSetShadow(Login::PublicTD[9], false);
	TextDrawAlignment(Login::PublicTD[9], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[9], 867906559);
	TextDrawBackgroundColour(Login::PublicTD[9], 255);
	TextDrawBoxColour(Login::PublicTD[9], 50);
	TextDrawUseBox(Login::PublicTD[9], true);
	TextDrawSetProportional(Login::PublicTD[9], true);
	TextDrawSetSelectable(Login::PublicTD[9], false);

	Login::PublicTD[10] = TextDrawCreate(230.000000, 182.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[10], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[10], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[10], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[10], true);
	TextDrawSetShadow(Login::PublicTD[10], false);
	TextDrawAlignment(Login::PublicTD[10], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[10], 867906304);
	TextDrawBackgroundColour(Login::PublicTD[10], 255);
	TextDrawBoxColour(Login::PublicTD[10], 50);
	TextDrawUseBox(Login::PublicTD[10], true);
	TextDrawSetProportional(Login::PublicTD[10], true);
	TextDrawSetSelectable(Login::PublicTD[10], false);

	Login::PublicTD[11] = TextDrawCreate(230.000000, 250.000000, "ld_dual:white");
	TextDrawFont(Login::PublicTD[11], TEXT_DRAW_FONT:4);
	TextDrawLetterSize(Login::PublicTD[11], 0.600000, 2.000000);
	TextDrawTextSize(Login::PublicTD[11], 180.000000, 35.000000);
	TextDrawSetOutline(Login::PublicTD[11], true);
	TextDrawSetShadow(Login::PublicTD[11], false);
	TextDrawAlignment(Login::PublicTD[11], TEXT_DRAW_ALIGN:2);
	TextDrawColour(Login::PublicTD[11], 867906304);
	TextDrawBackgroundColour(Login::PublicTD[11], 255);
	TextDrawBoxColour(Login::PublicTD[11], 50);
	TextDrawUseBox(Login::PublicTD[11], true);
	TextDrawSetProportional(Login::PublicTD[11], true);
	TextDrawSetSelectable(Login::PublicTD[11], true);

	// Login::PublicTD[12] = TextDrawCreate(245.000000, 314.000000, "ld_dual:white");
	// TextDrawFont(Login::PublicTD[12], TEXT_DRAW_FONT:4);
	// TextDrawLetterSize(Login::PublicTD[12], 0.600000, 2.000000);
	// TextDrawTextSize(Login::PublicTD[12], 150.000000, 44.000000);
	// TextDrawSetOutline(Login::PublicTD[12], true);
	// TextDrawSetShadow(Login::PublicTD[12], false);
	// TextDrawAlignment(Login::PublicTD[12], TEXT_DRAW_ALIGN:2);
	// TextDrawColour(Login::PublicTD[12], 872363007);
	// TextDrawBackgroundColour(Login::PublicTD[12], 255);
	// TextDrawBoxColour(Login::PublicTD[12], 50);
	// TextDrawUseBox(Login::PublicTD[12], true);
	// TextDrawSetProportional(Login::PublicTD[12], true);
	// TextDrawSetSelectable(Login::PublicTD[12], true);

	// Login::PublicTD[13] = TextDrawCreate(320.000000, 324.000000, "CONFIRMAR");
	// TextDrawFont(Login::PublicTD[13], TEXT_DRAW_FONT:2);
	// TextDrawLetterSize(Login::PublicTD[13], 0.449999, 2.400000);
	// TextDrawTextSize(Login::PublicTD[13], 298.500000, 75.000000);
	// TextDrawSetOutline(Login::PublicTD[13], false);
	// TextDrawSetShadow(Login::PublicTD[13], false);
	// TextDrawAlignment(Login::PublicTD[13], TEXT_DRAW_ALIGN:2);
	// TextDrawColour(Login::PublicTD[13], 255);
	// TextDrawBackgroundColour(Login::PublicTD[13], 255);
	// TextDrawBoxColour(Login::PublicTD[13], 135);
	// TextDrawUseBox(Login::PublicTD[13], false);
	// TextDrawSetProportional(Login::PublicTD[13], true);
	// TextDrawSetSelectable(Login::PublicTD[13], false);   
}

stock Login::CreatePlayerTD(playerid)
{
	Login::PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 320.000000, 55.000000, "<TITLE>");
	PlayerTextDrawFont(playerid, Login::PlayerTD[playerid][0], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Login::PlayerTD[playerid][0], 0.449999, 2.400000);
	PlayerTextDrawTextSize(playerid, Login::PlayerTD[playerid][0], 298.500000, 75.000000);
	PlayerTextDrawSetOutline(playerid, Login::PlayerTD[playerid][0], false);
	PlayerTextDrawSetShadow(playerid, Login::PlayerTD[playerid][0], false);
	PlayerTextDrawAlignment(playerid, Login::PlayerTD[playerid][0], TEXT_DRAW_ALIGN:2);
	PlayerTextDrawColour(playerid, Login::PlayerTD[playerid][0], 255);
	PlayerTextDrawBackgroundColour(playerid, Login::PlayerTD[playerid][0], 255);
	PlayerTextDrawBoxColour(playerid, Login::PlayerTD[playerid][0], 135);
	PlayerTextDrawUseBox(playerid, Login::PlayerTD[playerid][0], false);
	PlayerTextDrawSetProportional(playerid, Login::PlayerTD[playerid][0], true);
	PlayerTextDrawSetSelectable(playerid, Login::PlayerTD[playerid][0], false);

	Login::PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 235.000000, 260.000000, "DIGITE_SUA_SENHA");
	PlayerTextDrawFont(playerid, Login::PlayerTD[playerid][1], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Login::PlayerTD[playerid][1], 0.300000, 1.600000);
	PlayerTextDrawTextSize(playerid, Login::PlayerTD[playerid][1], 400.500000, 184.500000);
	PlayerTextDrawSetOutline(playerid, Login::PlayerTD[playerid][1], false);
	PlayerTextDrawSetShadow(playerid, Login::PlayerTD[playerid][1], false);
	PlayerTextDrawAlignment(playerid, Login::PlayerTD[playerid][1], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Login::PlayerTD[playerid][1], -1);
	PlayerTextDrawBackgroundColour(playerid, Login::PlayerTD[playerid][1], 255);
	PlayerTextDrawBoxColour(playerid, Login::PlayerTD[playerid][1], 135);
	PlayerTextDrawUseBox(playerid, Login::PlayerTD[playerid][1], false);
	PlayerTextDrawSetProportional(playerid, Login::PlayerTD[playerid][1], true);
	PlayerTextDrawSetSelectable(playerid, Login::PlayerTD[playerid][1], false);

	Login::PlayerTD[playerid][2] = CreatePlayerTextDraw(playerid, 235.000000, 190.000000, "<PLAYER_NAME>");
	PlayerTextDrawFont(playerid, Login::PlayerTD[playerid][2], TEXT_DRAW_FONT:2);
	PlayerTextDrawLetterSize(playerid, Login::PlayerTD[playerid][2], 0.300000, 1.600000);
	PlayerTextDrawTextSize(playerid, Login::PlayerTD[playerid][2], 298.500000, 184.500000);
	PlayerTextDrawSetOutline(playerid, Login::PlayerTD[playerid][2], false);
	PlayerTextDrawSetShadow(playerid, Login::PlayerTD[playerid][2], false);
	PlayerTextDrawAlignment(playerid, Login::PlayerTD[playerid][2], TEXT_DRAW_ALIGN:1);
	PlayerTextDrawColour(playerid, Login::PlayerTD[playerid][2], -1);
	PlayerTextDrawBackgroundColour(playerid, Login::PlayerTD[playerid][2], 255);
	PlayerTextDrawBoxColour(playerid, Login::PlayerTD[playerid][2], 135);
	PlayerTextDrawUseBox(playerid, Login::PlayerTD[playerid][2], false);
	PlayerTextDrawSetProportional(playerid, Login::PlayerTD[playerid][2], true);
	PlayerTextDrawSetSelectable(playerid, Login::PlayerTD[playerid][2], false);
}