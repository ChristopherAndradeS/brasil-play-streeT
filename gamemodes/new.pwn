#include <a_samp>
#include <DOF2>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <a_mysql>

new MySQL:Conexao;

#define MAX_GARAGES         30
#define MAX_PLAYER_VEHICLES 10
#define MAX_DESMANCHES      50
#define MAX_MECANICAS       50
#define MAX_OFICINAS        20
#define MAX_INV_SLOTS       16
#define MAX_VEHICLE_SLOTS   3
#define MAX_CARROS_CONCE    50

#define DIALOG_CMDS 3
#define DIALOG_PIX_ID 10
#define DIALOG_PIX_VALOR 11
#define DIALOG_TUNING 60
#define DIALOG_RODAS 61
#define DIALOG_NEON 62
#define DIALOG_MALAS 1500
#define DIALOG_MALAS_ACAO 1501
#define DIALOG_CRIAR_MEC 2000
#define DIALOG_MENU_MECANICO 2010
#define DIALOG_GPS_CAT 7701
#define DIALOG_GPS_LOC 7702
#define ITEM_DINHEIRO_SUJO 4

#define PASTA_GARAGENS    "Garagens/Gar_%d.ini"
#define PASTA_VEICULOS    "Veiculos/%s.ini"
#define ARQUIVO_CATS      "GPS/Categorias.txt"
#define PASTA_ORGS        "Orgs/%d.ini"
#define PASTA_OFICINAS    "Oficinas/Ofi_%d.ini"
#define ARQUIVO_ORGS      "Lideres.ini"
#define ARQUIVO_DESMANCHE "Desmanches/Desmanche_%d.ini"
#define ARQUIVO_CONCE_STOCK "Conce/Estoque.ini"
#define ARQUIVO_CONCE_LOC   "Conce/Local.ini"

enum pInfo 
{
    pSenha[129], pID, pDinheiro, pAdmin, pLevel, pVip, pSkin, pScore,
    pCpf, pBitcoin, pOrg, pLider, pMatou, pMorreu, pTempo,
    bool:pLogado
};

new Player[MAX_PLAYERS][pInfo];

// VARIÁVEIS DE SISTEMA
new bool:Trabalhando[MAX_PLAYERS];
new InviteOrg[MAX_PLAYERS];
new TempGPS_Categoria[MAX_PLAYERS][64];
new CheckpointAtivo[MAX_PLAYERS];
new PixDestino[MAX_PLAYERS];
new bool:InvAberto[MAX_PLAYERS];
new InvItem[MAX_PLAYERS][MAX_INV_SLOTS];
new InvQtd[MAX_PLAYERS][MAX_INV_SLOTS];
new SlotSelecionado[MAX_PLAYERS] = {-1, ...};
new bool:CelularAberto[MAX_PLAYERS];
new bool:BancoAberto[MAX_PLAYERS];
new SequestradoPor[MAX_PLAYERS];
new TimerLockPick[MAX_PLAYERS];
new bool:IsPicking[MAX_PLAYERS];
new LockPickCarro[MAX_PLAYERS];
new Float:LockCursorX[MAX_PLAYERS];
new Float:LockAlvoX[MAX_PLAYERS];
new bool:LockDir[MAX_PLAYERS];
new VeiculoAtualGaragem[MAX_PLAYERS];
new bool:GaragemAberta[MAX_PLAYERS];
new ConceCarroAtual[MAX_PLAYERS];
new bool:ConceAberta[MAX_PLAYERS];
new PlayerSpectating[MAX_PLAYERS];

// ARRAYS E ENUMS (DOF2)
enum gInfo { Float:gX, Float:gY, Float:gZ, gCriada }
new GarageInfo[MAX_GARAGES][gInfo];
new Text3D:GarageLabel[MAX_GARAGES];
new GaragePickup[MAX_GARAGES];

enum pVehInfo { pvModelo, pvPreco, pvCor1, pvCor2, pvSpawnadoID, pvNome[32] }
new PlayerVehicles[MAX_PLAYERS][MAX_PLAYER_VEHICLES][pVehInfo];

enum oInfo { oTipo, Float:oX, Float:oY, Float:oZ, oCriada }
new OficinaInfo[MAX_OFICINAS][oInfo];
new Text3D:OficinaLabel[MAX_OFICINAS];
new OficinaPickup[MAX_OFICINAS];

enum eConce { cModel, cPreco, cNome[32], cExiste }
new ConceStock[MAX_CARROS_CONCE][eConce];
new TotalCarrosConce = 0;
new Float:ConceX, Float:ConceY, Float:ConceZ;
new ConceCriada = 0;
new ConcePickup;
new Text3D:ConceLabel;

enum dsInfo { Float:dsX, Float:dsY, Float:dsZ, dsCriado }
new DesmancheInfo[MAX_DESMANCHES][dsInfo];
new Text3D:DesmancheLabel[MAX_DESMANCHES];
new TimerDesmanche[MAX_PLAYERS];

new NeonEsq[MAX_VEHICLES]; new NeonDir[MAX_VEHICLES];

enum vInfo { vArmaId[MAX_VEHICLE_SLOTS], vMunicao[MAX_VEHICLE_SLOTS] }
new VehicleData[MAX_VEHICLES][vInfo];

// --- DEFINIÇÕES DE TIPOS DE FACC ---
#define TIPO_ORG_LEGAL    0  // Policia, Medicos, News
#define TIPO_FAC_LAVAGEM  1  // Lava Jato (Limpa dinheiro sujo)
#define TIPO_FAC_DESMANCHE 2 // Desmanche de Carros
#define TIPO_FAC_COMUM    3  // Gangue de Rua / Máfia

// --- ENUM ATUALIZADO PARA MYSQL ---
enum eOrg
{
    oID,            // ID real no banco de dados
    oNome[32],
    oCor,
    oTipo,          // 0, 1, 2 ou 3
    oSkin,
    oLider[24],     // Nome do Líder
    oSubLider[24],  // Nome do Sub-Líder
    oCofre,
    Float:oX, Float:oY, Float:oZ,
    oCriada,        // Se está carregada no servidor
    oPickup,        // O ID do pickup
    Text3D:oLabel   // O ID do texto 3D
}
new OrgInfo[MAX_ORGS][eOrg];

#define ORG_MECANICA_ID 1
#define ITEM_MOTOR 5
#define ITEM_CHASSI 6
#define ITEM_RODAS 7

// FORWARDS
forward cmd_mochila(playerid, params[]);
forward cmd_celular(playerid, params[]);
forward cmd_tuning(playerid, params[]);
forward cmd_malas(playerid, params[]);
forward AnimarLockPick(playerid);
forward OnDebugSalvar(playerid, slot);
forward OnAbrirLojaMySQL(playerid);
forward ForcarSkinCorreta(playerid);


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
// --- RESPOSTA DO MENU MECÂNICO ---
    if(dialogid == DIALOG_MENU_MECANICO)
    {
        if(!response) return 1;
        
        if(listitem == 0) // Entrar em Serviço
        {
            SetPlayerSkin(playerid, 50); // Skin Mecânico
            SetPlayerColor(playerid, 0x808080AA); // Cor Cinza
            SendClientMessage(playerid, COR_VERDE_NEON, "Voce colocou seu uniforme de trabalho.");
        }
        if(listitem == 1) // Ferramentas
        {
            GivePlayerWeapon(playerid, 42, 500); // Extintor
            GivePlayerWeapon(playerid, 41, 500); // Spray
            SendClientMessage(playerid, COR_VERDE_NEON, "Voce pegou suas ferramentas.");
        }
        if(listitem == 2) // Sair de Serviço
        {
            SetPlayerSkin(playerid, 0); // CJ (Civil)
            ResetPlayerWeapons(playerid);
            SetPlayerColor(playerid, 0xFFFFFFFF); // Branco
            SendClientMessage(playerid, COR_V_CLARO, "Voce saiu de servico.");
        }
        return 1;
    }

    // --- RESPOSTA DO MENU DE ARMAS (OUTRAS ORGS) ---
    if(dialogid == DIALOG_MENUORG)
    {
        if(!response) return 1;

        if(listitem == 0) // Kit Básico
        {
            ResetPlayerWeapons(playerid);
            GivePlayerWeapon(playerid, 24, 100); // Deagle
            SetPlayerArmour(playerid, 100.0);    // Colete
            SendClientMessage(playerid, COR_V_CLARO, "Voce pegou o Kit Basico.");
        }
        if(listitem == 1) // Kit Tático
        {
            ResetPlayerWeapons(playerid);
            GivePlayerWeapon(playerid, 31, 300); // M4
            GivePlayerWeapon(playerid, 25, 50);  // Shotgun
            SetPlayerArmour(playerid, 100.0);
            SendClientMessage(playerid, COR_V_CLARO, "Voce pegou o Kit Tatico.");
        }
        if(listitem == 2) // Kit Pesado
        {
            ResetPlayerWeapons(playerid);
            GivePlayerWeapon(playerid, 30, 300); // AK47
            GivePlayerWeapon(playerid, 34, 20);  // Sniper
            SetPlayerArmour(playerid, 100.0);
            SendClientMessage(playerid, COR_V_CLARO, "Voce pegou o Kit Pesado.");
        }
        if(listitem == 3) // Vida
        {
            SetPlayerHealth(playerid, 100.0);
            SendClientMessage(playerid, COR_V_CLARO, "Vida restaurada.");
        }
        if(listitem == 4) // Colete
        {
            SetPlayerArmour(playerid, 100.0);
            SendClientMessage(playerid, COR_V_CLARO, "Colete restaurado.");
        }
        if(listitem == 5) // Limpar
        {
            ResetPlayerWeapons(playerid);
            SendClientMessage(playerid, COR_V_CLARO, "Suas armas foram guardadas.");
        }
        return 1;
    }

// DIALOG DE CRIAR MECÂNICA (ID 2005)
    if(dialogid == 2005)
    {
        if(!response) return 1;
        
        new id = -1;
        for(new i=0; i < MAX_OFICINAS; i++) { if(OficinaInfo[i][oCriada] == 0) { id = i; break; } }
        if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Limite de areas atingido!");
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        
        OficinaInfo[id][oCriada] = 1;
        OficinaInfo[id][oTipo] = (listitem + 1); 
        OficinaInfo[id][oX] = x;
        OficinaInfo[id][oY] = y;
        OficinaInfo[id][oZ] = z;
        
        // Salva
        new strArq[64];
        format(strArq, sizeof(strArq), PASTA_OFICINAS, id);
        DOF2_CreateFile(strArq);
        DOF2_SetInt(strArq, "Tipo", OficinaInfo[id][oTipo]);
        DOF2_SetFloat(strArq, "X", x); DOF2_SetFloat(strArq, "Y", y); DOF2_SetFloat(strArq, "Z", z);
        DOF2_SaveFile();
        
        // --- VISUAL ATUALIZADO PARA "MECÂNICA" ---
        new label[128];
        if(OficinaInfo[id][oTipo] == 1)
        {
            format(label, sizeof(label), "{00FF00}[ MECANICA - REPARO ]\n{FFFFFF}Exclusivo para Funcionarios\nUse: /reparar");
            SendClientMessage(playerid, COR_VERDE_NEON, "Area de Reparo criada!");
        }
        else
        {
            format(label, sizeof(label), "{00FFFF}[ MECANICA - TUNING ]\n{FFFFFF}Exclusivo para Funcionarios\nUse: /tunar");
            SendClientMessage(playerid, COR_VERDE_NEON, "Area de Tuning criada!");
        }
        OficinaPickup[id] = CreatePickup(3096, 1, x, y, z, -1);
        OficinaLabel[id] = Create3DTextLabel(label, 0xFFFFFFFF, x, y, z, 20.0, 0, 0);
        return 1;
    }

    // --- VARIÁVEIS GERAIS (Para Login/Registro) ---
    // Se essas linhas abaixo forem necessárias para algum código que vem DEPOIS, mantenha.
    // Mas lembre-se: 'nome' e 'arquivo' já foram criados no topo da Public.
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), PASTA_CONTAS, nome);

    // ============================================================
    // 1. SISTEMA DE PORTA MALAS
    // ============================================================
    if(dialogid == DIALOG_MALAS)
    {
        if(!response) return 1;
        new vid = GetPVarInt(playerid, "CarroMexendo"); 
        
        // A. GUARDAR ARMA
        if(listitem == 0) 
        {
            new arma = GetPlayerWeapon(playerid);
            new balas = GetPlayerAmmo(playerid);
            
            if(arma == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem arma na mao!");
            
            for(new i=0; i < MAX_VEHICLE_SLOTS; i++)
            {
                if(VehicleData[vid][vArmaId][i] == 0) 
                {
                    VehicleData[vid][vArmaId][i] = arma;
                    VehicleData[vid][vMunicao][i] = balas;
                    
                    // --- CORREÇÃO DO ERRO RemovePlayerWeapon ---
                    SetPlayerAmmo(playerid, arma, 0); // Zera munição para remover
                    // -------------------------------------------
                    
                    SendClientMessage(playerid, COR_VERDE_NEON, "Arma guardada no porta-malas!");
                    return 1;
                }
            }
            SendClientMessage(playerid, COR_ERRO, "Porta malas cheio!");
        }
        
        // B. PEGAR ARMA / VER ITENS
        if(listitem == 1 || listitem == 2)
        {
            new string[300];
            for(new i=0; i < MAX_VEHICLE_SLOTS; i++)
            {
                if(VehicleData[vid][vArmaId][i] != 0)
                {
                    format(string, sizeof(string), "%s%d. Arma ID: %d (Balas: %d)\n", string, i+1, VehicleData[vid][vArmaId][i], VehicleData[vid][vMunicao][i]);
                }
                else
                {
                    format(string, sizeof(string), "%s%d. (Vazio)\n", string, i+1);
                }
            }
            ShowPlayerDialog(playerid, DIALOG_MALAS_ACAO, DIALOG_STYLE_LIST, "Itens no Porta Malas", string, "Pegar", "Voltar");
        }
        return 1;
    }
    
    if(dialogid == DIALOG_MALAS_ACAO)
    {
        if(!response) return cmd_malas(playerid, ""); // Voltar ao menu anterior
        
        new vid = GetPVarInt(playerid, "CarroMexendo");
        new slot = listitem; 
        
        if(VehicleData[vid][vArmaId][slot] == 0) return SendClientMessage(playerid, COR_ERRO, "Este espaco esta vazio.");
        
        GivePlayerWeapon(playerid, VehicleData[vid][vArmaId][slot], VehicleData[vid][vMunicao][slot]);
        
        VehicleData[vid][vArmaId][slot] = 0;
        VehicleData[vid][vMunicao][slot] = 0;
        
        SendClientMessage(playerid, COR_VERDE_NEON, "Voce pegou a arma do porta-malas!");
        return 1;
    }

    // ============================================================
    // 2. MENU DE ORGANIZAÇÕES
    // ============================================================
    if(dialogid == DIALOG_MENUORG)
    {
        if(!response) return 1; 

        switch(listitem) 
        {
            case 0: // Kit Basico
            {
                GivePlayerWeapon(playerid, 24, 100); 
                SetPlayerArmour(playerid, 100.0);    
                SendClientMessage(playerid, 0x00FF00FF, "Voce pegou o Kit Basico!");
            }
            case 1: // Kit Tatico
            {
                GivePlayerWeapon(playerid, 31, 300); 
                GivePlayerWeapon(playerid, 25, 50);  
                SendClientMessage(playerid, 0x00FF00FF, "Voce pegou o Kit Tatico!");
            }
            case 2: // Kit Pesado
            {
                GivePlayerWeapon(playerid, 30, 300); 
                GivePlayerWeapon(playerid, 34, 20);  
                SendClientMessage(playerid, 0x00FF00FF, "Voce pegou o Kit Pesado!");
            }
            case 3: // Vida
            {
                SetPlayerHealth(playerid, 100.0);
                SendClientMessage(playerid, 0x00FF00FF, "Vida restaurada!");
            }
            case 4: // Colete
            {
                SetPlayerArmour(playerid, 100.0);
                SendClientMessage(playerid, 0x00FF00FF, "Colete restaurado!");
            }
            case 5: // Limpar
            {
                ResetPlayerWeapons(playerid);
                SendClientMessage(playerid, 0xFFFF00FF, "Armas guardadas.");
            }
        }
        return 1;
    }

// --- MENU PRINCIPAL DE TUNING ---
    if(dialogid == DIALOG_TUNING)
    {
        if(!response) return 1; 
        new veiculo = GetPlayerVehicleID(playerid);
        
        switch(listitem)
        {
            case 0: // Reparar
            {
                RepairVehicle(veiculo);
                SetVehicleHealth(veiculo, 1000.0);
                SendClientMessage(playerid, COR_V_CLARO, "Veiculo novinho em folha!");
            }
            case 1: // Nitro
            {
                AddVehicleComponent(veiculo, 1010);
                SendClientMessage(playerid, COR_V_CLARO, "Nitro instalado! Aperte Fogo para usar.");
            }
            case 2: // Hidraulica (Rebaixar)
            {
                AddVehicleComponent(veiculo, 1087);
                SendClientMessage(playerid, COR_V_CLARO, "Suspensao Hidraulica instalada! Use a buzina.");
            }
            case 3: // Rodas
            {
                ShowPlayerDialog(playerid, DIALOG_RODAS, DIALOG_STYLE_LIST, "Escolha a Roda", "Shadow\nMega\nRimshine\nWires\nClassic\nOff-Road\nCutter\nDollar", "Aplicar", "Voltar");
            }
            case 4: // Cor Preta
            {
                ChangeVehicleColor(veiculo, 0, 0);
                SendClientMessage(playerid, COR_V_CLARO, "Pintura Preta aplicada.");
            }
            case 5: // Cor Branca
            {
                ChangeVehicleColor(veiculo, 1, 1);
                SendClientMessage(playerid, COR_V_CLARO, "Pintura Branca aplicada.");
            }
            case 6: // MENU NEON
            {
                // Abre o menu de cores do neon
                ShowPlayerDialog(playerid, DIALOG_NEON, DIALOG_STYLE_LIST, "Cor do Neon", "{0000FF}Azul (Padrao)\n{FF0000}Vermelho\n{00FF00}Verde\n{FFFF00}Amarelo\n{FF00FF}Rosa\n{FFFFFF}Branco", "Instalar", "Voltar");
            }
            case 7: // Remover Neon
            {
                ColocarNeon(veiculo, 0); // 0 remove
                SendClientMessage(playerid, COR_V_CLARO, "Neon removido.");
            }
        }
        return 1;
    }

    // --- SUB-MENU DE CORES DO NEON ---
    if(dialogid == DIALOG_NEON)
    {
        if(!response) return cmd_tunar(playerid, ""); // Voltar
        new veiculo = GetPlayerVehicleID(playerid);

        // IDs dos objetos de neon do SA-MP:
        // 18648 = Azul, 18647 = Vermelho, 18649 = Verde, 18650 = Amarelo, 18651 = Rosa, 18652 = Branco
        
        if(listitem == 0) ColocarNeon(veiculo, 18648); // Azul
        if(listitem == 1) ColocarNeon(veiculo, 18647); // Vermelho
        if(listitem == 2) ColocarNeon(veiculo, 18649); // Verde
        if(listitem == 3) ColocarNeon(veiculo, 18650); // Amarelo
        if(listitem == 4) ColocarNeon(veiculo, 18651); // Rosa
        if(listitem == 5) ColocarNeon(veiculo, 18652); // Branco
        
        SendClientMessage(playerid, COR_VERDE_NEON, "Neon instalado com sucesso!");
        return 1;
    }

    // --- SUB-MENU DE RODAS ---
    if(dialogid == DIALOG_RODAS)
    {
        if(!response) return cmd_tunar(playerid, "");
        new veiculo = GetPlayerVehicleID(playerid);
        
        if(listitem == 0) AddVehicleComponent(veiculo, 1073); // Shadow
        if(listitem == 1) AddVehicleComponent(veiculo, 1074); // Mega
        if(listitem == 2) AddVehicleComponent(veiculo, 1075); // Rimshine
        if(listitem == 3) AddVehicleComponent(veiculo, 1076); // Wires
        if(listitem == 4) AddVehicleComponent(veiculo, 1077); // Classic
        if(listitem == 5) AddVehicleComponent(veiculo, 1025); // Off-Road
        if(listitem == 6) AddVehicleComponent(veiculo, 1079); // Cutter
        if(listitem == 7) AddVehicleComponent(veiculo, 1083); // Dollar
        
        SendClientMessage(playerid, COR_V_CLARO, "Roda aplicada!");
        return 1;
    }

    return 0;
}
    
// --- ROUBAR O VEÍCULO (LOCK PICK) ---
CMD:lockpick(playerid)
{
    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Chegue perto de um veiculo!");

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(doors == 0) return SendClientMessage(playerid, COR_ERRO, "Este veiculo ja esta aberto.");

    SendClientMessage(playerid, COR_V_CLARO, "Iniciando Lockpick... Acerte o alvo!");
    
    // Animação de mexer na porta
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 0, 0, 0); 
    
    // Inicia o Jogo
    IniciarLockPick(playerid, vehicleid);
    return 1;
}

CMD:menuorg(playerid)
{
    // Verificações básicas
    if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem org!");

    // --- 1. SE FOR MECÂNICO (Menu Exclusivo) ---
    if(Player[playerid][pOrg] == ORG_MECANICA_ID)
    {
        ShowPlayerDialog(playerid, DIALOG_MENU_MECANICO, DIALOG_STYLE_LIST, "Vestiario - Mecanica", 
            "1. Entrar em Servico (Uniforme)\n2. Pegar Ferramentas (Extintor/Spray)\n3. Sair de Servico (Civil)", 
            "Pegar", "Sair");
        return 1;
    }

    // --- 2. SE FOR OUTRA ORG (Menu de Guerra) ---
    new string[500];
    strcat(string, "1. Kit Basico (Deagle + Colete)\n");      // Item 0
    strcat(string, "2. Kit Tatico (M4 + Shotgun)\n");         // Item 1
    strcat(string, "3. Kit Pesado (AK47 + Sniper)\n");        // Item 2
    strcat(string, "4. Encher Vida (100%)\n");                // Item 3
    strcat(string, "5. Encher Colete (100%)\n");              // Item 4
    strcat(string, "6. Limpar Armas");                        // Item 5

    ShowPlayerDialog(playerid, DIALOG_MENUORG, DIALOG_STYLE_LIST, "Equipamentos da Org", string, "Pegar", "Cancelar");
    return 1;
}

// =============================================================================
//                      SISTEMA DE ORGS E FACÇÕES (BRASIL)
// =============================================================================

// Função para pegar o nome da Org
stock GetOrgName(orgid)
{
    new name[30];
    // Se a org existe (foi criada), pega o nome dela
    if(orgid > 0 && OrgInfo[orgid][oCriada] == 1) 
    {
        format(name, 30, OrgInfo[orgid][oNome]);
    }
    else 
    {
        format(name, 30, "Civil");
    }
    return name;
}

// --- CRIAR POSTO DE TRABALHO (Renomeado) ---
CMD:criarmecanica(playerid)
{
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono/Fundador.");
    
    // Mudamos o título do Dialog para Mecânica
    ShowPlayerDialog(playerid, 2005, DIALOG_STYLE_LIST, "Criar Area da Mecanica", "1. Area de Reparo (/reparar)\n2. Area de Tuning (/tunar)", "Criar", "Cancelar");
    return 1;
}

// --- COMANDO REPARAR (Exclusivo Org Mecânico) ---
CMD:reparar(playerid, params[])
{
    // 1. Verifica se é Mecânico
    if(Player[playerid][pOrg] != ORG_MECANICA_ID) return SendClientMessage(playerid, COR_ERRO, "Voce nao e da Organizacao de Mecanicos!");
    
    // 2. Verifica se está em um carro
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COR_ERRO, "Entre no veiculo que deseja reparar.");
    
    // 3. Verifica se está no local certo (Tipo 1)
    new id = -1;
    for(new i=0; i < MAX_OFICINAS; i++)
    {
        if(OficinaInfo[i][oCriada] == 1 && OficinaInfo[i][oTipo] == 1)
        {
            if(IsPlayerInRangeOfPoint(playerid, 5.0, OficinaInfo[i][oX], OficinaInfo[i][oY], OficinaInfo[i][oZ]))
            {
                id = i;
                break;
            }
        }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao esta em uma Area de Reparo da oficina!");

    // AÇÃO
    new veiculo = GetPlayerVehicleID(playerid);
    RepairVehicle(veiculo);
    SetVehicleHealth(veiculo, 1000.0);
    
    // Animação e Som
    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
    SendClientMessage(playerid, COR_VERDE_NEON, "[SERVICO] Veiculo reparado com sucesso!");
    
    // Opcional: Ganhar dinheiro pelo serviço
    GivePlayerMoney(playerid, 100); 
    SendClientMessage(playerid, COR_V_CLARO, "Voce ganhou R$ 100 pelo servico.");
    return 1;
}

// --- COMANDO TUNAR (Exclusivo Org Mecânico) ---
CMD:tunar(playerid, params[])
{
    if(Player[playerid][pOrg] != ORG_MECANICA_ID) return SendClientMessage(playerid, COR_ERRO, "Voce nao e da Organizacao de Mecanicos!");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COR_ERRO, "Entre no veiculo para tunar.");

    // Verifica se está no local certo (Tipo 2)
    new id = -1;
    for(new i=0; i < MAX_OFICINAS; i++)
    {
        if(OficinaInfo[i][oCriada] == 1 && OficinaInfo[i][oTipo] == 2)
        {
            if(IsPlayerInRangeOfPoint(playerid, 5.0, OficinaInfo[i][oX], OficinaInfo[i][oY], OficinaInfo[i][oZ]))
            {
                id = i;
                break;
            }
        }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao esta na Area de Tuning!");

    // Abre o Menu de Tuning que já tínhamos
    // Recriando o menu simples para garantir que funcione aqui
    new string[500];
    strcat(string, "1. Instalar Nitro (N10x)\n");
    strcat(string, "2. Suspensao a Ar (Hidraulica)\n");
    strcat(string, "3. Trocar Rodas\n");
    strcat(string, "4. Pintar Preto\n");
    strcat(string, "5. Pintar Branco\n");
    strcat(string, "6. Instalar Neon\n");
    strcat(string, "7. Remover Neon");

    ShowPlayerDialog(playerid, DIALOG_TUNING, DIALOG_STYLE_LIST, "Oficina - Tuning", string, "Aplicar", "Sair");
    return 1;
}

// --- CRIAR O LOCAL (ADMIN) ---
CMD:criardesmanche(playerid)
{
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Sem permissao.");

    // Procura vaga
    new id = -1;
    for(new i=0; i < MAX_DESMANCHES; i++)
    {
        if(DesmancheInfo[i][dsCriado] == 0)
        {
            id = i;
            break;
        }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Limite de desmanches atingido!");

    // Pega posição
    GetPlayerPos(playerid, DesmancheInfo[id][dsX], DesmancheInfo[id][dsY], DesmancheInfo[id][dsZ]);
    DesmancheInfo[id][dsCriado] = 1;

    // Salva no Arquivo
    new arquivo[64];
    format(arquivo, sizeof(arquivo), ARQUIVO_DESMANCHE, id);
    DOF2_CreateFile(arquivo);
    DOF2_SetFloat(arquivo, "X", DesmancheInfo[id][dsX]);
    DOF2_SetFloat(arquivo, "Y", DesmancheInfo[id][dsY]);
    DOF2_SetFloat(arquivo, "Z", DesmancheInfo[id][dsZ]);
    DOF2_SaveFile();

    // Cria o Texto
    new string[128];
    format(string, sizeof(string), "{FF0000}[ DESMANCHE ]\n{FFFFFF}Digite /desmanchar\nID: %d", id);
    DesmancheLabel[id] = Create3DTextLabel(string, 0xFFFFFFFF, DesmancheInfo[id][dsX], DesmancheInfo[id][dsY], DesmancheInfo[id][dsZ], 20.0, 0, 0);

    SendClientMessage(playerid, COR_VERDE_NEON, "Desmanche criado com sucesso!");
    return 1;
}

// --- DESMANCHAR O VEÍCULO (PLAYER) ---
CMD:desmanchar(playerid)
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COR_ERRO, "Voce precisa estar em um veiculo!");
    
    // Verifica local
    new id = -1;
    for(new i=0; i < MAX_DESMANCHES; i++)
    {
        if(DesmancheInfo[i][dsCriado] == 1)
        {
            if(IsPlayerInRangeOfPoint(playerid, 5.0, DesmancheInfo[i][dsX], DesmancheInfo[i][dsY], DesmancheInfo[i][dsZ]))
            {
                id = i;
                break;
            }
        }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao esta em um local de desmanche!");
    
    new veiculo = GetPlayerVehicleID(playerid);
    
    // AÇÃO
    RemovePlayerFromVehicle(playerid); 
    TogglePlayerControllable(playerid, 0); 
    
    // NOVA ANIMAÇÃO: Mecânico/CPR (Agachado mexendo no chão)
    // Loop = 1 (Repete), LockX/Y = 0 (Não anda), Time = 0 (Infinito até parar)
    ApplyAnimation(playerid, "MEDIC", "CPR", 4.1, 1, 0, 0, 0, 0, 1);
    
    SendClientMessage(playerid, COR_V_CLARO, "Desmanchando veiculo... Aguarde 10 segundos.");
    
    TimerDesmanche[playerid] = SetTimerEx("FinalizarDesmanche", 10000, false, "ii", playerid, veiculo);
    return 1;
}

forward FinalizarDesmanche(playerid, vehicleid);
public FinalizarDesmanche(playerid, vehicleid)
{
    TogglePlayerControllable(playerid, 1); 
    ClearAnimations(playerid); 
    
    DestroyVehicle(vehicleid); 
    
    // PREMIAÇÃO: APENAS DINHEIRO SUJO (Item ID 4)
    // Vamos dar 5000 de dinheiro sujo (configure a quantidade aqui)
    new quantidade = 5000;
    
    if(AddItemMochila(playerid, 4, quantidade))
    {
        new str[128];
        format(str, sizeof(str), "Sucesso! Voce recebeu %d de Dinheiro Sujo na mochila.", quantidade);
        SendClientMessage(playerid, COR_VERDE_NEON, str);
    }
    else
    {
        SendClientMessage(playerid, COR_ERRO, "Veiculo desmanchado, mas sua mochila estava cheia!");
    }
    
    return 1;
}

// --- GUARDAR COISAS (ARMAS) ---
CMD:malas(playerid)
{
    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Chegue perto de um carro!");
    
    // Abre Menu Principal
    ShowPlayerDialog(playerid, DIALOG_MALAS, DIALOG_STYLE_LIST, "Porta Malas", "1. Guardar Arma (Minha Mao)\n2. Pegar Arma (Do Carro)\n3. Ver O que tem dentro", "Selecionar", "Cancelar");
    
    // Salva o ID do carro na variável do player pra usar no Dialog
    SetPVarInt(playerid, "CarroMexendo", vehicleid); 
    return 1;
}

// --- ADMIN: CRIAR LOCAL ---
CMD:criarconce(playerid)
{
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    ConceX = x; ConceY = y; ConceZ = z;
    ConceCriada = 1;
    
    // Salva Local
    if(!DOF2_FileExists(ARQUIVO_CONCE_LOC)) DOF2_CreateFile(ARQUIVO_CONCE_LOC);
    DOF2_SetFloat(ARQUIVO_CONCE_LOC, "X", x);
    DOF2_SetFloat(ARQUIVO_CONCE_LOC, "Y", y);
    DOF2_SetFloat(ARQUIVO_CONCE_LOC, "Z", z);
    DOF2_SaveFile();
    
    // Cria visual
    if(ConcePickup) DestroyPickup(ConcePickup);
    if(IsValidDynamic3DTextLabel(ConceLabel)) DestroyDynamic3DTextLabel(ConceLabel); // Ou Delete3DTextLabel se for nativo
    
    ConcePickup = CreatePickup(1274, 1, x, y, z, -1);
    ConceLabel = Create3DTextLabel("{00FF00}[ CONCESSIONARIA ]\n{FFFFFF}Digite /comprarcarro", 0xFFFFFFFF, x, y, z, 20.0, 0, 0);
    
    SendClientMessage(playerid, COR_VERDE_NEON, "Concessionaria criada neste local!");
    return 1;
}

// --- ADMIN: COLOCAR CARRO ---
CMD:colocacar(playerid, params[])
{
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono.");
    if(TotalCarrosConce >= MAX_CARROS_CONCE) return SendClientMessage(playerid, COR_ERRO, "Estoque lotado! Max 50.");
    
    new modelo, preco, nome[32];
    if(sscanf(params, "iis[32]", modelo, preco, nome)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /colocacar [ID Modelo] [Preco] [Nome do Carro]");
    
    if(modelo < 400 || modelo > 611) return SendClientMessage(playerid, COR_ERRO, "ID de Veiculo invalido (400-611).");
    
    // Adiciona na memória
    new idx = TotalCarrosConce;
    ConceStock[idx][cModel] = modelo;
    ConceStock[idx][cPreco] = preco;
    format(ConceStock[idx][cNome], 32, nome);
    ConceStock[idx][cExiste] = 1;
    TotalCarrosConce++;
    
    // Salva no Arquivo
    if(!DOF2_FileExists(ARQUIVO_CONCE_STOCK)) DOF2_CreateFile(ARQUIVO_CONCE_STOCK);
    
    DOF2_SetInt(ARQUIVO_CONCE_STOCK, "Total", TotalCarrosConce);
    
    new key[32];
    format(key, 32, "Model_%d", idx);
    DOF2_SetInt(ARQUIVO_CONCE_STOCK, key, modelo);
    
    format(key, 32, "Preco_%d", idx);
    DOF2_SetInt(ARQUIVO_CONCE_STOCK, key, preco);
    
    format(key, 32, "Nome_%d", idx);
    DOF2_SetString(ARQUIVO_CONCE_STOCK, key, nome);
    
    DOF2_SaveFile();
    
    new msg[144];
    format(msg, sizeof(msg), "Veiculo %s adicionado a venda por R$ %d.", nome, preco);
    SendClientMessage(playerid, COR_VERDE_NEON, msg);
    return 1;
}

// --- PLAYER: ABRIR MENU ---
CMD:comprarcarro(playerid)
{
    if(ConceCriada == 0) return SendClientMessage(playerid, COR_ERRO, "A Concessionaria ainda nao foi criada.");
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, ConceX, ConceY, ConceZ)) return SendClientMessage(playerid, COR_ERRO, "Va ate a Concessionaria (Icone $ no mapa).");
    if(TotalCarrosConce == 0) return SendClientMessage(playerid, COR_ERRO, "Nenhum carro a venda no momento.");
    
    if(ConceAberta[playerid] == false)
    {
        ConceAberta[playerid] = true;
        ConceCarroAtual[playerid] = 0; // Começa no primeiro
        
        // --- AQUI ESTAVA O ERRO: USAR OS NOMES NOVOS ---
        CriarConcePremium(playerid);       // Nome novo
        AtualizarConcePremium(playerid);   // Nome novo
        // -----------------------------------------------
        
        SelectTextDraw(playerid, COR_VERDE_NEON);
    }
    return 1;
}

// CRIAR GARAGEM (Admin)
CMD:criargaragem(playerid)
{
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono.");
    
    // Procura slot
    new id = -1;
    for(new i=0; i < MAX_GARAGES; i++) { if(GarageInfo[i][gCriada] == 0) { id = i; break; } }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Limite atingido.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    GarageInfo[id][gCriada] = 1;
    GarageInfo[id][gX] = x; GarageInfo[id][gY] = y; GarageInfo[id][gZ] = z;
    
    // Salva
    new strArq[64];
    format(strArq, sizeof(strArq), PASTA_GARAGENS, id);
    DOF2_CreateFile(strArq);
    DOF2_SetFloat(strArq, "X", x);
    DOF2_SetFloat(strArq, "Y", y);
    DOF2_SetFloat(strArq, "Z", z);
    DOF2_SaveFile();
    
    // Cria visual
    GaragePickup[id] = CreatePickup(19134, 1, x, y, z, -1);
    GarageLabel[id] = Create3DTextLabel("{00BFFF}[ GARAGEM PUBLIC ]\n{FFFFFF}Aperte 'H' ou /garagem", 0xFFFFFFFF, x, y, z, 20.0, 0, 0);
    
    SendClientMessage(playerid, COR_VERDE_NEON, "Garagem criada com sucesso!");
    return 1;
}

// ABRIR GARAGEM (Player)
CMD:garagem(playerid, params[])
{
    // Verifica se está perto de alguma garagem
    new id = -1;
    for(new i=0; i < MAX_GARAGES; i++)
    {
        if(GarageInfo[i][gCriada] == 1)
        {
            if(IsPlayerInRangeOfPoint(playerid, 3.0, GarageInfo[i][gX], GarageInfo[i][gY], GarageInfo[i][gZ]))
            {
                id = i;
                break;
            }
        }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao esta em uma garagem!");
    
    if(GaragemAberta[playerid] == false)
    {
        VeiculoAtualGaragem[playerid] = 0;
        CriarGarageUI(playerid);
        AtualizarGarageUI(playerid);
        SelectTextDraw(playerid, 0x00BFFFFF); // Mouse Azul Ciano
    }
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    // ============================================================
    // 1. SISTEMA DE GARAGEM
    // ============================================================
    if(GaragemAberta[playerid])
    {
        if(playertextid == TD_Gar_BtnSair) { FecharGarageUI(playerid); return 1; }
        
        if(playertextid == TD_Gar_BtnAnt) 
        {
            VeiculoAtualGaragem[playerid]--;
            if(VeiculoAtualGaragem[playerid] < 0) VeiculoAtualGaragem[playerid] = MAX_PLAYER_VEHICLES-1;
            AtualizarGarageUI(playerid);
            return 1;
        }
        if(playertextid == TD_Gar_BtnProx) 
        {
            VeiculoAtualGaragem[playerid]++;
            if(VeiculoAtualGaragem[playerid] >= MAX_PLAYER_VEHICLES) VeiculoAtualGaragem[playerid] = 0;
            AtualizarGarageUI(playerid);
            return 1;
        }

        // --- RETIRAR VEÍCULO ---
        if(playertextid == TD_Gar_BtnSpawn)
        {
            new idx = VeiculoAtualGaragem[playerid];
            if(PlayerVehicles[playerid][idx][pvModelo] == 0) return SendClientMessage(playerid, COR_ERRO, "Espaco vazio!");
            if(PlayerVehicles[playerid][idx][pvSpawnadoID] > 0) return SendClientMessage(playerid, COR_ERRO, "Este veiculo ja esta na rua! Use Guardar primeiro.");
            
            new Float:x, Float:y, Float:z, Float:a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);
            
            new vid = CreateVehicle(PlayerVehicles[playerid][idx][pvModelo], x, y, z, a, PlayerVehicles[playerid][idx][pvCor1], PlayerVehicles[playerid][idx][pvCor2], -1);
            PutPlayerInVehicle(playerid, vid, 0);
            
            PlayerVehicles[playerid][idx][pvSpawnadoID] = vid; 
            
            SendClientMessage(playerid, COR_VERDE_NEON, "Veiculo retirado da garagem!");
            FecharGarageUI(playerid);
            return 1;
        }

        // --- GUARDAR VEÍCULO ---
        if(playertextid == TD_Gar_BtnStore)
        {
            new idx = VeiculoAtualGaragem[playerid];
            if(PlayerVehicles[playerid][idx][pvModelo] == 0) return SendClientMessage(playerid, COR_ERRO, "Espaco vazio!");
            
            new vid = PlayerVehicles[playerid][idx][pvSpawnadoID];
            if(vid == 0) return SendClientMessage(playerid, COR_ERRO, "Este veiculo ja esta guardado!");
            
            new Float:vx, Float:vy, Float:vz;
            GetVehiclePos(vid, vx, vy, vz);
            if(!IsPlayerInRangeOfPoint(playerid, 10.0, vx, vy, vz)) return SendClientMessage(playerid, COR_ERRO, "O veiculo esta muito longe para guardar!");

            DestroyVehicle(vid);
            PlayerVehicles[playerid][idx][pvSpawnadoID] = 0; 
            
            SendClientMessage(playerid, 0xFFFF00FF, "Veiculo guardado com sucesso.");
            AtualizarGarageUI(playerid); 
            return 1;
        }
    }

    #pragma tabsize 0 
    // ============================================================
    // 2. SISTEMA DE CONCESSIONÁRIA PREMIUM
    // ============================================================
    if(ConceAberta[playerid])
    {
        if(playertextid == TD_Shop_BtnSair) { FecharMenuConce(playerid); return 1; }

        if(playertextid == TD_Shop_BtnEsq)
        {
            ConceCarroAtual[playerid]--;
            if(ConceCarroAtual[playerid] < 0) ConceCarroAtual[playerid] = TotalCarrosConce - 1;
            AtualizarConcePremium(playerid);
            PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
            return 1;
        }

        if(playertextid == TD_Shop_BtnDir)
        {
            ConceCarroAtual[playerid]++;
            if(ConceCarroAtual[playerid] >= TotalCarrosConce) ConceCarroAtual[playerid] = 0;
            AtualizarConcePremium(playerid);
            PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
            return 1;
        }

        // BOTÃO COMPRAR
        if(playertextid == TD_Shop_BtnComp)
        {
            new idx = ConceCarroAtual[playerid];
            new preco = ConceStock[idx][cPreco];
            
            if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem dinheiro suficiente!");
            
            new slot = -1;
            for(new i=0; i < MAX_PLAYER_VEHICLES; i++)
            {
                if(PlayerVehicles[playerid][i][pvModelo] == 0) { slot = i; break; }
            }

            if(slot == -1) return SendClientMessage(playerid, COR_ERRO, "Sua garagem esta cheia! (Max 10 veiculos)");

            GivePlayerMoney(playerid, -preco);
            Player[playerid][pDinheiro] -= preco;

            PlayerVehicles[playerid][slot][pvModelo] = ConceStock[idx][cModel];
            PlayerVehicles[playerid][slot][pvPreco] = ConceStock[idx][cPreco];
            format(PlayerVehicles[playerid][slot][pvNome], 32, ConceStock[idx][cNome]);
            PlayerVehicles[playerid][slot][pvCor1] = 1; 
            PlayerVehicles[playerid][slot][pvCor2] = 1;
            PlayerVehicles[playerid][slot][pvSpawnadoID] = 0; 

            // Salva no Arquivo (DOF2)
            new nomePlayer[MAX_PLAYER_NAME], arquivoCarro[64];
            GetPlayerName(playerid, nomePlayer, sizeof(nomePlayer));
            format(arquivoCarro, sizeof(arquivoCarro), PASTA_VEICULOS, nomePlayer);
            if(!DOF2_FileExists(arquivoCarro)) DOF2_CreateFile(arquivoCarro);
            
            new key[32];
            format(key, 32, "Modelo_%d", slot); DOF2_SetInt(arquivoCarro, key, PlayerVehicles[playerid][slot][pvModelo]);
            format(key, 32, "Nome_%d", slot);   DOF2_SetString(arquivoCarro, key, PlayerVehicles[playerid][slot][pvNome]);
            format(key, 32, "Cor1_%d", slot);   DOF2_SetInt(arquivoCarro, key, 1);
            format(key, 32, "Cor2_%d", slot);   DOF2_SetInt(arquivoCarro, key, 1);
            DOF2_SetInt(arquivoCarro, "Total", MAX_PLAYER_VEHICLES);
            DOF2_SaveFile();

            new msg[144];
            format(msg, sizeof(msg), "Sucesso! Voce comprou %s por R$ %d. Ele esta na sua GARAGEM (/garagem).", ConceStock[idx][cNome], preco);
            SendClientMessage(playerid, COR_VERDE_NEON, msg);
            PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
            
            FecharMenuConce(playerid);
            return 1;
        }
    }

    // ============================================================
    // 3. SISTEMA DE LOCK PICK
    // ============================================================
    if(IsPicking[playerid] == true)
    {
        if(playertextid == TD_LockGame[playerid][3]) // Botão Girar
        {
            if(LockCursorX[playerid] >= LockAlvoX[playerid] && LockCursorX[playerid] <= (LockAlvoX[playerid] + 20.0))
            {
                SendClientMessage(playerid, COR_VERDE_NEON, "Sucesso! Voce destrancou o veiculo.");
                
                new engine, lights, alarm, doors, bonnet, boot, objective;
                new vid = LockPickCarro[playerid];
                GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
                SetVehicleParamsEx(vid, engine, lights, alarm, 0, bonnet, boot, objective); 
                
                GameTextForPlayer(playerid, "~g~Aberto", 2000, 3);
                ClearAnimations(playerid);
                FecharLockPick(playerid);
            }
            else
            {
                SendClientMessage(playerid, COR_ERRO, "Voce falhou e quebrou a micha!");
                GameTextForPlayer(playerid, "~r~Falhou", 2000, 3);
                ClearAnimations(playerid);
                FecharLockPick(playerid);
            }
            return 1;
        }
    }

    // ============================================================
    // 4. SISTEMA DE INVENTÁRIO (ATUALIZADO!)
    // ============================================================
    if(InvAberto[playerid] == true)
    {
        // A. CLIQUES NOS SLOTS
        for(new i=0; i < MAX_INV_SLOTS; i++)
        {
            if(playertextid == TD_InvSlotBG[playerid][i])
            {
                SlotSelecionado[playerid] = i; 
                AtualizarInventarioGrid(playerid); 
                return 1;
            }
        }

        // B. BOTÃO USAR (Verde - ID 6)
        if(playertextid == TD_InvUI[playerid][6])
        {
            new slot = SlotSelecionado[playerid];
            if(slot == -1 || InvItem[playerid][slot] == 0) return SendClientMessage(playerid, COR_ERRO, "Selecione um item valido primeiro!");

            if(InvItem[playerid][slot] == 4) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode 'usar' dinheiro sujo. Va ao lavador.");
            
            SendClientMessage(playerid, COR_VERDE_NEON, "Voce usou o item!");
            InvQtd[playerid][slot]--;
            if(InvQtd[playerid][slot] <= 0) InvItem[playerid][slot] = 0;
            AtualizarInventarioGrid(playerid);
            return 1;
        }

        // C. BOTÃO ENVIAR / TRANSFERIR (Azul - ID 7)
        if(playertextid == TD_InvUI[playerid][7])
        {
            new slot = SlotSelecionado[playerid];
            if(slot == -1 || InvItem[playerid][slot] == 0) return SendClientMessage(playerid, COR_ERRO, "Selecione um item valido primeiro!");

            // Abre o Dialog pedindo CPF
            ShowPlayerDialog(playerid, 1555, DIALOG_STYLE_INPUT, "Transferencia", 
                "Digite o CPF do cidadao para quem voce quer enviar este item:", 
                "Proximo", "Cancelar");
            return 1;
        }

        // D. BOTÃO DROP (Vermelho - ID 8)
        if(playertextid == TD_InvUI[playerid][8])
        {
            new slot = SlotSelecionado[playerid];
            if(slot == -1 || InvItem[playerid][slot] == 0) return SendClientMessage(playerid, COR_ERRO, "Selecione um item para dropar!");

            InvItem[playerid][slot] = 0; 
            InvQtd[playerid][slot] = 0;
            SlotSelecionado[playerid] = -1; 
            AtualizarInventarioGrid(playerid);
            SalvarInventario(playerid);
            return 1;
       
    return 0; // <--- ESTA CHAVE FALTAVA NO SEU CÓDIGO
}

stock ColocarNeon(vehicleid, modelo_neon)
{
    // 1. Remove neon anterior se tiver
    if(IsValidObject(NeonEsq[vehicleid])) DestroyObject(NeonEsq[vehicleid]);
    if(IsValidObject(NeonDir[vehicleid])) DestroyObject(NeonDir[vehicleid]);

    // 2. Se o modelo for 0, apenas remove e sai
    if(modelo_neon == 0) return 1;

    // 3. Cria os objetos
    NeonEsq[vehicleid] = CreateObject(modelo_neon, 0, 0, 0, 0, 0, 0);
    NeonDir[vehicleid] = CreateObject(modelo_neon, 0, 0, 0, 0, 0, 0);

    // 4. Gruda no carro (X, Y, Z, Rotação)
    // -0.8 = Esquerda, -0.60 = Altura (Debaixo do carro)
    AttachObjectToVehicle(NeonEsq[vehicleid], vehicleid, -0.8, 0.0, -0.60, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(NeonDir[vehicleid], vehicleid,  0.8, 0.0, -0.60, 0.0, 0.0, 0.0);
    
    return 1;
}

// --- CRIA O VISUAL DO MINIGAME ---
stock IniciarLockPick(playerid, vehicleid)
{
    IsPicking[playerid] = true;
    LockPickCarro[playerid] = vehicleid;
    
    // Define um alvo aleatório na barra (Entre a posição 250 e 350 da tela)
    // LockAlvoX[playerid] = 250.0 + random(100); 
    // LockCursorX[playerid] = 250.0; // Começa na esquerda
    LockDir[playerid] = true; // true = indo pra direita


    // Inicia a animação (Timer rápido)
    TimerLockPick[playerid] = SetTimerEx("AnimarLockPick", 50, true, "i", playerid);
    return 1;
}

// --- ANIMAÇÃO DA BARRA BRANCA ---
forward AnimarLockPick(playerid);
public AnimarLockPick(playerid)
{
    if(!IsPicking[playerid]) return KillTimer(TimerLockPick[playerid]);

    // Movimento do Cursor
    if(LockDir[playerid] == true) LockCursorX[playerid] += 8.0; // Velocidade indo
    else LockCursorX[playerid] -= 8.0; // Velocidade voltando

    // Batendo nas bordas (250 é inicio, 400 é fim)
    if(LockCursorX[playerid] >= 400.0) LockDir[playerid] = false;
    if(LockCursorX[playerid] <= 250.0) LockDir[playerid] = true;

    // Destroi e Recria o cursor na nova posição (Para dar ilusão de movimento)
    PlayerTextDrawDestroy(playerid, TD_LockGame[playerid][2]);
    
    TD_LockGame[playerid][2] = CreatePlayerTextDraw(playerid, LockCursorX[playerid], 295.0, "|");
    PlayerTextDrawAlignment(playerid, TD_LockGame[playerid][2], 2);
    PlayerTextDrawColor(playerid, TD_LockGame[playerid][2], -1); // Branco
    PlayerTextDrawFont(playerid, TD_LockGame[playerid][2], 1);
    PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][2], 0.5, 4.0);
    
    PlayerTextDrawShow(playerid, TD_LockGame[playerid][2]);
    return 1;
}

// --- FECHAR TUDO ---
stock FecharLockPick(playerid)
{
    IsPicking[playerid] = false;
    KillTimer(TimerLockPick[playerid]);
    CancelSelectTextDraw(playerid);
    for(new i=0; i < 5; i++) PlayerTextDrawDestroy(playerid, TD_LockGame[playerid][i]);
    return 1;
}

stock AtualizarConcePremium(playerid)
{
    new idx = ConceCarroAtual[playerid];
    
    // Atualiza Modelo 3D
    PlayerTextDrawSetPreviewModel(playerid, TD_Shop_Preview, ConceStock[idx][cModel]);
    PlayerTextDrawSetPreviewRot(playerid, TD_Shop_Preview, -15.0, 0.0, -25.0, 1.0);
    PlayerTextDrawSetPreviewVehCol(playerid, TD_Shop_Preview, 1, 1); // Branco padrão

    // Atualiza Textos
    PlayerTextDrawSetString(playerid, TD_Shop_Nome, ConceStock[idx][cNome]);
    
    new str[32];
    format(str, sizeof(str), "R$ %d", ConceStock[idx][cPreco]);
    PlayerTextDrawSetString(playerid, TD_Shop_Preco, str);

    // Mostra Tudo
    PlayerTextDrawShow(playerid, TD_Shop_Fundo);
    PlayerTextDrawShow(playerid, TD_Shop_Header);
    PlayerTextDrawShow(playerid, TD_Shop_Preview);
    PlayerTextDrawShow(playerid, TD_Shop_Nome);
    PlayerTextDrawShow(playerid, TD_Shop_Preco);
    PlayerTextDrawShow(playerid, TD_Shop_BtnEsq);
    PlayerTextDrawShow(playerid, TD_Shop_BtnDir);
    PlayerTextDrawShow(playerid, TD_Shop_BtnComp);
    PlayerTextDrawShow(playerid, TD_Shop_BtnSair);
    return 1;
}

stock FecharMenuConce(playerid)
{
    // Mesmo que a variável diga false, tentamos destruir para garantir
    ConceAberta[playerid] = false;
    CancelSelectTextDraw(playerid);
    
    PlayerTextDrawDestroy(playerid, TD_Shop_Fundo);
    PlayerTextDrawDestroy(playerid, TD_Shop_Header);
    PlayerTextDrawDestroy(playerid, TD_Shop_Preview);
    PlayerTextDrawDestroy(playerid, TD_Shop_Nome);
    PlayerTextDrawDestroy(playerid, TD_Shop_Preco);
    PlayerTextDrawDestroy(playerid, TD_Shop_BtnEsq);
    PlayerTextDrawDestroy(playerid, TD_Shop_BtnDir);
    PlayerTextDrawDestroy(playerid, TD_Shop_BtnComp);
    PlayerTextDrawDestroy(playerid, TD_Shop_BtnSair);
    return 1;
}

stock AtualizarGarageUI(playerid)
{
    new idx = VeiculoAtualGaragem[playerid];
    new modelo = PlayerVehicles[playerid][idx][pvModelo];

    if(modelo == 0) // Slot vazio
    {
        PlayerTextDrawSetPreviewModel(playerid, TD_Gar_Preview, 0); // Nada
        PlayerTextDrawSetString(playerid, TD_Gar_Nome, "Vazio");
        PlayerTextDrawSetString(playerid, TD_Gar_Status, " ");
    }
    else
    {
        // Tem Carro
        PlayerTextDrawSetPreviewModel(playerid, TD_Gar_Preview, modelo);
        PlayerTextDrawSetPreviewRot(playerid, TD_Gar_Preview, -15.0, 0.0, -25.0, 1.0);
        PlayerTextDrawSetPreviewVehCol(playerid, TD_Gar_Preview, PlayerVehicles[playerid][idx][pvCor1], PlayerVehicles[playerid][idx][pvCor2]);

        PlayerTextDrawSetString(playerid, TD_Gar_Nome, PlayerVehicles[playerid][idx][pvNome]);
        
        if(PlayerVehicles[playerid][idx][pvSpawnadoID] > 0)
        {
             PlayerTextDrawSetString(playerid, TD_Gar_Status, "~r~NA RUA (USE GUARDAR)");
        }
        else
        {
             PlayerTextDrawSetString(playerid, TD_Gar_Status, "~g~GUARDADO (USE RETIRAR)");
        }
    }

    // Mostra Tudo
    PlayerTextDrawShow(playerid, TD_Gar_Fundo);
    PlayerTextDrawShow(playerid, TD_Gar_Header);
    PlayerTextDrawShow(playerid, TD_Gar_Preview);
    PlayerTextDrawShow(playerid, TD_Gar_Nome);
    PlayerTextDrawShow(playerid, TD_Gar_Status);
    PlayerTextDrawShow(playerid, TD_Gar_BtnAnt);
    PlayerTextDrawShow(playerid, TD_Gar_BtnProx);
    PlayerTextDrawShow(playerid, TD_Gar_BtnSpawn);
    PlayerTextDrawShow(playerid, TD_Gar_BtnStore);
    PlayerTextDrawShow(playerid, TD_Gar_BtnSair);
    return 1;
}