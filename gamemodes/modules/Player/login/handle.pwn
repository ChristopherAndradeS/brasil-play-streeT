#include <YSI\YSI_Coding\y_hooks>

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
