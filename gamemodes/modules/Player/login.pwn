#include <YSI\YSI_Coding\y_hooks>

forward OnPlayerLogin(playerid);

new gLoginIssue[][64] = 
{
    {"sem problemas"},
    {"pequena demais"},
    {"grande demais"}
};

hook OnPlayerConnect(playerid)
{

    Player::CreateTimer(playerid, pyr::TIMER_LOGIN_KICK, "PYR_Kick", LOGIN_MUSIC_MS, false, "iis", 
    playerid, 
    pyr::TIMER_LOGIN_KICK, 
    "Demorou muito para fazer login!");

    Login::SetPlayer(playerid);
    
    return 1;
}

hook OnPlayerSpawn(playerid)
{
    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
        return 1;

    //Adicionar Timer e sistema de carregamento para evitar travamentos ao spwanar

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 2000, 3);

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_REGISTER) && !IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_LOGIN))
        return 1;
    
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        SelectTextDraw(playerid, COLOR_THEME_BPS);
        return 1;
    }

    if(clickedid == Login::PublicTD[TD_LOGIN_SEL])
    {
        inline dialog_register(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_REGISTER))
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
            
            format(Player[playerid][pyr::pass], 16, stext);

            Login::RegisterPlayer(playerid);

            Login::UnSetPlayer(playerid); 

            return 1;
        }

        inline dialog_login(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_LOGIN))
                return 1;

            if(!sresponse)
            {
                SendClientMessage(playerid, -1, "{ffff33}[ ! ] {ffffff}Voce precisa digitar sua {ffff33}senha!");
                return 1;
            }

            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name);
            
            DB::GetDataString(db_entity, "players", "pass", Player[playerid][pyr::pass], 32, "name = '%s'", name);

            if(strcmp(stext, Player[playerid][pyr::pass]))
            {  
                Dialog_ShowCallback(playerid, using inline dialog_login, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {ff3333}| {ffffff}Login", 
                "{ff3333}[ x ] {ffffff}Senha {ff3333}incorreta!\n\n\
                >> {ffffff}Digite sua {ff3333}senha {ff3333}novamente!:\n\n", "Inserir", "Fechar");
                return 1;
            }

            Login::UnSetPlayer(playerid);  

            return 1;
        }

        new str[512];

        if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_REGISTER))
        {
            format(str, 512, "{33ff33}>> {ffffff}Digite uma {33ff33}senha:\n\n\
            {ffff33}[ i ] {ffffff}Sua senha deve conter de {ffff33}5 {ffffff}a {ffff33}16 {ffffff}caracteres \
            Estes sendo: {ffff33}numeros{ffffff}, {ffff33}letras {ffffff} ou {ffff33}simbolos\n\n");
            Dialog_ShowCallback(playerid, using inline dialog_register, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
            return 1;
        }

        else if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_IN_LOGIN))
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
    TogglePlayerSpectating(playerid, true);

    TogglePlayerControllable(playerid, false);

    PlayAudioStreamForPlayer(playerid, LOGIN_MUSIC_URL);

    ClearChat(playerid, 25);
 
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "players", "name", "name = '%q'", name))
    {
        SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Parece que voce e {33ff33}novo aqui!{ffffff}, faca o registro para poder jogar!");
        SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_REGISTER);
        Login::ShowTDForPlayer(playerid, false);
    }

    else
    {
        SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Seja bem-vindo novamente, faca o {33ff33}login {ffffff}para poder jogar!");
        SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_LOGIN);
        Login::ShowTDForPlayer(playerid, true);
    }
}

stock Login::UnSetPlayer(playerid)
{
    ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_REGISTER);
    ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_IN_LOGIN);
    SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED);
    
    Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);

    Login::HideTDForPlayer(playerid);
    Player::LoadData(playerid);
    StopAudioStreamForPlayer(playerid);
    TogglePlayerSpectating(playerid, false);
    TogglePlayerClock(playerid, true);
    Player::SetCPF(playerid);

    CallLocalFunction("OnPlayerLogin", "i", playerid);

    return 1; 
}

stock Login::RegisterPlayer(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    new status = DB::Insert(db_entity, "players", "name, pass, payday_tleft, bitcoin, money, pX, pY, pZ, pA, \
    score, skinid, orgid", "'%q', '%q', %i, %i, %f, %f, %f, %f, %f, %i, %i, %i", name, Player[playerid][pyr::pass], 
    3600000, 0, 500.0, 834.28 + RandomFloat(2.0), -1834.89 + RandomFloat(2.0), 12.502, 180.0,
    1, random(300), 0);

    if(status)
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Sua conta foi {33ff33}registrada {ffffff}com sucesso!");
        return 1;
    }

    SendClientMessage(playerid, -1, "{ff3333}[ ERRO FATAL ] {ffffff}Sua conta {ff3333}nao foi registrada {ffffff}houve um erro grave, avise um {ff3333}moderador!");
    Kick(playerid);

    return 0;
}
