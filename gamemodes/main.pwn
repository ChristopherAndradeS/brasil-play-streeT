#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <YSI\YSI_Players\y_android>
#include <YSI\YSI_Data\y_iterate>
#include <YSI\YSI_Coding\y_va>
#include <YSI\YSI_Coding\y_inline>
#include <YSI\YSI_Visual\y_commands>
#include <YSI\YSI_Visual\y_dialog> 
#include <YSI\YSI_Coding\y_hooks>

/*                          GLOBAL HEADERS                 */
#include "../gamemodes/modules/header.pwn"
#include "../gamemodes/modules/utils.pwn"
/*                          HEADERS                        */
#include "../gamemodes/modules/DB/header.pwn"
#include "../gamemodes/modules/TextDraws/header.pwn"
#include "../gamemodes/modules/Player/header.pwn"
#include "../gamemodes/modules/Admin/header.pwn"
#include "../gamemodes/modules/Server/header.pwn" 
#include "../gamemodes/modules/Maps/header.pwn"
/*                          HANDLE                          */
#include "../gamemodes/modules/Player/handle.pwn"
#include "../gamemodes/modules/Admin/handle.pwn"
/*                          MAPAS                           */
#include "../gamemodes/modules/Maps/banks.pwn"
#include "../gamemodes/modules/Maps/dealership.pwn"
#include "../gamemodes/modules/Maps/garages.pwn"
#include "../gamemodes/modules/Maps/mechanicals.pwn"
#include "../gamemodes/modules/Maps/police_org.pwn"
#include "../gamemodes/modules/Maps/spawns.pwn"
#include "../gamemodes/modules/Maps/squares.pwn"
#include "../gamemodes/modules/Maps/store.pwn"
/*                          TEXTDRAWS                       */
#include "../gamemodes/modules/TextDraws/gui/login.pwn"
#include "../gamemodes/modules/TextDraws/gui/acs_editor.pwn"
#include "../gamemodes/modules/TextDraws/hud/baseboard.pwn"
/*                          DATABASE                        */
#include "../gamemodes/modules/DB/db_init.pwn"
/*                          PLAYER                          */
#include "../gamemodes/modules/Player/login.pwn"
#include "../gamemodes/modules/Player/payday.pwn"
#include "../gamemodes/modules/Player/acessory.pwn"
#include "../gamemodes/modules/Admin/commands.pwn"

public OnGameModeInit()
{
    new modelid, name[64], sucess;
    Acessory::GetNameByModelid(modelid, name);

    for(new i = 1; i <= 8; i++)
    {
        if(DB::Exists(db_stock, "acessorys", "uid", "uid = %d", i))
            continue;

        for(;;)
        {
            modelid = RandomMinMax(18632, 19914);
            sucess = Acessory::GetNameByModelid(modelid, name);
            
            if(sucess)
                break;
        }

        DB::Insert(db_stock, "acessorys", 
        "uid, name, creator, price, modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, color1, color2", 
        "%i, '%s', 'SERVER', %.2f, %i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %f, %i, %i", 
        i, name, Float:RandomFloatMinMax(50.0, 300.0), modelid, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, -1, -1);
    }
}

public OnGameModeExit()
{
	if(DB_Close(db_entity))
    	db_entity = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ENTIDADES encerrada com sucesso!\n");

    if(DB_Close(db_stock))
    	db_stock = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ESTOQUES encerrada com suceso!\n");

    return 1;
}

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
    if(success == COMMAND_UNDEFINED)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}O comando \'%s\' nao existe", cmdtext); 
        return COMMAND_OK;
    }

    return COMMAND_OK;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPos(playerid, fX, fY, fZ);
    return 1;
}

hook function TogglePlayerSpectating(playerid, bool:toggle)
{
    if(toggle)
        SetFlag(Player[playerid][pyr::flags], MASK_PLAYER_SPECTATING);
    
    return continue(playerid, bool:toggle);
}