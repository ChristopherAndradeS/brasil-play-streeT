YCMD:convidar(playerid, params[], help)
{   
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Convida um membro da sua organização");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_COLEADER)) return 1;

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Use: /convidar {ff3333}[ ID ].");
    
    if(!Org::ValidTargetID(playerid, targetid, .in_org = false, .same_org = false)) return 1;
    
    if(org::Player[targetid][pyr::invite_orgid] != INVALID_ORG_ID && org::Player[targetid][pyr::inviterid] != INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}O jogador já possui um {ff3333}convite aberto.");
    
    new orgid = org::Player[playerid][pyr::orgid];

    org::Player[targetid][pyr::invite_orgid] = orgid;
    org::Player[targetid][pyr::inviterid] = playerid;

    SendClientMessage(targetid, -1, "{ffff99}[ ORG ] {ffffff}O (Co)Líder {ffff99}%s \
    {ffffff}da {%06x}%s {ffffff}te convidou para {ffff99}organização!",
    GetPlayerNameStr(playerid), Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

    SendClientMessage(targetid, -1, "{ffff99}[ ORG ] {ffffff}Use {ffff99}/aceitar {ffffff}para confirmar o convite.");
   
    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {ffffff}Convite enviado para {ffff99}%s {ffffff}com sucesso.",
    GetPlayerNameStr(targetid));
   
    return 1;
}

YCMD:aceitar(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) return 1;

    if(org::Player[playerid][pyr::orgid] != INVALID_ORG_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você já faz parte de uma {ff3333}organização");
    
    new orgid = org::Player[playerid][pyr::invite_orgid];
    new inviterid = org::Player[playerid][pyr::inviterid];

    if(orgid == INVALID_ORG_ID || inviterid == INVALID_PLAYER_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você não possui convite aberto");
    
    if(!GetFlag(Org[orgid][org::flags], FLAG_ORG_CREATED))    
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}A organização que te convidou {ff3333}não existe mais!");

    Org::SetMember(inviterid, playerid, orgid, ORG_ROLE_NOVICE);

    if(IsValidPlayer(inviterid))
        SendClientMessage(inviterid, -1, "{55ff55}[ ORG ] %s {ffffff}aceitou seu convite com {55ff55}sucesso.",
        GetPlayerNameStr(playerid));
    
    org::Player[playerid][pyr::invite_orgid] = INVALID_ORG_ID;
    org::Player[playerid][pyr::inviterid]    = INVALID_PLAYER_ID;
    return 1;
}

YCMD:demitir(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Expulsa um membro da sua organização");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_LEADER)) return 1;

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Use: /demitir {ff3333}[ ID ].");
    
    if(!Org::ValidTargetID(playerid, targetid, .in_org = true, .same_org = true)) return 1;

    if(!Org::UnSetMember(targetid))
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {fffff}Esse jogador {ff3333}não {ffffff}faz parte de uma organização!");
   
    SendClientMessage(targetid, -1, "{ff3333}[ ORG ] {ffffff}Você foi {ff3333}expulso {ffffff}da sua organização!");

    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {ffffff}Você expulsou {ffff99}%s {ffffff}com sucesso.", GetPlayerNameStr(targetid));

    return 1;
}

YCMD:ow(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Entra/Sai do modo de trabalho da sua organização");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE)) return 1;

    if(!GetFlag(org::Player[playerid][pyr::flags], FLAG_PLAYER_ON_WORK)) 
        Org::SetMemberOnWork(playerid);
    else  
        Org::UnSetMemberOnWork(playerid);
    
    return 1;
}

YCMD:r(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Envia uma mensagem no rádio da sua organização");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE)) return 1;
    
    new msg[128];
    if(sscanf(params, "s[128]", msg)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Use: /r {ff3333}[ MSG ].");
    
    new orgid = org::Player[playerid][pyr::orgid];

    foreach(new i : Player)
    {
        if(IsValidPlayer(i) && org::Player[i][pyr::orgid] == orgid)
        {
            SendClientMessage(i, Org[orgid][org::color], "[ Radio ORG ] {ffffff}%s diz: %s",
            GetPlayerNameStr(playerid), msg);
        }
    }

    return 1;
}

YCMD:ajudaorg(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Ajuda Organização - Lista de comandos disponiveis");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE)) return 1;
    
    new str[512];
    
    if(org::Player[playerid][pyr::role] >= ORG_ROLE_NOVICE)
        strcat(str, "r\now\norgs\npedircontas\nmenuorg\n");
    if(org::Player[playerid][pyr::role] >= ORG_ROLE_COLEADER)
        strcat(str, "convidar\n");
    if(org::Player[playerid][pyr::role] >= ORG_ROLE_LEADER)
        strcat(str, "demitir");

    inline no_use_dialog(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, listitem

        if(!response) return 1;
        Command_ReProcess(playerid, inputtext, true);
        return 1;
    }

    format(str, 512, "{ffffff}%s", str);

    Dialog_ShowCallback(playerid, using inline no_use_dialog, DIALOG_STYLE_LIST, 
    "Comandos ORG", str, "Selecionar", "Fechar");

    return 1;
}

YCMD:pedircontas(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Use para sair da sua organização atual!");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE)) return 1;
    
    inline dialog_confirm(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, listitem, inputtext

        if(!response) return 1;
        
        Org::UnSetMember(playerid);

        SendClientMessage(playerid, -1, "{55ff55}[ ORG ] {ffffff}Você {55ff55}saiu {ffffff}da organização com {55ff55}sucesso");

        return 1;
    }

    new orgid = org::Player[playerid][pyr::orgid];
    new ORG_ROLES:role  = org::Player[playerid][pyr::role];

    new msg[512];

    format(msg, 512, 
    "{ff9933}>> {ffffff}Voce tem {ff9933}certeza {ffffff}que deseja sair da sua organizacao: {%06x}%s?\n\n\
    {ffffff}Essa acao {ff9933}nao pode ser desfeita!\n\n", Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

    switch(role)
    {
        case ORG_ROLE_LEADER:
        {
            strcat(msg, 
            "{ff3333}[ ! ] {ffffff}Voce e o {ff3333}LIDER {ffffff}dessa organizacao!\n\
            Tenha certeza disso. Pois sua organizacao ficara {ff3333}vulneravel {ff3333}sem um lider");
        }

        case ORG_ROLE_COLEADER:
        {
           strcat(msg, 
            "{ff3333}[ ! ] {ffffff}Voce e o {ff3333}COLIDER {ffffff}dessa organização!\n\
            Tenha certeza da sua acao. Pois sua organizacao ficara {ff3333}vulneravel {ff3333}sem um colider");
        }
    } 

    Dialog_ShowCallback(playerid, using inline dialog_confirm, DIALOG_STYLE_MSGBOX, 
    "CONFIRMAR CONTAS", msg, "{ff5555}Sair", "{55ff55}Ficar");

    return 1;
}

YCMD:menuorg(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ORG ] {ffffff}Menu da organização. Pegue Armas e Coletes");
        return 1;
    }

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE)) return 1;
    
    new msg[512];
    strcat(msg, "{ffff99}1. {ffffff}Kit Basico {ffff99}(Deagle)\n");   
    strcat(msg, "{ffff99}2. {ffffff}Kit Tatico {ffff99}(M4 + Shotgun)\n");         
    strcat(msg, "{ffff99}3. {ffffff}Kit Pesado {ffff99}(AK47 + Sniper)\n");        
    strcat(msg, "{ffff99}4. {ffffff}Pegar {ffff99}Kit médico\n");               
    strcat(msg, "{ffff99}5. {ffffff}Pegar {ffff99}Colete (100%%)\n");              
    strcat(msg, "{ffff99}6. {ffffff}Limpar Armas");                      

    inline dialog_kit(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, listitem, inputtext

        if(!response) return 1;

        switch(listitem)
        {
            case 0:
            {
                if(org::Player[playerid][pyr::tick_kit] >= GetTickCount())
                    return SendClientMessage(playerid, -1, "{ff9933}[ ORG KIT ] {ffffff}Espere {ff9933}2 minutos {ffffff}para pegar um novo kit.");
            
                ResetPlayerWeapons(playerid);

                GivePlayerWeapon(playerid, WEAPON:24, 100);
     
                org::Player[playerid][pyr::tick_kit] = GetTickCount() + 120000;
                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Voce pegou o {33ff33}Kit Basico.");
            }

            case 1:
            {
                if(org::Player[playerid][pyr::tick_kit] >= GetTickCount())
                    return SendClientMessage(playerid, -1, "{ff9933}[ ORG KIT ] {ffffff}Espere {ff9933}2 minutos {ffffff}para pegar um novo kit.");
            
                ResetPlayerWeapons(playerid);

                GivePlayerWeapon(playerid, WEAPON:31, 300);
                GivePlayerWeapon(playerid, WEAPON:25, 50);
            
                org::Player[playerid][pyr::tick_kit] = GetTickCount() + 120000;
                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Voce pegou o {33ff33}Kit Tatico.");
            }

            case 2:
            {
                if(org::Player[playerid][pyr::tick_kit] >= GetTickCount())
                    return SendClientMessage(playerid, -1, "{ff9933}[ ORG KIT ] {ffffff}Espere {ff9933}2 minutos {ffffff}para pegar um novo kit.");
            
                ResetPlayerWeapons(playerid);

                GivePlayerWeapon(playerid, WEAPON:30, 300);
                GivePlayerWeapon(playerid, WEAPON:34, 20); 

                org::Player[playerid][pyr::tick_kit] = GetTickCount() + 120000;
                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Voce pegou o {33ff33}Kit Pesado.");
            }

            case 3:
            {
                if(Player[playerid][pyr::health] >= 100.0)
                    return SendClientMessage(playerid, -1, "{ff9933}[ ORG KIT ] {ffffff}Você não está precisando de {ff9933}Kit Médico.");
                
                Player[playerid][pyr::health] = 100.0;
                SetPlayerHealth(playerid, 100.0);
                
                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Voce pegou um {33ff33}KitMedico.");
            }

            case 4:
            {
                if(Player[playerid][pyr::health] >= 200.0)
                    return SendClientMessage(playerid, -1, "{ff9933}[ ORG KIT ] {ffffff}Você não está precisando de {ff9933}Colete.");
            
                Player[playerid][pyr::health] = 200.0;
                SetPlayerHealth(playerid, 100.0);
                SetPlayerArmour(playerid, 100.0);

                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Voce pegou um {33ff33}Colete.");
            }

            case 5:
            {
                ResetPlayerWeapons(playerid);

                if(Player[playerid][pyr::health] > 100.0)
                {
                    Player[playerid][pyr::health] -= 100.0;
                    SetPlayerHealth(playerid, Player[playerid][pyr::health]);
                    SetPlayerArmour(playerid, 0.0);
                }

                SendClientMessage(playerid, -1, "{33ff33}[ ORG KIT ] {ffffff}Suas armas e colete {33ff33}guardados.");
            }
        }
    }

    Dialog_ShowCallback(playerid, using inline dialog_kit, DIALOG_STYLE_LIST, 
    "Equipamentos da Organicacao", msg, "Pegar", "Cancelar");

    return 1;
}
