#define MAX_PASSWORD_LEN (16)

enum E_PLAYER_LOGIN
{
    lgn::input[MAX_PASSWORD_LEN],
}

new lgn::Player[MAX_PLAYERS][E_PLAYER_LOGIN];

forward OnPlayerLogin(playerid);
forward OnPlayerPasswordHash(playerid, hashid);
forward OnPlayerPasswordVerify(playerid, bool:success);

new gLoginIssue[][64] = 
{
    {"sem problemas"}, {"pequena demais"}, {"grande demais"}
};

stock Login::SetPlayer(playerid)
{
    Player::CreateTimer(playerid, pyr::TIMER_LOGIN_KICK, "PYR_Kick", LOGIN_MUSIC_MS, false, "iis", 
    playerid, 
    _:pyr::TIMER_LOGIN_KICK, 
    "Demorou muito para fazer login!");
    
    TogglePlayerSpectating(playerid, true);

    TogglePlayerControllable(playerid, false);

    PlayAudioStreamForPlayer(playerid, LOGIN_MUSIC_URL);

    ClearChat(playerid, 25);
 
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "players", "name = '%q'", name))
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Parece que voce e {33ff33}novo aqui!{ffffff}, faca o registro para poder jogar!");
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER);
        Login::ShowTDForPlayer(playerid, false);
    }

    else
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Seja bem-vindo novamente, faca o {33ff33}login {ffffff}para poder jogar!");
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN);
        Login::ShowTDForPlayer(playerid, true);
    }
}

stock Login::UnSetPlayer(playerid)
{
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN);
    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED);
    
    Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);

    Login::HideTDForPlayer(playerid);
    Player::LoadData(playerid);
    StopAudioStreamForPlayer(playerid);
    TogglePlayerSpectating(playerid, false);
    TogglePlayerControllable(playerid, true);
    TogglePlayerClock(playerid, true);

    CallLocalFunction("OnPlayerLogin", "i", playerid);

    return 1; 
}

stock Login::RegisterPlayer(playerid)
{
    new name[MAX_PLAYER_NAME], ip[16];
    GetPlayerName(playerid, name);
    GetPlayerIp(playerid, ip);

    new status = DB::Insert(db_entity, "players", 
    "name, pass, ip, payday_tleft, bitcoin, money, pX, pY, pZ, pA, score, skinid", 
    "'%q', '%q', '%q', %i, %i, %f, %f, %f, %f, %f, %i, %i", name, Player[playerid][pyr::pass], ip, 
    3600000, 0, 500.0, 834.28 + RandomFloat(2.0), -1834.89 + RandomFloat(2.0), 12.502, 180.0,
    1, random(300));

    if(status)
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Sua conta foi {33ff33}registrada {ffffff}com sucesso!");
        return 1;
    }

    SendClientMessage(playerid, -1, "{ff3333}[ ERRO FATAL ] {ffffff}Sua conta {ff3333}nao foi registrada {ffffff}houve um erro grave, avise um {ff3333}moderador!");
    Kick(playerid);

    return 0;
}


stock Login::IsValidPassword(const text[], &issue)
{
    if(strlen(text) < 5)
    {
        issue = 1;
        return 0;
    }

    if(strlen(text) > MAX_PASSWORD_LEN)
    {
        issue = 2;
        return 0;
    }

    issue = 0;

    return 1;
}

stock lgn::ClearData(playerid)
{
    lgn::Player[playerid][lgn::input]     = '\0';
}
