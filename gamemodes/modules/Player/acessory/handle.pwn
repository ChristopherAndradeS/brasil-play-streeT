#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerSpawn(playerid)
{
    for(new i = 0; i < 10; i++)
        RemovePlayerAttachedObject(playerid, i);
    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    for(new i = 0; i < MAX_PLAYER_ACESSORYS; i++)
        if(DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d AND flags = 1", name, i))
            Acessory::LoadOnPlayer(playerid, i);

    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    for(new i = 0; i < MAX_PLAYER_ACESSORYS; i++)
        if(DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, i))
            DB::SetDataInt(db_entity, "acessorys", "flags", IsPlayerAttachedObjectSlotUsed(playerid, i), 
            "owner = '%q' AND slotid = %d", name, i);
    
    for(new i = 0; i < 10; i++)
        RemovePlayerAttachedObject(playerid, i);

    return 1;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!GetFlag(acs::Player[playerid][acs::flags], FLAG_EDITING_ACS)) return 1;
    
    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_POS_AXIS_BTN])
    {
        inline response_pos_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext
            if(!sresponse) return 1;
            Acessory::ChangeAxis(playerid, MEA_TYPE_POSITION, slistitem);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline response_pos_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo de Posicao", 
        "{ff9933}1. {ff0000}Eixo X\n{ff9933}2. {00ff00}Eixo Y\n{ff9933}3. {0000ff}Eixo Z", 
        "{ff9933}Selecionar", "{ffffff}Fechar");
    }

    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_ANG_AXIS_BTN])
    {
        inline response_ang_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext
            if(!sresponse) return 1;
            Acessory::ChangeAxis(playerid, MEA_TYPE_ANGLE, slistitem);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline response_ang_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo de Rotacao", 
        "{ff9933}1. {ff0000}Eixo X\n{ff9933}2. {00ff00}Eixo Y\n{ff9933}3. {0000ff}Eixo Z", 
        "{ff9933}Selecionar", "{ffffff}Fechar");
    }

    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_SCL_AXIS_BTN])
    {
        inline response_scl_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext
            if(!sresponse) return 1; 
            Acessory::ChangeAxis(playerid, MEA_TYPE_SCALE, slistitem);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline response_scl_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo Escala", 
        "{ff9933}1. {ff0000}Eixo X\n{ff9933}2. {00ff00}Eixo Y\n{ff9933}3. {0000ff}Eixo Z", 
        "{ff9933}Selecionar", "{ffffff}Fechar");
    }

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!GetFlag(acs::Player[playerid][acs::flags], FLAG_EDITING_ACS)) return 1;
    
    new slotid = acs::Player[playerid][acs::slotid]; 

    // EXIT
    if(clickedid == Acessory::PublicTD[TD_ACS_EXIT_BTN])
    {
        inline confirm_exit(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem, stext
            if(!sresponse) return 1;
            
            Acessory::UnSetPlayerEditor(playerid);     
            return 1;   
        }

        Dialog_ShowCallback(playerid, using inline confirm_exit, DIALOG_STYLE_MSGBOX, 
        "Confirmar Saida", "{ffff33}>> {ffffff}Deseja {ffff33}sair {ffffff}do modo de edicao?\n\
        Os dados de posicao, rotacao e escala serao {ffff33}perdidos:", "{ffffff}Sim", "{ffffff}Nao, voltar");
 
        return 1;
    }
    
    // OFFSET POS
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_POS_BTN])
    {
        new msg[256];

        inline response_pos_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse) return 1;

            new Float:value;

            if(!Acessory::VerifyInputOffset(MEA_TYPE_POSITION, stext, value))
            {
                format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
                O valor deve estar entre {ff3333}0.00 {ffffff}e {ff3333}%.2f {ffffff}metros:\n", MAX_ACS_OFFSET_POS);

                Dialog_ShowCallback(playerid, using inline response_pos_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Posicao", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
                return 1;
            }    

            acs::Player[playerid][acs::pOffset] = value;
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_POS, "OFFSET:~n~~y~%.3f m", value);
            return 1;
        }

        format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
        O valor deve estar entre {ff9933}0.00 {ffffff}e {ff9933}%.2f {ffffff}metros:\n", MAX_ACS_OFFSET_POS);

        Dialog_ShowCallback(playerid, using inline response_pos_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Posicao", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    // OFFSET ANG
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_ANG_BTN])
    {
        new msg[256];

        inline response_ang_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse) return 1;

            new Float:value;

            if(!Acessory::VerifyInputOffset(MEA_TYPE_ANGLE, stext, value))
            {
                format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
                O valor deve estar entre {ff3333}0.00 {ffffff}e {ff3333}%.2f {ffffff}graus:\n", MAX_ACS_OFFSET_ANG);

                Dialog_ShowCallback(playerid, using inline response_ang_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Rotacao", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
                return 1;
            }    

            acs::Player[playerid][acs::aOffset] = value;
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_ANG, "OFFSET:~n~~y~%.1f graus", value);
            return 1;
        }

        format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
        O valor deve estar entre {ff9933}0.00 {ffffff}e {ff9933}%.2f {ffffff}graus:\n", MAX_ACS_OFFSET_ANG);

        Dialog_ShowCallback(playerid, using inline response_ang_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Rotacao", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    // OFFSET SCL
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_SCL_BTN])
    {
        new msg[256];

        inline response_scl_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse) return 1;

            new Float:value;

            if(!Acessory::VerifyInputOffset(MEA_TYPE_SCALE, stext, value))
            {
                format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
                O valor deve estar entre {ff3333}0.00 {ffffff}e {ff3333}%.2f {ffffff}metros:\n", MAX_ACS_OFFSET_SCL);

                Dialog_ShowCallback(playerid, using inline response_scl_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Escala", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
                return 1;
            }    

            acs::Player[playerid][acs::sOffset] = value;
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_SCL, "OFFSET:~n~~y~%.3f m", value);
            return 1;
        }

        format(msg, 256, "{ffffff}Digite um valor decimal para o deslocamento\n\
        O valor deve estar entre {ff3333}0.00 {ffffff}e {ff3333}%.2f {ffffff}metros:\n", MAX_ACS_OFFSET_SCL);

        Dialog_ShowCallback(playerid, using inline response_scl_offset, DIALOG_STYLE_INPUT, "Selecionar Offset Escala", msg, "{ff9933}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    // POSIÇÃO -
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_POS_MINUS])
    {
        switch(acs::Player[playerid][acs::pAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::pX] = floatclamp(acs::Player[playerid][acs::pX] - acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::pY] = floatclamp(acs::Player[playerid][acs::pY] - acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::pZ] = floatclamp(acs::Player[playerid][acs::pZ] - acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS);
            default: return 1;
        }

        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    // POSIÇÃO +
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_POS_PLUS])
    {
        switch(acs::Player[playerid][acs::pAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::pX] = floatclamp(acs::Player[playerid][acs::pX] + acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::pY] = floatclamp(acs::Player[playerid][acs::pY] + acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::pZ] = floatclamp(acs::Player[playerid][acs::pZ] + acs::Player[playerid][acs::pOffset], MIN_ACS_POS, MAX_ACS_POS);
            default: return 1;
        }

        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    // ROTAÇÃO -
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_ANG_MINUS])
    {
        switch(acs::Player[playerid][acs::aAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::rX] = floatclamp(acs::Player[playerid][acs::rX] - acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::rY] = floatclamp(acs::Player[playerid][acs::rY] - acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::rZ] = floatclamp(acs::Player[playerid][acs::rZ] - acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG);
            default: return 1;
        }
        
        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    // ROTAÇÃO +
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_ANG_PLUS])
    {
        switch(acs::Player[playerid][acs::aAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::rX] = floatclamp(acs::Player[playerid][acs::rX] + acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::rY] = floatclamp(acs::Player[playerid][acs::rY] + acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::rZ] = floatclamp(acs::Player[playerid][acs::rZ] + acs::Player[playerid][acs::aOffset], MIN_ACS_ANG, MAX_ACS_ANG);
            default: return 1;
        }
        
        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    // ESCALA -
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_SCL_MINUS])
    {
        switch(acs::Player[playerid][acs::sAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::sX] = floatclamp(acs::Player[playerid][acs::sX] - acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::sY] = floatclamp(acs::Player[playerid][acs::sY] - acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::sZ] = floatclamp(acs::Player[playerid][acs::sZ] - acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL);
            default: return 1;
        }
        
        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    // ESCALA +
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_SCL_PLUS])
    {
        switch(acs::Player[playerid][acs::sAxis])
        {   
            case AXIS_TYPE_X: acs::Player[playerid][acs::sX] = floatclamp(acs::Player[playerid][acs::sX] + acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL); 
            case AXIS_TYPE_Y: acs::Player[playerid][acs::sY] = floatclamp(acs::Player[playerid][acs::sY] + acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL);
            case AXIS_TYPE_Z: acs::Player[playerid][acs::sZ] = floatclamp(acs::Player[playerid][acs::sZ] + acs::Player[playerid][acs::sOffset], MIN_ACS_SCL, MAX_ACS_SCL);
            default: return 1;
        }
        
        Acessory::UpdateForPlayer(playerid, slotid);
        return 1;
    }

    //SALVAR
    if(clickedid == Acessory::PublicTD[TD_ACS_SAVE_BTN])
    {
        inline confirm_save(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem, stext
            if(!sresponse) return 1;

            Acessory::SaveData(playerid, slotid);        
            Acessory::UnSetPlayerEditor(playerid);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline confirm_save, DIALOG_STYLE_MSGBOX, 
        "Confirmar Salvamento", "{ffff33}>> {ffffff}Deseja {ffff33}salvar seu acessorio?", "{33ff33}Sim", "{ff3333}Nao, Voltar");
 
        return 1;
    }

    //ALTERAR VISÃO
    if(clickedid == Acessory::PublicTD[TD_ACS_CHANGE_VIEW_BTN])
        Acessory::UpdateEditorCam(playerid);
    
    return 1;
}

public Response_ACC_BONE(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
        
    new slotid = acs::Player[playerid][acs::slotid];
    
    if(!Acessory::ChangeBone(playerid, slotid, listitem + 1))
        return SendClientMessage(playerid, -1, "{ff3333}[ ACS ] {ffffff}Esse osso ja esta {ff3333}selecionado!");
    
    SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Osso do acessorio {33ff33}alterado {ffffff}Novo: {33ff33}%s", gBoneName[listitem + 1]);
 
    return 1;
}

public Response_ACC_LOJA(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) 
        return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");

    if(!DB::Exists(db_stock, "acessorys", "uid = %d", listitem + 1))
    {
        return SendClientMessage(playerid, -1, "{ff3333}[ ACS ] {ffffff}Estoque vazio! Já compraram esse acessório");
    }
    
    new slotid = Acessory::GetFreeSlot(playerid);

    if(slotid == INVALID_SLOTID) return 0;

    new stockid = listitem + 1;

    new Float:price;

    DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", stockid);

    if(!Player::RemoveMoney(playerid, price))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ACS LOJA ] {ffffff}Você nao tem {ff3333}dinheiro {ffffff}suficiente!");
        return 0;
    }

    Acessory::GivePlayerStock(playerid, slotid, stockid);

    Response_ACC_OPTIONS(playerid, dialogid, response, 1, inputtext);
 
    return 1;
}

public Response_ACC_OPTIONS(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response)  return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    new slotid = acs::Player[playerid][acs::slotid];
    new boneid;

    DB::GetDataInt(db_entity, "acessorys", "boneid", boneid, "owner = '%q' AND slotid = %d", name, slotid);

    switch(listitem)
    { 
        case 0:
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, slotid))
            {
                RemovePlayerAttachedObject(playerid, slotid);
                //acs::ClearData(playerid);
                SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Acessorio {33ff33}#%d {ffffff}desequipado!", slotid + 1);
            }

            else
            {
                Acessory::LoadOnPlayer(playerid, slotid);
                SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Acessorio {33ff33}#%d {ffffff}equipado!", slotid + 1);
            }
        } 

        case 1: Acessory::SetPlayerEditor(playerid, slotid);
            
        case 2:
        {
            new msg[1024];
       
            for(new i = 1; i < sizeof(gBoneName); i++)
                format(msg, sizeof(msg), "%s{9999ff}%d. {ffffff}%s\n", msg, i, gBoneName[i]);
            
            Dialog_ShowCallback(playerid, using public Response_ACC_BONE<iiiis>, DIALOG_STYLE_LIST, 
            "Escolha o local:", msg, "{9999ff}Escolher", "{ffffff}Voltar");
        }

        case 3:
        {
            new str[512], acs_name[64], modelid, Float:price;

            DB::GetDataInt(db_entity, "acessorys", "modelid", modelid, "owner = '%q' AND slotid = %d", name, slotid);
            DB::GetDataFloat(db_entity, "acessorys", "price", price, "owner = '%q' AND slotid = %d", name, slotid);
            
            Acessory::GetNameByModelid(modelid, acs_name);

            inline response_confirm_delete(spid, sdialogid, sresponse, slistitem, string:stext[])
            {
                #pragma unused spid, sdialogid, slistitem, stext

                if(!sresponse) return 1;

                Player::GiveMoney(playerid, price * 0.6);
                DB::Delete(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, slotid);
                RemovePlayerAttachedObject(playerid, slotid);
                acs::ClearData(playerid);
                SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Acessorio {33ff33}#%d {ffffff}deletado e dinheiro reembolsado!", slotid + 1);

                return 1;
            }

            format(str, 512, "{ff9933}[ ! ] {ffffff}Voce tem certeza que deseja excluir o acessorio #%d?\n\n\
            {9999ff}» {ffffff}Nome: {ffffff}%s\n\
            {9999ff}» {ffffff}Osso: {9999ff}%s\n\
            {9999ff}» {ffffff}Reembolso: {339933}%.2f {33ff33}(80%% do valor original)\n\n\
            {ff3333}[ i ] {ffffff}Se {ff3333}excluir {ffffff}esse acessorio {ff3333}perdera para sempre!", 
            slotid + 1, acs_name, gBoneName[boneid], price * 0.8);

            Dialog_ShowCallback(playerid, using inline response_confirm_delete, DIALOG_STYLE_MSGBOX, 
            "{ff3333} Atencao!", str, "{ff9933}Sim, excluir", "{ffffff}Nao");            
        }   
    }

    return 1;
}

public Response_ACC_MENU(playerid, dialogid, response, listitem, string:inputtext[])
{
	#pragma unused dialogid, inputtext

    if(!response) return 1;

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if((listitem + 1) <= MAX_PLAYER_ACESSORYS)
    {              
        if(!DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, listitem))
        {
            Response_ACC_MENU(playerid, dialogid, response, MAX_PLAYER_ACESSORYS, inputtext);
            return 1;
        }

        DB::GetDataInt(db_entity, "acessorys", "boneid", acs::Player[playerid][acs::boneid] , "owner = '%q' AND slotid = %d", name, listitem);
        acs::Player[playerid][acs::slotid] = listitem;

        new str[512];

        format(str, sizeof(str), "{9999ff}1. %s {ffffff}Acessorio\n\
        {9999ff}2. {ffffff}Editar Acessorio\n\
        {9999ff}3. {ffffff}Trocar Osso\n\
        {9999ff}4. {ff3333}Excluir {ffffff}Acessorio", IsPlayerAttachedObjectSlotUsed(playerid, listitem) ? "{ff9933}Desequipar" : "{33ff33}Equipar");

        Dialog_ShowCallback(playerid, using public Response_ACC_OPTIONS<iiiis>, DIALOG_STYLE_LIST, "{ffffff}[ ACS ] O que fazer?", str, 
        "{ffffff}Selecionar", "{ffffff}Voltar");
    }   

    else
    {
        new count = DB::GetCount(db_stock, "acessorys", "");
 
        if(!count)
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ACS ] {ffffff}A loja de Acessorios esta vazia! Volte mais tarde.");
            return 0;
        }

        if(Acessory::GetFreeSlot(playerid) == -1)
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ACS LOJA ] {ffffff}Parece que voce ja possui o numero {ff3333}maximo {ffffff}de acessorios!");
            return 0;
        }

        new msg[1024], acs_name[64], boneid, Float:price;
        
        format(msg, sizeof(msg), "{ffffff}nome\t{ffffff}osso\t{ffffff}preco\n");
        
        for(new i = 1; i <= MAX_STOCK_ACESSORYS; i++)
        {  
            if(DB::Exists(db_stock, "acessorys", "uid = %d", i))
            {

                DB::GetDataString(db_stock, "acessorys", "name", acs_name, 64, "uid = %d", i);
                DB::GetDataInt(db_stock, "acessorys", "boneid", boneid, "uid = %d", i);
                DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", i);

                format(msg, sizeof(msg), "%s{9999ff}%d. {ffffff}%s\t{9999ff}%s\t{33ff33}%.2f R$\n", 
                msg, i, acs_name, gBoneName[boneid], price);
            }

            else
                format(msg, sizeof(msg), "%s{cdcdcd}ESTOQUE VAZIO\t\t\n", msg);
         }
    
        Dialog_ShowCallback(playerid, using public Response_ACC_LOJA<iiiis>, 
        DIALOG_STYLE_TABLIST_HEADERS, "{ffffff}Loja de Acessorios", msg, "Comprar", "Voltar");

        SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Abrindo {33ff33}Loja {ffffff}de Acessorios.");
    }

    return 1;
}
