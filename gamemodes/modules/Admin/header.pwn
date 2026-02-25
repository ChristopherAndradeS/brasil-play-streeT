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

#define INVALID_ADM_ROLE_ID  (E_ROLES_ADMIN:0)
#define MAX_ADM_COMANDS      (32)

enum E_ROLES_ADMIN
{  
    ROLE_ADM_APR_HELPER = 1,
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

enum E_ADM_CMD_ERROR
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
    E_ROLES_ADMIN:adm::lvl,
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

forward OnSpectatorListUpdate(spectatorid, reason);
forward ban_input_dialog(playerid, dialogid, response, listitem, string:inputtext[]);
