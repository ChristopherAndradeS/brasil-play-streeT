#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerLogin(playerid)
{
    new level;

    if(!Adm::IsAdmin(playerid, level)) return 1;
    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    SetFlag(Admin[playerid][adm::flags], floatround(Float:floatpower(2, level)));
    Admin[playerid][adm::lvl] = level;
    
    return 1;
}
