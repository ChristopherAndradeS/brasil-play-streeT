#include <YSI\YSI_Coding\y_hooks>

forward Response_ADM_PANEL(playerid, dialogid, response, listitem, string:inputtext[]);

public Response_ADM_PANEL(playerid, dialogid, response, listitem, string:inputtext[])
{
    #pragma unused playerid, dialogid, inputtext

    if(!response) return 1;

    switch(listitem)
    {
        case 0:
        {
            ShowPlayerDialog(playerid, 1212, DIALOG_STYLE_LIST, 
            "{00FF00}COMANDOS DA ADMINISTRACAO",
            "1. Ver Telemetria do jogador espectado\n\
            2. Enviar aviso\n\
            3. Congelar / Descongelar jogador\n\
            4. Kickar\n\
            5. Setar Skin\n\
            6. Setar Vida\n\
            7. Setar Colete\n\
            8. Prender / Soltar jogador\n\
            9. Setar Nível\n\
            10. Setar Dinheiro\n\
            11. Promover/Rebaixar/Setar Admin\n\
            12. Kickar jogador\n\
            13. Banir / Desbanir jogador\n\
            14. Banir IP/ Desbanir IP jogador\n", "Selecionar", "Voltar");                
        }

        case 1:
        {

        }

        case 2:
        {

        }

        case 3:
        {

        }

        case 4:
        {
            ShowPlayerDialog(playerid, 1212, DIALOG_STYLE_LIST, 
            "{00FF00}COMANDOS DA ADMINISTRACAO",
            "1. Enviar aviso global\n\
            2. Criar cronometro global\n\
            3. Respawnar todos os carros\n\
            4. Limpar chat global\n\
            5. Promover/Rebaixar/Setar alguem\n\
            6. Kickar alguem\n\
            7. Prender / Soltar alguem\n\
            8. Banir / Desbanir alguem\n\
            9. Banir IP/ Desbanir IP alguem\n\
            10. Voltar", "Selecionar", "Voltar"); 
        }
    }
    return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!Admin[playerid][adm::lvl]) return 1;

    if(clickedid == Adm::PublicTD[TD_ADM_BTN_LEFT])
    {
        new idx = list_find(gAdminSpectates, Admin[playerid][adm::spectateid]);

        new targetid = Adm::GetNextSpectateID(playerid, idx, -1);

        if(targetid != INVALID_PLAYER_ID)
        {
            Admin[playerid][adm::spectateid] = targetid;
            Adm::SpectatePlayer(playerid, targetid);
            Adm::UpdateTextDraw(playerid, targetid);
        }

        else
            SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Nenhum jogador valido para espectar!");

        return 1;
    }
    
    if(clickedid == Adm::PublicTD[TD_ADM_BTN_RIGHT])
    {
        new idx = list_find(gAdminSpectates, Admin[playerid][adm::spectateid]);

        new targetid = Adm::GetNextSpectateID(playerid, idx, 1);

        if(targetid != INVALID_PLAYER_ID)
        {
            Admin[playerid][adm::spectateid] = targetid;
            Adm::SpectatePlayer(playerid, targetid);
            Adm::UpdateTextDraw(playerid, targetid);
        }
        
        else
            SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Nenhum jogador valido para espectar!");

        return 1;
    }

    if(clickedid == Adm::PublicTD[TD_ADM_BTN_HIDE])
    {
        if(IsPlayerTextDrawVisible(playerid, Adm::PlayerTD[playerid][0]))
        {
            for(new i = 0; i < 14; i++)
            {
                if(_:TD_ADM_BTN_HIDE == i) continue;
                TextDrawHideForPlayer(playerid, Adm::PublicTD[i]);
            }
            for(new i = 0; i < 9; i++)
                PlayerTextDrawHide(playerid, Adm::PlayerTD[playerid][i]); 
        }

        else
        {
            for(new i = 0; i < 14; i++)
                TextDrawShowForPlayer(playerid, Adm::PublicTD[i]);
            for(new i = 0; i < 9; i++)
                PlayerTextDrawShow(playerid, Adm::PlayerTD[playerid][i]);   

            Adm::UpdateTextDraw(playerid, Admin[playerid][adm::spectateid]);          
        }

        return 1;
    }

    if(clickedid == Adm::PublicTD[TD_ADM_BTN_PANEL])
    {
        new msg[512];
        format(msg, 512, 
        "{ffff33}1. {ffffff}Executar comandos em %s\n\
        {ffff33}2. {ffffff}Espectar ID especifico \n\
        {ffff33}3. {ffffff}Disfarcar de jogador\n\
        {ffff33}4. {ffffff}Se revelar como admin\n\
        {ffff33}5. {ffffff}Executar comandos globais\n\
        {ffff33}6. {ffffff}Abrir modo de edicao\n", GetPlayerNameEx(Admin[playerid][adm::spectateid]));

        Dialog_ShowCallback(playerid, using public Response_ADM_PANEL<iiiis>, DIALOG_STYLE_LIST, msg, "Selecionar", "Fechar");

        return 1;
    }

    return 1;
}