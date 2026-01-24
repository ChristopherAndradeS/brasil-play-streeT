#include <YSI\YSI_Coding\y_hooks>

enum _:E_MAP_SQUARE
{
    MAP_SQUARE_HP = 1,
    MAP_SQUARE_LS
}

enum _:E_MAP_MEC
{
    MAP_MEC_LS = 1,
    MAP_MEC_AIRPORT,
    MAP_MEC_DROP,
}

hook OnGameModeInit()
{
    Bank::LoadMap();
    print("[ MAPA ] Mapa do Nubank carregado com sucesso\n");
    Dealership::LoadMap();
    print("[ MAPA ] Mapa da Concessionária carregado com sucesso\n");
    Garage::LoadMap();
    print("[ MAPA ] Mapa das Garagens carregado com sucesso\n");
    Org::LoadMap();
    print("[ MAPA ] Mapa da PRF carregado com sucesso\n");
    Spawn::LoadMap();
    print("[ MAPA ] Mapa do Spawn carregado com sucesso\n");
    Store::LoadMap();
    print("[ MAPA ] Mapa da Loja carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_HP);
    print("[ MAPA ] Mapa da Praça Hospital carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_LS);
    print("[ MAPA ] Mapa da Praça LS carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_LS);
    print("[ MAPA ] Mapa da Mecânica LS carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_AIRPORT);
    print("[ MAPA ] Mapa dA Mecânia Aeroporto carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_DROP);
    print("[ MAPA ] Mapa dA Mecânia Drop carregado com sucesso\n");

    return 1;
}

hook OnPlayerConnect(playerid)
{
    Bank::RemoveGTAObjects(playerid);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_LS);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_AIRPORT);
    Org::RemoveGTAObjects(playerid);
    Spawn::RemoveGTAObjects(playerid);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_HP);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_LS);
}