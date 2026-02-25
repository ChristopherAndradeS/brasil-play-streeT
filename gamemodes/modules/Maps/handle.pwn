#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Bank::LoadMap(MAP_BANK_NU);
    print("[ MAPA ] Mapa do Nubank carregado com sucesso\n");
    Bank::LoadMap(MAP_BANK_LOTTERY);
    print("[ MAPA ] Mapa da Loterica carregado com sucesso\n");
    Dealership::LoadMap();
    print("[ MAPA ] Mapa da Concessionária carregado com sucesso\n");
    Garage::LoadMap();
    print("[ MAPA ] Mapa das Garagens carregado com sucesso\n");
    Org::LoadMap();
    print("[ MAPA ] Mapa da PRF carregado com sucesso\n");
    Spawn::LoadMap();
    print("[ MAPA ] Mapa do Spawn carregado com sucesso\n");
    Store::LoadMap(MAP_STORE_247);
    print("[ MAPA ] Mapa da Loja carregado com sucesso\n");
    Store::LoadMap(MAP_STORE_BINCO);
    print("[ MAPA ] Mapa da Loja carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_HP);
    print("[ MAPA ] Mapa da Praça Hospital carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_LS);
    print("[ MAPA ] Mapa da Praça LS carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_AIRPORT);
    print("[ MAPA ] Mapa da Mecânia Aeroporto carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_DROP);
    print("[ MAPA ] Mapa da Mecânia Drop carregado com sucesso\n");
    Prision::LoadMap();
    print("[ MAPA ] Mapa da Prisão staff carregado com sucesso\n");
    Arena::LoadMap();
    print("[ MAPA ] Mapa da Arena PvP carregado com sucesso\n");
    Ammu::LoadMap();
    print("[ MAPA ] Mapa da Arena PvP carregado com sucesso\n");
    House::LoadMap();
    print("[ MAPA ] Mapa do Predio carregado com sucesso\n");
    return 1;
}

hook OnPlayerConnect(playerid)
{
    Officine::RemoveGTAObjects(playerid, MAP_MEC_LS);
    Officine::RemoveGTAObjects(playerid, MAP_MEC_AIRPORT);
    Org::RemoveGTAObjects(playerid);
    Store::RemoveGTAObjects(playerid, MAP_STORE_BINCO);
    Spawn::RemoveGTAObjects(playerid);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_HP);
    Square::RemoveGTAObjects(playerid, MAP_SQUARE_LS);
    Ammu::RemoveGTAObjects(playerid);
    Bank::RemoveGTAObjects(playerid, MAP_BANK_LOTTERY);
    House::RemoveGTAObjects(playerid);
    
    return 1;
}
