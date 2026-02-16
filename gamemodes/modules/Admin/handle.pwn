#include <YSI\YSI_Coding\y_hooks>

forward OnSpectatorListUpdate(spectatorid, reason);

hook OnGameModeInit()
{
    gAdminSpectates = list_new();
    return 1;
}

hook OnGameModeExit()
{
    list_delete(gAdminSpectates);
    printf("[ LISTA ] Lista Espectadores Admin deletada!\n");
    return 1;
}

hook OnPlayerLogin(playerid)
{
    Adm::Load(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    Adm::UnSet(playerid);
    if(IsValidVehicle(Admin[playerid][adm::vehicleid]))
        DestroyVehicle(Admin[playerid][adm::vehicleid]);
    
    Admin[playerid][adm::vehicleid] = INVALID_VEHICLE_ID;
    
    return 1;
}

public OnSpectatorListUpdate(spectatorid, reason)
{
    if(!list_valid(gAdminSpectates)) return 1;

    foreach(new i : Adm_Iter)
    {
        if(Admin[i][adm::spectateid] == spectatorid)
        {
            SendClientMessage(i, -1, "{ffff33}[ ADM ] {ffffff}O jogador \
            {ffffff}[ {ffff33}ID: %d {ffffff}] {ffff33}%s", 
            spectatorid, reason > 1 ? "Saiu do mundo!" :  "Se desconectou!");
            
            Admin[i][adm::spectateid] = Adm::GetNextSpectateID(i, 0, 1);
            
            if(Admin[i][adm::spectateid] != INVALID_PLAYER_ID) 
                Adm::SpectatePlayer(i, Admin[i][adm::spectateid]);
            else
            {
                Adm::UnSetWork(i);
                SendClientMessage(i, -1, "{ff3333}[ CMD ] {ffffff}Nenhum jogador online para entrar em modo de trabalho!"); 
            }
        }
    }

    return 1;
}

stock Adm::AddSpectatorInList(spectatorid)   
{
    if(!list_valid(gAdminSpectates)) return 0;

    if(list_find(gAdminSpectates, spectatorid) == -1)
    {
        list_add(gAdminSpectates, spectatorid);
        return 1;
    }

    return 0;
}

stock Adm::RemSpectatorInList(spectatorid, reason)   
{   
    if(!list_valid(gAdminSpectates)) return 0;

    new idx = list_find(gAdminSpectates, spectatorid);

    if(idx != -1)
    {
        list_remove(gAdminSpectates, idx);
        CallLocalFunction("OnSpectatorListUpdate", "ii", spectatorid, reason);
        return 1;
    }

    return 0;
}