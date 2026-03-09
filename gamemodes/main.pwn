#define MAX_PLAYERS (50)
#define MAX_NPCS    (2)

#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <samp_bcrypt>
#include <PawnPlus>
#include <sampvoice>
#include <discord-connector>
//#include <colandreas>

#define CGEN_MEMORY 20000

#define ON_DEBUG_MODE

#include <YSI/YSI_Data/y_iterate>
#include <YSI/YSI_Coding/y_va>
#include <YSI/YSI_Coding/y_inline>
#include <YSI/YSI_Extra/y_inline_timers>
#include <YSI/YSI_Visual/y_commands>
#include <YSI/YSI_Visual/y_dialog> 
#include <YSI/YSI_Coding/y_hooks>

//     _   _                _               
//    | | | |              | |              
//    | |_| | ___  __ _  __| | ___ _ __ ___ 
//    |  _  |/ _ \/ _` |/ _` |/ _ \ '__/ __|
//    | | | |  __/ (_| | (_| |  __/ |  \__ \
//    \_| |_/\___|\__,_|\__,_|\___|_|  |___/
//                                          
//                                    

//  --------------------  GLOBAL HEADERS -----------------------
#include "./gamemodes/modules/header.pwn"
#include "./gamemodes/modules/utils.pwn"
//  --------------------  GLOBAL HEADERS -----------------------

#include "./gamemodes/modules/Admin/header.pwn"                                      
#include "./gamemodes/modules/DB/header.pwn"
#include "./gamemodes/modules/Discord/header.pwn"
#include "./gamemodes/modules/Games/header.pwn"
#include "./gamemodes/modules/LinkedLists/header.pwn"
#include "./gamemodes/modules/Maps/header.pwn"
#include "./gamemodes/modules/NPC/header.pwn"
#include "./gamemodes/modules/Organization/header.pwn"
#include "./gamemodes/modules/Player/header.pwn"

//  ------------------------- PLAYERS --------------------------
#include "./gamemodes/modules/Player/acessory/header.pwn"
//  ------------------------- PLAYERS --------------------------

#include "./gamemodes/modules/Server/header.pwn" 

//  -------------------------  SHOPS ---------------------------
#include "./gamemodes/modules/Shop/dealership/header.pwn" 
//  -------------------------  SHOPS ---------------------------

#include "./gamemodes/modules/TextDraws/header.pwn"
#include "./gamemodes/modules/Vehicle/header.pwn"

//  -------------------------  GAMES ---------------------------
#include "./gamemodes/modules/Games/Arena/header.pwn"
#include "./gamemodes/modules/Games/Race/header.pwn"
//  -------------------------  GAMES ---------------------------

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
#include "./gamemodes/modules/Discord/core.pwn"
#include "./gamemodes/modules/Games/core.pwn"
#include "./gamemodes/modules/LinkedLists/core.pwn"

//  --------------------------- MAPAS -----------------------------
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
#include "./gamemodes/modules/Maps/core/groove.pwn"
//  --------------------------- MAPAS -----------------------------

#include "./gamemodes/modules/Organization/core.pwn"
#include "./gamemodes/modules/Player/core.pwn"

//  ------------------------- PLAYERS --------------------------
#include "./gamemodes/modules/Player/acessory/core.pwn"
#include "./gamemodes/modules/Player/injury/core.pwn"
#include "./gamemodes/modules/Player/login/core.pwn"
#include "./gamemodes/modules/Player/payday/core.pwn"
#include "./gamemodes/modules/Player/punishment/core.pwn"
//  ------------------------- PLAYERS --------------------------

#include "./gamemodes/modules/Server/core.pwn" 

//  -------------------------  SHOPS ---------------------------
#include "./gamemodes/modules/Shop/dealership/core.pwn" 
//  -------------------------  SHOPS ---------------------------

//  ------------------------- TEXTDRAWS ---------------------------
//                          [    GUI    ]
#include "./gamemodes/modules/TextDraws/gui/login.pwn"
#include "./gamemodes/modules/TextDraws/gui/acs_editor.pwn"
#include "./gamemodes/modules/TextDraws/gui/admin.pwn"
#include "./gamemodes/modules/TextDraws/gui/dealership.pwn"
#include "./gamemodes/modules/TextDraws/gui/garage.pwn"
//                          [    HUD    ]
#include "./gamemodes/modules/TextDraws/hud/baseboard.pwn"
#include "./gamemodes/modules/TextDraws/hud/velocimeter.pwn"
#include "./gamemodes/modules/TextDraws/hud/travel.pwn"
//  ------------------------- TEXTDRAWS ---------------------------

#include "./gamemodes/modules/Vehicle/core.pwn"

//  -------------------------  GAMES ---------------------------
#include "./gamemodes/modules/Games/Arena/core.pwn"
#include "./gamemodes/modules/Games/Race/core.pwn"
//  -------------------------  GAMES ---------------------------

//     _   _                 _ _           
//    | | | |               | | |          
//    | |_| | __ _ _ __   __| | | ___  ___ 
//    |  _  |/ _` | '_ \ / _` | |/ _ \/ __|
//    | | | | (_| | | | | (_| | |  __/\__ \
//    \_| |_/\__,_|_| |_|\__,_|_|\___||___/
//                                         
//                                         

#include "./gamemodes/modules/DB/handle.pwn"
#include "./gamemodes/modules/LinkedLists/handle.pwn"
#include "./gamemodes/modules/Server/handle.pwn"
#include "./gamemodes/modules/Discord/handle.pwn"
#include "./gamemodes/modules/Maps/handle.pwn"
#include "./gamemodes/modules/TextDraws/handle.pwn"
#include "./gamemodes/modules/NPC/handle.pwn"
#include "./gamemodes/modules/Player/handle.pwn"

//  ------------------------- PLAYERS --------------------------
#include "./gamemodes/modules/Player/injury/handle.pwn"
#include "./gamemodes/modules/Player/login/handle.pwn"
#include "./gamemodes/modules/Player/payday/handle.pwn"
#include "./gamemodes/modules/Player/acessory/handle.pwn"
//#include "./gamemodes/modules/Player/voice/handle.pwn"
//  ------------------------- PLAYERS --------------------------

#include "./gamemodes/modules/Organization/handle.pwn"
#include "./gamemodes/modules/Vehicle/handle.pwn"
#include "./gamemodes/modules/Admin/handle.pwn"
#include "./gamemodes/modules/Games/handle.pwn"

//  -------------------------- GAMES --------------------------
#include "./gamemodes/modules/Games/Race/handle.pwn"
#include "./gamemodes/modules/Games/Arena/handle.pwn"
//  -------------------------- GAMES --------------------------

//  -------------------------  SHOPS ---------------------------
#include "./gamemodes/modules/Shop/dealership/handle.pwn" 
//  -------------------------  SHOPS ---------------------------

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
#include "./gamemodes/modules/Shop/commands.pwn" 

main()
{
    pp_use_funcidx(true);
}

public OnGameModeInit()
{
    /* GAS STATION */
    Gas[0][gas::pX] = 1944.5725;
    Gas[1][gas::pX] = 1938.5725;
    Gas[0][gas::pY] = Gas[1][gas::pY] = -1772.6949;
    Gas[0][gas::pZ] = Gas[1][gas::pZ] = 13.55;

    Gas[0][gas::pickup] = CreateDynamicPickup(19621, 0, 1944.5725, -1772.6949, 13.55);
    Gas[1][gas::pickup] = CreateDynamicPickup(19621, 0, 1938.5725, -1772.6949, 13.55);
    
    new str[144];
    format(str, 144, "[ {ff9933}POSTO DE GASOLINA {ffffff}]\nDigite {ff9933}/abastecer");

    Gas[0][gas::label] = CreateDynamic3DTextLabel(str, -1, 1944.5725, -1772.6949, 13.55, 60.0);
    Gas[1][gas::label] = CreateDynamic3DTextLabel(str, -1, 1938.5725, -1772.6949, 13.55, 60.0);

    Mec[ofc::pX] = 1943.4880;
    Mec[ofc::pY] = -1810.5806;
    Mec[ofc::pZ] = 13.5663;

    Mec[ofc::pickup] = CreateDynamicPickup(19627, 0, 1943.4880, -1810.5806, 13.5663);

    format(str, 144, "[ {ff5599}OFICINA MECANICA{ffffff}]\nDigite {ff5599}/oficina");

    Mec[ofc::label] = CreateDynamic3DTextLabel(str, -1, 1943.4880, -1810.5806, 13.5663, 60.0);

    return 1;
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

    DestroyAllDynamic3DTextLabels();
    DestroyAllDynamicPickups();

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
    
    if(IsPlayerControllable(playerid))
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

YCMD:savepos(playerid, params[], help)
{
    new Float:x, Float:y, Float:z;
    new linha[128];
    new File:arquivo;

    // 1. Obtém a posição atual do jogador
    GetPlayerPos(playerid, x, y, z);

    // 2. Formata a string que será salva no arquivo
    // Usamos \r\n para pular linha no Windows (padrão do bloco de notas)
    format(linha, sizeof(linha), "%f, %f, %f\r\n", x, y, z);

    // 3. Abre o arquivo "positions.txt" no modo "append" (adicionar ao final)
    arquivo = fopen("positions.txt", io_append);

    if(arquivo)
    {
        // 4. Escreve a linha e fecha o arquivo
        fwrite(arquivo, linha);
        fclose(arquivo);

        SendClientMessage(playerid, -1, "{00FF00}Sucesso: {FFFFFF}Sua posicao foi salva");
    }
    else
    {
        SendClientMessage(playerid, -1, "{FF0000}Erro: {FFFFFF}Não foi possivel abrir o arquivo.");
    }

    return 1;
}

YCMD:teste(playerid, params[], help)
{
    DC::Log(LOG_TYPE_ERR, "[ DB ] Erro ao tentar carregar posições de spawn do jogador %s!", GetPlayerNameStr(playerid));

    return 1;
}