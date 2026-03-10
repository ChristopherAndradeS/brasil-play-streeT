#include <YSI/YSI_Coding/y_hooks>

public DSP_UpdateCarRotate(playerid, vehicleid)
{
    if(!IsValidVehicle(dsp::Player[playerid][dsp::vehicleid]) || !IsValidPlayer(playerid)) 
    {
        Dealership::UnSetPlayerInShop(playerid);
        return 1;
    }

    new Float:angle;
    GetVehicleZAngle(vehicleid, angle);
    SetVehicleZAngle(vehicleid, angle >= 360.0 ? 0.0 : angle + 2.0);
    return 1;
}

stock Dealership::UnSetPlayerInShop(playerid)
{
    Player::KillTimer(playerid, pyr::TIMER_DSP);
    
    if(IsValidVehicle(dsp::Player[playerid][dsp::vehicleid]))
        DestroyVehicle(dsp::Player[playerid][dsp::vehicleid]);

    dsp::Player[playerid][dsp::idex] = 0;
    dsp::Player[playerid][dsp::categoryid] = 0; 
    dsp::Player[playerid][dsp::color1] = 0; 
    dsp::Player[playerid][dsp::color2] = 0; 

    if(!IsValidPlayer(playerid)) return 1;

    SetPlayerPos(playerid, Player[playerid][pyr::oX], Player[playerid][pyr::oY], Player[playerid][pyr::oZ]);
    SetPlayerFacingAngle(playerid, Player[playerid][pyr::oA]);
    SetCameraBehindPlayer(playerid);
    SetPlayerVirtualWorld(playerid, 0);
    TogglePlayerControllable(playerid, true);

    Dealership::HideTDForPlayer(playerid);
    Baseboard::ShowTDForPlayer(playerid); 

    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CLOCK);
    SetPlayerWeather(playerid, Server[srv::g_weatherid]);

    return 1;
}

stock Dealership::UpdatePlayerShop(playerid, modelid, color1, color2, Float:price)
{
    if(IsValidVehicle(dsp::Player[playerid][dsp::vehicleid]))
        DestroyVehicle(dsp::Player[playerid][dsp::vehicleid]);

    dsp::Player[playerid][dsp::vehicleid] = CreateVehicle(modelid, -1660.7682, 1211.1519, 20.8884 + 0.5, 271.3025, color1, color2, -1);
    SetVehicleVirtualWorld(dsp::Player[playerid][dsp::vehicleid], 60);

    new 
        veh_name[32]
    ;

    GetVehicleNameByModel(GetVehicleModel(dsp::Player[playerid][dsp::vehicleid]), veh_name);

    Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_NAME, "NOME: ~p~~h~%s", veh_name);
    Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_PRICE, "PRECO: ~g~~h~%.2f R$", price);
    Dealership::UpdateTextDrawColor(playerid, PTD_DSP_SPR_COLOR1, gVehicleColoursTableRGBA[color1]);
    Dealership::UpdateTextDrawColor(playerid, PTD_DSP_SPR_COLOR2, gVehicleColoursTableRGBA[color2]);
}

stock Dealership::SetPlayerInShop(playerid, modelid, color1, color2, Float:price)
{
    if(IsValidVehicle(dsp::Player[playerid][dsp::vehicleid]))
        DestroyVehicle(dsp::Player[playerid][dsp::vehicleid]);
    
    dsp::Player[playerid][dsp::vehicleid] = CreateVehicle(modelid, -1660.7682, 1211.1519 + 0.5, 20.8884 + 0.5, 271.3025, color1, color2, -1);
    SetVehicleVirtualWorld(dsp::Player[playerid][dsp::vehicleid], 60);
       
    new 
        veh_name[32]
    ;

    GetVehicleNameByModel(GetVehicleModel(dsp::Player[playerid][dsp::vehicleid]), veh_name);

    Baseboard::HideTDForPlayer(playerid);
    Dealership::ShowTDForPlayer(playerid);

    SetPlayerPos(playerid, -1660.7682,1211.1519,15.8884 + 0.2);
    SetPlayerCameraPos(playerid,-1653.031372,1211.236450,21.756246);
    SetPlayerCameraLookAt(playerid,-1659.092773,1211.074340,20.876249);
    SetPlayerVirtualWorld(playerid, 60);
    TogglePlayerControllable(playerid, false);
  
    Player::CreateTimer(playerid, pyr::TIMER_DSP, "DSP_UpdateCarRotate", 33, true, "ii", playerid, dsp::Player[playerid][dsp::vehicleid]);

    Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_NAME, "NOME: ~p~~h~%s", veh_name);
    Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_PRICE, "PRECO: ~g~~h~%.2f R$", price);
    Dealership::UpdateTextDrawColor(playerid, PTD_DSP_SPR_COLOR1, gVehicleColoursTableRGBA[color1]);
    Dealership::UpdateTextDrawColor(playerid, PTD_DSP_SPR_COLOR2, gVehicleColoursTableRGBA[color2]);

    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CLOCK);
    SetPlayerWeather(playerid, 1);

    return 1;
}



