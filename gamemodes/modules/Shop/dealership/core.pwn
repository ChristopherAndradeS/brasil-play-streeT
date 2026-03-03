#include <YSI/YSI_Coding/y_hooks>

public UpdateCarRotate(playerid, vehicleid)
{
    new Float:angle;
    GetVehicleZAngle(vehicleid, angle);
    SetVehicleZAngle(vehicleid, angle >= 360.0 ? 0.0 : angle + 6.0);
    return 1;
}

stock Dealership::SetInShop(playerid, modelid, color1, color2, bool:change = false)
{
    if(IsValidVehicle(pyr::Shop[playerid][dsp::vehicleid]))
        DestroyVehicle(pyr::Shop[playerid][dsp::vehicleid]);
    
    pyr::Shop[playerid][dsp::vehicleid] = CreateVehicle(modelid, -1660.7682, 1211.1519, 20.8884, 271.3025, color1, color2, -1);
    SetVehicleVirtualWorld(pyr::Shop[playerid][dsp::vehicleid], 1);

    if(!change)
    {
        Baseboard::HideTDForPlayer(playerid);
        Dealership::ShowTDForPlayer(playerid);
    
        SetPlayerPos(playerid, -1660.7682,1211.1519,15.8884);
        SetPlayerCameraPos(playerid,-1653.031372,1211.236450,21.756246);
        SetPlayerCameraLookAt(playerid,-1659.092773,1211.074340,20.876249);
        SetPlayerVirtualWorld(playerid, 1);
        TogglePlayerControllable(playerid, false);
        pyr::Shop[playerid][dsp::timerid]  = SetTimerEx("UpdateCarRotate", 33, true, "ii", playerid, pyr::Shop[playerid][dsp::vehicleid]);
        return  1;
    }

    if(IsValidTimer(pyr::Shop[playerid][dsp::timerid]))
        KillTimer(pyr::Shop[playerid][dsp::timerid]);

    pyr::Shop[playerid][dsp::timerid] = SetTimerEx("UpdateCarRotate", 100, true, "ii", playerid, pyr::Shop[playerid][dsp::vehicleid]);
    
    return 1;
}   

// YCMD:enter(playerid, params[], help)
// {
//     Dealership::SetInShop(playerid, g_models[0], 1, 1);
//     GetPlayerPos(playerid, Player[playerid][pyr::oX], Player[playerid][pyr::oY], Player[playerid][pyr::oZ]);
//     GetPlayerFacingAngle(playerid, Player[playerid][pyr::oA]);

//     return 1;
// }

// YCMD:prev(playerid, params[], help)
// {
//     pyr::Shop[playerid][dsp::idex] = (pyr::Shop[playerid][dsp::idex] + 1) % sizeof(g_models);
//     Dealership::SetInShop(playerid, g_models[pyr::Shop[playerid][dsp::idex]], 1, 1, true);

//     return 1;
// }

// YCMD:quitar(playerid, params[], help)
// {
//     if(IsValidTimer(pyr::Shop[playerid][dsp::timerid]))
//     {
//         printf("TIMER MORTO");
//         KillTimer(pyr::Shop[playerid][dsp::timerid]);
//         printf("TIMER MORTO");
//     }
    
//     if(IsValidVehicle(pyr::Shop[playerid][dsp::vehicleid]))
//         DestroyVehicle(pyr::Shop[playerid][dsp::vehicleid]);

//     SetPlayerPos(playerid, Player[playerid][pyr::oX], Player[playerid][pyr::oY], Player[playerid][pyr::oZ]);
//     SetPlayerFacingAngle(playerid, Player[playerid][pyr::oA]);
//     SetCameraBehindPlayer(playerid);
//     TogglePlayerControllable(playerid, true);

//     Dealership::HideTDForPlayer(playerid);
//     Baseboard::ShowTDForPlayer(playerid);

//     return 1;
// }
