#include <YSI\YSI_Coding\y_hooks>

#define MAX_ACS_OFFSET_POS  (0.5)
#define MAX_ACS_OFFSET_ANG  (90.0)
#define MAX_ACS_OFFSET_SCL  (1.0)
#define MAX_ACS_POS         (0.5)
#define MIN_ACS_POS         (-0.5)
#define MAX_ACS_ANG         (359.9)
#define MIN_ACS_ANG         (0.1)
#define MAX_ACS_SCL         (2.0)
#define MIN_ACS_SCL         (0.5)

forward Response_ACC_MENU(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_BONE(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_OPTIONS(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_LOJA(playerid, dialogid, response, listitem, string:inputtext[]);

new gBoneName[][32] = 
{
    {"INVALID_BONE"}, {"Coluna"}, {"Cabeca"}, {"Braco esquerdo"}, {"Braco direito"}, {"Mao esquerda"},
    {"Mao direita"}, {"Coxa esquerda"}, {"Coxa direita"}, {"Pe esquerdo"}, {"Pe direito"},
    {"Panturrilha direita"}, {"Panturrilha esquerda"}, {"Antebraco esquerdo"}, {"Antebraco direito"},
    {"Ombro esquerdo"}, {"Ombro direito"}, {"Pescoco"}, {"Maxilar"}
};

new gAxisName[][16] = { {"INVALID_AXIS"}, {"Eixo X"}, {"Eixo Y"}, {"Eixo Z"} };

new Float:Acessory::gCamOffset[][6] =
{
    {-1.135681, -0.403320, -0.345319, -0.997536, -0.020563, -0.067073},
    {-0.621765, -0.896484, -0.333306, -0.791430, -0.594250, -0.143192},
    {-0.793701, 0.915649, -0.333306, -0.342547, 0.938410, -0.045233},
    {-0.182189, 0.689453, -0.651344, -0.021868, 0.999473, -0.023974},
    {0.585815, 0.147705, -0.651344, 0.997276, -0.069751, -0.023974},
    {-0.658447, -0.146484, -0.658907, -0.997040, 0.061724, -0.045835},
    {0.698608, -0.394287, -0.243360, 0.818994, -0.560657, -0.122108},
    {-0.922302, 0.370361, -0.261321, -0.809996, 0.571164, -0.132956},
    {1.242004, 0.485839, 0.416791, 0.997580, -0.015914, -0.067674},
    {-1.132934, -0.138549, 0.432420, -0.997250, 0.062141, -0.040371},
    {0.200012, -1.198120, 0.417545, -0.101406, -0.992897, -0.062217},
    {0.461608, -0.244140, 0.708893, 0.669668, -0.550676, -0.498296},
    {-0.700195, 0.053222, 0.711026, -0.958514, 0.242879, -0.149198},
    {0.631713, 0.252441, 0.760899, 0.986556, 0.033236, -0.160004}
};

hook OnPlayerSpawn(playerid)
{
    for(new i = 0; i < 10; i++)
        RemovePlayerAttachedObject(playerid, i);
    
    return 1;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!IsFlagSet(acs::Player[playerid][acs::flags], MASK_EDITING_ACS))
        return 1;
    
    //new slotid = acs::Player[playerid][acs::slotid]; 

    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_POS_AXIS_BTN])
    {
        inline response_pos_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext

            if(!sresponse)
                return 1;

            acs::Player[playerid][acs::pAxis] = slistitem + 1;

            new color;

            switch(slistitem)
            {   
                case 0:  color = 0xFF000090;
                case 1:  color = 0x00FF0090;
                case 2:  color = 0x0000FF90;
                default: color = -1;
            }

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_POS_AXIS, "%s", gAxisName[slistitem + 1]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_POS_AXIS_BTN, color);
        }

        Dialog_ShowCallback(playerid, using inline response_pos_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo de Posicao", 
        "1. {ff0000}Eixo X\n\
        2. {00ff00}Eixo Y\n\
        3. {0000ff}Eixo Z", "Selecionar", "Fechar");
    }

    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_ANG_AXIS_BTN])
    {
        inline response_ang_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext

            if(!sresponse)
                return 1;

            acs::Player[playerid][acs::aAxis] = slistitem + 1;

            new color;

            switch(slistitem)
            {   
                case 0:  color = 0xFF000090;
                case 1:  color = 0x00FF0090;
                case 2:  color = 0x0000FF90;
                default: color = -1;
            }

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_ANG_AXIS, "%s", gAxisName[slistitem + 1]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_ANG_AXIS_BTN, color);
        }

        Dialog_ShowCallback(playerid, using inline response_ang_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo de Rotacao", 
        "1. {ff0000}Eixo X\n\
        2. {00ff00}Eixo Y\n\
        3. {0000ff}Eixo Z", "Selecionar", "Fechar");
    }

    if(playertextid == Acessory::PlayerTD[playerid][PTD_ACS_SCL_AXIS_BTN])
    {
        inline response_scl_axis(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, stext

            if(!sresponse)
                return 1;

            acs::Player[playerid][acs::sAxis] = slistitem + 1;

            new color;

            switch(slistitem)
            {   
                case 0:  color = 0xFF000090;
                case 1:  color = 0x00FF0090;
                case 2:  color = 0x0000FF90;
                default: color = -1;
            }

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_SCL_AXIS, "%s", gAxisName[slistitem + 1]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_SCL_AXIS_BTN, color);
        }

        Dialog_ShowCallback(playerid, using inline response_scl_axis, DIALOG_STYLE_LIST, 
        "{ffffff}Selecionar Eixo Escala", 
        "1. {ff0000}Eixo X\n\
        2. {00ff00}Eixo Y\n\
        3. {0000ff}Eixo Z", "Selecionar", "Fechar");
    }

    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!IsFlagSet(acs::Player[playerid][acs::flags], MASK_EDITING_ACS))
        return 1;
    
    if(clickedid == Acessory::PublicTD[TD_ACS_EXIT_BTN])
    {
        inline confirm_exit(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            if(!sresponse)
                return 1;

            #pragma unused spid, sdialogid, slistitem, stext

            Acessory::HideTDForPlayer(playerid);
            Acessory::DestroyPlayerTD(playerid);
            
            acs::ClearData(playerid);

            TogglePlayerControllable(playerid, true);
            SetCameraBehindPlayer(playerid);

            ResetFlag(acs::Player[playerid][acs::flags], MASK_EDITING_ACS);

            SendClientMessage(playerid, COLOR_WARNING, "[ EDITOR ACS ] {ffffff}Editor de Acessorios {ff9933}fechado.");
        }

        Dialog_ShowCallback(playerid, using inline confirm_exit, DIALOG_STYLE_MSGBOX, 
        "Confirmar Saida", "{ffff33}>> {ffffff}Deseja {ffff33}sair {ffffff}do modo de edicao?\n\
        Os dados de posicao, rotacao e escala serao {ffff33}perdidos:", "{ffffff}Sim", "{ffffff}Nao, Voltar");
 
        return 1;
    }

    if(!IsFlagSet(acs::Player[playerid][acs::flags], MASK_EDITING_ACS))
        return 1;
    
    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_POS_BTN])
    {
        inline response_pos_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse)
                return 1;

            new Float:value;

            if(isnull(stext) || sscanf(stext, "f", value))
            {
                Dialog_ShowCallback(playerid, using inline response_pos_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Posicao", "{ffffff}Digite um valor {ff3333}decimal {ffffff}valido!:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }

            if(value < 0.0 || value > 0.25)
            {
                Dialog_ShowCallback(playerid, using inline response_pos_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Posicao", "{ffffff}Digite um valor decimal entre {ff3333}0.0 {ffffff}e {ff3333}0.25:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }    

            acs::Player[playerid][acs::pOffset] = value;

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_POS, "OFFSET:~n~~y~%.3f m", value);
        }

        Dialog_ShowCallback(playerid, using inline response_pos_offset, DIALOG_STYLE_INPUT, 
        "Selecionar Offset Posicao", "{ffffff}Digite um valor decimal para o {ff9933}Offset {ffffff}de {ff9933}posicao:\n", "{ffffff}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_ANG_BTN])
    {
        inline response_ang_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse)
                return 1;

            new Float:value;

            if(isnull(stext) || sscanf(stext, "f", value))
            {
                Dialog_ShowCallback(playerid, using inline response_ang_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Rotacao", "{ffffff}Digite um valor {ff3333}decimal {ffffff}valido!:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }

            if(value < 0.0 || value > 90.0)
            {
                Dialog_ShowCallback(playerid, using inline response_ang_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Rotacao", "{ffffff}Digite um valor decimal entre {ff3333}-90 {ffffff}e {ff3333}90.0!:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }    

            acs::Player[playerid][acs::aOffset] = value;

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_ANG, "OFFSET:~n~~y~%.1f graus", value);
        }

        Dialog_ShowCallback(playerid, using inline response_ang_offset, DIALOG_STYLE_INPUT, 
        "Selecionar Offset Rotacao", "{ffffff}Digite um valor decimal para o {ff9933}Offset {ffffff}de {ff9933}rotacao:\n", "{ffffff}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    if(clickedid == Acessory::PublicTD[TD_ACS_OFFSET_SCL_BTN])
    {
        inline response_scl_offset(spid, sdialogid, sresponse, slistitem, string:stext[])
        {
            #pragma unused spid, sdialogid, slistitem

            if(!sresponse)
                return 1;

            new Float:value;

            if(isnull(stext) || sscanf(stext, "f", value))
            {
                Dialog_ShowCallback(playerid, using inline response_scl_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Escala", "{ffffff}Digite um valor {ff3333}decimal {ffffff}valido!:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }

            if(value < 0.0 || value > 1.0)
            {
                Dialog_ShowCallback(playerid, using inline response_scl_offset, DIALOG_STYLE_INPUT, 
                "Selecionar Offset Escala", "{ffffff}Digite um valor decimal entre {ff3333}-1.0 {ffffff}e {ff3333}1.0!:\n", "{ffffff}Selecionar", "{ffffff}Fechar");

                return 1;
            }    

            acs::Player[playerid][acs::sOffset] = value;

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_SCL, "OFFSET:~n~~y~%.3f m", value);
        }

        Dialog_ShowCallback(playerid, using inline response_scl_offset, DIALOG_STYLE_INPUT, 
        "Selecionar Offset Escala", "{ffffff}Digite um valor decimal para o {ff9933}Offset {ffffff}de {ff9933}escala:\n", "{ffffff}Selecionar", "{ffffff}Fechar");
        return 1;
    }

    new slotid = acs::Player[playerid][acs::slotid]; 
    
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

            if(!sresponse)
                return 1;

            Acessory::SaveData(playerid, slotid);
            Acessory::HideTDForPlayer(playerid);
            Acessory::DestroyPlayerTD(playerid);
            acs::ClearData(playerid);

            TogglePlayerControllable(playerid, true);
            SetCameraBehindPlayer(playerid);

            ResetFlag(acs::Player[playerid][acs::flags], MASK_EDITING_ACS);

            SendClientMessage(playerid, COLOR_WARNING, "[ EDITOR ACS ] {ffffff}Editor de Acessorios {ff9933}fechado.");
        }

        Dialog_ShowCallback(playerid, using inline confirm_save, DIALOG_STYLE_MSGBOX, 
        "Confirmar Salvamento", "{ffff33}>> {ffffff}Deseja {ffff33}salvar seu acessorio?", "{ffffff}Sim", "{ffffff}Nao, Voltar");
 
        return 1;
    }

    //ALTERAR VISÃO
    if(clickedid == Acessory::PublicTD[TD_ACS_CHANGE_VIEW_BTN])
    {
        Acessory::UpdateEditorCam(playerid);
    }

    return 1;
}

public Response_ACC_BONE(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) 
        return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
        
    new slotid = acs::Player[playerid][acs::slotid];

    new new_boneid = listitem + 1;

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "acessorys", "owner, slotid", "owner = '%s' AND slotid = %d", name, slotid))
    {
        printf("[ ERRO ] Falha ao tentar trocar osso do acessorio #%d do jogador, %s");
        return 0;
    }

    new modelid, old_boneid, Float:pX, Float:pY, Float:pZ, Float:rX, Float:rY, Float:rZ, Float:sX, Float:sY, Float:sZ, c1, c2;

    GetPlayerAttachedObject(playerid, slotid, modelid, old_boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, c1, c2);

    if(old_boneid == new_boneid)
    {
        SendClientMessage(playerid, COLOR_ERRO, "[ ACS ] {ffffff}Esse osso ja esta {ff3333}selecionado!");
        CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
        return 0;
    }

    RemovePlayerAttachedObject(playerid, slotid);

    SetPlayerAttachedObject(playerid, slotid, modelid, new_boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, c1, c2);

    DB::SetDataInt(db_entity, "acessorys", "boneid", new_boneid, "owner = '%s' AND slotid = %d", name, slotid);

    SendClientMessage(playerid, COLOR_THEME_BPS, "[ ACS ] {ffffff}Osso do acessorio {33ff33}alterado \
    {ffffff}Antigo: {33ff33}%s {ffffff}| Novo: {33ff33}%s", gBoneName[old_boneid], gBoneName[new_boneid]);
 
    return 1;
}

public Response_ACC_LOJA(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) 
        return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");

    new slotid = Acessory::GetFreeSlot(playerid);

    if(slotid == -1) return 0;

    new stockid = listitem + 1;

    new Float:price;

    DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", stockid);

    if(!Player::RemoveMoney(playerid, price))
    {
        SendClientMessage(playerid, COLOR_ERRO, "[ ACS LOJA ] {ffffff}Você nao tem {ff3333}dinheiro {ffffff}suficiente!");
        return 0;
    }

    Acessory::GivePlayerStock(playerid, slotid, stockid);

    Response_ACC_MENU(playerid, dialogid, response, slotid, inputtext);
 
    return 1;
}

public Response_ACC_OPTIONS(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) 
        return CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");

    new slotid = acs::Player[playerid][acs::slotid];

    switch(listitem)
    {
        case 0:
        {
            Acessory::CreatePlayerTD(playerid);
            Acessory::ShowTDForPlayer(playerid);

            if(!IsPlayerAttachedObjectSlotUsed(playerid, slotid))
                Acessory::PutOnPlayer(playerid, slotid);

            new modelid, boneid;
                        
            #pragma unused modelid

            SetFlag(acs::Player[playerid][acs::flags], MASK_EDITING_ACS);

            acs::Player[playerid][acs::pOffset] = 0.05;
            acs::Player[playerid][acs::aOffset] = 15.0;
            acs::Player[playerid][acs::sOffset] = 0.1;
            acs::Player[playerid][acs::pAxis]   = AXIS_TYPE_X;
            acs::Player[playerid][acs::aAxis]   = AXIS_TYPE_X;
            acs::Player[playerid][acs::sAxis]   = AXIS_TYPE_X;
            acs::Player[playerid][acs::boneid]  = boneid;
            acs::Player[playerid][acs::camid]   = -1;
            
            Acessory::UpdateEditorCam(playerid);
            TogglePlayerControllable(playerid, false);

            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name);

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_POS, "OFFSET:~n~~y~%.3f m", acs::Player[playerid][acs::pOffset]);
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_ANG, "OFFSET:~n~~y~%.1f graus", acs::Player[playerid][acs::aOffset]);
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_SCL, "OFFSET:~n~~y~%.3f m", acs::Player[playerid][acs::sOffset]);

            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_POS_AXIS, "%s", gAxisName[acs::Player[playerid][acs::pAxis]]);
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_ANG_AXIS, "%s", gAxisName[acs::Player[playerid][acs::aAxis]]);
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_SCL_AXIS, "%s", gAxisName[acs::Player[playerid][acs::sAxis]]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_POS_AXIS_BTN, -16777072);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_ANG_AXIS_BTN, -16777072);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_SCL_AXIS_BTN, -16777072);

            GetPlayerAttachedObject(playerid, slotid, modelid, boneid, 
            acs::Player[playerid][acs::pX], acs::Player[playerid][acs::pY], acs::Player[playerid][acs::pZ],
            acs::Player[playerid][acs::rX], acs::Player[playerid][acs::rY], acs::Player[playerid][acs::rZ],
            acs::Player[playerid][acs::sX], acs::Player[playerid][acs::sY], acs::Player[playerid][acs::sZ]);

            SendClientMessage(playerid, COLOR_WARNING, "[ EDITOR ACS ] {ffffff}Editor de Acessorios {ff9933}aberto.");
        }

        case 1:
        {
            new msg[1024], line[128];
       
            for(new i = 1; i < sizeof(gBoneName); i++)
            {  
                format(line, sizeof(line), "{9999ff}%d. {ffffff}%s\n", i, gBoneName[i]);
                strcat(msg, line);
            }

            Dialog_ShowCallback(playerid, using public Response_ACC_BONE<iiiis>, DIALOG_STYLE_LIST, 
            "Escolha o local:", msg, "{ffffff}Escolher", "{ffffff}Voltar");
        }

        case 2:
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, slotid))
            {
                RemovePlayerAttachedObject(playerid, slotid);
                //acs::ClearData(playerid);
                SendClientMessage(playerid, COLOR_THEME_BPS, "[ ACS ] {ffffff}Acessorio {33ff33}#%d {ffffff}desequipado!", slotid + 1);
            }
            else
            {
                Acessory::PutOnPlayer(playerid, slotid);
                SendClientMessage(playerid, COLOR_THEME_BPS, "[ ACS ] {ffffff}Acessorio {33ff33}#%d {ffffff}equipado!", slotid + 1);
            }
            
            CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
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

    if((listitem + 1) <= MAX_ACESSORYS)
    {              
        if(!DB::Exists(db_entity, "acessorys", "owner, slotid", "owner = '%s' AND slotid = %d", name, listitem))
        {
            HidePlayerDialog(playerid);
            CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
            return 0;
        }

        acs::Player[playerid][acs::slotid] = listitem;

        new str[512];

        format(str, sizeof(str), "{9999ff}1. {ffffff}Editar Acessorio\n\
        {9999ff}2. {ffffff}Trocar Osso\n\
        {9999ff}3. %s {ffffff}Acessorio", IsPlayerAttachedObjectSlotUsed(playerid, listitem) ? "{ff3333}Desequipar" : "{33ff33}Equipar");

        Dialog_ShowCallback(playerid, using public Response_ACC_OPTIONS<iiiis>, DIALOG_STYLE_LIST, "{ffffff}[ ACS ] O que fazer?", str, 
        "{ffffff}Selecionar", "{ffffff}Voltar");
    }   

    else
    {
        new count = DB::GetCount(db_stock, "acessorys", "*", "");
 
        if(!count)
        {
            SendClientMessage(playerid, COLOR_ERRO, "[ ACS ] {ffffff}A loja de Acessorios esta vazia! Volte mais tarde.");
            return 0;
        }

        if(Acessory::GetFreeSlot(playerid) == -1)
        {
            SendClientMessage(playerid, COLOR_ERRO, "[ ACS LOJA ] {ffffff}Parece que voce ja possui o numero {ff3333}maximo {ffffff}de acessorios!");
            //CallLocalFunction("OnPlayerCommandText", "is", playerid, "/acessorios");
            return 0;
        }

        new msg[1024], line[128], acs_name[64], boneid, Float:price;
        
        format(line, sizeof(line), "{ffffff}nome\t{ffffff}osso\t{ffffff}preco\n");
        strcat(msg, line);

        for(new i = 1; i <= MAX_STOCK_ACESSORYS; i++)
        {  
            if(DB::Exists(db_stock, "acessorys", "uid", "uid = %d", i))
            {

                DB::GetDataString(db_stock, "acessorys", "name", acs_name, 64, "uid = %d", i);
                DB::GetDataInt(db_stock, "acessorys", "boneid", boneid, "uid = %d", i);
                DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", i);

                format(line, sizeof(line), "{9999ff}%d. {ffffff}%s\t{9999ff}%s\t{33ff33}%.2f R$\n", i, acs_name, gBoneName[boneid], price);
            }

            else
                format(line, sizeof(line), "{cdcdcd}ESTOQUE VAZIO\t\t\n");
 
            strcat(msg, line);
        }
    
        Dialog_ShowCallback(playerid, using public Response_ACC_LOJA<iiiis>, 
        DIALOG_STYLE_TABLIST_HEADERS, "{ffffff}Loja de Acessorios", msg, "Comprar", "Voltar");

        SendClientMessage(playerid, COLOR_THEME_BPS, "[ ACS ] {ffffff}Abrindo {33ff33}Loja {ffffff}de Acessorios.");
    }

    return 1;
}

YCMD:acessorios(playerid, params[], help)
{
    #pragma unused params, help

    new line[128], msg[1024], name[MAX_PLAYER_NAME], modelid;
    
    GetPlayerName(playerid, name);

    format(line, sizeof(line), "{ffffff}Slot\t{ffffff}ID \t{ffffff}Status\n");
    strcat(msg, line);

    for(new i = 0; i < MAX_ACESSORYS; i++)
    {
        if(DB::Exists(db_entity, "acessorys", "owner, slotid", "owner = '%s' AND slotid = %d", name, i))
        {
            DB::GetDataInt(db_entity, "acessorys", "modelid", modelid, "owner = '%s' AND slotid = %d", name, i);

            format(line, sizeof(line), "{ffffff}Slot: {9999ff}%d\t{ffffff}%d\t%s\n", 
            i + 1,
            modelid,
            IsPlayerAttachedObjectSlotUsed(playerid, i) ? "{33ff33}[ EQUIPADO ]" : "{ff9933}[ DESEQUIPADO ]");
        }

        else
        {
            format(line, sizeof(line), "{ffffff}Slot: {ff3333}%d\t\t{ff3333}[ VAZIO ]\n", i + 1);
        }

        strcat(msg, line);
    }

    format(line, sizeof(line), "{cdcdcd}CLIQUE AQUI para comprar\t\t\n");
    strcat(msg, line);

    Dialog_ShowCallback(playerid, using public Response_ACC_MENU<iiiis>, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Gerenciar Acessorios", msg, "Selecionar", "Fechar");
    return 1;
}

stock Acessory::PutOnPlayer(playerid, slotid)
{
    new name[MAX_PLAYER_NAME], modelid, boneid, 
        Float:pX, Float:pY, Float:pZ, 
        Float:rX, Float:rY, Float:rZ,
        Float:sX, Float:sY, Float:sZ;
    
    GetPlayerName(playerid, name);

    DB::GetDataInt(db_entity, "acessorys", "modelid", modelid, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataInt(db_entity, "acessorys", "boneid", boneid, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pX", pX, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pY", pY, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pZ", pZ, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rX", rX, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rY", rY, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rZ", rZ, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sX", sX, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sY", sY, "owner = '%s' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sZ", sZ, "owner = '%s' AND slotid = %d", name, slotid);

    SetPlayerAttachedObject(playerid, slotid, modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ);
}

stock Acessory::UpdateForPlayer(playerid, slotid)
{
    if(!IsPlayerAttachedObjectSlotUsed(playerid, slotid))
        return 1;

    new modelid, boneid, 
        Float:pX, Float:pY, Float:pZ, 
        Float:rX, Float:rY, Float:rZ, 
        Float:sX, Float:sY, Float:sZ, c1, c2;

    GetPlayerAttachedObject(playerid, slotid, modelid, boneid, 
    pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, c1, c2);

    RemovePlayerAttachedObject(playerid, slotid);

    SetPlayerAttachedObject(playerid, slotid, modelid, boneid, 
    acs::Player[playerid][acs::pX], acs::Player[playerid][acs::pY], acs::Player[playerid][acs::pZ],
    acs::Player[playerid][acs::rX], acs::Player[playerid][acs::rY], acs::Player[playerid][acs::rZ],
    acs::Player[playerid][acs::sX], acs::Player[playerid][acs::sY], acs::Player[playerid][acs::sZ], c1, c2);

    return 1;
}

stock Acessory::UpdateEditorCam(playerid)
{
    if(!IsFlagSet(acs::Player[playerid][acs::flags], MASK_EDITING_ACS))
        return 1;
    
    acs::Player[playerid][acs::camid] += 1;

    if(acs::Player[playerid][acs::camid] >= 14)
        acs::Player[playerid][acs::camid] = 0;  
    
    new Float:pX, Float:pY, Float:pZ, idx;

    idx = acs::Player[playerid][acs::camid];

    GetPlayerPos(playerid, pX, pY, pZ);
    
    SetPlayerCameraPos(playerid, 
    pX - Acessory::gCamOffset[idx][0], 
    pY - Acessory::gCamOffset[idx][1], 
    pZ - Acessory::gCamOffset[idx][2]);
    
    SetPlayerCameraLookAt(playerid, pX, pY, pZ);
    SetPlayerCameraLookAt(playerid, 
    pX - Acessory::gCamOffset[idx][0] + Acessory::gCamOffset[idx][3], 
    pY - Acessory::gCamOffset[idx][1] + Acessory::gCamOffset[idx][4],
    pZ - Acessory::gCamOffset[idx][2] + Acessory::gCamOffset[idx][5]);

    return 1;
}

stock Acessory::GetNameByModelid(modelid, name[], len = sizeof(name))
{
    switch(modelid)
    {
        case 11745:         format(name, len, "Bolsa preta grande");
        case 18632:         format(name, len, "Vara de pesca");
        case 18634:         format(name, len, "Pe de cabra");
        case 18635:         format(name, len, "Martelo");
        case 18636:         format(name, len, "Bone de policia 1");
        case 18638:         format(name, len, "Capacete EPI");
        case 18645:         format(name, len, "Capacete de moto 1");
        case 18639:         format(name, len, "Chapeu de couro preto");
        case 18891..18910:  format(name, len, "Bandana #%d", 18911 - modelid);
        case 18911..18920:  format(name, len, "Mascara #%d", 18921 - modelid);
        case 18921..18925:  format(name, len, "Boina #%d", 18926 - modelid);
        case 18926..18935:  format(name, len, "Bone #%d", 18936 - modelid); 
        case 18936..18938:  format(name, len, "Capacete #%d", 18939 - modelid); 
        case 18939..18943:  format(name, len, "Bone pra tras #%d", 18944 - modelid);
        case 18944..18951:  format(name, len, "Chapeu mafioso #%d", 18952 - modelid);
        case 18952:         format(name, len, "Capacete Box");
        case 18953..18954:  format(name, len, "Gorro de la #%d", 18955 - modelid);
        case 18955..18959:  format(name, len, "Bone Pala #%d", 18960 - modelid);
        case 18960:         format(name, len, "Bone Pala Hip-Hop");
        case 18961:         format(name, len, "Bone de caminhoneiro");
        case 18962:         format(name, len, "Chapeu preto");
        case 18963:         format(name, len, "Cabeca CJ Elvis");
        case 18964..18966:  format(name, len, "Touca #%d", 18967 - modelid);
        case 18967..18969:  format(name, len, "Chapeu Pescador #%d", 18970 - modelid);
        case 18970..18973:  format(name, len, "Chapeu CowBoy #%d", 18974 - modelid);
        case 18974:         format(name, len, "Mascara do Zorro");
        case 18976:         format(name, len, "Capacete de ciclismo");
        case 18977..18979:  format(name, len, "Capacete de moto #%d", 18980 - modelid);
        case 19006..19035:  format(name, len, "Óculos #%d", 19036 - modelid);
        case 19039..19053:  format(name, len, "Relogio de pulso #%d", 19054 - modelid);
        case 19064..19066:  format(name, len, "Chapeu de natal #%d", 19067 - modelid);
        case 19067..19069:  format(name, len, "Gorro gangster #%d", 19070 - modelid);
        case 19078..19079:  format(name, len, "Papagaio #%d", 19080 - modelid);
        case 19085:         format(name, len, "Tapa-olho");
        case 19095..19098:  format(name, len, "Chapeu de matuto #%d", 19099 - modelid);
        case 19099..19100:  format(name, len, "Chapeu de policia #%d", 19101 - modelid);
        case 19101..19105:  format(name, len, "Chapeu de guerra com alca #%d", 19106 - modelid);
        case 19106..19110:  format(name, len, "Chapeu de guerra sem alca #%d", 19111 - modelid);
        case 19111..19120:  format(name, len, "Chapeu de guerra colorido #%d", 19121 - modelid);
        case 19136:         format(name, len, "Chapeu de pistoleiro");
        case 19137:         format(name, len, "Chapeu mascote de frango");
        case 19138..19140:  format(name, len, "Óculos Hybam #%d", 19141 - modelid);
        case 19141:         format(name, len, "Capacete Swat");
        case 19142:         format(name, len, "Colete Swat");
        case 19160:         format(name, len, "Bone DUDE");
        case 19161..19162:  format(name, len, "Bone de policia #%d", 19164 - modelid);
        case 19274:         format(name, len, "Peruca de Palhaco");
        case 19314:         format(name, len, "Chifre de corno");
        case 19317..19319:  format(name, len, "Guitarra #%d", 19320 - modelid);
        case 19330..19331:  format(name, len, "Capacete de bombeiro #%d", 19332 - modelid);
        case 19352:         format(name, len, "Cartola preta");
        case 19421..19424:  format(name, len, "Fones de ouvido #%d", 19425 - modelid);
        case 19469:         format(name, len, "Lenco de pescoco");
        case 19472:         format(name, len, "Mascara de gas");
        case 19487:         format(name, len, "Cartola branca");
        case 19488:         format(name, len, "Chapeu branco");
        case 19528:         format(name, len, "Chapeu de bruxa");
        case 19553:         format(name, len, "Chapeu de palha");
        case 19554:         format(name, len, "Gorro malandro");
        case 19555..19556:  format(name, len, "Luva de Box %s", modelid == 19555 ? "Esquerda" : "Direita");
        case 19558:         format(name, len, "Chapeu de pizza");
        case 19559:         format(name, len, "Mochila de camping");
        case 19878:         format(name, len, "Skate");
        case 19904:         format(name, len, "Colete EPI");
        case 19914:         format(name, len, "Taco de basebol");
        default:            format(name, len, "Modelo: #%d", modelid);
    }
}

stock Acessory::GetFreeSlot(playerid)
{    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    for(new i = 0; i < MAX_ACESSORYS; i++)
        if(!DB::Exists(db_entity, "acessorys", "owner, slotid", "owner = '%s' AND slotid = %d", name, i))
            return i;
    
    return -1;
}

stock Acessory::SaveData(playerid, slotid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "acessorys", "owner, slotid", "owner = '%s' AND slotid = %d", name, slotid))
    {
        return 0;
    }

    DB::SetDataFloat(db_entity, "acessorys", "pX", acs::Player[playerid][acs::pX], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "pY", acs::Player[playerid][acs::pY], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "pZ", acs::Player[playerid][acs::pZ], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rX", acs::Player[playerid][acs::rX], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rY", acs::Player[playerid][acs::rY], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rZ", acs::Player[playerid][acs::rZ], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sX", acs::Player[playerid][acs::sX], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sY", acs::Player[playerid][acs::sY], "owner = '%s' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sZ", acs::Player[playerid][acs::sZ], "owner = '%s' AND slotid = %d", name, slotid);

    SendClientMessage(playerid, COLOR_SUCESS, "[ ACS ] {ffffff}Acessorio {33ff33}#%d salvo {ffffff}com sucesso.", slotid + 1);
        
    return 1;
}

stock Acessory::GivePlayerStock(playerid, slotid, stockid)
{
    new name[MAX_PLAYER_NAME], modelid, boneid, Float:price,
        Float:pX, Float:pY, Float:pZ, 
        Float:rX, Float:rY, Float:rZ,
        Float:sX, Float:sY, Float:sZ;

    GetPlayerName(playerid, name);

    DB::GetDataInt(db_stock, "acessorys", "modelid", modelid, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pX", pX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pX", pX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pY", pY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pZ", pZ, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rX", rX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rY", rY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rZ", rZ, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sX", sX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sY", sY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sZ", sZ, "uid = %d", stockid);

    DB::Insert(db_entity, "acessorys", "owner, slotid, owner_type, price, \
    modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, color1, color2", "'%s', %i, %i, %f, \
    %i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %f, %i, %i", name, slotid, OWNER_TYPE_PLAYER, price,
    modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, -1, -1);
    
    SetPlayerAttachedObject(playerid, slotid, modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ);

    SendClientMessage(playerid, COLOR_THEME_BPS, "[ ACS LOJA ] {ffffff}Acessorio {33ff33}%s {ffffff}comprado com sucesso!", name);
    
    DB::Delete(db_stock, "acessorys", "uid = %d", stockid);

    acs::Player[playerid][acs::slotid] = slotid;
}