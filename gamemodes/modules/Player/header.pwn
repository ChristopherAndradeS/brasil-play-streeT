#include <YSI\YSI_Coding\y_hooks>

#define MAX_PLAYER_ACESSORYS    (5)
#define MAX_STOCK_ACESSORYS     (8)
#define MAX_PLAYER_VEHICLES     (5)

#define INVALID_SLOTID          (-1)

/*                  PLAYER                  */
enum E_PLAYER 
{
    pyr::pass[16],
    pyr::bitcoin,
    Float:pyr::money,
    Float:pyr::health,
    pyr::score,
    pyr::orgid,
    pyr::flags,
    Text3D:pyr::cpf_tag,

    adm::adminid,
}

enum (<<= 1)
{
    MASK_PLAYER_LOGGED = 1,        
    MASK_PLAYER_IN_REGISTER,  
    MASK_PLAYER_IN_LOGIN,
    MASK_PLAYER_SPECTATING,
    MASK_PLAYER_IN_JAIL,

    MASK_PLAYER_IS_ADM = 256,
    MASK_PLAYER_IN_ORG
}

new Player[MAX_PLAYERS][E_PLAYER];

/*                  PLAYER TIMERS                 */

enum _:E_PLAYER_TIMERS
{
    pyr::TIMER_LOGIN_KICK,
    pyr::TIMER_JAIL,
    pyr::TIMER_PAYDAY,
}

new pyr::Timer[MAX_PLAYERS][E_PLAYER_TIMERS];

/*                  LOGIN                 */

enum E_PLAYER_LOGIN
{
    lgn::input[16],
}

new lgn::Player[MAX_PLAYERS][E_PLAYER_LOGIN];

/*                  PAYDAY                 */
enum E_PLAYER_PAYDAY
{
    pdy::bonus,
    pdy::time_left, 
}

new pdy::Player[MAX_PLAYERS][E_PLAYER_PAYDAY];

/*                  PLAYER ACESSORYS                 */

enum _:AXIS_TYPE
{
    AXIS_TYPE_NONE = -1,
    AXIS_TYPE_X,
    AXIS_TYPE_Y,
    AXIS_TYPE_Z,
}

enum _:MEASUREMENT_TYPE
{
    MEA_TYPE_POSITION,
    MEA_TYPE_ANGLE,
    MEA_TYPE_SCALE,
}

enum E_PLAYER_ACESSORY
{
    acs::modelid,
    acs::slotid,
    acs::boneid,
    Float:acs::pX, Float:acs::pY, Float:acs::pZ,
    Float:acs::rX, Float:acs::rY, Float:acs::rZ,
    Float:acs::sX, Float:acs::sY, Float:acs::sZ,
    acs::color1, acs::color2,

    acs::flags,
    acs::camid,
    Float:acs::pOffset, Float:acs::aOffset, Float:acs::sOffset,
    acs::pAxis, acs::aAxis, acs::sAxis
}

enum (<<= 1)
{    
    MASK_EDITING_ACS = 1, 
}

new acs::Player[MAX_PLAYERS][E_PLAYER_ACESSORY];

/*                  PLAYER FORWARDS                 */
forward Player::Kick(playerid, timerid, const msg[]);

/*                  PLAYER PUBLICS                 */
public Player::Kick(playerid, timerid, const msg[]) 
{    
    Player::KillTimer(playerid, timerid);
    
    if(IsPlayerConnected(playerid))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}%s", msg);
        Kick(playerid);
    }
    
    return 1; 
}

/*                  PLAYER FUNCS                 */
stock IsValidPlayer(playerid)
{
    if(playerid == INVALID_PLAYER_ID)return 0;

    return (IsPlayerConnected(playerid) && IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED));
}

stock Player::ClearAllData(playerid)
{
    Player::ClearData(playerid);
    lgn::ClearData(playerid);
    pdy::ClearData(playerid);
    acs::ClearData(playerid);
}

stock Player::ClearData(playerid)
{
    Player[playerid][pyr::pass]          = '\0';
    Player[playerid][pyr::bitcoin]       = 0;
    Player[playerid][pyr::money]         = 0.0;
    Player[playerid][pyr::flags]         = 0x00000000;
    Player[playerid][pyr::score]         = 0;
    Player[playerid][pyr::orgid]         = 0;
}

stock lgn::ClearData(playerid)
{
    lgn::Player[playerid][lgn::input]     = '\0';
}

stock pdy::ClearData(playerid)
{
    pdy::Player[playerid][pdy::bonus]       = 0;
    pdy::Player[playerid][pdy::time_left]   = 0;
}

stock acs::ClearData(playerid)
{
    acs::Player[playerid][acs::flags]   = 0x00000000;
    acs::Player[playerid][acs::modelid] = INVALID_OBJECT_ID;
    acs::Player[playerid][acs::slotid]  = INVALID_SLOTID;
    acs::Player[playerid][acs::boneid]  = 0;
    acs::Player[playerid][acs::pOffset] = 0.0;
    acs::Player[playerid][acs::aOffset] = 0.0;
    acs::Player[playerid][acs::sOffset] = 0.0;
    acs::Player[playerid][acs::pAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::aAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::sAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::camid]   = 0;
    acs::Player[playerid][acs::pX]      = 0.0;
    acs::Player[playerid][acs::pY]      = 0.0;
    acs::Player[playerid][acs::pZ]      = 0.0;
    acs::Player[playerid][acs::rX]      = 0.0;
    acs::Player[playerid][acs::rY]      = 0.0;
    acs::Player[playerid][acs::rZ]      = 0.0;
    acs::Player[playerid][acs::sX]      = 0.0;
    acs::Player[playerid][acs::sY]      = 0.0;
    acs::Player[playerid][acs::sZ]      = 0.0;
    acs::Player[playerid][acs::color1]  = -1;
    acs::Player[playerid][acs::color2]  = -1;
}

stock Player::LoadData(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    DB::GetDataInt(db_entity, "players", "bitcoin", Player[playerid][pyr::bitcoin], "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);
    DB::GetDataInt(db_entity, "players", "score", Player[playerid][pyr::score], "name = '%q'", name);
    DB::GetDataInt(db_entity, "players", "orgid", Player[playerid][pyr::orgid], "name = '%q'", name);
    DB::GetDataInt(db_entity, "players", "payday_tleft", pdy::Player[playerid][pdy::time_left], "name = '%q'", name);

    return 1;
}

stock Player::CreateTimer(playerid, timerid, const callback[] = "", time, bool:repeate, const specifiers[] = "", OPEN_MP_TAGS:...)
{
    if(IsValidTimer(KillTimer(pyr::Timer[playerid][timerid])))
        return printf("[ TIMER Player ] Erro ao tentar criar Timer #%d (%s [PID : %d]) %d pois já existia", timerid, callback, playerid, time);
    
    pyr::Timer[playerid][timerid] = SetTimerEx(callback, time, repeate, specifiers, ___(6));
    return printf("[ TIMER Player ] Timer #%d (%s [PID : %d]) %d foi criado\n", timerid, callback, playerid, time);
}

stock Player::KillTimer(playerid, timerid)
{
    if(!IsValidTimer(pyr::Timer[playerid][timerid])) return 0;
    
    KillTimer(pyr::Timer[playerid][timerid]);

    pyr::Timer[playerid][timerid] = INVALID_TIMER;
    printf("[ TIMER Player ] Timer #%d ([PID : %d]) foi morto\n", timerid, playerid);
    
    return 1;
}

stock Player::RemoveMoney(playerid, Float:price, bool:takeout = true)
{
    if(floatcmp(Player[playerid][pyr::money], price) >= 0)
    {
        Player[playerid][pyr::money] = takeout ? Player[playerid][pyr::money] - price : Player[playerid][pyr::money];
        
        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name);

        DB::SetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);

        Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %2.f", Player[playerid][pyr::money]);

        return 1;
    }

    return 0;
}

stock Player::GiveMoney(playerid, Float:price)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    Player[playerid][pyr::money] += price;
    
    DB::SetDataFloat(db_entity, "players", "money", Player[playerid][pyr::money], "name = '%q'", name);
    
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %.2f", Player[playerid][pyr::money]);
    
    SendClientMessage(playerid, -1, "{339933} [ R$ ] {ffffff}Voce recebeu {339933}%.2f {ffffff}R$\n", price);
    
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
    
    return 1;   
}

stock Player::IsValidName(name[], &issue)
{        
    if(strlen(name) < 3 || strlen(name) > 20)
    {
        issue = 2;
        return 0;
    }

    issue = 1;

    for(new i = 0; name[i]; i++)
    {
        switch(name[i])
        {
            case '\0': continue;
            case 32: name[i] = '_';
            case 48..57: continue;
            case 65..90: continue;
            case 95: continue;
            case 97..122: continue;
            default: return 0;
        }
    }

    issue = 0;

    return 1;
} 

stock Login::IsValidPassword(const text[], &issue)
{
    if(strlen(text) < 5)
    {
        issue = 1;
        return 0;
    }

    if(strlen(text) > 16)
    {
        issue = 2;
        return 0;
    }

    issue = 0;
    return 1;
}

stock Player::Spawn(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "players", "name", "name = '%q'", name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ERRO FATAL ] {ffffff}Sua conta {ff3333}nao esta registrada {ffffff}houve um erro grave ao spawnar, avise um {ff3333}moderador!");
        Kick(playerid);
        printf("[ DB (ERRO) ] Erro ao tentar carregar posições de spawn do jogador!");
        return 0;
    }

    new skinid, Float:pX, Float:pY, Float:pZ, Float:pA;
    DB::GetDataInt(db_entity, "players", "skinid", skinid, "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "pX", pX, "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "pY", pY, "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "pZ", pZ, "name = '%q'", name);
    DB::GetDataFloat(db_entity, "players", "pA", pA, "name = '%q'", name);

    /* SET SPAWN */

    //new sucess = CA_RayCastLine(pX, pY, pZ + 0.5, x, y, pZ + 0.5, pX, pY, pZ);
    new sucess = 1;

    if(sucess)
        SetSpawnInfo(playerid, 0, 
        skinid, pX, pY, pZ, pA, 
        WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);
    else
    {
        SetSpawnInfo(playerid, 0, skinid, 
        834.28 + RandomFloat(2.0), -1834.89 + RandomFloat(2.0), 12.502, 180.0, 
        WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);

        SendClientMessage(playerid, -1, "{ff9933}[ SERVER ] {ffffff}Seu Spawn anterior era inválido, enviado para spawn civil padrão!");
    }
    
    SpawnPlayer(playerid);

    /* PÓS SPAWN */

    // CPF
    Player::SetCPF(playerid);

    // RODAPÉ
    Baseboard::ShowTDForPlayer(playerid);

    return 1;
}

stock Player::SetCPF(playerid)
{
    new str[64];
    format(str, 64, "{33ff33}CPF: {ffffff}[ {33ff33}%d {ffffff}]", playerid);
    new Text3D:label = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.0, 25.0, playerid, INVALID_VEHICLE_ID, 1);
    Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.4);
    Player[playerid][pyr::cpf_tag] = label;
}