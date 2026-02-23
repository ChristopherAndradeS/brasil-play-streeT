
YCMD:convidar(playerid, params[], help)
{   
    if(!Org::HasPermission(playerid, FLAG_PLAYER_LEADER | FLAG_PLAYER_COLEADER)) return 1;

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Use: /convidar {ff3333}[ ID ].");
    
    if(!Org::ValidTargetID(playerid, targetid)) return 1;
    
    if(org::Player[targetid][pyr::invite] != INVALID_ORG_ID)
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}O jogador já possui um {ff3333}convite aberto.");
    
    new orgid = org::Player[playerid][pyr::orgid];

    org::Player[targetid][pyr::invite] = orgid;

    SendClientMessage(targetid, -1, "{ffff99}[ ORG ] {ffffff}O (Co)Líder {ffff99}%s \
    {ffffff}da {%06x}%s {ffffff}te convidou para {ffff99}organização!",
    GetPlayerNameStr(playerid), Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

    SendClientMessage(targetid, -1, "{ffff99}[ ORG ] {fffff}Use {ffff99}/aceitar {ffffff}para confirmar o convite.");
   
    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {fffff}Convite enviado para {ffff99}%s {ffffff}com sucesso.",
    GetPlayerNameStr(targetid));
   
    return 1;
}

YCMD:aceitar(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    new orgid = org::Player[playerid][pyr::invite];

    if(orgid == INVALID_ORG_ID) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você não possui convite aberto");
    
    if(GetFlag(Org[orgid][org::flags], FLAG_ORG_CREATED))    
        return SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}A organização que te convidou {ff3333}não existe mais!");

    Org::SetPlayer(playerid, orgid, true);

    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {ffffff}Parabens! Agora você é {ffff99}membro {ffffff}da organização {%06x}%s.",
    Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

    return 1;
}

YCMD:demitir(playerid, params[], help)
{
    if(!Org::HasPermission(playerid, FLAG_PLAYER_LEADER | FLAG_PLAYER_COLEADER)) return 1;

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Use: /demitir {ff3333}[ ID ].");
    
    if(!Org::ValidTargetID(playerid, targetid, .has_org = true, .same_org = true)) return 1;

    new orgid = org::Player[playerid][pyr::orgid];

    switch(org::Player[playerid][pyr::role])
    {
        case ORG_ROLE_LEADER:
        {
            format(Org[orgid][org::leader], 24, "%s", NO_LEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "leader", NO_LEADER_NAME, "orgid = %d", orgid);
        }

        case ORG_ROLE_COLEADER:
        {
            format(Org[orgid][org::coleader], 24, "%s", NO_COLEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "coleader", NO_COLEADER_NAME, "orgid = %d", orgid);
        }
    }

    Org::UnSetPlayer(playerid);

    SendClientMessage(targetid, -1, "{ff3333}[ ORG ] {fffff}Você foi {ff3333}expulso {ffffff}da sua organização!");
   
    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {fffff}Você expulsou {ffff99}%s {ffffff}com sucesso.",
    GetPlayerNameStr(targetid));

    return 1;
}

YCMD:r(playerid, params[], help)
{
    if(!Org::HasPermission(playerid, FLAG_PLAYER_MEMBER)) return 1;
    
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