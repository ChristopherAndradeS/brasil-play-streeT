#include <YSI\YSI_Coding\y_hooks>

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
    {"sem problemas"},
    {"pequena demais"},
    {"grande demais"}
};

public OnPlayerPasswordHash(playerid, hashid)
{
    #pragma unused hashid

    if(!IsPlayerConnected(playerid) || !GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER))
        return 1;

    bcrypt_get_hash(Player[playerid][pyr::pass]);

    if(!Player[playerid][pyr::pass][0])
    {
        lgn::Player[playerid][lgn::input] = '\0';
        SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Nao foi possivel proteger sua senha, tente novamente.");
        return 1;
    }

    Login::RegisterPlayer(playerid);
    Login::UnSetPlayer(playerid);

    return 1;
}

hook OnPlayerPasswordVerify(playerid, bool:success)
{
    if(!IsPlayerConnected(playerid)) return 1;

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN))
    {
        if(!success)
        {
            lgn::Player[playerid][lgn::input] = '\0';
            SendClientMessage(playerid, -1, "{ff3333}[ x ] {ffffff}Senha incorreta! Clique novamente para tentar.");
            return 1;
        }

        Login::UnSetPlayer(playerid);
    }

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER) && !GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN))
        return 1;
    
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        SelectTextDraw(playerid, 0x99FF99FF);
        return 1;
    }

    if(clickedid == Login::PublicTD[TD_LOGIN_SEL])
    {
        inline dialog_register(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER))
                return 1;

            if(!sresponse)
            {
                SendClientMessage(playerid, -1, "{ffff33}[ ! ] {ffffff}Voce precisa digitar uma {ffff33}senha!"); 
                return 1;
            }
            
            new issue;
            
            if(!Login::IsValidPassword(stext, issue))
            {
                new str[128];
                format(str, sizeof(str), "{ff3333}[ x ] {ffffff}Sua senha esta {ff3333}%s!\n\n\
                >> {ffffff}Digite uma {33ff33}senha {ffffff}novamente:", gLoginIssue[issue]);
                Dialog_ShowCallback(playerid, using inline dialog_register, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
                return 1;
            }

            format(lgn::Player[playerid][lgn::input], MAX_PASSWORD_LEN, "%s", stext);

            if(!bcrypt_hash(playerid, "OnPlayerPasswordHash", stext, BCRYPT_COST))
            {
                SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Nao foi possivel criptografar sua senha no momento.");
                return 1;
            }

            SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Processando sua senha de forma segura...");

            return 1;
        }

        inline dialog_login(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN))
                return 1;

            if(!sresponse)
            {
                SendClientMessage(playerid, -1, "{ffff33}[ ! ] {ffffff}Voce precisa digitar sua {ffff33}senha!");
                return 1;
            }

            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name);
            DB::GetDataString(db_entity, "players", "pass", Player[playerid][pyr::pass], BCRYPT_HASH_LENGTH, "name = '%q'", name);

            if(!Player[playerid][pyr::pass][0])
            {
                SendClientMessage(playerid, -1, "{ff3333}[ x ] {ffffff}Conta com senha inválida no banco, contate um administrador.");
                return 1;
            }

            if(!bcrypt_verify(playerid, "OnPlayerPasswordVerify", stext, Player[playerid][pyr::pass]))
            {
                SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Falha ao validar senha no momento, tente novamente.");
                return 1;
            }

            format(lgn::Player[playerid][lgn::input], MAX_PASSWORD_LEN, "%s", stext);

            return 1;
        }

        new str[512];

        if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_REGISTER))
        {
            format(str, 512, "{33ff33}>> {ffffff}Digite uma {33ff33}senha:\n\n\
            {ffff33}[ i ] {ffffff}Sua senha deve conter de {ffff33}5 {ffffff}a {ffff33} "#MAX_PASSWORD_LEN"{ffffff}caracteres \
            Estes sendo: {ffff33}numeros{ffffff}, {ffff33}letras {ffffff} ou {ffff33}simbolos\n\n");
            Dialog_ShowCallback(playerid, using inline dialog_register, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
            return 1;
        }

        else if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_LOGIN))
        {
            format(str, 512, "{33ff33}>> {ffffff}Digite sua {33ff33}senha:\n\n");
            Dialog_ShowCallback(playerid, using inline dialog_login, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
            return 1;
        }

        return 1;
    }

    return 1;
}

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
