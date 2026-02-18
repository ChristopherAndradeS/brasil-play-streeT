#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    // Org::Create("Groove Street", ORG_TYPE:1, "SERVER", "Andrade", "Andrew", 
    // {65, 105, 106, 195}, 0x33FF33FF, 2495.33, -1690.26, 4.76);
    
    return 1;
}

stock Org::Create(const name[], ORG_TYPE:type, const creator[], const leader[], const coleader[], const skins[MAX_ORGS_SKINS], color, Float:sX, Float:sY, Float:sZ)
{
    new sucess = DB::Insert(db_stock, "organizations", 
    "name, type, creator, leader, coleader, skins, color, funds, flags, sX, sY, sZ", 
    "'%q', %i, '%q', '%q', '%q', '%q', %i, %f, %i, %f, %f, %f", 
    name, _:type, creator, leader, coleader, DB::GetIntListStr(skins, MAX_ORGS_SKINS), color, 0.0, 0, sX, sY, sZ);
     
    if(sucess)
        printf("[ ORGS (DB) ] Organizacao %s | Lider: %s | Colider: %s criada com sucesso", name, leader, coleader);
    else
        printf("[ ORGS (DB) ] Erro ao criar organizacao");
}

stock DB::GetIntListStr(const list[], len = sizeof(list))
{
    new liststr[64];

    for(new i = 0; i < len; i++)
        format(liststr, 64, "%s%d ", liststr, list[i]);

    return liststr;
}

YCMD:orgs(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    new msg[1024], line[128], org::members[MAX_ORGS];
    
    foreach(new i : Player)
    {
        if(!IsValidPlayer(i) || Player[i][pyr::orgid] == INVALID_ORG_TYPE) continue;
        org::members[Player[i][pyr::orgid]]++;
    }

    strcat(msg, "{ff99ff}ID\t{ffffff}Organizacao\t{ff99ff}Lider\t{ffffff}Colider\t{ff99ff}Membros Online\n");

    for(new i = 1; i < MAX_ORGS; i++)
    {
        if(!GetFlag(Organization[i][org::flags], FLAG_ORG_CREATED)) continue;
        
        format(line, 128, "%d\t{%x}%s\t%s\t%s\t{ffffff}%d membros\n", i, Organization[i][org::color], Organization[i][org::name], 
        Organization[i][org::leader], Organization[i][org::coleader], org::members[i]);
        
        strcat(msg, line);
    }

    inline no_use_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, response, listitem, inputtext

        return 1;
    }
    
    Dialog_ShowCallback(playerid, using inline no_use_dialog, DIALOG_STYLE_TABLIST_HEADERS, "Orgs do Servidor", msg, "Fechar");
   
    return 1;
}

YCMD:darlider(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Define jogador como lider de uma organização.");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_CEO)) return 1;

    new name[MAX_PLAYER_NAME], orgid;

    if(sscanf(params, "s[24]", name, orgid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /darlider {ff3333}[ NOME ] <orgid 1 - %d >", MAX_ORGS);

    if(orgid <= 0 || orgid >= MAX_ORGS || !GetFlag(Organization[orgid][org::flags], FLAG_ORG_CREATED))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Parâmetro {ff3333}[ ORGID ] {ffffff}Inválido! Use {ff3333}/allorgs.");
    
    new admin_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, admin_name);

    new sucess = Org::SetLeader(playerid, name, admin_name, orgid);

    if(sucess)
        SendClientMessage(playerid, -1, "{33ff33}[ ADMIN ] {ffffff}Jogador {33ff33}%s {ffffff}setado como lider da organizaçõa {33ff33}%s {ffffff}com sucesso.",
        name, Organization[orgid][org::name]);

    return 1;
}

stock Org::SetLeader(playerid, const name[], const admin_name[], orgid)
{
    if(!Player::Exists(name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador provavelmente não existe no {ff3333}banco de dados!");
        return 0;
    }

    new flags;
    DB::GetDataInt(db_entity, "players", "flags", flags, "name = '%q'", name);

    if(GetFlag(flags, FLAG_PLAYER_IS_LEADER))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador {ff3333}já é lider {ffffff}de uma organização!");
        return 0;
    }

    new targetid = GetPlayerIDByName(name);

    if(IsValidPlayer(targetid))
    {
        Player[targetid][pyr::orgid] = orgid;
        SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_IS_LEADER);

        SetPlayerColor(targetid, Organization[orgid][org::color]);
        //Org::SetMemberRandSkin(targetid);

        SendClientMessage(targetid, -1, "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}líder\
        da organização {%x}%s", Organization[orgid][org::color], Organization[orgid][org::name]);

        DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
        DB::SetDataInt(db_entity, "players", "orgid", Player[targetid][pyr::flags], "name = '%q'", name);

        SendClientMessage(targetid, -1, "{ffff33}[ ORGS ] {ffffff}Use {ffff33}/ajudaorg {ffffff}para ver o painel de comandos da sua organização.");
    }

    DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
    DB::SetDataInt(db_entity, "players", "orgid", flags | FLAG_PLAYER_IS_LEADER, "name = '%q'", name);
    DB::SetDataString(db_stock, "organizations", "leader", name, "name = '%q'", Organization[orgid][org::name]);

    printf("[ ORG (DB) ] O admin %s, setou %s como lider da organizacao %s", admin_name, name, Organization[orgid][org::name]);
    return 1;
}

stock Org::GetSkins(const name[], output[MAX_ORGS_SKINS])
{
    new buffer[64];
    DB::GetDataString(db_stock, "organizations", "skins", buffer, 64, "name = '%q'", name);

    printf("buffer %s", buffer);

    return sscanf(buffer, "a<i>["#MAX_ORGS_SKINS"]", output);
}

// YCMD:darsub(playerid, params[])
// {
//     // Apenas Lider da própria org ou Admin
//     new minhaOrg = Player[playerid][pOrg];
//     if(Player[playerid][pLider] == 0 && Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Lider ou Admin.");
    
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /darsub [ID]");
//     if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
//     // Se for Lider, só pode dar sub pra quem é da mesma org
//     if(Player[playerid][pLider] == 1 && Player[id][pOrg] != minhaOrg) return SendClientMessage(playerid, COR_ERRO, "Este jogador nao e da sua org! Convide ele antes.");

//     // Se for admin, usa a org que o player já está
//     new orgAlvo = Player[id][pOrg];
//     if(orgAlvo == 0) return SendClientMessage(playerid, COR_ERRO, "O jogador nao tem organizacao.");

//     // 1. Atualiza Jogador
//     Player[id][pLider] = 2; // Vamos usar 2 para Sub-Líder
//     SalvarConta(id);

//     // 2. Atualiza Memória da Org
//     new nome[MAX_PLAYER_NAME];
//     GetPlayerName(id, nome, sizeof(nome));
//     format(OrgInfo[orgAlvo][oSubLider], 24, "%s", nome);

//     // 3. Atualiza MySQL da Org
//     new query[256];
//     mysql_format(Conexao, query, sizeof(query), "UPDATE organizacoes SET sublider='%e' WHERE id=%d", nome, OrgInfo[orgAlvo][oID]);
//     mysql_tquery(Conexao, query);

//     SendClientMessage(playerid, COR_VERDE_NEON, "Sub-Lider definido com sucesso!");
//     SendClientMessage(id, COR_V_CLARO, "Voce foi promovido a Sub-Lider!");
//     return 1;
// }

// // 2. CONVIDAR (Comando de Lider)
// YCMD:convidar(playerid, params[])
// {
//     if(Player[playerid][pLider] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao e Lider!");
//     if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem Org!");

//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /convidar [ID]");
//     if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
//     if(Player[id][pOrg] != 0) return SendClientMessage(playerid, COR_ERRO, "Esse jogador ja tem Org/Faccao.");
    
//     InviteOrg[id] = Player[playerid][pOrg]; // Salva qual org convidou
    
//     new string[128], nome[24];
//     GetPlayerName(playerid, nome, 24);
    
//     format(string, sizeof(string), "O Lider %s te convidou para a %s. Digite /aceitar", nome, GetOrgName(Player[playerid][pOrg]));
//     SendClientMessage(id, COR_V_CLARO, string);
//     SendClientMessage(playerid, COR_V_CLARO, "Convite enviado.");
//     return 1;
// }


// YCMD:aceitar(playerid)
// {
//     if(InviteOrg[playerid] == 0) return SendClientMessage(playerid, COR_ERRO, "Ninguem te convidou.");
    
//     new orgid = InviteOrg[playerid];
    
//     // Verifica se a org ainda existe
//     if(OrgInfo[orgid][oCriada] == 0) return SendClientMessage(playerid, COR_ERRO, "Essa org nao existe mais.");

//     Player[playerid][pOrg] = orgid;
//     Player[playerid][pLider] = 0;
//     InviteOrg[playerid] = 0;
    
//     // Seta a cor da org
//     SetPlayerColor(playerid, OrgInfo[orgid][oCor]);

//     // --- NOVA LÓGICA: ATUALIZA A SKIN ---
//     if(OrgInfo[orgid][oSkin] > 0)
//     {
//         SetPlayerSkin(playerid, OrgInfo[orgid][oSkin]);
//         Player[playerid][pSkin] = OrgInfo[orgid][oSkin]; // Atualiza na variável para salvar no banco depois
//         SendClientMessage(playerid, COR_V_CLARO, "Voce recebeu o uniforme da faccao!");
//     }
//     // ------------------------------------
    
//     SalvarConta(playerid);
    
//     new string[128];
//     format(string, sizeof(string), "Parabens! Agora voce e membro da %s.", GetOrgName(orgid));
//     SendClientMessage(playerid, COR_V_CLARO, string);
//     return 1;
// }


// // 4. DEMITIR (Lider expulsa membro)
// YCMD:demitir(playerid, params[])
// {
//     if(Player[playerid][pLider] != 1 && Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Lideres.");
    
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /demitir [ID]");
    
//     if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
//     // Verifica se é da mesma org (se não for admin)
//     if(Player[playerid][pAdmin] < 4 && Player[id][pOrg] != Player[playerid][pOrg]) return SendClientMessage(playerid, COR_ERRO, "Ele nao e da sua faccao.");
    
//     if(id == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode se demitir.");

//     new orgid = Player[id][pOrg];

//     // Se o cara era Sub-Líder, limpa o nome dele da tabela da Org
//     if(Player[id][pLider] == 2)
//     {
//         format(OrgInfo[orgid][oSubLider], 24, "Ninguem");
//         new query[128];
//         mysql_format(Conexao, query, sizeof(query), "UPDATE organizacoes SET sublider='Ninguem' WHERE id=%d", OrgInfo[orgid][oID]);
//         mysql_tquery(Conexao, query);
//     }

//     // Reseta o jogador
//     Player[id][pOrg] = 0;
//     Player[id][pLider] = 0;
//     SetPlayerColor(id, 0xFFFFFFFF); // Branco
//     SalvarConta(id); // Salva na tabela contas
    
//     SendClientMessage(playerid, COR_V_CLARO, "Membro demitido.");
//     SendClientMessage(id, COR_ERRO, "Voce foi demitido da organizacao.");
//     return 1;
// }

// // 5. RADIO (/r)
// YCMD:r(playerid, params[])
// {
//     if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem org.");
    
//     new texto[100];
//     if(sscanf(params, "s[100]", texto)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /r [Mensagem]");
    
//     new string[144], nome[24];
//     GetPlayerName(playerid, nome, 24);
    
//     // Pega o nome da org direto da memória do novo sistema
//     new nomeOrg[30];
//     new orgid = Player[playerid][pOrg];
    
//     if(OrgInfo[orgid][oCriada] == 1) format(nomeOrg, 30, OrgInfo[orgid][oNome]);
//     else format(nomeOrg, 30, "Org %d", orgid);

//     format(string, sizeof(string), "(Radio %s) %s: %s", nomeOrg, nome, texto);
    
//     for(new i=0; i < MAX_PLAYERS; i++)
//     {
//         if(IsPlayerConnected(i) && Player[i][pOrg] == orgid)
//         {
//             SendClientMessage(i, 0x87CEEBFF, string); // Cor Azul Claro padrão pra radio
//         }
//     }
//     return 1;
// }

// // --- COLOCAR NO PORTA MALAS (SEQUESTRAR) ---
// YCMD:sequestrar(playerid, params[])
// {
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /sequestrar [ID]");
//     if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador desconectado.");
//     if(id == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode se sequestrar.");
    
//     // Verifica distância
//     new Float:x, Float:y, Float:z;
//     GetPlayerPos(id, x, y, z);
//     if(!IsPlayerInRangeOfPoint(playerid, 3.0, x, y, z)) return SendClientMessage(playerid, COR_ERRO, "Chegue mais perto do jogador!");
    
//     // Verifica veículo próximo
//     new vehicleid = GetClosestVehicle(playerid);
//     if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Voces precisam estar perto de um carro!");
    
//     // AÇÃO
//     // Coloca no Banco de trás (ID 2 ou 3) para "simular" o porta malas
//     PutPlayerInVehicle(id, vehicleid, 2); 
//     TogglePlayerControllable(id, 0); // Congela
    
//     // Mostra tela preta
//     CriarVenda(id);
//     PlayerTextDrawShow(id, TD_Venda[id]);
    
//     SequestradoPor[id] = vehicleid;
    
//     SendClientMessage(playerid, COR_VERDE_NEON, "Voce jogou o cidadao no porta-malas!");
//     SendClientMessage(id, COR_ERRO, "Voce foi jogado no porta-malas!");
//     return 1;
// }

// // --- TIRAR DO PORTA MALAS ---
// YCMD:liberar(playerid, params[])
// {
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /liberar [ID]");
//     if(SequestradoPor[id] == 0) return SendClientMessage(playerid, COR_ERRO, "Este jogador nao esta sequestrado.");
    
//     // Tira do carro e descongela
//     RemovePlayerFromVehicle(id);
//     TogglePlayerControllable(id, 1);
//     PlayerTextDrawHide(id, TD_Venda[id]); // Tira a tela preta
//     SequestradoPor[id] = 0;
    
//     SendClientMessage(playerid, COR_VERDE_NEON, "Voce liberou o jogador.");
//     return 1;
// }



// YCMD:lavar(playerid)
// {
//     // 1. Verifica se tem Org e se é de Lavagem (Tipo 1)
//     if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao pertence a uma faccao.");
    
//     // Verifica o TIPO da org no banco de dados (que carregamos na memória)
//     new orgid = Player[playerid][pOrg];
//     if(OrgInfo[orgid][oTipo] != 1) return SendClientMessage(playerid, COR_ERRO, "Sua faccao nao trabalha com lavagem de dinheiro.");

//     // 2. Verifica se está na HQ (Perto do Pickup da Org)
//     if(!IsPlayerInRangeOfPoint(playerid, 5.0, OrgInfo[orgid][oX], OrgInfo[orgid][oY], OrgInfo[orgid][oZ])) 
//         return SendClientMessage(playerid, COR_ERRO, "Voce precisa estar na HQ para usar a maquina de lavar.");

//     // 3. Procura o Dinheiro Sujo na Mochila
//     new slot = -1;
//     for(new i=0; i < MAX_INV_SLOTS; i++)
//     {
//         if(InvItem[playerid][i] == ITEM_DINHEIRO_SUJO)
//         {
//             slot = i;
//             break;
//         }
//     }

//     if(slot == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem Dinheiro Sujo na mochila.");

//     // 4. A MÁGICA: Converte e Limpa
//     new quantia = InvQtd[playerid][slot];
    
//     // Remove o item da mochila
//     InvItem[playerid][slot] = 0;
//     InvQtd[playerid][slot] = 0;
    
//     // Dá o dinheiro limpo na mão
//     GivePlayerMoney(playerid, quantia);
//     Player[playerid][pDinheiro] += quantia;
    
//     // Atualiza o banco de dados (Salva mochila e conta)
//     SalvarInventario(playerid);
//     SalvarConta(playerid);

//     // Visual e Som
//     ApplyAnimation(playerid, "DEALER", "DEALER_DEAL", 4.1, 0, 0, 0, 0, 0, 0);
//     PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0); // Som de caixa registradora
    
//     new str[128];
//     format(str, sizeof(str), "{00FF00}LAVAGEM CONCLUIDA: {FFFFFF}Voce limpou R$ %d. O dinheiro esta na sua mao.", quantia);
//     SendClientMessage(playerid, -1, str);
    
//     return 1;
// }