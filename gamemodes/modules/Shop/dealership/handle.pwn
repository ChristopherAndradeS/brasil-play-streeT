#include <YSI/YSI_Coding/y_hooks>

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    new 
        category = dsp::Player[playerid][dsp::categoryid],
        idex = dsp::Player[playerid][dsp::idex]
    ;

    if
    (
        playertextid == Dealership::PlayerTD[playerid][PTD_DSP_SPR_COLOR1] || 
        playertextid == Dealership::PlayerTD[playerid][PTD_DSP_SPR_COLOR2]
    )
    {
        new colorid = (playertextid == Dealership::PlayerTD[playerid][PTD_DSP_SPR_COLOR1]) ? 1 : 2;

        new page;

        inline dsp_color_dialog(targetid, dialogid, response, listitem, string:inputtext[])
        {
            #pragma unused targetid, dialogid, inputtext 

            if(!response) return 1;    

            if(listitem == 128)
            {
                new msg[2048];

                for(new i = 128; i < 256; i++)
                {
                    format(msg, sizeof(msg), "%s{%06x}###\n", msg, gVehicleColoursTableRGBA[i] >>> 8);
                }  

                page = 1;
                Dialog_ShowCallback(playerid, using inline dsp_color_dialog, DIALOG_STYLE_LIST, "Concessionaria", msg, "Selecionar", "Voltar");
                return 1;
            }

            new color = listitem + (128 * page);

            switch(colorid)
            {
                case 1: dsp::Player[playerid][dsp::color1] = color;
                case 2: dsp::Player[playerid][dsp::color2] = color;
            }
            
            new modelid, Float:price;
            GetVehicleShopData(category, idex, modelid, price);

            Dealership::UpdatePlayerShop(playerid, modelid, 
            dsp::Player[playerid][dsp::color1], dsp::Player[playerid][dsp::color2], price);

            return 1;
        }

        new msg[2048];

        for(new i = 0; i < 128; i++)
        {
            format(msg, sizeof(msg), "%s{%06x}###\n", msg, gVehicleColoursTableRGBA[i] >>> 8);
        }  

        format(msg, sizeof(msg), "%s{ff3333}Mais Cores >>>\n", msg);

        Dialog_ShowCallback(playerid, using inline dsp_color_dialog, DIALOG_STYLE_LIST, "Concessionaria", msg, "Selecionar", "Fechar");
        return 1;
    }

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    new 
        category = dsp::Player[playerid][dsp::categoryid],
        color1 = dsp::Player[playerid][dsp::color1],
        color2 = dsp::Player[playerid][dsp::color2]
    ;
    
    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_PREV])
    {
        dsp::Player[playerid][dsp::idex] = (dsp::Player[playerid][dsp::idex] - 1) % Dealership::gCategoryCount[category];
        
        new modelid, Float:price;
        GetVehicleShopData(category, dsp::Player[playerid][dsp::idex], modelid, price);

        Dealership::UpdatePlayerShop(playerid, modelid, color1, color2, price);

        return 1;
    }

    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_NEXT])
    {
        dsp::Player[playerid][dsp::idex] = (dsp::Player[playerid][dsp::idex] + 1) % Dealership::gCategoryCount[category];
        
        new modelid, Float:price;
        GetVehicleShopData(category, dsp::Player[playerid][dsp::idex], modelid, price);

        Dealership::UpdatePlayerShop(playerid, modelid, color1, color2, price);
        return 1;
    }

    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_HIDE])
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
        return 1;  
    }

    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_QUIT])
    {
        Dealership::UnSetPlayerInShop(playerid);   
        return 1;    
    }

    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_CAT])
    {
        inline dsp_dialog(targetid, dialogid, response, listitem, string:inputtext[])
        {
            #pragma unused targetid, dialogid, inputtext 

            if(!response) return 1;    

            dsp::Player[playerid][dsp::idex] = 0;
            dsp::Player[playerid][dsp::categoryid] = listitem; 
            
            new modelid, Float:price;
            GetVehicleShopData(dsp::Player[playerid][dsp::categoryid], 0, modelid, price);

            Dealership::UpdatePlayerShop(playerid, modelid, color1, color2, price);

            return 1;
        }

        new msg[256];

        for(new i = 0; i < sizeof(Dealership::gCategoryName); i++)
        {
            format(msg, 256, "%s{ff1199}%d{ffffff}. %s\n", msg, i + 1, Dealership::gCategoryName[i]);
        }

        Dialog_ShowCallback(playerid, using inline dsp_dialog, DIALOG_STYLE_LIST, "Concessionaria", msg, "Selecionar", "Fechar");
        return 1;
    }

    if(clickedid == Dealership::PublicTD[TD_DSP_BTN_BUY])
    {
        new modelid, Float:price, veh_name[32];

        GetVehicleShopData(category, dsp::Player[playerid][dsp::idex], modelid, price);
        
        GetVehicleNameByModel(modelid, veh_name);

        inline dsp_buy_dialog(targetid, dialogid, response, listitem, string:inputtext[])
        {
            #pragma unused targetid, dialogid, listitem, inputtext 

            if(!response) return 1;    
       
            if(!Player::RemoveMoney(playerid, price, true)) return 1;
            
            new slotid, owner[MAX_PLAYER_NAME];
            
            GetPlayerName(playerid, owner);

            DB::GetDataInt(db_entity, "players", "veh_count", slotid, "name = '%q'", owner);
            
            if(slotid >= MAX_PLAYER_VEHICLES)
                return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você já possui o número máximo de veículos por jogador!");

            new data[E_VEHICLES];

            format(data[veh::owner_name], 24, "%s", owner);
            data[veh::slotid] = slotid;
            data[veh::owner_type] = OWNER_TYPE_PLAYER;
            data[veh::modelid] = modelid;
            data[veh::fuel] = 60.0; 
            data[veh::health] = 1250.0;
            data[veh::color1] = color1;
            data[veh::color2] = color2;
            data[veh::paintjobid] = -1;

            if(Veh::Insert(owner, slotid, data))
            {
                Player::RemoveMoney(playerid, price);
                DB::SetDataInt(db_entity, "players", "veh_count", slotid + 1, "name = '%q'", owner);
            }

            else
            {
                SendClientMessage(playerid, -1, "{33ff33}[ ERRO ] {ffffff}Um erro fatal aconteceu. Avise um moderador!");
                return 1;            
            }
        
            SendClientMessage(playerid, -1, "{55ff55}[ VEH ] {ffffff}Você comprou um {55ff55}%s{ffffff}, já enviamos ele para sua garagem.", veh_name);
            SendClientMessage(playerid, -1, "{ff5555}[ VEH ] {ffffff}Você tem um novo veículo na sua garagem. Use {ff5555}/garagem {ffffff}para conferir");

            Dealership::UnSetPlayerInShop(playerid);
            return 1;
        }

        new msg[256];

        format(msg, 256, "{ff9911}>> {ffffff}Voce deseja comprar o veiculo {ff9911}%s {ffffff}por {55ff55}%.2f R$ {ffffff}?", veh_name, price);
      
        Dialog_ShowCallback(playerid, using inline dsp_buy_dialog, DIALOG_STYLE_MSGBOX, "Concessionaria", msg, "{55ff55}Sim", "{ff5555}Não");

        return 1;
    }

    return 1;
}


