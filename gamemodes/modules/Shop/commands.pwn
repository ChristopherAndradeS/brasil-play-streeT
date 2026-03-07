YCMD:loja(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    Shop::HandleCommands(playerid);
    return 1;
}

stock Dealership::ShopOpen(playerid)
{
    inline dsp_dialog(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, inputtext 

        if(!response) return 1;    

        dsp::Player[playerid][dsp::idex] = 0;
        dsp::Player[playerid][dsp::categoryid] = listitem; 
        dsp::Player[playerid][dsp::color1] = RandomMinMax(0, 255); 
        dsp::Player[playerid][dsp::color2] = RandomMinMax(0, 255); 
        
        new modelid, Float:price;
        GetVehicleShopData(dsp::Player[playerid][dsp::categoryid], 0, modelid, price);

        Dealership::SetPlayerInShop(playerid, modelid, dsp::Player[playerid][dsp::color1], dsp::Player[playerid][dsp::color2], price);

        GetPlayerPos(playerid, Player[playerid][pyr::oX], Player[playerid][pyr::oY], Player[playerid][pyr::oZ]);
        GetPlayerFacingAngle(playerid, Player[playerid][pyr::oA]);   

        return 1;
    }

    new msg[256];

    for(new i = 0; i < sizeof(Dealership::gCategoryName); i++)
    {
        format(msg, 256, "%s{ff1199}%d{ffffff}. %s\n", msg, i + 1, Dealership::gCategoryName[i]);
    }


    Dialog_ShowCallback(playerid, using inline dsp_dialog, DIALOG_STYLE_LIST, 
    "Concessionaria", msg, "Selecionar", "Fechar");

    return 1;
}

stock Shop::HandleCommands(playerid)
{
    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    new regionid = GetRegionFromXY(pX, pY);

    switch(regionid)
    {
        case 24:
        { 
            if(IsPlayerInRangeOfPoint(playerid, 2.5, -18.1846, -1619.5968, 3.6084)) 
                return Dealership::ShopOpen(playerid); 
            else
                return 0;  
        }
    }

    return 0;
}
