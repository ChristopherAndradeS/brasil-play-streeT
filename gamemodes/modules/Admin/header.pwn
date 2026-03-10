enum E_ROLES_ADMIN
{  
    INVALID_ADM_ROLE_ID = 0,
    ROLE_ADM_APR_HELPER = 1,
    ROLE_ADM_HELPER, 
    ROLE_ADM_APR_STAFF,          
    ROLE_ADM_STAFF,        
    ROLE_ADM_FOREMAN,         
    ROLE_ADM_MASTER,     
    ROLE_ADM_MANAGER,     
    ROLE_ADM_CEO,     
    ROLE_ADM_FOUNDER, 
    MAX_ADMIN_ROLES,      
}

new const Adm::gColors[MAX_ADMIN_ROLES] =
{
    0xADADAD, 0x99FF99, 0x00FF55, 0x5555FF, 0x1155FF, 0x7711FF, 0xFF1166, 0xFF2121, 0x21EEFF, 0x0099FF
};

new const Adm::gRoleNames[MAX_ADMIN_ROLES][32] = 
{ 
    {"INVALID_ADM_ROLE"},  {"( APR ) Helper"}, {"Helper"}, {"( APR ) Staff"}, {"Staff"}, {"Encarregado"}, {"Master"}, {"Gerente"}, {"Dono"}, {"Fundador"}
};

enum (<<= 1)
{
    FLAG_ADM_WORKING = 1,
    FLAG_IS_ADMIN,    
}

enum E_ADMIN
{
    adm::flags,
    E_ROLES_ADMIN:adm::lvl,
    adm::vehicleid,
    adm::spectateid,
}

new Admin[MAX_PLAYERS][E_ADMIN];

new List:gAdminSpectates;
new Iterator:Adm_Iter<MAX_PLAYERS>;

forward OnSpectatorListUpdate(spectatorid, reason);
forward ban_input_dialog(playerid, dialogid, response, listitem, string:inputtext[]);
