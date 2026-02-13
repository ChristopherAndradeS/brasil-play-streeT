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

#define MAX_ADM_COMANDS      (32)

enum _:E_ROLES_ADMIN
{
    INVALID_ROLE_ID,  
    ROLE_ADM_APR_HELPER,
    ROLE_ADM_HELPER, 
    ROLE_ADM_APR_STAFF,          
    ROLE_ADM_STAFF,        
    ROLE_ADM_FOREMAN,         
    ROLE_ADM_MASTER,     
    ROLE_ADM_MANAGER,     
    ROLE_ADM_CEO,     
    ROLE_ADM_FOUNDER, 
    MAX_ADMIN_ROLES      
}

enum _:E_ADM_CMD_ERROR
{
    ADM_CMD_NOT_IN_WORK,
    ADM_CMD_LOW_LEVEL,
    ADM_CMD_IS_NOT_ADMIN,
}

enum (<<= 1)
{
    FLAG_ADM_WORKING = 1,
    FLAG_IS_ADMIN,    
}

enum E_ADMIN
{
    adm::flags,
    adm::lvl,
    adm::spectateid,
}

new Admin[MAX_PLAYERS][E_ADMIN];

new List:gAdminSpectates;
new Iterator:Adm_Iter<MAX_PLAYERS>;

new const Adm::gRoleNames[][32] = 
{ 
    {"NO_ROLE"}, {"( APR ) Helper"}, {"Helper"}, {"( APR ) Staff"}, {"Staff"},
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

stock Adm::Exists(const name[], &level = INVALID_ADM_LEVEL)
{
    if(DB::Exists(db_entity, "admins", "name = '%q'", name))
        return DB::GetDataInt(db_entity, "admins", "level", level, "name = '%q'", name);
    
    level = INVALID_ADM_LEVEL;

    return 0;
}

stock Adm::Set(const name[], const promoter[], level)
{
    new old_level;
    new timestr[32];
    GetISODate(timestr, 32, Server[srv::gmt]);
    
    new targetid = GetPlayerIDByName(name);

    if(Adm::Exists(name, old_level))
    {
        if(old_level == level) return 1;
        
        if(!level)
        {
            DB::Delete(db_entity, "admins", "name = '%q'", name);
            
            printf("[ ADMIN ] O jogador %s foi expulso da equipe por %s\n", name, promoter);

            if(targetid != INVALID_PLAYER_ID)
            {
                Adm::UnSet(targetid);
                SendClientMessage(targetid, -1, "{ff3333}[ ADM ] {ffffff}Voce foi {ff3333}expulso {ffffff}da equipe!");
            }

            return 1;
        }

        if(old_level < level)
        {
            if(targetid != INVALID_PLAYER_ID)
            {
                SendClientMessage(targetid, -1, "{33ff33}[ ADM ] {ffffff}Voce foi {33ff33}provido {ffffff}para %s%s",
                Adm::GetColorString(level), Adm::gRoleNames[level]);
                Adm::UpdateLevel(targetid, level);
                DB::Update(db_entity, "admins", "level = %i, promoter = '%q', promote_date = '%q' WHERE name = '%q'", 
                level, promoter, timestr, name);
            }

            printf("[ ADMIN ] O jogador %s foi provido por %s. Nível: %d\n", name, promoter, level);
        }
        
        else if(old_level > level)
        {
            if(targetid != INVALID_PLAYER_ID)
            {
                SendClientMessage(targetid, -1, "{ff3333}[ ADM ] {ffffff}Voce foi {ff3333}rebaixado {ffffff}para %s%s",
                Adm::GetColorString(level), Adm::gRoleNames[level]);
                Adm::UpdateLevel(targetid, level);
                DB::Update(db_entity, "admins", "level = %i, promoter = '%q', promote_date = '%q' WHERE name = '%q'", 
                level, promoter, timestr, name);
            }
            printf("[ ADMIN ] O jogador %s foi rebaixado por %s. Nível: %d\n", name, promoter, level);
        }
    }

    else
    {
        new sucess = DB::Insert(db_entity, "admins", "name, level, promoter, promote_date", 
        "'%q', %i, '%q', '%q'", name, level, promoter, timestr);

        if(sucess)
        {
            SendClientMessage(targetid, COLOR_SUCESS,  "[ ADM ] {ffffff}Parabens! Voce faz parte da {33ff33}STAFF BPS");
            SendClientMessage(targetid, COLOR_WARNING, "[ ADM ] {ffffff}Voce se tornou um {ff9933}admin! \
            Cargo: %s%s",  Adm::GetColorString(level), Adm::gRoleNames[level]);

            Adm::UpdateLevel(targetid, level);

            printf("[ ADMIN ] O jogador %s tornou-se admin. Nível: %d. Promotor: %s\n", name, level, promoter);
        }

        else
        {
            printf("[ DB (ADMIN) ] Erro fatal ao setar admin lvl: %d em %s por %s", level, name, promoter);
            return 0;
        }
    }

    return 1;
}

stock Adm::Load(playerid)
{
    new level;

    if(!Adm::Exists(GetPlayerNameEx(playerid), level)) return 0;
    
    SetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN);
    Admin[playerid][adm::lvl] = level;
    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID; 

    return 1;   
}

stock Adm::UpdateLevel(playerid, level)
{
    SetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN);
    Admin[playerid][adm::lvl] = level;
}

stock Adm::UnSet(playerid)
{
    if(Adm::IsSpectating(playerid))
        Adm::UnSetWork(playerid);
    
    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID;
    Admin[playerid][adm::lvl]        = 0;
    Admin[playerid][adm::flags]      = 0;
}

stock Adm::SetWork(playerid)
{
    new level = Admin[playerid][adm::lvl], name[MAX_PLAYER_NAME];
  
    GetPlayerName(playerid, name);

    Admin[playerid][adm::spectateid] = Adm::GetNextSpectateID(playerid, -1, 1);

    if(Admin[playerid][adm::spectateid] == INVALID_PLAYER_ID) return 0;

    SetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);
 
    TogglePlayerSpectating(playerid, true);

    Baseboard::HideTDForPlayer(playerid);
    Adm::ShowTDForPlayer(playerid);
    
    Adm::SpectatePlayer(playerid, Admin[playerid][adm::spectateid]);

    Adm::SendMsgToAllTagged(FLAG_IS_ADMIN, -1, 
    "{ffff33}[ ADM AVISO ] %s%s {ffff33}entrou {ffffff}no modo de trabalho", Adm::GetColorString(level), name);

    Iter_Add(Adm_Iter, playerid);

    return 1;
}

stock Adm::UnSetWork(playerid)
{
    new level = Admin[playerid][adm::lvl], name[MAX_PLAYER_NAME];
  
    GetPlayerName(playerid, name);

    ResetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);

    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID;

    TogglePlayerSpectating(playerid, false);

    Adm::HideTDForPlayer(playerid);
    Baseboard::ShowTDForPlayer(playerid);

    Adm::SendMsgToAllTagged(FLAG_IS_ADMIN, -1, 
    "{ffff33}[ ADM AVISO ] %s%s {ffff33}saiu {ffffff}no modo de trabalho", Adm::GetColorString(level), name);  

    Iter_Remove(Adm_Iter, playerid);

    return 1;
}

stock Adm::HandleWork(playerid)
{    
    if(!IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
       return Adm::SetWork(playerid);
    
    Adm::UnSetWork(playerid);

    return 1;
}

stock Adm::IsSpectating(playerid)
    return (IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING) && IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING));

stock Adm::SpectatePlayer(playerid, targetid)
{
    if(IsPlayerInAnyVehicle(targetid))
        PlayerSpectateVehicle(playerid, targetid);
    else
        PlayerSpectatePlayer(playerid, targetid);

    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

    Adm::UpdateTextDraw(playerid, targetid);

    return 1;
}

stock Adm::GetNextSpectateID(playerid, currentid, dir)
{
    if(!list_valid(gAdminSpectates)) return INVALID_PLAYER_ID;

    new len = list_size(gAdminSpectates);
    
    if(len == 0) return INVALID_PLAYER_ID;

    if(currentid < 0 || currentid >= len) currentid = (dir == 1) ? -1 : len;

    new checked = 0, idx = currentid;

    while(checked < len)
    {
        idx += dir;

        if(idx >= len)      idx = 0;
        else if(idx < 0)    idx = len - 1;

        new targetid = list_get(gAdminSpectates, idx);

        if(targetid == playerid)
        {
            checked++;
            continue;
        }

        if(Adm::IsValidSpectateID(playerid, targetid)) return targetid;

        checked++;
    }

    return INVALID_PLAYER_ID;
}


stock Adm::SendMsgToAllTagged(flags, color, const msg[], GLOBAL_TAG_TYPES:...)
{
    new format_msg[144];
    va_format(format_msg, 144, msg, ___(3));
    
    foreach(new i : Player)
    {
        if(Admin[i][adm::flags] >= flags)
            SendClientMessage(i, color, format_msg);
    }

    return 1;
}

stock Adm::HasPermission(playerid, level)
{    
    if(!IsFlagSet(Admin[playerid][adm::flags], FLAG_IS_ADMIN))
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem permissao para isso!");
        return 0;
    }

    if((Admin[playerid][adm::lvl]) < level)
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem cargo de admin para isso!");
        return 0;
    }   

    if(!IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce precisar estar em modo de trabalho: /aw!");
        return 0;
    }

    return 1;
}

stock Adm::IsValidSpectateID(playerid, targetid)
{
    if((Admin[playerid][adm::lvl] <= Admin[targetid][adm::lvl])) return 0;

    return (!IsFlagSet(Player[targetid][pyr::flags], MASK_PLAYER_SPECTATING));
}

stock Adm::ValidTargetID(playerid, targetid, bool:can_equal = false, bool:sendmsg = true)
{
    if(!IsValidPlayer(targetid)) 
    {
        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}O jogador {ff3333}nao esta online!");
        return 0;
    }

    if(!can_equal && (playerid == targetid))
    {
        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao em {ff3333}si mesmo!");
        return 0;        
    }

    if((Admin[playerid][adm::lvl] <= Admin[targetid][adm::lvl]))
    {
        if((can_equal && (playerid == targetid))) return 1;

        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    }   

    return 1;     
}

stock Adm::IsValidTargetName(playerid, const name[], const target_name[])
{
    new player_lvl, target_lvl;

    Adm::Exists(name, player_lvl);
    Adm::Exists(target_name, target_lvl);

    if(!isnull(name) && !strcmp(name, target_name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao em voce mesmo!");
        return 0;
    }

    if(player_lvl <= target_lvl)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    }

    return 1;
}