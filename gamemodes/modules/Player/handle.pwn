#include <YSI\YSI_Coding\y_hooks>

#define INDETERMINATE_TIME (0x7FFFFFFF)

new const gNameIssue[][32] =
{
    {"INVALID_ISSUE"},
    {"contem caracter ilegal"},
    {"tem tamanho invalido"}
};

hook OnPlayerConnect(playerid)
{
    ClearChat(playerid, 20);

    new name[MAX_PLAYER_NAME], issue;
    GetPlayerName(playerid, name);

    /* VERIFICAR NOME - É ADEQUADO ?  */
    if(!IsValidPlayerName(name, issue))
    {
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}Seu nome de usuario e invalido: {ff3333}%s", gNameIssue[issue]);
        Kick(playerid);
        return -1; // ENCERRA PROXÍMAS EXECUÇÕES DE hook OnPlayerConnect
    }

    /* VERIFICAR PUNIÇÃO - ESTÁ BANIDO ?  */
    if(DB::Exists(db_entity, "punishments", "name", "name = %s AND level = 2", name))
    {
        new left_time;

        DB::GetDataInt(db_entity, "punishments", "left_tstamp", left_time, "name = %s AND level = 2", name);

        if(left_time > gettime())
        {
            SendClientMessage(playerid, COLOR_THEME_BPS, "[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");

            DB::Delete(db_entity, "punishments", "name = %s AND level = 2", name);

            return 1;
        }

        new ip[16], reason[64], admin_name[MAX_PLAYER_NAME], date[16], level;

        DB::GetDataString(db_entity, "punishments", "name", ip, 16, "name = %s AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "reason", reason, 64, "name = %s AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "punished_by", admin_name, 24, "name = %s AND level = 2", name);
        DB::GetDataString(db_entity, "punishments", "date", date, 16, "name = %s AND level = 2", name);
        DB::GetDataInt(db_entity, "punishments", "level", level, "name = %s AND level = 2", name);

        new str[512], time_str[64];
        
        format(time_str, 64, "%s {ffffff}(%d dias)", date, floatround((left_time - gettime()) / 86400));
     
        format(str, sizeof(str), "{ff3333}Você foi banido!\n\n\
        {ffffff}Indentificamos uma atividade suspeita neste usuario e aplicamos um banimento!\n\n\
        Admin:     \t{ff3333}%s\n\
        {ffffff}Punição:   \t{ff3333}Banimento\n\
        {ffffff}Motivo:    \t{ff3333}%s{ffffff}\n\
        {ffffff}Expira em: \t{ff3333}%s\n\n\
        {ffffff}Você pode abrir uma revisão de BAN no nosso {7289da}discord:\n{ffffff}Link: {7289da}" DISCORD_LINK, 
        admin_name, reason, time_str);
        
        inline dialog(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, sresponse, slistitem, stext
            return -1;
        }

        Dialog_ShowCallback(playerid, using inline dialog, DIALOG_STYLE_MSGBOX, "{ffffff}BPS {ff3333}| {ffffff}Punições", str, "Fechar", "");
        
        SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}Você esta {ff3333}banido {ffffff}deste servidor!");

        Kick(playerid);

        return -1;
    }

    /* HANDLE CARREGAMENTO GERAL  */

    // TEXTDRAWS

    Login::CreatePlayerTD(playerid); 
    Baseboard::CreatePlayerTD(playerid);

    // MAPAS

    //Bank::RemoveGTAObjects(playerid);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_LS);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_AIRPORT);
    Org::RemoveGTAObjects(playerid);
    Spawn::RemoveGTAObjects(playerid);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_HP);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_LS);
    
    return 1;
}

hook OnPlayerSpawn(playerid)
{
    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
        return -1;

    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
        return 1;
        
    new Float:pX, Float:pY, Float:pZ, Float:pA, name[MAX_PLAYER_NAME];

    GetPlayerName(playerid, name);
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);

    DB::SetDataFloat(db_entity, "players", "pX", pX, "name = '%s'", name);
    DB::SetDataFloat(db_entity, "players", "pY", pY, "name = '%s'", name);
    DB::SetDataFloat(db_entity, "players", "pZ", pZ, "name = '%s'", name);
    DB::SetDataFloat(db_entity, "players", "pA", pA, "name = '%s'", name);

    new t_left = GetTimerRemaining(pyr::Timer[playerid][pyr::TIMER_PAYDAY]);
    DB::SetDataInt(db_entity, "players", "payday_tleft", t_left, "name = '%s'", name);

    Player::KillTimer(playerid, pyr::TIMER_PAYDAY);
    Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);

    if(IsValidDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]))
    {
        DestroyDynamic3DTextLabel(Player[playerid][pyr::cpf_tag]);
        Player[playerid][pyr::cpf_tag] = INVALID_3DTEXT_ID;
    }

    Player::ClearAllData(playerid);

    return 1;
}