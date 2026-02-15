#define MAX_PLAYERS 20

#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <samp_bcrypt>
#include <PawnPlus>
#include <samp_bcrypt>

#define CGEN_MEMORY 20000

#include <YSI\YSI_Data\y_iterate>
#include <YSI\YSI_Coding\y_va>
#include <YSI\YSI_Coding\y_inline>
#include <YSI\YSI_Extra\y_inline_timers>
#include <YSI\YSI_Visual\y_commands>
#include <YSI\YSI_Visual\y_dialog> 
#include <YSI\YSI_Coding\y_hooks>

/*                          GLOBAL HEADERS                 */
#include "../gamemodes/modules/header.pwn"
#include "../gamemodes/modules/utils.pwn"
/*                          HEADERS                        */
#include "../gamemodes/modules/DB/header.pwn"
#include "../gamemodes/modules/Vehicle/header.pwn"
#include "../gamemodes/modules/Server/header.pwn" 
#include "../gamemodes/modules/TextDraws/header.pwn"
#include "../gamemodes/modules/Player/header.pwn"
#include "../gamemodes/modules/Admin/header.pwn"
#include "../gamemodes/modules/Maps/header.pwn"
#include "../gamemodes/modules/Games/header.pwn"
/*                          HANDLE                          */
#include "../gamemodes/modules/Server/handle.pwn"
#include "../gamemodes/modules/Vehicle/handle.pwn"
#include "../gamemodes/modules/Player/handle.pwn"
#include "../gamemodes/modules/Admin/handle.pwn"
#include "../gamemodes/modules/DB/handle.pwn"
#include "../gamemodes/modules/Maps/handle.pwn"
#include "../gamemodes/modules/Games/handle.pwn"
/*                          SERVER                          */
#include "../gamemodes/modules/Server/wheather.pwn"
#include "../gamemodes/modules/Server/players.pwn"
/*                          MAPAS                           */
#include "../gamemodes/modules/Maps/banks.pwn"
#include "../gamemodes/modules/Maps/dealership.pwn"
#include "../gamemodes/modules/Maps/garages.pwn"
#include "../gamemodes/modules/Maps/mechanicals.pwn"
#include "../gamemodes/modules/Maps/police_org.pwn"
#include "../gamemodes/modules/Maps/spawns.pwn"
#include "../gamemodes/modules/Maps/squares.pwn"
#include "../gamemodes/modules/Maps/store.pwn"
#include "../gamemodes/modules/Maps/prision.pwn"
/*                          TEXTDRAWS                       */
#include "../gamemodes/modules/TextDraws/gui/login.pwn"
#include "../gamemodes/modules/TextDraws/gui/acs_editor.pwn"
#include "../gamemodes/modules/TextDraws/gui/admin.pwn"
#include "../gamemodes/modules/TextDraws/hud/baseboard.pwn"
#include "../gamemodes/modules/TextDraws/hud/velocimeter.pwn"
/*                          PLAYER                          */
#include "../gamemodes/modules/Player/punishment.pwn"
#include "../gamemodes/modules/Player/login.pwn"
#include "../gamemodes/modules/Player/payday.pwn"
#include "../gamemodes/modules/Player/acessory.pwn"
/*                          ADMIN                          */
#include "../gamemodes/modules/Admin/commands.pwn"
#include "../gamemodes/modules/Admin/panel.pwn"
/*                          VEHICLE                        */
#include "../gamemodes/modules/Vehicle/commands.pwn"
/*                          GAME                        */
#include "../gamemodes/modules/Games/commands.pwn"
// -- HEADERS 
#include "../gamemodes/modules/Games/Race/header.pwn"
// -- HANDLES
#include "../gamemodes/modules/Games/Race/handle.pwn"

main()
{
    // Avoid amx_FindPublic collisions on some plugin stacks during GMX/unload.
    pp_use_funcidx(true);
}

public pp_on_error(source[], message[], error_level:level, &retval)
{
    printf("[ PawnPlus ] %s | nivel: %d | %s", source, _:level, message);
    return 0;
}

public OnGameModeExit()
{
    foreach(new i : Player)
    {
        Kick(i);
        printf("Jogador kikado");
    }

	if(DB_Close(db_entity))
    	db_entity = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ENTIDADES encerrada com sucesso!\n");

    if(DB_Close(db_stock))
    	db_stock = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ESTOQUES encerrada com suceso!\n");

    new count;
    for(new region = 0; region < REGION_COUNT; region++)
    {
        if(linked_list_valid(veh::gRegion[region]))
            linked_list_delete(veh::gRegion[region]);
        
        if(IsValidDynamicArea(veh::gAreas[region]))
            DestroyDynamicArea(veh::gAreas[region]);
        
        count++;
    }

    printf("[ LISTAS ] %d Lista Encadeada de Veículos e Áreas Dinâmicas destruídas com sucesso!\n", count);

    return 1;
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
    if(IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {      
        Adm::SendMsgToAllTagged(FLAG_ADM_WORKING | FLAG_IS_ADMIN, 0xFFFF33AA, 
        "[ ADM CHAT ] %s%s {ffffff}: {ffff33}%s", 
        Adm::GetColorString(Admin[playerid][adm::lvl]), GetPlayerNameStr(playerid), text);  

        return 0;      
    }

    SendClientMessageToAll(-1, "%s [ %d ] diz: %s", GetPlayerNameStr(playerid), playerid, text);

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
        SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING);
        
        if(IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
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

// hook SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size)
// {
//     SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_CHECKPOINT);
//     PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
//     return continue(playerid, Float:x, Float:y, Float:z, Float:size);
// }

// public OnPlayerEnterCheckpoint(playerid)
// {
//     if(IsPlayerCheckpointActive(playerid))
//     {
//         ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_CHECKPOINT);
//         DisablePlayerCheckpoint(playerid);
//         SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Você chegou ao seu destino!");
//         PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0); 
//         return 1;
//     }
    
//     return 1;
// }

YCMD:veh(playerid, params[], help)
{
    new modelid;

    if(sscanf(params, "i", modelid)) return 1;

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    new vehicleid = CreateVehicle(modelid, pX, pY, pZ, 0.0, RandomMinMax(0, 10), RandomMinMax(0, 10), -1);
    PutPlayerInVehicle(playerid, vehicleid, 0);

    LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));

    new regionid = Vehicle[vehicleid][veh::regionid];

    new count = linked_list_size(veh::gRegion[regionid]);

    new str[128];
    format(str, 128, "Veiculo: {33ff33}%d {ffffff}| Regiao: {33ff33}%d {ffffff}| QTR: {33ff33}%d", vehicleid, regionid, count);

    Vehicle[vehicleid][veh::tex3did] = CreateDynamic3DTextLabel(str, -1, pX, pY, pZ, 50.0, .attachedplayer = INVALID_PLAYER_ID, .attachedvehicle = vehicleid);

    return 1;
}

YCMD:teste(playerid, params[], help)
{
    SendClientMessage(playerid, -1, "%d veiculos", GetVehicleModelCount(571));
    SendClientMessage(playerid, -1, "%d seat", game::Player[playerid][pyr::seat]);
    SendClientMessage(playerid, -1, "%d gameid", game::Player[playerid][pyr::gameid]);
    SendClientMessage(playerid, -1, "%d vw", GetPlayerVirtualWorld(playerid));
    SendClientMessage(playerid, -1, "0x%08x flags", game::Player[playerid][pyr::flags]);
    return 1;
}

YCMD:games(playerid, params[], help)
{
    new gameid = strval(params);

    SendClientMessage(playerid, -1, "%s nome", Game[gameid][game::name]);
    SendClientMessage(playerid, -1, "%d tipo", _:Game[gameid][game::type]);
    SendClientMessage(playerid, -1, "%d vw", Game[gameid][game::vw]);
    SendClientMessage(playerid, -1, "%d star_time", Game[gameid][game::start_time]);
    SendClientMessage(playerid, -1, "%d min_player", Game[gameid][game::min_players]);
    SendClientMessage(playerid, -1, "%d max_playes", Game[gameid][game::max_players]);
    SendClientMessage(playerid, -1, "%d playes count", Game[gameid][game::players_count]);
    SendClientMessage(playerid, -1, "%d state", _:Game[gameid][game_state]);
    SendClientMessage(playerid, -1, "0x%08x flags", Game[gameid][game::flags]);

    return 1;
}

YCMD:kill(playerid, params[], help)
{
    SetPlayerHealth(playerid, 0);
    return 1;
}

YCMD:teste2(playerid, params[], help)
{
    for(new PlayerText:i = PlayerText:0; i < MAX_PLAYER_TEXT_DRAWS; i++)
    {
        if(IsValidPlayerTextDraw(playerid, i))
        {
            printf("PlayerTextDraw %d is valid. %d visible", i, IsPlayerTextDrawVisible(playerid, i));
            //PlayerTextDrawShow(playerid, i);
        }
    }

    // for(new Text:i = Text:0; i < MAX_TEXT_DRAWS; i++)
    // {
    //     if(IsValidTextDraw(i))
    //     {
    //         printf("TextDraw %d is valid", i);
    //         //PlayerTextDrawShow(playerid, i);
    //     }
    // }

    return 1;
}