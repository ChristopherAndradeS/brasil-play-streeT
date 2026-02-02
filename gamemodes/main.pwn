#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <YSI\YSI_Data\y_iterate>
#include <YSI\YSI_Coding\y_va>
#include <YSI\YSI_Coding\y_inline>
#include <YSI\YSI_Visual\y_dialog> 
#include <YSI\YSI_Visual\y_commands>
#include <YSI\YSI_Coding\y_hooks>

/*                  MASTER HEADERS                  */
#include "../gamemodes/modules/header.pwn"
#include "../gamemodes/modules/utils.pwn"
/*                  HEADERS                  */
#include "../gamemodes/modules/DB/header.pwn"
#include "../gamemodes/modules/TextDraws/header.pwn"
#include "../gamemodes/modules/Player/header.pwn"
#include "../gamemodes/modules/Server/header.pwn" 
#include "../gamemodes/modules/Maps/header.pwn"
/*                  HIGH PRIORITY */
#include "../gamemodes/modules/Player/handle.pwn"
/*                  MAPAS                  */
#include "../gamemodes/modules/Maps/banks.pwn"
#include "../gamemodes/modules/Maps/dealership.pwn"
#include "../gamemodes/modules/Maps/garages.pwn"
#include "../gamemodes/modules/Maps/mechanicals.pwn"
#include "../gamemodes/modules/Maps/police_org.pwn"
#include "../gamemodes/modules/Maps/spawns.pwn"
#include "../gamemodes/modules/Maps/squares.pwn"
#include "../gamemodes/modules/Maps/store.pwn"
/*                  TEXTDRAWS                  */
#include "../gamemodes/modules/TextDraws/gui/login.pwn"
#include "../gamemodes/modules/TextDraws/gui/acs_editor.pwn"
#include "../gamemodes/modules/TextDraws/hud/baseboard.pwn"
/*                  DATABASE                   */
#include "../gamemodes/modules/DB/db_init.pwn"
/*                  PLAYER                  */
#include "../gamemodes/modules/Player/login.pwn"
#include "../gamemodes/modules/Player/payday.pwn"
#include "../gamemodes/modules/Player/acessory.pwn"

main(){}

public OnGameModeExit()
{
	if(DB_Close(db_entity))
    	db_entity = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ENTIDADES encerrada com suceso!\n");

    if(DB_Close(db_stock))
    	db_stock = DB:0;

    printf("[ DATABASE ] Conexão com o banco de dados de ESTOQUES encerrada com suceso!\n");

    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPos(playerid, fX, fY, fZ);
    return 1;
}
