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
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    if(org::Player[playerid][pyr::orgid] != INVALID_ORG_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você já faz parte de uma {ff3333}organização");
    
    new orgid = org::Player[playerid][pyr::invite_orgid];
    new inviterid = org::Player[playerid][pyr::inviterid];

    if(orgid == INVALID_ORG_ID || inviterid == INVALID_PLAYER_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você não possui convite aberto");
    
    if(!GetFlag(Org[orgid][org::flags], FLAG_ORG_CREATED))    
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}A organização que te convidou {ff3333}não existe mais!");

    Org::SetMember(inviterid, playerid, orgid, ORG_ROLE_NOVICE);

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
            SendClientMessage(i, Org[orgid][org::color], "( Radio ORG ) {ffffff}%s diz: %s",
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

    if(!Org::HasPermission(playerid, ORG_ROLE_NOVICE))
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ORG ] {ffffff}Voce nao tem permissao para isso!");
        return 1;
    }

    new str[512];
    
    if(org::Player[playerid][pyr::role] >= ORG_ROLE_NOVICE)
        strcat(str, "r\now\n");
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

// CMD:menuorg(playerid)
// {
//     // Verificações básicas
//     if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem org!");

//     // --- 1. SE FOR MECÂNICO (Menu Exclusivo) ---
//     if(Player[playerid][pOrg] == ORG_MECANICA_ID)
//     {
//         ShowPlayerDialog(playerid, DIALOG_MENU_MECANICO, DIALOG_STYLE_LIST, "Vestiario - Mecanica", 
//             "1. Entrar em Servico (Uniforme)\n2. Pegar Ferramentas (Extintor/Spray)\n3. Sair de Servico (Civil)", 
//             "Pegar", "Sair");
//         return 1;
//     }

//     // --- 2. SE FOR OUTRA ORG (Menu de Guerra) ---
//     new string[500];
//     strcat(string, "1. Kit Basico (Deagle + Colete)\n");      // Item 0
//     strcat(string, "2. Kit Tatico (M4 + Shotgun)\n");         // Item 1
//     strcat(string, "3. Kit Pesado (AK47 + Sniper)\n");        // Item 2
//     strcat(string, "4. Encher Vida (100%)\n");                // Item 3
//     strcat(string, "5. Encher Colete (100%)\n");              // Item 4
//     strcat(string, "6. Limpar Armas");                        // Item 5

//     ShowPlayerDialog(playerid, DIALOG_MENUORG, DIALOG_STYLE_LIST, "Equipamentos da Org", string, "Pegar", "Cancelar");
//     return 1;
// }
