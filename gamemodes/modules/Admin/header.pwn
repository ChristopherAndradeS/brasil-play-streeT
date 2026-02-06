#define COLOR_ADM_APP_HELPER  (0x99FF99)
#define COLOR_ADM_HELPER      (0x00FF55)
#define COLOR_ADM_APP_STAFF   (0x5555FF)     
#define COLOR_ADM_STAFF       (0x1155FF)
#define COLOR_ADM_FOREMAN     (0x7711FF)
#define COLOR_ADM_MASTER      (0xFF1166)
#define COLOR_ADM_MANAGER     (0xFF2121)
#define COLOR_ADM_CEO         (0x21EEFF)
#define COLOR_ADM_FOUNDER     (0x0099FF)

#define FCOLOR_ADM_APP_HELPER  "{99FF99}"
#define FCOLOR_ADM_HELPER      "{00FF55}"
#define FCOLOR_ADM_APP_STAFF   "{5555FF}"     
#define FCOLOR_ADM_STAFF       "{1155FF}"
#define FCOLOR_ADM_FOREMAN     "{7711FF}"
#define FCOLOR_ADM_MASTER      "{FF1166}"
#define FCOLOR_ADM_MANAGER     "{FF2121}"
#define FCOLOR_ADM_CEO         "{21EEFF}"
#define FCOLOR_ADM_FOUNDER     "{0099FF}"

#define INVALID_ADM_LEVEL    (0)

enum (<<= 1)
{
    FLAG_ADM_NONE = 1,
    FLAG_ADM_APPRENTICE_HELPER,    
    FLAG_ADM_HELPER,        
    FLAG_ADM_APPRENTICE_STAFF,        
    FLAG_ADM_STAFF,        
    FLAG_ADM_FOREMAN,         
    FLAG_ADM_MASTER,     
    FLAG_ADM_MANAGER,     
    FLAG_ADM_CEO,     
    FLAG_ADM_FOUNDER, 
    FLAG_ADM_WORKING      
}

enum E_ADMIN
{
    adm::flags,
    adm::lvl
}

new Admin[MAX_PLAYERS][E_ADMIN];

new const Adm::gRoleNames[][32] = 
{ 
    {"NO_ROLE"}, {"[ APR ] Helper"}, {"Helper"}, {"[ APR ] Staff"}, {"Staff"},
    {"Encarregado"}, {"Master"}, {"Gerente"}, {"Dono"}, {"Fundador"}
};

stock Adm::GetColorString(level)
{
    new string[16];

    switch(level)
    {
        case 1:  format(string, 16, FCOLOR_ADM_APP_HELPER);
        case 2:  format(string, 16, FCOLOR_ADM_HELPER);
        case 3:  format(string, 16, FCOLOR_ADM_APP_STAFF);
        case 4:  format(string, 16, FCOLOR_ADM_STAFF);
        case 5:  format(string, 16, FCOLOR_ADM_FOREMAN);
        case 6:  format(string, 16, FCOLOR_ADM_MASTER);
        case 7:  format(string, 16, FCOLOR_ADM_MANAGER);
        case 8:  format(string, 16, FCOLOR_ADM_CEO);
        case 9:  format(string, 16, FCOLOR_ADM_FOUNDER);
        default: format(string, 16, "{ffffff}");
    }

    return string;
}

stock Adm::IsAdmin(playerid, &level)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(DB::Exists(db_entity, "admins", "name", "name = '%q'", name))
        return DB::GetDataInt(db_entity, "admins", "level", level, "name = '%q'", name);
    
    level = INVALID_ADM_LEVEL;

    return 0;
}

stock Adm::SetPlayer(playerid, const promoter[], level)
{
    new timestr[32];
    GetISODate(timestr, 32, -3);

    new sucess = DB::Insert(db_entity, "admins", "name, level, promoter, promote_date", 
    "'%q', %i, '%q', '%q'", GetPlayerNameEx(playerid), level, promoter, timestr);

    if(sucess)
    {
        SendClientMessage(playerid, COLOR_SUCESS, "[ ADM ] {ffffff}Parabens! Voce faz parte da {33ff33}STAFF BPS");
        SendClientMessage(playerid, COLOR_WARNING, "[ ADM ] {ffffff}Voce se tornou um {ff9933}admin! \
        Cargo: %s%s",  Adm::GetColorString(level), Adm::gRoleNames[level]);

        printf("[ ADMIN ] O jogador %s tornou-se admin. Nível: %d. Promotor: %s\n", GetPlayerNameEx(playerid), level, promoter);
        return 1;
    }

    return 0;
}

stock Adm::SetInWork(playerid)
{
    new level = Admin[playerid][adm::lvl];
  
    if(IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {
        ResetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);
        TogglePlayerSpectating(playerid, false);

        Adm::SendMsgToAllTagged(FLAG_ADM_APPRENTICE_HELPER, 0xFFFF33FF, 
        "[ ADM AVISO ] %s%s {ffffff}%s {ffff33}saiu {ffffff}do modo de trabalho", 
        Adm::GetColorString(Admin[playerid][adm::lvl]), Adm::gRoleNames[level], GetPlayerNameEx(playerid));
    }

    else
    {
        SetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);

        if(IsAndroidPlayer(playerid))
            TogglePlayerSpectating(playerid, true);
        
        else
        {
            new Float:pX, Float:pY, Float:pZ;
            GetPlayerPos(playerid, pX, pY, pZ);
        
            CallRemoteFunction("FlyMode", "fff", pX, pY, pZ);
        }

        Adm::SendMsgToAllTagged(FLAG_ADM_APPRENTICE_HELPER, 0xFFFF33FF, 
        "[ ADM AVISO ] %s%s {ffffff}%s {ffff33}entrou {ffffff}no modo de trabalho", 
        Adm::GetColorString(Admin[playerid][adm::lvl]), Adm::gRoleNames[level], GetPlayerNameEx(playerid)); 
    }

    return 1;
}

stock Adm::SendMsgToAllTagged(flags, color, const msg[], GLOBAL_TAG_TYPES:...)
{
    foreach(new i : Player)
    {
        if(Admin[i][adm::flags] >= flags)
            SendClientMessage(i, color, msg, ___(3));
    }

    return 1;
}

stock Adm::HasPermission(playerid, flags)
{    
    if((Admin[playerid][adm::flags]) < (flags & ~FLAG_ADM_WORKING))
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem permissao para isso!");
        return 0;
    }

    if(flags & FLAG_ADM_WORKING)
    {
        if(!(Admin[playerid][adm::flags] & FLAG_ADM_WORKING))
        {
            SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce precisar estar em modo de trabalho: /aw!");
            return 0;
        }
    }

    return 1;
}

stock Adm::ValidTargetID(playerid, targetid, can_equal = false)
{
    if(!IsValidPlayer(targetid)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}O jogador {ff3333}nao esta online!");
        return 0;
    }

    if(!can_equal && (playerid == targetid))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao em {ff3333}si mesmo!");
        return 0;        
    }

    if((Admin[playerid][adm::flags] & ~FLAG_ADM_WORKING) <= (Admin[targetid][adm::flags] & ~FLAG_ADM_WORKING))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    }

    return 1;    
}

stock Adm::SpectatePlayer(playerid, targetid)
{
    printf("%d", IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING));
    if(playerid == targetid || !IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING)) return 0;

    if(IsPlayerInAnyVehicle(targetid))
        PlayerSpectateVehicle(playerid, targetid);
    else
        PlayerSpectatePlayer(playerid, targetid);
    
    SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Espectando jogador: {ffff33}%s [ID : %d]", GetPlayerNameEx(targetid), targetid);
 
    return 1;
}