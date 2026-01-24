#include <YSI\YSI_Coding\y_hooks>

new const gNameIssue[][32 char] =
{
    {"NO_PROBLEM"},
    {"contém caractér ilegal"},
    {"tem tamanho inválido"}
};

hook OnPlayerConnect(playerid)
{
    ClearChat(playerid, 20);

    new name[MAX_PLAYER_NAME], issue;
    GetPlayerName(playerid, name);

    if(!IsValidPlayerName(name, issue))
    {
        KickDelay(playerid, "Seu nome de usuário é inválido: {ff3333}%s", gNameIssue[issue]);
        return -1; 
    }

    if(Database::GetRowCount("player_punisheds", "name", name, _))
    {
        new left_time;

        Database::LoadDataString("player_punisheds", "name", name, "ip", ip);
        Database::LoadDataString("player_punisheds", "name", name, "reason", reason);
        Database::LoadDataString("player_punisheds", "name", name, "punished_by", admin_name);
        level = Database::LoadDataInt("player_punisheds", "name", name, "level");
        left_time = Database::LoadDataInt("player_punisheds", "name", name, "left_tstamp");

        if(gettime() > left_time)
        {
            SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Você foi {33ff33}perdoado {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");
            return 1;
        }

        new ip[16], reason[64], admin_name[MAX_PLAYER_NAME], level;

        Database::LoadDataString("player_punisheds", "name", name, "ip", ip);
        Database::LoadDataString("player_punisheds", "name", name, "reason", reason);
        Database::LoadDataString("player_punisheds", "name", name, "punished_by", admin_name);
        level = Database::LoadDataInt("player_punisheds", "name", name, "level");

        new str[512], time_str[64];
        
        if(left_time == -1)
            format(time_str, 64, "Indeterminado");
        else
        {
            GetTimestampString(time_str, left_time);
            format(time_str, 64, "%s {ffffff}(%d dias)", time_str, floatround((left_time - gettime()) / 86400));
        }
    
        format(str, sizeof(str), "{ff3333}Você foi banido!\n\n\
        {ffffff}Indentificamos uma atividade suspeita neste usuário e aplicamos um banimento!\n\n\
        Admin:     \t{ff3333}%s\n\
        {ffffff}Punição:   \t{ff3333}%s\n\
        {ffffff}Motivo:    \t{ff3333}%s{ffffff}\n\
        {ffffff}Expira em: \t{ff3333}%s\n\n\
        {ffffff}Você pode abrir uma revisão de BAN no nosso {7289da}discord:\n{ffffff}Link: {7289da}" DISCORD_LINK, 
        admin_name, !(level - 1) ? "Cadeia Staff" : "Banimento", reason, time_str);
        
        inline dialog(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, sresponse, slistitem, stext
            return -1;
        }

        Dialog_ShowCallback(playerid, using inline dialog, DIALOG_STYLE_MSGBOX, "{ffffff}BPS {ff3333}| {ffffff}Punições", str, "Fechar", "");
        
        KickDelay(playerid, "Você está {ff3333}banido!");
        return -1;
    }

    return 1;
}