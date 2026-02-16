#define MAX_PLAYERS 50

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
    /* GAMES */
#include "../gamemodes/modules/Games/Race/header.pwn"
/*                          HANDLE                          */
#include "../gamemodes/modules/Server/handle.pwn"
#include "../gamemodes/modules/Vehicle/handle.pwn"
#include "../gamemodes/modules/Player/handle.pwn"
#include "../gamemodes/modules/Admin/handle.pwn"
#include "../gamemodes/modules/DB/handle.pwn"
#include "../gamemodes/modules/Maps/handle.pwn"
#include "../gamemodes/modules/Games/handle.pwn"
    /* GAMES */
#include "../gamemodes/modules/Games/Race/handle.pwn"
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
#include "../gamemodes/modules/Player/commands.pwn"
/*                          ADMIN                          */
#include "../gamemodes/modules/Admin/commands.pwn"
#include "../gamemodes/modules/Admin/panel.pwn"
/*                          VEHICLE                        */
#include "../gamemodes/modules/Vehicle/commands.pwn"
/*                          GAME                        */
#include "../gamemodes/modules/Games/commands.pwn"

main()
{
    pp_use_funcidx(true);
}

public OnGameModeExit()
{
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

    printf("[ LISTAS ] %d Lista Encadeada de Veiculos e Areas Dinâmicas destruidas com sucesso!\n", count);

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

    if(!IsFlagSet(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ SEGURANCA ] {ffffff}Chat bloqueado durante login/registro. Use apenas o dialog para senha.");
        return 0;
    }

    if(!strcmp(lgn::Player[playerid][lgn::input], text))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ OPA! ] {ffffff}Nao compartilhe {ff3333}sua senha {ffffff}com ninguem, {ff3333}nem mesmo com admins!");
        return 0;
    }

    if(IsFlagSet(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {      
        Adm::SendMsgToAllTagged(FLAG_ADM_WORKING | FLAG_IS_ADMIN, 0xFFFF33AA, 
        "[ ADM CHAT ] %s%s {ffffff}: {ffff33}%s", 
        Adm::GetColorString(Admin[playerid][adm::lvl]), GetPlayerNameStr(playerid), text);  

        return 0;      
    }   

    if(!bcrypt_verify(playerid, "OnPlayerPasswordVerify", text, Player[playerid][pyr::pass]))
        return 0;

    SendClientMessageToAll(-1, "{99FF99}[ G ] {ffffff}%s [ %d ] {99FF99}diz: {ffffff}%s", GetPlayerNameStr(playerid), playerid, text);
    
    ApplyAnimation(playerid, "ped", "IDLE_chat", 4.1, false, false, false, false, 1500);

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

public OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_CHECKPOINT)) return 1;
    
    ResetFlag(Player[playerid][pyr::flags], MASK_PLAYER_CHECKPOINT);
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Você chegou ao seu destino!");
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0); 
    
    return 1;
}