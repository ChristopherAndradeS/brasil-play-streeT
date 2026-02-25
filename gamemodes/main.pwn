#define MAX_PLAYERS 50

#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <samp_bcrypt>
#include <PawnPlus>
#include <sampvoice>

#define CGEN_MEMORY 20000

#define ON_DEBUG_MODE

#include <YSI/YSI_Data/y_iterate>
#include <YSI/YSI_Coding/y_va>
#include <YSI/YSI_Coding/y_inline>
#include <YSI/YSI_Extra/y_inline_timers>
#include <YSI/YSI_Visual/y_commands>
#include <YSI/YSI_Visual/y_dialog> 
#include <YSI/YSI_Coding/y_hooks>

/*                          GLOBAL HEADERS                 */
#include "./gamemodes/modules/header.pwn"
#include "./gamemodes/modules/utils.pwn"

//     _   _                _               
//    | | | |              | |              
//    | |_| | ___  __ _  __| | ___ _ __ ___ 
//    |  _  |/ _ \/ _` |/ _` |/ _ \ '__/ __|
//    | | | |  __/ (_| | (_| |  __/ |  \__ \
//    \_| |_/\___|\__,_|\__,_|\___|_|  |___/
//                                          
//                                          
#include "./gamemodes/modules/Admin/header.pwn"                                      
#include "./gamemodes/modules/DB/header.pwn"
#include "./gamemodes/modules/Games/header.pwn"
#include "./gamemodes/modules/LinkedLists/header.pwn"
#include "./gamemodes/modules/Maps/header.pwn"
#include "./gamemodes/modules/Organization/header.pwn"
#include "./gamemodes/modules/Player/header.pwn"
#include "./gamemodes/modules/Server/header.pwn" 
#include "./gamemodes/modules/TextDraws/header.pwn"
#include "./gamemodes/modules/Vehicle/header.pwn"

//  ------------------ GAMES ----------------------------
#include "./gamemodes/modules/Games/Arena/header.pwn"
#include "./gamemodes/modules/Games/Race/header.pwn"
//  ------------------ GAMES ----------------------------

//     _____ ___________ _____ _____ 
//    /  __ \  _  | ___ \  ___/  ___|
//    | /  \/ | | | |_/ / |__ \ `--. 
//    | |   | | | |    /|  __| `--. \
//    | \__/\ \_/ / |\ \| |___/\__/ /
//     \____/\___/\_| \_\____/\____/ 
//                                   
//  
#include "./gamemodes/modules/Admin/core.pwn"                                      
#include "./gamemodes/modules/DB/core.pwn"
#include "./gamemodes/modules/Games/core.pwn"
#include "./gamemodes/modules/LinkedLists/core.pwn"

//  ------------------------- [ MAPAS ] ---------------------------

#include "./gamemodes/modules/Maps/core/banks.pwn"
#include "./gamemodes/modules/Maps/core/dealership.pwn"
#include "./gamemodes/modules/Maps/core/garages.pwn"
#include "./gamemodes/modules/Maps/core/mechanicals.pwn"
#include "./gamemodes/modules/Maps/core/police_org.pwn"
#include "./gamemodes/modules/Maps/core/spawns.pwn"
#include "./gamemodes/modules/Maps/core/squares.pwn"
#include "./gamemodes/modules/Maps/core/store.pwn"
#include "./gamemodes/modules/Maps/core/prision.pwn"
#include "./gamemodes/modules/Maps/core/arena.pwn"
#include "./gamemodes/modules/Maps/core/ammu.pwn"
#include "./gamemodes/modules/Maps/core/house.pwn"

//  ------------------------- [ MAPAS ] ---------------------------

#include "./gamemodes/modules/Organization/core.pwn"
#include "./gamemodes/modules/Player/core.pwn"
#include "./gamemodes/modules/Server/core.pwn" 

//  ----------------------- [ TEXTDRAWS ] -------------------------

//                          [    GUI    ]
#include "./gamemodes/modules/TextDraws/gui/login.pwn"
#include "./gamemodes/modules/TextDraws/gui/acs_editor.pwn"
#include "./gamemodes/modules/TextDraws/gui/admin.pwn"
//                          [    HUD    ]
#include "./gamemodes/modules/TextDraws/hud/baseboard.pwn"
#include "./gamemodes/modules/TextDraws/hud/velocimeter.pwn"

//  ----------------------- [ TEXTDRAWS ] -------------------------

#include "./gamemodes/modules/Vehicle/core.pwn"

//  ------------------ GAMES ----------------------------
#include "./gamemodes/modules/Games/Arena/core.pwn"
#include "./gamemodes/modules/Games/Race/core.pwn"
//  ------------------ GAMES ----------------------------

//     _   _                 _ _           
//    | | | |               | | |          
//    | |_| | __ _ _ __   __| | | ___  ___ 
//    |  _  |/ _` | '_ \ / _` | |/ _ \/ __|
//    | | | | (_| | | | | (_| | |  __/\__ \
//    \_| |_/\__,_|_| |_|\__,_|_|\___||___/
//                                         
//                                         
#include "./gamemodes/modules/DB/handle.pwn"
#include "./gamemodes/modules/Server/handle.pwn"
#include "./gamemodes/modules/LinkedLists/handle.pwn"
#include "./gamemodes/modules/Maps/handle.pwn"
#include "./gamemodes/modules/TextDraws/handle.pwn"
#include "./gamemodes/modules/Player/handle.pwn"
#include "./gamemodes/modules/Organization/handle.pwn"
#include "./gamemodes/modules/Vehicle/handle.pwn"
#include "./gamemodes/modules/Admin/handle.pwn"
#include "./gamemodes/modules/Games/handle.pwn"

//  -------------------------- GAMES --------------------------
#include "./gamemodes/modules/Games/Race/handle.pwn"
#include "./gamemodes/modules/Games/Arena/handle.pwn"
//  -------------------------- GAMES --------------------------
             
//  ------------------------- PLAYERS --------------------------
#include "./gamemodes/modules/Player/punishment/punishment.pwn"
#include "./gamemodes/modules/Voice/handle.pwn"
#include "./gamemodes/modules/Player/login/login.pwn"
#include "./gamemodes/modules/Player/payday/payday.pwn"
#include "./gamemodes/modules/Acessory/acessory.pwn"
//  ------------------------- PLAYERS --------------------------

//  -------------------------- ADMS ----------------------------
//#include "./gamemodes/modules/Admin/panel.pwn"
//  -------------------------- ADMS ----------------------------

//     _____ ________  ______  ___  ___   _   _______  _____ 
//    /  __ \  _  |  \/  ||  \/  | / _ \ | \ | |  _  \/  ___|
//    | /  \/ | | | .  . || .  . |/ /_\ \|  \| | | | |\ `--. 
//    | |   | | | | |\/| || |\/| ||  _  || . ` | | | | `--. \
//    | \__/\ \_/ / |  | || |  | || | | || |\  | |/ / /\__/ /
//     \____/\___/\_|  |_/\_|  |_/\_| |_/\_| \_/___/  \____/ 
//                                                           
//                                                           
#include "./gamemodes/modules/Player/commands.pwn"
#include "./gamemodes/modules/Organization/commands.pwn"
#include "./gamemodes/modules/Admin/commands.pwn"
#include "./gamemodes/modules/Vehicle/commands.pwn"
#include "./gamemodes/modules/Games/commands.pwn"

main()
{
    pp_use_funcidx(true);
}

public OnGameModeExit()
{
	if(DB_Close(db_entity)) db_entity = DB:0;

    printf("[ DATABASE ] Conexao com o banco de dados de ENTIDADES encerrada com sucesso!\n");

    if(DB_Close(db_stock)) db_stock = DB:0;

    printf("[ DATABASE ] Conexao com o banco de dados de ESTOQUES encerrada com suceso!\n");

    new count;

    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
    {
        if(linked_list_valid(veh::Region[regionid])) linked_list_delete(veh::Region[regionid]);
        if(linked_list_valid(pyr::Region[regionid])) linked_list_delete(pyr::Region[regionid]);
        if(IsValidDynamicArea(Areas[regionid]))      DestroyDynamicArea(Areas[regionid]);
        
        count++;
    }

    printf("[  AREAS  ] %d areas globais foram destruídas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de jogadores foram deletadas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de veículos foram deletadas com sucesso\n", count);

    return 1;
}

public pp_on_error(source[], message[], error_level:level, &retval)
{
    printf("[ PawnPlus ] %s | nivel: %d | %s", source, _:level, message);
    return 0;
}

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
    switch(success)
    {
        case COMMAND_UNDEFINED:
        {
            SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}O comando \'%s\' nao existe", cmdtext); 
            return COMMAND_SILENT;            
        }    
    }

    return success;
}

public OnPlayerText(playerid, text[])
{
    if(isnull(text)) return 0;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ SEGURANCA ] {ffffff}Chat bloqueado durante login/registro. Use apenas o dialog para senha.");
        return 0;
    }

    if(!strcmp(lgn::Player[playerid][lgn::input], text))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ OPA! ] {ffffff}Nao compartilhe {ff3333}sua senha {ffffff}com ninguem, {ff3333}nem mesmo com admins!");
        return 0;
    }

    if(GetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {      
        Adm::SendMsgToAllTagged(FLAG_ADM_WORKING | FLAG_IS_ADMIN, 0xFFFF33AA, 
        "[ ADM CHAT ] %s%s {ffffff}: {ffff33}%s", 
        Adm::GetColorString(Admin[playerid][adm::lvl]), GetPlayerNameStr(playerid), text);  
        return 0;      
    }   

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    SendMessageToNearPlayer(pX, pY, pZ, "{FFFF99}[ L ] {ffffff}%s {FFFF99}[ %d ] diz: {ffffff}%s", GetPlayerNameStr(playerid), playerid, text);
    
    ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.1, false, false, false, false, 1500);

    return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(Admin[playerid][adm::lvl] < ROLE_ADM_MANAGER) return 1;
    
    SetPlayerPos(playerid, fX, fY, fZ);

    return 1;
}

hook function TogglePlayerSpectating(playerid, bool:toggle)
{
    if(toggle)
    {
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING);
        
        if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED))
            Adm::RemSpectatorInList(playerid, 2);
    }

    return continue(playerid, bool:toggle);
}

hook function SendClientMessage(playerid, colour, const msg[], GLOBAL_TAG_TYPES:...)
{
    new fixed_msg[144];
    va_format(fixed_msg, 144, msg, ___(3));
    RemoveGraphicAccent(fixed_msg);
    return continue(playerid, colour, fixed_msg);
}

hook function SendClientMessageToAll(colour, const msg[], GLOBAL_TAG_TYPES:...)
{
    new fixed_msg[144];
    va_format(fixed_msg, 144, msg, ___(2));
    RemoveGraphicAccent(fixed_msg);
    return continue(colour, fixed_msg);
}

stock SendMessageToNearPlayer(Float:pX, Float:pY, Float:pZ, const msg[], GLOBAL_TAG_TYPES:...)
{
    new count, near_players[MAX_PLAYERS];
    
    count = Player::GetPlayersIntoRange(pX, pY, pZ, 70.0, near_players);

    new formated_msg[144];
    va_format(formated_msg, 144, msg, ___(4));

    for(new i = 0; i < count; i++)
    {   
        new playerid = near_players[i];

        if(playerid == INVALID_PLAYER_ID) continue;
        
        SendClientMessage(playerid, -1, formated_msg); 
    }

    return 1;
}
