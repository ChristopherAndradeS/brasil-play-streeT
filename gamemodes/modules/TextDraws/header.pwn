#include <YSI\YSI_Coding\y_hooks>

#define Baseboard::    bboard_

new Text:Login::PublicTD[7];
new PlayerText:Login::PlayerTD[MAX_PLAYERS][3];

new Text:Baseboard::PublicTD[13];
new PlayerText:Baseboard::PlayerTD[MAX_PLAYERS][5];

/*  LOGIN  */
enum _:E_TD_LOGIN
{
    Text:TD_LOGIN_SEL = 5,
}

enum _:E_PTD_LOGIN
{
    PlayerText:PTD_LOGIN_TITLE,
    PlayerText:PTD_LOGIN_NAME,
    PlayerText:PTD_LOGIN_PASS,
}

/*  BaseBoard  */

enum _:E_TD_BASEBOARD
{
    Text:TD_BASEBOARD_CLOCK     = 4,
}

enum _:E_PTD_BASEBOARD
{
    PlayerText:PTD_BASEBOARD_CPF,
    PlayerText:PTD_BASEBOARD_PAYDAY,
    PlayerText:PTD_BASEBOARD_MONEY,
    PlayerText:PTD_BASEBOARD_LVL,
    PlayerText:PTD_BASEBOARD_BITCOIN,
}

hook OnGameModeInit()
{
    Login::CreatePublicTD();
    Baseboard::CreatePublicTD();

    printf("[ TEXTDRAW ] TextDraw: Login carregada\n");
    printf("[ TEXTDRAW ] TextDraw: Rodapé carregada\n");

    return 1;
}

hook OnPlayerConnect(playerid)
{
    Login::CreatePlayerTD(playerid);
    Baseboard::CreatePlayerTD(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);

    Login::DestroyPlayerTD(playerid);
    Baseboard::DestroyPlayerTD(playerid);
    return 1;
}