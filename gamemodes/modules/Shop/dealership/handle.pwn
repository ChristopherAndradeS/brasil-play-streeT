#include <YSI/YSI_Coding/y_hooks>

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == TD_DSP_BTN_PREV)
    {
        pyr::Shop[playerid][dsp::idex] = (pyr::Shop[playerid][dsp::idex] - 1) % sizeof(g_models);
        Dealership::SetInShop(playerid, g_models[pyr::Shop[playerid][dsp::idex]], 1, 1, true);
        return 1;
    }

    if(clickedid == TD_DSP_BTN_NEXT)
    {
        pyr::Shop[playerid][dsp::idex] = (pyr::Shop[playerid][dsp::idex] + 1) % sizeof(g_models);
        Dealership::SetInShop(playerid, g_models[pyr::Shop[playerid][dsp::idex]], 1, 1, true);
        return 1;
    }

    if(clickedid == TD_DSP_BTN_HIDE)
    {
        if(Dealership::IsVisibleTDForPlayer(playerid))
        {
            for(new i = 0; i < 13; i++)
            {
                if(_:TD_DSP_BTN_HIDE == i) continue;
                TextDrawHideForPlayer(playerid, Dealership::PublicTD[i]);
            }
            for(new i = 0; i < 5; i++)
            {
                if(_:PTD_DSP_TXT_HIDE == i) continue;
                PlayerTextDrawHide(playerid, Dealership::PlayerTD[playerid][i]); 
            }

            Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_HIDE, "Mostrar");
        }

        else
        {
            for(new i = 0; i < 13; i++)
                TextDrawShowForPlayer(playerid, Dealership::PublicTD[i]);
            for(new i = 0; i < 5; i++)
                PlayerTextDrawShow(playerid, Dealership::PlayerTD[playerid][i]);   

            Dealership::UpdateTDForPlayer(playerid, PTD_DSP_TXT_HIDE, "Esconder");         
        }       
    }

    if(clickedid == TD_DSP_BTN_QUIT)
    {
        if(IsValidTimer(pyr::Shop[playerid][dsp::timerid]))
        {
            KillTimer(pyr::Shop[playerid][dsp::timerid]);
        }
        
        if(IsValidVehicle(pyr::Shop[playerid][dsp::vehicleid]))
            DestroyVehicle(pyr::Shop[playerid][dsp::vehicleid]);

        SetPlayerPos(playerid, Player[playerid][pyr::oX], Player[playerid][pyr::oY], Player[playerid][pyr::oZ]);
        SetPlayerFacingAngle(playerid, Player[playerid][pyr::oA]);
        SetCameraBehindPlayer(playerid);
        TogglePlayerControllable(playerid, true);

        Dealership::HideTDForPlayer(playerid);
        Baseboard::ShowTDForPlayer(playerid);        
    }

    return 1;
}
