#include <YSI\YSI_Coding\y_hooks>

#define MAX_ACESSORYS           (3)
#define MAX_PLAYER_VEHICLES     (5)

enum (<<= 1)
{
    MASK_PLAYER_LOGGED = 1,        
    MASK_PLAYER_IN_REGISTER,  
    MASK_PLAYER_IN_LOGIN,

    MASK_PLAYER_IS_ADM = 256,
    MASK_PLAYER_IN_ORG
}

enum _:E_PLAYER_TIMERS
{
    pyr::TIMER_LOGIN_KICK,
}

new pyr::Timer[MAX_PLAYERS][E_PLAYER_TIMERS];

enum E_PLAYER 
{
    pyr::pass[16],
    pyr::payday_tleft,
    pyr::bitcoin,
    Float:pyr::money,
    Float:pyr::health,
    pyr::score,
    pyr::orgid,
    pyr::flags,
    Text3D:pyr::cpf_tag,
}

new Player[MAX_PLAYERS][E_PLAYER];

enum E_PLAYER_LOGIN
{
    lgn::input[16],
    lgn::timerid,
}

new lgn::Player[MAX_PLAYERS][E_PLAYER_LOGIN];

enum E_PLAYER_PAYDAY
{
    pdy::bonus,
    pdy::time_left,
    pdy::timerid,
}

new pdy::Player[MAX_PLAYERS][E_PLAYER_PAYDAY];

enum E_PLAYER_ACESSORY
{
    acs:vehicleid,
    acs::modelid,
    acs::boneid,
    Float:acs::pX, Float:acs::pY, Float:acs::pZ,
    Float:acs::rX, Float:acs::rY, Float:acs::rZ,
    Float:acs::sX, Float:acs::sY, Float:acs::sZ,
}

enum E_PLAYER_VEHICLE
{
    veh::modelid,
    Float:veh::pX, Float:veh::pY, Float:veh::pZ, Float:veh::pA, 
    veh::color1, veh::color2
}

new acs::Player[MAX_PLAYERS][MAX_ACESSORYS][E_PLAYER_ACESSORY];
new veh::Player[MAX_PLAYERS][MAX_PLAYER_VEHICLES][E_PLAYER_VEHICLE];

forward Player::Kick(playerid, timerid, const msg[], GLOBAL_TAG_TYPES:...);

public Player::Kick(playerid, timerid, const msg[]) 
{    
    KillTimer(pyr::Timer[playerid][timerid]);
    
    if(IsPlayerConnected(playerid))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}%s", msg);
        Kick(playerid);
    }
    return 1; 
}

stock IsValidPlayer(playerid)
    return (IsPlayerConnected(playerid) && Player::IsFlagSet(playerid, MASK_PLAYER_LOGGED));

stock Player::SetFlag(playerid, tag_binary) 
    Player[playerid][pyr::flags] |= tag_binary;

stock Player::ResetFlag(playerid, tag_binary) 
    Player[playerid][pyr::flags] &= ~tag_binary;

stock Player::IsFlagSet(playerid, tag_binary) 
    return (Player[playerid][pyr::flags] & tag_binary);

stock Player::ClearAllFlags(playerid) 
    return (Player[playerid][pyr::flags] = 0x00000000);

stock Player::ClearAllData(playerid)
{
    Player::ClearData(playerid);
}

stock Player::ClearData(playerid)
{
    Player[playerid][pyr::pass]          = '\0';
    Player[playerid][pyr::payday_tleft] = 0;
    Player[playerid][pyr::bitcoin]       = 0;
    Player[playerid][pyr::money]         = 0.0;
    Player[playerid][pyr::score]         = 0;
    Player[playerid][pyr::orgid]         = 0;

    Player::ClearAllFlags(playerid); 
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

stock Player::SetToSpawn(playerid)
{
    new name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);

    // Adicionar kick player
    if(!Database::GetRowCount("players", "name", name, _))
    {
        printf("[ DB (ERRO) ] Erro ao tentar carregar posições de spawn do jogador!");
        return 0;
    }

    SetSpawnInfo(playerid, 0, 
    Database::LoadDataInt("players", "name", name, "skinid"), 
    Database::LoadDataFloat("players", "name", name, "pX"),
    Database::LoadDataFloat("players", "name", name, "pY"),
    Database::LoadDataFloat("players", "name", name, "pZ"),
    Database::LoadDataFloat("players", "name", name, "pA"),  WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0, WEAPON:0);
    
    Player::SetFlag(playerid, MASK_PLAYER_LOGGED);

    KillTimer(pyr::Timer[playerid][pyr::TIMER_LOGIN_KICK]);
    pyr::Timer[playerid][pyr::TIMER_LOGIN_KICK] = INVALID_TIMER;

    TogglePlayerSpectating(playerid, false);
    TogglePlayerClock(playerid, true);
    
    SpawnPlayer(playerid);

    new str[64];
    format(str, 64, "{33ff33}CPF: {ffffff}[ {33ff33}%d {ffffff}]", playerid);

    new Text3D:label = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.0, 25.0, playerid, INVALID_VEHICLE_ID, 1);

    Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.4);

    Player[playerid][pyr::cpf_tag] = label;

    Baseboard::ShowTDForPlayer(playerid);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_CPF, "CPF: %d", playerid);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_MONEY, "~g~~h~~h~R$: %2.f", Player[playerid][pyr::money]);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_LVL, "L: %d", Player[playerid][pyr::score]);
    Baseboard::UpdateTDForPlayer(playerid, PTD_BASEBOARD_BITCOIN, "~y~B$: %d", Player[playerid][pyr::bitcoin]);

    CallLocalFunction("OnPlayerLogin", "i", playerid);

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

stock Player::GenerateFakeCPFFromName(const name[], output[], size)
{
    new hash;
    
    hash = hashname(name);
    norm_hash(hash);
    
    new digits[11];
 
    for(new i = 0; i < 8; i++)
    {
        new nibble = (hash >> (i * 4)) & 0xF;

        if (nibble <= 9)
            digits[i] = nibble;
        else
            digits[i] = nibble % 10;
    }

    new year, month, day;
    getdate(year, month, day);

    new sum = 0;
    for(new i = 0; i < 10; i++)
        sum += digits[i];

    digits[8] = sum % 9; 

    digits[9] =  floatround((year / 10) % 10);
    digits[10] = (year % 100) % 10; 

    format(output, size,
        "%d%d%d.%d%d%d.%d%d%d-%d%d",
        digits[0], digits[1], digits[2],
        digits[3], digits[4], digits[5],
        digits[6], digits[7], digits[8],
        digits[9], digits[10]);
}