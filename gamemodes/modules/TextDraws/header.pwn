#include <YSI\YSI_Coding\y_hooks>

new Text:Login::PublicTD[7];
new PlayerText:Login::PlayerTD[MAX_PLAYERS][3];

new Text:Baseboard::PublicTD[13];
new PlayerText:Baseboard::PlayerTD[MAX_PLAYERS][5];

new Text:Acessory::PublicTD[21];
new PlayerText:Acessory::PlayerTD[MAX_PLAYERS][14];

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

/*  Acessory  */

enum _:E_TD_ACESSORY
{
    Text:TD_ACS_OFFSET_POS_MINUS    = 3,
    Text:TD_ACS_OFFSET_ANG_MINUS    = 4,
    Text:TD_ACS_OFFSET_SCL_MINUS    = 5,
    Text:TD_ACS_OFFSET_POS_PLUS     = 6,
    Text:TD_ACS_OFFSET_ANG_PLUS     = 7,
    Text:TD_ACS_OFFSET_SCL_PLUS     = 8,
    Text:TD_ACS_SAVE_BTN            = 9,
    Text:TD_ACS_CHANGE_VIEW_BTN     = 10,
    Text:TD_ACS_EXIT_BTN            = 11,
    Text:TD_ACS_OFFSET_POS_BTN      = 14,
    Text:TD_ACS_OFFSET_ANG_BTN      = 15,
    Text:TD_ACS_OFFSET_SCL_BTN      = 16,
}

enum _:E_PTD_ACESSORY
{
    PlayerText:PTD_ACS_MODEL_1,
    PlayerText:PTD_ACS_MODEL_2,
    PlayerText:PTD_ACS_MODEL_3,
    PlayerText:PTD_ACS_MODEL_4,
    PlayerText:PTD_ACS_MODEL_5,
    PlayerText:PTD_ACS_OFFSET_POS,
    PlayerText:PTD_ACS_OFFSET_ANG,
    PlayerText:PTD_ACS_OFFSET_SCL,
    PlayerText:PTD_ACS_POS_AXIS_BTN,
    PlayerText:PTD_ACS_ANG_AXIS_BTN,
    PlayerText:PTD_ACS_SCL_AXIS_BTN,
    PlayerText:PTD_ACS_POS_AXIS,
    PlayerText:PTD_ACS_ANG_AXIS,
    PlayerText:PTD_ACS_SCL_AXIS,
}

hook OnGameModeInit()
{
    Login::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Login carregada\n");

    Baseboard::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Rodapé carregada\n");

    Acessory::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Editor de acessórios carregada\n");
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