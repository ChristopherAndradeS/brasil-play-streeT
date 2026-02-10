#include <YSI\YSI_Coding\y_hooks>

forward OnSpectatorListUpdate(spectatorid, reason);

stock Adm::SetPlayerCommands(playerid, roleid)
{   
    Command_SetPlayer(YCMD:aa, playerid, roleid >= ROLE_ADM_APR_HELPER);
    Command_SetPlayer(YCMD:aw, playerid, roleid >= ROLE_ADM_APR_HELPER);
    Command_SetPlayer(YCMD:ir, playerid, roleid >= ROLE_ADM_APR_HELPER);
    Command_SetPlayer(YCMD:verid, playerid, roleid >= ROLE_ADM_APR_HELPER);

    Command_SetPlayer(YCMD:kick, playerid, roleid >= ROLE_ADM_APR_STAFF);
    Command_SetPlayer(YCMD:congelar, playerid, roleid >= ROLE_ADM_APR_STAFF);
    Command_SetPlayer(YCMD:descongelar, playerid, roleid >= ROLE_ADM_APR_STAFF);

    Command_SetPlayer(YCMD:megafone, playerid, roleid >= ROLE_ADM_FOREMAN);
  
    Command_SetPlayer(YCMD:cronometro, playerid, roleid >= ROLE_ADM_FOREMAN);

    Command_SetPlayer(YCMD:lchat, playerid, roleid >= ROLE_ADM_MANAGER);
    Command_SetPlayer(YCMD:setarskin, playerid, roleid >= ROLE_ADM_MANAGER);
    Command_SetPlayer(YCMD:setarvida, playerid, roleid >= ROLE_ADM_MANAGER);
    Command_SetPlayer(YCMD:setarcolete, playerid, roleid >= ROLE_ADM_MANAGER);

    Command_SetPlayer(YCMD:prender, playerid, roleid >= ROLE_ADM_APR_HELPER);  //ROLE_ADM_MANAGER  
    Command_SetPlayer(YCMD:soltar, playerid, roleid >= ROLE_ADM_APR_HELPER);
    Command_SetPlayer(YCMD:prenderoff, playerid, roleid >= ROLE_ADM_MANAGER);    
    //Command_SetPlayer(YCMD:soltaroff, playerid, roleid >= ROLE_ADM_MANAGER);
    //Command_SetPlayer(YCMD:criargps, playerid, roleid >= ROLE_ADM_MANAGER);
    //Command_SetPlayer(YCMD:criarorg, playerid, roleid >= ROLE_ADM_MANAGER);

    //Command_SetPlayer(YCMD:ban, playerid, roleid >= ROLE_ADM_CEO);  
    //Command_SetPlayer(YCMD:banip, playerid, roleid >= ROLE_ADM_CEO);  
    //Command_SetPlayer(YCMD:desban, playerid, roleid >= ROLE_ADM_CEO);  
    //Command_SetPlayer(YCMD:desbanip, playerid, roleid >= ROLE_ADM_CEO);  
    //Command_SetPlayer(YCMD:setadm, playerid, roleid >= ROLE_ADM_CEO);  
    //Command_SetPlayer(YCMD:remadm, playerid, roleid >= ROLE_ADM_CEO);  
}

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
    new level;

    if(!Adm::Exists(GetPlayerNameEx(playerid), level)) return 1;
    
    SetFlag(Admin[playerid][adm::flags], floatround(Float:floatpower(2, level)));
    Admin[playerid][adm::lvl] = level;
    Adm::SetPlayerCommands(playerid, Admin[playerid][adm::lvl]);
    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID;
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    Adm::RemSpectatorInList(playerid, 1);
    Adm::SetPlayerCommands(playerid, 0);
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
            spectatorid, reason > 1 ? "Sai do mundo!" :  "Se desconectou!");
            
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