#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Bank::LoadMap(MAP_BANK_NU);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa do Nubank carregado com sucesso\n");
    Bank::LoadMap(MAP_BANK_LOTTERY);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Loterica carregado com sucesso\n");
    Dealership::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Concessionaria carregado com sucesso\n");
    Garage::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa das Garagens carregado com sucesso\n");
    Org::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da PRF carregado com sucesso\n");
    Spawn::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa do Spawn carregado com sucesso\n");
    Store::LoadMap(MAP_STORE_247);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Loja carregado com sucesso\n");
    Store::LoadMap(MAP_STORE_BINCO);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Loja carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_HP);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Praca Hospital carregado com sucesso\n");
    Square::LoadMap(MAP_SQUARE_LS);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Praca LS carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_AIRPORT);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Mecania Aeroporto carregado com sucesso\n");
    Officine::LoadMap(MAP_MEC_DROP);
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Mecania Drop carregado com sucesso\n");
    Prision::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Prisao staff carregado com sucesso\n");
    Arena::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Arena PvP carregado com sucesso\n");
    Ammu::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Arena PvP carregado com sucesso\n");
    House::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa do Predio carregado com sucesso\n");   
    Groove::LoadMap();
    DC::LoadCountMaps++;
    print("[ MAPA ] Mapa da Groove carregado com sucesso\n"); 
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
    Groove::RemoveGTAObjects(playerid);
    return 1;
}
