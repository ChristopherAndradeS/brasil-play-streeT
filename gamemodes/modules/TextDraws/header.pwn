new Text:Login::PublicTD[7] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Login::PlayerTD[MAX_PLAYERS][3] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Baseboard::PublicTD[13] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Baseboard::PlayerTD[MAX_PLAYERS][5] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Acessory::PublicTD[21] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Acessory::PlayerTD[MAX_PLAYERS][14] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Adm::PublicTD[14] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Adm::PlayerTD[MAX_PLAYERS][9] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Veh::PublicTD[11] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Veh::PlayerTD[MAX_PLAYERS][18] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new PlayerText:Travel::PlayerTD[MAX_PLAYERS][2] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Dealership::PublicTD[13] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Dealership::PlayerTD[MAX_PLAYERS][5] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

new Text:Garage::PublicTD[12]  = {INVALID_TEXT_DRAW, ...};
new PlayerText:Garage::PlayerTD[MAX_PLAYERS][7] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

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

/*  Admin  */

enum _:E_TD_ADMIN
{
    Text:TD_ADM_BTN_LEFT = 2,
    Text:TD_ADM_BTN_RIGHT = 3, 
    Text:TD_ADM_BTN_VIEW_INV = 6,
    Text:TD_ADM_BTN_PANEL = 7,
    Text:TD_ADM_BTN_HIDE = 8,
}

enum _:E_PTD_ADMIN
{
    PlayerText:PTD_ADM_TXT_NAME,
    PlayerText:PTD_ADM_TXT_ROLE,
    PlayerText:PTD_ADM_TXT_ID,
    PlayerText:PTD_ADM_BAR_HEALTH,
    PlayerText:PTD_ADM_BAR_ARMOUR,
    PlayerText:PTD_ADM_TXT_WORLD,
    PlayerText:PTD_ADM_TXT_PING,
    PlayerText:PTD_ADM_TXT_STATE,
    PlayerText:PTD_ADM_TXT_ORGNAME,
}

/*  Velocimetro  */

enum _:E_PTD_VEH
{
    PlayerText:PTD_VEH_BAR_FUEL,
    PlayerText:PTD_VEH_TXT_SPEED,
    PlayerText:PTD_VEH_BAR_HEALTH,
    PlayerText:PTD_VEH_BAR_ARMOUR,
    PlayerText:PTD_VEH_FIRST_DOT = 4,
    PlayerText:PTD_VEH_LAST_DOT  = 16,
    PlayerText:PTD_VEH_TXT_NAME = 17,
}

/*  DealerShip  */

enum _:E_TD_DSP
{
    Text:TD_DSP_BTN_PREV = 3,
    Text:TD_DSP_BTN_NEXT = 4,
    Text:TD_DSP_BTN_BUY = 7,
    Text:TD_DSP_BTN_QUIT = 6,
    Text:TD_DSP_BTN_HIDE = 9,
    Text:TD_DSP_BTN_CAT = 8,
}

enum _:E_PTD_DSP
{
    PlayerText:PTD_DSP_TXT_NAME,
    PlayerText:PTD_DSP_TXT_PRICE,
    PlayerText:PTD_DSP_SPR_COLOR1,
    PlayerText:PTD_DSP_SPR_COLOR2,
    PlayerText:PTD_DSP_TXT_HIDE,
}

/*  DealerShip  */

enum _:E_TD_GRG
{
    Text:TD_GRG_BTN_PREV = 9,
    Text:TD_GRG_BTN_NEXT = 10,
}

enum _:E_PTD_GRG
{
    PlayerText:PTD_GRG_TXT_NAME,
    PlayerText:PTD_GRG_BAR_HEALTH,
    PlayerText:PTD_GRG_BAR_FUEL,
    PlayerText:PTD_GRG_BAR_ARMOUR,
    PlayerText:PTD_GRG_TXT_PAGE,
    PlayerText:PTD_GRG_SPR_COLOR1,
    PlayerText:PTD_GRG_SPR_COLOR2,
}
