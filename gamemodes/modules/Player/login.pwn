#include <YSI\YSI_Coding\y_hooks>

new gLoginIssue[][64] = 
{
    {"sem problemas"},
    {"pequena demais"},
    {"grande demais"}
};

hook OnPlayerConnect(playerid)
{
    inline const KickPlayer(pid, const pmsg[])
    {
        KickDelay(playerid, msg[]);
    }

    TogglePlayerSpectating(playerid, true);

    PlayAudioStreamForPlayer(playerid, "https://files.catbox.moe/gqya30.mp3");

    ClearChat(playerid, 25);

    Player::ClearAllData(playerid);

    lgn::Player[playerid][lgn::timerid] = SetTimerEx("KickDelay", 2 * 60000, false, "is", playerid, "Demorou muito para fazer login!");

    SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}%s", msg, ___(2));
    new timerid = Timer_CreateCallback(using inline KickPlayer<is>, 750, 1);
    Timer_KillCallback(timerid);

    if(!Player::LoadAllData(playerid))
    {
        SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Parece que você é {33ff33}novo aqui!{ffffff}, faça o registro para poder jogar!");
        Player::SetFlag(playerid, MASK_PLAYER_IN_REGISTER);
        Login::ShowTDForPlayer(playerid, false);
    }

    else
    {
        SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Seja bem-vindo novamente, faça o {33ff33}login {ffffff}para poder jogar!");
        Player::SetFlag(playerid, MASK_PLAYER_IN_LOGIN);
        Login::ShowTDForPlayer(playerid, true);
    }

    return 1;
}

hook OnPlayerSpawn(playerid)
{
    if(!Player::IsFlagSet(playerid, MASK_PLAYER_LOGGED))
        return 1;

    Spawn::RemoveGTAObjects(playerid);
    Bank::RemoveGTAObjects(playerid);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_LS);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_AIRPORT);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_DROP);
    Org::RemoveGTAObjects(playerid);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_HP);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_LS);

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 1500, 3);
    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Login::PublicTD[TD_LOGIN_SEL_PASS])
    {
        /* OnDialogResponce */
        inline dialog(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused slistitem, sdialogid, sresponse

            /* QUANDO REGISTRO FOR RESPONDIDO */
            if(Player::IsFlagSet(spid, MASK_PLAYER_IN_REGISTER))
            {
                if(!sresponse)
                {
                    SendClientMessage(spid, -1, "{ffff33}[ ! ] {ffffff}Você precisa digitar uma {ffff33}senha!"); 
                    return 1;
                }
                
                new issue;
                
                if(!Login::IsValidPassword(stext, issue))
                {
                    new str[128];
                    format(str, sizeof(str), "{ff3333}[ x ] {ffffff}Sua senha está {ff3333}%s!\n\n\
                    >> {ffffff}Digite uma {33ff33}senha {ffffff}novamente:", gLoginIssue[issue]);
                    Dialog_ShowCallback(playerid, using inline dialog, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
                    return 1;
                }
                
                format(Player[playerid][pyr::pass], 16, stext);

                Login::RegisterPlayer(playerid);
                Player::ResetFlag(playerid, MASK_PLAYER_IN_REGISTER);

                Player::SetToSpawn(playerid);

                Login::HideTDForPlayer(playerid);
                Login::DestroyPlayerTD(playerid);
                StopAudioStreamForPlayer(playerid);
            }

            /* QUANDO LOGIN FOR RESPONDIDO */
            else if(Player::IsFlagSet(spid, MASK_PLAYER_IN_LOGIN))
            {
                if(!sresponse)
                {
                    SendClientMessage(spid, -1, "{ffff33}[ ! ] {ffffff}Você precisa digitar sua {ffff33}senha!");
                    return 1;
                }

                if(strcmp(stext, Player[spid][pyr::pass]))
                {  
                    Dialog_ShowCallback(spid, using inline dialog, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {ff3333}| {ffffff}Login", 
                    "{ff3333}[ x ] {ffffff}Senha {ff3333}incorreta!\n\n\
                    >> {ffffff}Digite sua {ff3333}senha {ff3333}novamente!:\n\n", "Inserir", "Fechar");
                    return 1;
                }

                Player::ResetFlag(playerid, MASK_PLAYER_IN_LOGIN);
            
                Player::SetToSpawn(playerid);
                Login::HideTDForPlayer(playerid);
                Login::DestroyPlayerTD(playerid);

                StopAudioStreamForPlayer(playerid);

                return 1;
            }
        }

        new str[512];

        if(Player::IsFlagSet(playerid, MASK_PLAYER_IN_REGISTER))
            format(str, 512, "{33ff33}>> {ffffff}Digite uma {33ff33}senha:\n\n\
            {ffff33}[ i ] {ffffff}Sua senha deve conter de {ffff33}5 {ffffff}a {ffff33}16 {ffffff}caracteres \
            Estes sendo: {ffff33}números{ffffff}, {ffff33}letras {ffffff} ou {ffff33}símbolos\n\n");
                
        else if(Player::IsFlagSet(playerid, MASK_PLAYER_IN_LOGIN))
            format(str, 512, "{33ff33}>> {ffffff}Digite sua {33ff33}senha:\n\n");
        
        Dialog_ShowCallback(playerid, using inline dialog, DIALOG_STYLE_PASSWORD, "{ffffff}BPS {33ff33}| {ffffff}Log-in", str, "Inserir", "Fechar");
    }

    return 1;
}

stock Login::RegisterPlayer(playerid)
{
    new status = Player::InsertData(playerid, Player[playerid][pyr::pass], 3600000, 0, 500.0, 
    834.28 + RandomFloat(2.0), -1834.89 + RandomFloat(2.0), 12.502, 180.0, 1, random(300), 0);

    Player::LoadAllData(playerid);

    if(status)
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Sua conta foi {33ff33}registrada {ffffff}com sucesso!");
}