// =============================================================================
//       BRASIL PLAY STREET (BPS) - VERSÃO HÍBRIDA (MySQL + DOF2)
//       DC (DISCORD) @Koongg444 Wpp (WhatsApp) 81985089075
// =============================================================================
#pragma tabsize 0
#pragma disablerecursion
#include <a_samp>
#include <DOF2>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <a_mysql>

// =============================================================================
//                            1. CONFIGURAÇÕES
// =============================================================================

// --- MYSQL (Contas e Toys) ---
#define SQL_HOST 
#define SQL_USER 
#define SQL_PASS 
#define SQL_DB   

new MySQL:Conexao;

// --- DEFINIÇÕES DE CORES ---
#define COR_V_CLARO     0x00FF00FF
#define COR_V_ESCURO    0x006400FF
#define COR_BRANCO      0xFFFFFFFF
#define COR_ERRO        0xFF0000FF
#define COR_STAFF       0x00D900FF
#define COR_GLOBAL      0x33AA33FF
#define COR_VERDE_NEON  0x00FF00FF
#define COR_VERDE_TEMA  0x00FF00FF
#define COR_VERDE_BOTAO 0x00AA00FF
#define COR_FUNDO_SOLIDO 0x111111FF
#define COR_ROSA_CHOQUE 0xFF1493AA 
#define HEX_ROSA        "{FF00DD}" 
#define COR_ROSA_AVISO  0xFF00DDAA
#define COR_AMARELO     0xFFFF00AA

// --- LIMITES ---
#define MAX_GARAGES     30
#define MAX_PLAYER_VEHICLES 10
#define MAX_ACESSORIOS  5
#define MAX_ORGS        30
#define MAX_DESMANCHES  50
#define MAX_MECANICAS   50
#define MAX_OFICINAS    20
#define MAX_INV_SLOTS   16
#define MAX_VEHICLE_SLOTS 3
#define MAX_CARROS_CONCE 50

// --- IDs DE DIALOGS ---
#define DIALOG_LOGIN 1000
#define DIALOG_REGISTRO 1001
#define DIALOG_CMDS 3
#define DIALOG_ORGS 4
#define DIALOG_PIX_ID 10
#define DIALOG_PIX_VALOR 11
#define DIALOG_TUNING 60
#define DIALOG_RODAS 61
#define DIALOG_NEON 62
#define DIALOG_MENUORG 999
#define DIALOG_MALAS 1500
#define DIALOG_MALAS_ACAO 1501
#define DIALOG_CRIAR_MEC 2000
#define DIALOG_MENU_MECANICO 2010
#define DIALOG_GPS_CAT 7701
#define DIALOG_GPS_LOC 7702
#define D_ACC_MENU 19000
#define D_ACC_LOJA 19001
#define D_ACC_OPCOES 19002
#define D_ACC_OSSO 19004
#define ITEM_DINHEIRO_SUJO 4

// --- CAMINHOS DE ARQUIVOS (DOF2) ---
#define PASTA_GARAGENS    "Garagens/Gar_%d.ini"
#define PASTA_VEICULOS    "Veiculos/%s.ini"
#define ARQUIVO_CATS      "GPS/Categorias.txt"
#define PASTA_ADMINS      "Admins/%s.ini"
#define PASTA_BANIDOS     "Banidos/%s.ini"
#define PASTA_BANIP       "BanidosIP/%s.ini"
#define PASTA_PRESOS      "Presos/%s.ini"
#define PASTA_CONTAS      "Contas/%s.ini" // (Ainda usado p/ backup ou soltar preso off)
#define PASTA_ORGS        "Orgs/%d.ini"
#define PASTA_OFICINAS    "Oficinas/Ofi_%d.ini"
#define ARQUIVO_ORGS      "Lideres.ini"
#define ARQUIVO_DESMANCHE "Desmanches/Desmanche_%d.ini"
#define ARQUIVO_CONCE_STOCK "Conce/Estoque.ini"
#define ARQUIVO_CONCE_LOC   "Conce/Local.ini"

// =============================================================================
//                            2. VARIÁVEIS GLOBAIS
// =============================================================================

enum pInfo {
    pSenha[129], pID, pDinheiro, pAdmin, pLevel, pVip, pSkin, pScore,
    pCpf, pBitcoin, pOrg, pLider, pMatou, pMorreu, pTempo,
    bool:pLogado
};
new Player[MAX_PLAYERS][pInfo];
new bool:IsLogged[MAX_PLAYERS];

// ACESSÓRIOS
enum eAcessorioInfo {
    tModel, tBone,
    Float:tX, Float:tY, Float:tZ,
    Float:tRX, Float:tRY, Float:tRZ,
    Float:tSX, Float:tSY, Float:tSZ,
    tSlotOcupado
}
new PlayerToys[MAX_PLAYERS][MAX_ACESSORIOS][eAcessorioInfo];
new EditandoSlot[MAX_PLAYERS];
new bool:EditorAberto[MAX_PLAYERS];
new EditandoModo[MAX_PLAYERS];
new Float:EditStep[MAX_PLAYERS];

// VARIÁVEIS DE SISTEMA
new bool:Trabalhando[MAX_PLAYERS];
new bool:AdminTrabalhando[MAX_PLAYERS];
new InviteOrg[MAX_PLAYERS];
new TempGPS_Categoria[MAX_PLAYERS][64];
new CheckpointAtivo[MAX_PLAYERS];
new TimerVelocimetro;
new pPaydayTempo[MAX_PLAYERS];
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
new Text3D:TagCPF[MAX_PLAYERS];

// --- CORREÇÃO DO MAPA (VERSÃO STREAMER) ---
#define ObjectMaterial SetDynamicObjectMaterial
#define ObjectMaterialText SetDynamicObjectMaterialText
new tmpobjid;
new TuningShop[78];
new object_world = -1, object_int = -1;

// ARRAYS E ENUMS (DOF2)
enum gInfo { Float:gX, Float:gY, Float:gZ, gCriada }
new GarageInfo[MAX_GARAGES][gInfo];
new Text3D:GarageLabel[MAX_GARAGES];
new GaragePickup[MAX_GARAGES];

enum pVehInfo { pvModelo, pvPreco, pvCor1, pvCor2, pvSpawnadoID, pvNome[32] }
new PlayerVehicles[MAX_PLAYERS][MAX_PLAYER_VEHICLES][pVehInfo];

new Text3D:TagAdmin[MAX_PLAYERS];

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

new const NomeMeses[12][10] = { "JANEIRO", "FEVEREIRO", "MARCO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO" };

#define ORG_MECANICA_ID 1
#define ITEM_MOTOR 5
#define ITEM_CHASSI 6
#define ITEM_RODAS 7

// MACROS
#define VerificarAdmin(%0,%1) if(Player[%0][pAdmin] < %1) return SendClientMessage(%0, COR_ERRO, "Voce nao tem permissao para usar este comando.")
#define VerificarTra(%0) if(!Trabalhando[%0] && Player[%0][pAdmin] < 6) return SendClientMessage(%0, COR_ERRO, "Voce precisa estar em modo de trabalho! Use /tra.")

// FORWARDS
forward cmd_mochila(playerid, params[]);
forward cmd_celular(playerid, params[]);
forward cmd_tuning(playerid, params[]);
forward cmd_malas(playerid, params[]);
forward RelogioPayday();
forward AtualizarVelocimetroGlobal();
forward AnimarLockPick(playerid);
forward FinalizarDesmanche(playerid, vehicleid);
forward TocarMusicaLogin(playerid);
forward VerificarConta(playerid);
forward AoCriarConta(playerid);
forward FinalizarCarregamento(playerid);
forward CarregarConta(playerid);
forward OnToysCarregados(playerid);
forward OnDebugSalvar(playerid, slot);
forward OnAbrirLojaMySQL(playerid);
forward AtualizarRodape();
forward OnAcessoriosCarregados(playerid);
forward OnToysSalvos();
forward ForcarSkinCorreta(playerid);

main()
{
	print("-----------------------------------");
	print(" Brasil Play Street - v1.0 COMPLETO");
	print("-----------------------------------");
}

public OnGameModeInit()
{
    //ShowNameTags(0);
    
    
    SetTimer("AtualizarRodape", 1000, true);
    TimerVelocimetro = SetTimer("AtualizarVelocimetroGlobal", 200, true);
    SetTimer("RelogioPayday", 60000, true);

    // --- CARREGAR ORGS/FACS (NOVO SISTEMA MYSQL) ---
    // Substituiu o antigo loop de arquivos "PASTA_ORGS"
    CarregarOrgsMySQL();

    // --- CARREGAR OFICINAS (AINDA EM DOF2) ---
    for(new i=0; i < MAX_OFICINAS; i++)
    {
        new strArq[64];
        format(strArq, sizeof(strArq), PASTA_OFICINAS, i);
        if(DOF2_FileExists(strArq))
        {
            OficinaInfo[i][oCriada] = 1;
            OficinaInfo[i][oTipo] = DOF2_GetInt(strArq, "Tipo");
            OficinaInfo[i][oX] = DOF2_GetFloat(strArq, "X");
            OficinaInfo[i][oY] = DOF2_GetFloat(strArq, "Y");
            OficinaInfo[i][oZ] = DOF2_GetFloat(strArq, "Z");
            
            OficinaPickup[i] = CreatePickup(3096, 1, OficinaInfo[i][oX], OficinaInfo[i][oY], OficinaInfo[i][oZ], -1);
            
            new label[128];
            if(OficinaInfo[i][oTipo] == 1) format(label, 128, "{00FF00}[ MECANICA - REPARO ]");
            else format(label, 128, "{00FFFF}[ MECANICA - TUNING ]");
            
            OficinaLabel[i] = Create3DTextLabel(label, 0xFFFFFFFF, OficinaInfo[i][oX], OficinaInfo[i][oY], OficinaInfo[i][oZ], 20.0, 0, 0);
        }
    }

    // --- CARREGAR GARAGENS (AINDA EM DOF2) ---
    for(new i=0; i < MAX_GARAGES; i++)
    {
        new strArq[64];
        format(strArq, sizeof(strArq), PASTA_GARAGENS, i);
        if(DOF2_FileExists(strArq))
        {
            GarageInfo[i][gCriada] = 1;
            GarageInfo[i][gX] = DOF2_GetFloat(strArq, "X");
            GarageInfo[i][gY] = DOF2_GetFloat(strArq, "Y");
            GarageInfo[i][gZ] = DOF2_GetFloat(strArq, "Z");
            
            GaragePickup[i] = CreatePickup(19134, 1, GarageInfo[i][gX], GarageInfo[i][gY], GarageInfo[i][gZ], -1);
            GarageLabel[i] = Create3DTextLabel("{00BFFF}[ GARAGEM PUBLIC ]", 0xFFFFFFFF, GarageInfo[i][gX], GarageInfo[i][gY], GarageInfo[i][gZ], 20.0, 0, 0);
        }
    }

    // --- CARREGAR DESMANCHES (AINDA EM DOF2) ---
    new arquivo[64], string[128];
    for(new i=0; i < MAX_DESMANCHES; i++)
    {
        format(arquivo, sizeof(arquivo), ARQUIVO_DESMANCHE, i);
        if(DOF2_FileExists(arquivo))
        {
            DesmancheInfo[i][dsCriado] = 1;
            DesmancheInfo[i][dsX] = DOF2_GetFloat(arquivo, "X");
            DesmancheInfo[i][dsY] = DOF2_GetFloat(arquivo, "Y");
            DesmancheInfo[i][dsZ] = DOF2_GetFloat(arquivo, "Z");
            
            format(string, sizeof(string), "{FF0000}[ DESMANCHE ]\nID: %d", i);
            DesmancheLabel[i] = Create3DTextLabel(string, 0xFFFFFFFF, DesmancheInfo[i][dsX], DesmancheInfo[i][dsY], DesmancheInfo[i][dsZ], 20.0, 0, 0);
        }
    }

    // --- CARREGAR CONCESSIONÁRIA ---
    if(DOF2_FileExists(ARQUIVO_CONCE_LOC))
    {
        ConceX = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "X");
        ConceY = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "Y");
        ConceZ = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "Z");
        ConceCriada = 1;
        
        ConcePickup = CreatePickup(1274, 1, ConceX, ConceY, ConceZ, -1); 
        ConceLabel = Create3DTextLabel("{00FF00}[ CONCESSIONARIA ]", 0xFFFFFFFF, ConceX, ConceY, ConceZ, 20.0, 0, 0);
    }

    // Carregar Estoque
    if(DOF2_FileExists(ARQUIVO_CONCE_STOCK))
    {
        TotalCarrosConce = DOF2_GetInt(ARQUIVO_CONCE_STOCK, "Total");
        for(new i=0; i < TotalCarrosConce; i++)
        {
            new key[32];
            format(key, 32, "Model_%d", i); ConceStock[i][cModel] = DOF2_GetInt(ARQUIVO_CONCE_STOCK, key);
            format(key, 32, "Preco_%d", i); ConceStock[i][cPreco] = DOF2_GetInt(ARQUIVO_CONCE_STOCK, key);
            format(key, 32, "Nome_%d", i); strmid(ConceStock[i][cNome], DOF2_GetString(ARQUIVO_CONCE_STOCK, key), 0, 32, 32);
            ConceStock[i][cExiste] = 1;
        }
    }


    // =========================================================================
    // 4. MAPAS E OBJETOS
    // =========================================================================
    SetGameModeText("BPS v1.0");
    AddPlayerClass(0, 1481.0, -1771.0, 13.0, 0.0, 0, 0, 0, 0, 0, 0);

    // CARREGAR GARAGENS
    for(new i=0; i < MAX_GARAGES; i++)
    {
        new strArq[64];
        format(strArq, sizeof(strArq), PASTA_GARAGENS, i);
        if(DOF2_FileExists(strArq))
        {
            GarageInfo[i][gCriada] = 1;
            GarageInfo[i][gX] = DOF2_GetFloat(strArq, "X");
            GarageInfo[i][gY] = DOF2_GetFloat(strArq, "Y");
            GarageInfo[i][gZ] = DOF2_GetFloat(strArq, "Z");
            
            GaragePickup[i] = CreatePickup(19134, 1, GarageInfo[i][gX], GarageInfo[i][gY], GarageInfo[i][gZ], -1); // Cone/Icone
            GarageLabel[i] = Create3DTextLabel("{00BFFF}[ GARAGEM PUBLIC ]\n{FFFFFF}Aperte 'H' ou /garagem", 0xFFFFFFFF, GarageInfo[i][gX], GarageInfo[i][gY], GarageInfo[i][gZ], 20.0, 0, 0);
        }
    }


    // 1. TIMER DO VELOCÍMETRO
    TimerVelocimetro = SetTimer("AtualizarVelocimetroGlobal", 200, true);

    // 2. CARREGAR DESMANCHES
    // Crie a pasta "Desmanches" nas suas scriptfiles se não tiver!
    for(new i=0; i < MAX_DESMANCHES; i++)
    {
        format(arquivo, sizeof(arquivo), ARQUIVO_DESMANCHE, i);
        if(DOF2_FileExists(arquivo))
        {
            DesmancheInfo[i][dsCriado] = 1;
            DesmancheInfo[i][dsX] = DOF2_GetFloat(arquivo, "X");
            DesmancheInfo[i][dsY] = DOF2_GetFloat(arquivo, "Y");
            DesmancheInfo[i][dsZ] = DOF2_GetFloat(arquivo, "Z");
            
            format(string, sizeof(string), "{FF0000}[ DESMANCHE ]\n{FFFFFF}Digite /desmanchar\nID: %d", i);
            DesmancheLabel[i] = Create3DTextLabel(string, 0xFFFFFFFF, DesmancheInfo[i][dsX], DesmancheInfo[i][dsY], DesmancheInfo[i][dsZ], 20.0, 0, 0);
        }
    }
    

    // 4. CARREGAR CONCESSIONÁRIA (O Código novo entra aqui!)
    if(DOF2_FileExists(ARQUIVO_CONCE_LOC))
    {
        ConceX = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "X");
        ConceY = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "Y");
        ConceZ = DOF2_GetFloat(ARQUIVO_CONCE_LOC, "Z");
        ConceCriada = 1;
        
        ConcePickup = CreatePickup(1274, 1, ConceX, ConceY, ConceZ, -1); 
        ConceLabel = Create3DTextLabel("{00FF00}[ CONCESSIONARIA ]\n{FFFFFF}Digite /comprarcarro", 0xFFFFFFFF, ConceX, ConceY, ConceZ, 20.0, 0, 0);
    }

    if(DOF2_FileExists(ARQUIVO_CONCE_STOCK))
    {
        TotalCarrosConce = DOF2_GetInt(ARQUIVO_CONCE_STOCK, "Total");
        for(new i=0; i < TotalCarrosConce; i++)
        {
            new key[32];
            format(key, 32, "Model_%d", i);
            ConceStock[i][cModel] = DOF2_GetInt(ARQUIVO_CONCE_STOCK, key);
            
            format(key, 32, "Preco_%d", i);
            ConceStock[i][cPreco] = DOF2_GetInt(ARQUIVO_CONCE_STOCK, key);
            
            format(key, 32, "Nome_%d", i);
            strmid(ConceStock[i][cNome], DOF2_GetString(ARQUIVO_CONCE_STOCK, key), 0, 32, 32);
            
            ConceStock[i][cExiste] = 1;
        }
        printf("[CONCE] Carregados %d veiculos.", TotalCarrosConce);
    }
    
    // 5. CONFIGURAÇÕES GERAIS E ORGS
    SetGameModeText("BPS v1.0");
    AddPlayerClass(0, 1481.0, -1771.0, 13.0, 0.0, 0, 0, 0, 0, 0, 0);
    
    // Se não existir arquivo de lideres, cria
    if(!DOF2_FileExists(ARQUIVO_ORGS))
    {
        DOF2_CreateFile(ARQUIVO_ORGS);
        DOF2_SetString(ARQUIVO_ORGS, "LiderPM", "Ninguem");
        DOF2_SaveFile();
    }
    
    CarregarOrgsMySQL();

    // 6. MAPAS E TEXTURAS (Se tiver mapas novos, cole ABAIXO desta linha)
    // CreateObject(...);
    // CreateDynamicObject(...);
    
    // --- LIGAR O RELÓGIO DO PAYDAY (Roda a cada 1 minuto) ---
    SetTimer("RelogioPayday", 60000, true); // 60000ms = 1 minuto

	return 1;
}

public OnGameModeExit()
{
    // Salva e fecha o sistema de arquivos (DOF2)
    DOF2_Exit();

    // Fecha a conex�o com o Banco de Dados (Evita erros de "Too many connections")
    if(Conexao != MYSQL_INVALID_HANDLE)
    {
        mysql_close(Conexao);
    }

    // Para o timer global do veloc�metro
    KillTimer(TimerVelocimetro);

    return 1;
}

public OnPlayerConnect(playerid)
{
    // --- LIMPEZA GERAL (Obrigatório) ---
    IsLogged[playerid] = false;
    
    // Zera o dinheiro visual e da variável
    ResetPlayerMoney(playerid);
    Player[playerid][pDinheiro] = 0; 

    // Zera os acessórios na memória
    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        PlayerToys[playerid][i][tSlotOcupado] = 0;
        PlayerToys[playerid][i][tModel] = 0;
    }
    
    
    // --- ADICIONE ISTO AQUI NO TOPO ---
    new nome[MAX_PLAYER_NAME];
    new ip[16];
    GetPlayerName(playerid, nome, sizeof(nome));
    GetPlayerIp(playerid, ip, sizeof(ip));
    // ----------------------------------
    // PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][2], "Registro");
    // PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][0], "Andrade");
    // PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][1], "Digite_sua_senha");
    // // Carregar Veículos (Mantido seu código DOF2)
    // new arquivo[64];
    // format(arquivo, sizeof(arquivo), PASTA_VEICULOS, nome);
    
    // for(new i=0; i < MAX_PLAYER_VEHICLES; i++)
    // {
    //     PlayerVehicles[playerid][i][pvModelo] = 0;
    //     PlayerVehicles[playerid][i][pvSpawnadoID] = 0; 
    // }

    // if(DOF2_FileExists(arquivo))
    // {
    //     new total = DOF2_GetInt(arquivo, "Total");
    //     for(new i=0; i < total; i++)
    //     {
    //         new key[32];
    //         format(key, 32, "Modelo_%d", i);
    //         PlayerVehicles[playerid][i][pvModelo] = DOF2_GetInt(arquivo, key);
            
    //         format(key, 32, "Nome_%d", i);
    //         strmid(PlayerVehicles[playerid][i][pvNome], DOF2_GetString(arquivo, key), 0, 32, 32);
            
    //         format(key, 32, "Cor1_%d", i);
    //         PlayerVehicles[playerid][i][pvCor1] = DOF2_GetInt(arquivo, key);
            
    //         format(key, 32, "Cor2_%d", i);
    //         PlayerVehicles[playerid][i][pvCor2] = DOF2_GetInt(arquivo, key);
    //     }
    // }

    // // Zera Variáveis
    // AdminTrabalhando[playerid] = false;
    // CelularAberto[playerid] = false; 
    // BancoAberto[playerid] = false;   
    // Player[playerid][pTempo] = 0;    
    // InvAberto[playerid] = false;
    // SlotSelecionado[playerid] = -1;  

    // CriarCelular(playerid); 

    // for (new i = 0; i < 20; i++) SendClientMessage(playerid, -1, " ");
    
    // // MOSTRAR TELA DE LOGIN
 
    // // Ýcones do Mapa
    // for(new i=1; i < MAX_ORGS; i++)
    // {
    //     if(OrgInfo[i][oCriada] == 1)
    //     {
    //         SetPlayerMapIcon(playerid, i, OrgInfo[i][oX], OrgInfo[i][oY], OrgInfo[i][oZ], 31, 0, MAPICON_GLOBAL);
    //     }
    // }

    // SetTimerEx("TocarMusicaLogin", 2000, false, "i", playerid);

    // // === AQUI ESTÝ A MÝGICA: VERIFICAR NO MYSQL ===
    // // Pergunta ao banco se esse nome já existe
    // new query[128];
    // mysql_format(Conexao, query, sizeof(query), "SELECT senha FROM contas WHERE nome = '%e' LIMIT 1", nome);
    // mysql_tquery(Conexao, query, "VerificarConta", "d", playerid);    
    // === REMOÇÃO DE OBJETOS DO MAPA (COMEÇO) ===
        

        //     Player::DeleteCPFtag(playerid);
//     Player::SaveAllData();
//     Player::Clear();

//     // 2. Limpa os acessórios visuais para não bugar o próximo player
//     for(new i=0; i < MAX_ACESSORIOS; i++)
//     {
//         if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
//     }

//     // 3. Marca como deslogado
//     IsLogged[playerid] = false;
    
// // Destruir carros do player ao sair
//     for(new i=0; i < MAX_PLAYER_VEHICLES; i++)
//     {
//         if(PlayerVehicles[playerid][i][pvSpawnadoID] > 0)
//         {
//             DestroyVehicle(PlayerVehicles[playerid][i][pvSpawnadoID]);
//             PlayerVehicles[playerid][i][pvSpawnadoID] = 0;
//         }
//     }

//     if(IsPicking[playerid]) FecharLockPick(playerid);
//     if(IsLogged[playerid]) SalvarConta(playerid);

// 	return 1;
// }

// stock Player::SetPlayerLogin(playerid)
// {
//     TogglePlayerSpectating(playerid, true);

    
// }

// stock Player::Clear(playerid)
// {
//     Player[playerid][P_UID] = 0;;
//     Player[playerid][P_PASS] = '\0';
//     Player[playerid][P_PAYDAY_TMP] = 0;
//     Player[playerid][P_CPF] = '\0';
//     Player[playerid][P_BITCOIN] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_MONEY] = 0;
//     Player[playerid][p_ADM_LVL] = 0;
//     Player[playerid][P_SCORE] = 0;
//     Player[playerid][P_VIP_LVL] = 0;
//     Player[playerid][P_SKIN_ID] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_IS_LEADER] = 0;
// }

// stock ACS::Clear(playerid)
// {
//     Player[playerid][P_UID] = 0;;
//     Player[playerid][P_PASS] = '\0';
//     Player[playerid][P_PAYDAY_TMP] = 0;
//     Player[playerid][P_CPF] = '\0';
//     Player[playerid][P_BITCOIN] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_MONEY] = 0;
//     Player[playerid][p_ADM_LVL] = 0;
//     Player[playerid][P_SCORE] = 0;
//     Player[playerid][P_VIP_LVL] = 0;
//     Player[playerid][P_SKIN_ID] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_IS_LEADER] = 0;
// }

// stock INV::Clear(playerid)
// {
//     Player[playerid][P_UID] = 0;;
//     Player[playerid][P_PASS] = '\0';
//     Player[playerid][P_PAYDAY_TMP] = 0;
//     Player[playerid][P_CPF] = '\0';
//     Player[playerid][P_BITCOIN] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_MONEY] = 0;
//     Player[playerid][p_ADM_LVL] = 0;
//     Player[playerid][P_SCORE] = 0;
//     Player[playerid][P_VIP_LVL] = 0;
//     Player[playerid][P_SKIN_ID] = 0;
//     Player[playerid][P_ORGID] = 0;
//     Player[playerid][P_IS_LEADER] = 0;
// }

// public OnPaydayReach(playerid)
// {
//     if(Player[playerid][P_IS_LOGGED])
//         return 1;

//     new payment = 1500, bonus = 0;
                
//     if(Player[playerid][P_ORGID] > 0) bonus = 1200;
//     if(Player[playerid][P_ADMIN_LVL] > 0)  bonus += 500;

//     new total = payment + bonus;
    
//     Player[playerid][P_MONEY] += total;

//     SetPlayerScore(playerid, Player[playerid][P_SCORE] + 1);
//     Player[playerid][P_SCORE] = GetPlayerScore(playerid);

//     Player::SaveData(playerid);
    
//     SendClientMessage(playerid, COR_V_CLARO, "|__________________ PAYDAY BPS __________________|");
//     SendClientMessage(playerid, -1, "Você recebeu seu pagamento por jogar 1 hora! :)");
    
//     new str[128];
//     format(str, sizeof(str), "Salário Base: R$ %d | Bonus Org/Admin: R$ %d", payment, bonus);
//     SendClientMessage(playerid, -1, str);
    
//     format(str, sizeof(str), "{00FF00}TOTAL RECEBIDO: R$ %d  |  +1 RESPECT (Nivel)", total);
//     SendClientMessage(playerid, -1, str);
//     SendClientMessage(playerid, COR_V_CLARO, "|________________________________________________|");
    
//     PlayerPlaySound(i, 1052, 0.0, 0.0, 0.0);

//     Player::UpdateRodape(playerid);
        
//     return 1;
// }

// stock Player::UpdateRodape(playerid)
// {
//     timestamp = Player[playerid][P_PAYDAY_TMP];

//     TimestampToTime(timestamp, hour, minute, second, -3);

//     new str[64];
//     format(str, sizeof(str), "CPF:%d  ~y~BtCoin:%d  ~w~RECOMPENSA ÀS: %02d:%02d:%02d", 
//         Player[i][P_CPF], Player[i][P_BITCOIN], hour, minute, second);

//     PlayerTextDrawSetString(i, PTD_Stats[i], str);
// }

// stock Player::CreateCPFtag(playerid)
// {
//     if(IsValidDynamic3DTextLabel(Player[playerid][P_CPF_TAG]))
//         return;
//     if(isnull(Player[playerid][P_CFP]))
//         return;
//     if(!Player[playerid][P_IS_LOGGED])
//         return;

//     new str[64];

//     format(str, sizeof(str), "{00BFFF}CPF: {FFFFFF}%d", Player[playerid][P_CPF]);

//     Player[playerid][P_CPF_TAG] = Create3DTextLabel(str, -1, 0.0, 0.0, 0.0, 20.0, 0, 1);
//     Attach3DTextLabelToPlayer(Player[playerid][P_CPF_TAG], playerid, 0.0, 0.0, 0.4);
// }

// stock Player::DeleteCPFtag(playerid)
// {
//     if(!IsValidDynamic3DTextLabel(Player[playerid][P_CPF_TAG])) 
//         return 1;

//     DestroyDynamic3DTextLabel(Player[playerid][P_CPF_TAG]);
//     Player[playerid][P_CPF_TAG] = INVALID_3DTEXT_ID;

//     return 1;
// }

// stock Player::UpdateCPFtag(playerid)
// {
//     if(!IsValidDynamic3DTextLabel(Player[playerid][P_CPF_TAG])) 
//         return 1;
    
//     if(Player[playerid][P_IS_LOGGED] && IsPlayerSpawned(playerid))
//         return;

//     new str[64];
//     format(str, sizeof(str), "{00BFFF}CPF: {FFFFFF}%d", Player[playerid][P_CPF]);
//     UpdateDynamic3DTextLabelText(Player[playerid][P_CPF_TAG], -1, str);

//     return 1;
// }
    ////////////////////////////////// Spawn LS //////////////////////////////////
    
////////////////////////////////// PRAÇA HP//////////////////////////////////
    
////////////////////////////////// MECANICA //////////////////////////////////

////////////////////////////////// MECANICA LS 2//////////////////////////////////
 
 #include <YSI\YSI_Coding\y_hooks>

#define GUI::   gui_
#define HUD::   hud_
#define MAX_INV_SLOTS (3)

    /* EDITOR DE ACESSÓRIOS */
new Text:TD_Edit_Fundo; 
new Text:TD_Edit_Botoes[10];
new PlayerText:PTD_Edit_Info[MAX_PLAYERS];

    /* CELULAR */
new PlayerText:Celular[MAX_PLAYERS][20];

    /* INVENTÁRIO */
new PlayerText:TD_InvUI[MAX_PLAYERS][12];
new PlayerText:TD_InvSlotBG[MAX_PLAYERS][MAX_INV_SLOTS];
new PlayerText:TD_InvSlotItem[MAX_PLAYERS][MAX_INV_SLOTS];
new PlayerText:TD_InvSlotQtd[MAX_PLAYERS][MAX_INV_SLOTS];

    /* LOCK PICK GAME */
new PlayerText:TD_LockGame[MAX_PLAYERS][5];

    /* GARAGEM */
new PlayerText:TD_Gar_Fundo; 
new PlayerText:TD_Gar_Header; 
new PlayerText:TD_Gar_Preview;
new PlayerText:TD_Gar_Nome; 
new PlayerText:TD_Gar_Status;
new PlayerText:TD_Gar_BtnSpawn; 
new PlayerText:TD_Gar_BtnStore; 
new PlayerText:TD_Gar_BtnProx; 
new PlayerText:TD_Gar_BtnAnt; 
new PlayerText:TD_Gar_BtnSair;

    /* LOJA */
new PlayerText:TD_Shop_Fundo; 
new PlayerText:TD_Shop_Header; 
new PlayerText:TD_Shop_Preview;
new PlayerText:TD_Shop_Nome; 
new PlayerText:TD_Shop_Preco;
new PlayerText:TD_Shop_BtnEsq; 
new PlayerText:TD_Shop_BtnDir; 
new PlayerText:TD_Shop_BtnComp; 
new PlayerText:TD_Shop_BtnSair;

    /* LOGIN */
new Text:TD_Login_Fundo; 
new Text:TD_Login_LogoPequena; 
new Text:TD_Login_LogoGrande;
new Text:TD_Login_BoxUser; 
new Text:TD_Login_BoxSenha; 
new Text:TD_Login_IconUser; 
new Text:TD_Login_IconPass;
new Text:TD_Login_BtnConectar;
new Text:TD_Login_BtnCriar; 
new Text:TD_Login_Esqueci;
new PlayerText:PTD_Login_Nome[MAX_PLAYERS];

    /* BANCO */
new Text:TD_BancoFundo; 
new Text:TD_BancoTitulo; 
new Text:TD_BtnPix; 
new Text:TD_BtnSair; 
new PlayerText:PTD_Saldo[MAX_PLAYERS];
    ///================= MAP NUBANK ===================
    
//////////=========REMOVER PRAÇA=========//////////
    
    // === REMOÇÃO DE OBJETOS DO MAPA (FIM) ===
    
    // Zera variáveis importantes ao conectar
    LimparDados(playerid);
    IsLogged[playerid] = false;
    
    // -------------------------------------------------------------------------
    //                          SISTEMA DE ACESSÓRIOS
    // -------------------------------------------------------------------------

    EditandoModo[playerid] = 0;

    // Esconde nick de admins trabalhando
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Trabalhando[i])
        {
            ShowPlayerNameTagForPlayer(playerid, i, 0); 
        }
    }
    
    // --- VERIFICAR BANIMENTO (Mantido DOF2 por enquanto, como você pediu) ---
    new arqBan[64], arqIp[64];
    
    format(arqBan, sizeof(arqBan), PASTA_BANIDOS, nome);
    if(DOF2_FileExists(arqBan))
    {
        new motivo[64], admin[24];
        strmid(motivo, DOF2_GetString(arqBan, "Motivo"), 0, 64, 64);
        strmid(admin, DOF2_GetString(arqBan, "Admin"), 0, 24, 24);
        
        new str[200];
        format(str, sizeof(str), "{FF0000}BANIDO!\n{FFFFFF}Voce esta banido deste servidor.\nAdmin: %s\nMotivo: %s", admin, motivo);
        ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "Banimento", str, "Fechar", "");
        Kick(playerid); 
        return 0; 
    }
    
    format(arqIp, sizeof(arqIp), PASTA_BANIP, ip);
    if(DOF2_FileExists(arqIp))
    {
        SendClientMessage(playerid, 0xFF0000AA, "SEU IP ESTA BANIDO DESTE SERVIDOR!");
        Kick(playerid);
        return 0;
    }
    
    // --- LÓGICA DE LOGIN/INTERFACE ---
    TogglePlayerSpectating(playerid, 1);

    // Carregar Veículos (Mantido seu código DOF2)
    new arquivo[64];
    format(arquivo, sizeof(arquivo), PASTA_VEICULOS, nome);
    
    for(new i=0; i < MAX_PLAYER_VEHICLES; i++)
    {
        PlayerVehicles[playerid][i][pvModelo] = 0;
        PlayerVehicles[playerid][i][pvSpawnadoID] = 0; 
    }

    if(DOF2_FileExists(arquivo))
    {
        new total = DOF2_GetInt(arquivo, "Total");
        for(new i=0; i < total; i++)
        {
            new key[32];
            format(key, 32, "Modelo_%d", i);
            PlayerVehicles[playerid][i][pvModelo] = DOF2_GetInt(arquivo, key);
            
            format(key, 32, "Nome_%d", i);
            strmid(PlayerVehicles[playerid][i][pvNome], DOF2_GetString(arquivo, key), 0, 32, 32);
            
            format(key, 32, "Cor1_%d", i);
            PlayerVehicles[playerid][i][pvCor1] = DOF2_GetInt(arquivo, key);
            
            format(key, 32, "Cor2_%d", i);
            PlayerVehicles[playerid][i][pvCor2] = DOF2_GetInt(arquivo, key);
        }
    }

    // Zera Variáveis
    AdminTrabalhando[playerid] = false;
    CelularAberto[playerid] = false; 
    BancoAberto[playerid] = false;   
    Player[playerid][pTempo] = 0;    
    InvAberto[playerid] = false;
    SlotSelecionado[playerid] = -1;  

    CriarCelular(playerid); 

    for (new i = 0; i < 20; i++) SendClientMessage(playerid, -1, " ");
    
    // MOSTRAR TELA DE LOGIN
 
    // Ícones do Mapa
    for(new i=1; i < MAX_ORGS; i++)
    {
        if(OrgInfo[i][oCriada] == 1)
        {
            SetPlayerMapIcon(playerid, i, OrgInfo[i][oX], OrgInfo[i][oY], OrgInfo[i][oZ], 31, 0, MAPICON_GLOBAL);
        }
    }

    SetTimerEx("TocarMusicaLogin", 2000, false, "i", playerid);

    // === AQUI ESTÁ A MÁGICA: VERIFICAR NO MYSQL ===
    // Pergunta ao banco se esse nome já existe
    new query[128];
    mysql_format(Conexao, query, sizeof(query), "SELECT senha FROM contas WHERE nome = '%e' LIMIT 1", nome);
    mysql_tquery(Conexao, query, "VerificarConta", "d", playerid);

    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    // CANCELAR (ESC) - Fecha tudo o que estiver aberto
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        if(EditorAberto[playerid]) { FecharEditorMobile(playerid); return 1; }
        if(InvAberto[playerid]) { cmd_mochila(playerid, ""); return 1; }
        if(GaragemAberta[playerid]) { cmd_garagem(playerid, ""); return 1; }
        if(ConceAberta[playerid]) { FecharMenuConce(playerid); return 1; }
        return 1;
    }

    // EDITOR DE ACESSÓRIOS (TD GLOBAL)
    for(new i=0; i < 9; i++) {
        if(clickedid == TD_Edit_Botoes[i]) {
            new slot = EditandoSlot[playerid];
            new Float:valor = EditStep[playerid];
            if(i==0) AtualizarToy(playerid, slot, 1, -valor);
            else if(i==1) AtualizarToy(playerid, slot, 1, valor);
            else if(i==2) AtualizarToy(playerid, slot, 2, -valor);
            else if(i==3) AtualizarToy(playerid, slot, 2, valor);
            else if(i==4) AtualizarToy(playerid, slot, 3, -valor);
            else if(i==5) AtualizarToy(playerid, slot, 3, valor);
            else if(i==6) {
                EditandoModo[playerid]++;
                if(EditandoModo[playerid]>2) EditandoModo[playerid]=0;
                new str[64];
                if(EditandoModo[playerid]==0) format(str,64,"Editando:~n~POSICAO");
                else if(EditandoModo[playerid]==1) format(str,64,"Editando:~n~ROTACAO");
                else format(str,64,"Editando:~n~TAMANHO");
                PlayerTextDrawSetString(playerid, PTD_Edit_Info[playerid], str);
                if(EditandoModo[playerid]==1) EditStep[playerid]=5.0; else EditStep[playerid]=0.05;
            }
            else if(i==7) { SalvarToys(playerid); FecharEditorMobile(playerid); SendClientMessage(playerid, COR_VERDE_NEON, "Salvo!"); }
            else if(i==8) { CarregarToys(playerid); FecharEditorMobile(playerid); }
            return 1;
        }
    }

    // LOGIN (TD GLOBAL)
    if(clickedid == TD_Login_BtnConectar || clickedid == TD_Login_IconPass || clickedid == TD_Login_BoxSenha) {
        if(Player[playerid][pSenha][0] != EOS) ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Digite sua senha:", "Entrar", "Sair");
        else SendClientMessage(playerid, COR_ERRO, "Crie uma conta primeiro.");
        return 1;
    }
    if(clickedid == TD_Login_BtnCriar) {
        if(Player[playerid][pSenha][0] == EOS) ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "Registro", "Crie uma senha:", "Criar", "Sair");
        else SendClientMessage(playerid, COR_ERRO, "Voce ja tem conta.");
        return 1;
    }

    // BANCO (TD GLOBAL)
    if(clickedid == TD_BtnSair) {
        BancoAberto[playerid] = false;
        // TextDrawHideForPlayer(playerid, TD_BancoFundo); TextDrawHideForPlayer(playerid, TD_BancoTitulo);
        // TextDrawHideForPlayer(playerid, TD_BtnPix); TextDrawHideForPlayer(playerid, TD_BtnSair);
        // PlayerTextDrawHide(playerid, PTD_Saldo);
        // CancelSelectTextDraw(playerid);
        if(CelularAberto[playerid]) { for(new i=0; i<8; i++) PlayerTextDrawShow(playerid, Celular[playerid][i]); SelectTextDraw(playerid, 0xFF0000AA); }
        return 1;
    }
    if(clickedid == TD_BtnPix) {
        cmd_celular(playerid, ""); 
        ShowPlayerDialog(playerid, DIALOG_PIX_ID, DIALOG_STYLE_INPUT, "PIX", "Digite o ID:", "Ok", "Sair");
        return 1;
    }

    return 0;
}

// ============================================================
// 3. AS FUNÇÕES AUXILIARES (AGORA FORA DA PUBLIC, LÁ EMBAIXO)
// ============================================================

stock FecharEditorMobile(playerid)
{
    EditorAberto[playerid] = false;
    CancelSelectTextDraw(playerid);
    TextDrawHideForPlayer(playerid, TD_Edit_Fundo);
    for(new i=0; i < 9; i++) TextDrawHideForPlayer(playerid, TD_Edit_Botoes[i]);
    PlayerTextDrawHide(playerid, PTD_Edit_Info[playerid]);
    return 1;
}

stock IsTextDrawVisibleForPlayer(playerid, Text:td)
{
    #pragma unused playerid, td 
    return 1; 
}

stock AtualizarToy(playerid, slot, eixo, Float:valor)
{
    if(EditandoModo[playerid] == 0) // POSIÇÃO
    {
        if(eixo == 1) PlayerToys[playerid][slot][tX] += valor;
        if(eixo == 2) PlayerToys[playerid][slot][tY] += valor;
        if(eixo == 3) PlayerToys[playerid][slot][tZ] += valor;
    }
    else if(EditandoModo[playerid] == 1) // ROTAÇÃO
    {
        if(eixo == 1) PlayerToys[playerid][slot][tRX] += valor;
        if(eixo == 2) PlayerToys[playerid][slot][tRY] += valor;
        if(eixo == 3) PlayerToys[playerid][slot][tRZ] += valor;
    }
    else if(EditandoModo[playerid] == 2) // TAMANHO
    {
        if(eixo == 1) PlayerToys[playerid][slot][tSX] += valor;
        if(eixo == 2) PlayerToys[playerid][slot][tSY] += valor;
        if(eixo == 3) PlayerToys[playerid][slot][tSZ] += valor;
    }
    
    SetPlayerAttachedObject(playerid, slot, PlayerToys[playerid][slot][tModel], PlayerToys[playerid][slot][tBone], 
        PlayerToys[playerid][slot][tX], PlayerToys[playerid][slot][tY], PlayerToys[playerid][slot][tZ], 
        PlayerToys[playerid][slot][tRX], PlayerToys[playerid][slot][tRY], PlayerToys[playerid][slot][tRZ], 
        PlayerToys[playerid][slot][tSX], PlayerToys[playerid][slot][tSY], PlayerToys[playerid][slot][tSZ]);
        
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // Deleta a Tag do CPF
    if(TagCPF[playerid]) 
    {
        Delete3DTextLabel(TagCPF[playerid]);
        TagCPF[playerid] = Text3D:0;
    }

    if(Player[playerid][pLogado] == true)
    {
        SalvarToys(playerid);
        SalvarConta(playerid);
        
        SalvarInventario(playerid); // <--- ADICIONE ISSO AQUI
    }
    
    // 1. SALVAR TUDO ANTES DE QUALQUER COISA
    if(IsLogged[playerid])
    {
        SalvarToys(playerid); // Salva os acessórios (MySQL)
        SalvarConta(playerid); // Salva dinheiro, level, etc.
    }

    // 2. Limpa os acessórios visuais para não bugar o próximo player
    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
    }

    // 3. Marca como deslogado
    IsLogged[playerid] = false;
    
// Destruir carros do player ao sair
    for(new i=0; i < MAX_PLAYER_VEHICLES; i++)
    {
        if(PlayerVehicles[playerid][i][pvSpawnadoID] > 0)
        {
            DestroyVehicle(PlayerVehicles[playerid][i][pvSpawnadoID]);
            PlayerVehicles[playerid][i][pvSpawnadoID] = 0;
        }
    }

    if(IsPicking[playerid]) FecharLockPick(playerid);
    if(IsLogged[playerid]) SalvarConta(playerid);
	return 1;
}

stock EsconderLogin(playerid)
{
    StopAudioStreamForPlayer(playerid);
    
    return 1;
}

public OnPlayerSpawn(playerid)
{
    // --- SISTEMA DE NAMETAG (CPF) ---
    
    // 1. Limpa tag anterior para não duplicar
    Delete3DTextLabel(TagCPF[playerid]); 

    // 2. Verifica se o jogador tem CPF carregado (Só pra garantir)
    if(Player[playerid][pCpf] > 0)
    {
        new labelCPF[64];
        // {00BFFF} é um Azul Claro (Deep Sky Blue)
        // {FFFFFF} é Branco
        format(labelCPF, sizeof(labelCPF), "{00BFFF}CPF: {FFFFFF}%d", Player[playerid][pCpf]);

        // 3. Cria o texto
        // Cor: Branco (Transparente), Distância: 20 metros, Linha de Visão: 0 (vê através de parede? não), TestLOS: 1
        TagCPF[playerid] = Create3DTextLabel(labelCPF, 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, 1);

        // 4. Cola na cabeça do jogador (Offset Z 0.4 fica bem em cima)
        Attach3DTextLabelToPlayer(TagCPF[playerid], playerid, 0.0, 0.0, 0.4);
    }

    // 1. TEXTDRAWS (Visual)
    
    // 2. SEGURANÇA (Verifica se está logado antes de tudo)
    // Usamos a variável do MySQL (pLogado) em vez da antiga IsLogged
    if(Player[playerid][pLogado] == false)
    {
        SendClientMessage(playerid, 0xFF0000AA, "Voce nao esta logado e foi kickado.");
        Kick(playerid);
        return 1;
    }

    // 3. SISTEMA DE PRESO (DOF2 - Mantido conforme seu código)
    new nome[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), PASTA_PRESOS, nome);
    
    if(DOF2_FileExists(arquivo))
    {
        SetPlayerInterior(playerid, 6);
        SetPlayerPos(playerid, 264.6288, 77.5742, 1001.0391); // Cela
        SendClientMessage(playerid, 0xFF0000AA, "Voce ainda esta preso! Cumpra sua pena.");
        // Nota: Se estiver preso, não carregamos o resto para evitar bugar animação ou spawn
        return 1; 
    }
    
    EsconderLogin(playerid);

    // 4. POSIÇÃO DE SPAWN (LS)
    SetPlayerPos(playerid, 832.0, -1863.0, 12.9);
    SetPlayerFacingAngle(playerid, 180.0);
    SetCameraBehindPlayer(playerid);

    // 5. SKIN (Usa a salva ou a padrão)
    if(Player[playerid][pSkin] > 0)
    {
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
    }
    else
    {
        SetPlayerSkin(playerid, 154);
        Player[playerid][pSkin] = 154; 
    }

    // 6. STATUS (Dinheiro e Score)
    SetPlayerScore(playerid, Player[playerid][pScore]);
    
    // Importante: Resetar antes de dar, para não duplicar o dinheiro se spawnar 2x
    ResetPlayerMoney(playerid); 
    GivePlayerMoney(playerid, Player[playerid][pDinheiro]);
 
    // 7. ANIMAÇÕES (Preload)
    ApplyAnimation(playerid, "BOMBER", "null", 0.0, 0, 0, 0, 0, 0, 0); 
    ApplyAnimation(playerid, "MEDIC", "null", 0.0, 0, 0, 0, 0, 0, 0);
   
    // 8. CARREGAR ACESSÓRIOS (CORRIGIDO)
    // Só chamamos uma vez e verificamos se está logado (que já verificamos lá em cima, mas ok garantir)
    if(Player[playerid][pLogado])
    {
        CarregarToys(playerid);
    }

    if(Player[playerid][pLogado])
    {
        CarregarToys(playerid);
        
        CarregarInventario(playerid); // <--- ADICIONE ISSO AQUI
    }

    // Chama a função da Tag
    AtualizarTagCPF(playerid);

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
// --- DIALOG 1: PEDE CPF ---
    if(dialogid == 1555)
    {
        if(!response) return 1;
        new cpfAlvo = strval(inputtext);
        new idAlvo = GetPlayerIDByCPF(cpfAlvo);

        if(idAlvo == -1) return SendClientMessage(playerid, COR_ERRO, "CPF nao encontrado ou cidadao offline.");
        if(idAlvo == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode enviar para si mesmo.");
        
        // Salva o ID do alvo temporariamente para o próximo passo
        SetPVarInt(playerid, "TransfID", idAlvo); 
        
        // Pergunta a quantidade
        new str[128], nomeItem[32];
        new slot = SlotSelecionado[playerid];
        
        // Pega nome do item só pra ficar bonito
        if(InvItem[playerid][slot] == ITEM_DINHEIRO_SUJO) nomeItem = "Dinheiro Sujo";
        else format(nomeItem, 32, "Item ID %d", InvItem[playerid][slot]);

        format(str, sizeof(str), "Item: %s\nQuantidade Disponivel: %d\n\nDigite quanto quer enviar:", nomeItem, InvQtd[playerid][slot]);
        ShowPlayerDialog(playerid, 1556, DIALOG_STYLE_INPUT, "Quantidade", str, "Confirmar", "Voltar");
        return 1;
    }

    // --- DIALOG 2: PEDE QUANTIDADE E FINALIZA ---
    if(dialogid == 1556)
    {
        if(!response) return 1;
        new quantia = strval(inputtext);
        new idAlvo = GetPVarInt(playerid, "TransfID");
        new slot = SlotSelecionado[playerid];

        // Validações de segurança
        if(!IsPlayerConnected(idAlvo)) return SendClientMessage(playerid, COR_ERRO, "O cidadao saiu da cidade durante a transacao.");
        if(quantia <= 0) return SendClientMessage(playerid, COR_ERRO, "Quantidade invalida.");
        if(quantia > InvQtd[playerid][slot]) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem tudo isso.");

        // Verifica a distância (Opcional: Se quiser que seja "Correio Mágico" tire isso. Se quiser RP, deixe)
        /*
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        if(!IsPlayerInRangeOfPoint(idAlvo, 5.0, x, y, z)) return SendClientMessage(playerid, COR_ERRO, "O cidadao esta muito longe!");
        */

        // 1. TENTA ADICIONAR NA MOCHILA DO ALVO
        if(AddItemMochila(idAlvo, InvItem[playerid][slot], quantia))
        {
            // 2. SE DEU CERTO, REMOVE DO REMETENTE
            InvQtd[playerid][slot] -= quantia;
            if(InvQtd[playerid][slot] <= 0) // Se acabou tudo
            {
                InvItem[playerid][slot] = 0;
                InvQtd[playerid][slot] = 0;
                SlotSelecionado[playerid] = -1; // Desmarca
            }

            // 3. ATUALIZA VISUAL E SALVA
            AtualizarInventarioGrid(playerid); // Atualiza sua tela
            
            // Se o alvo estiver com mochila aberta, atualiza a dele também!
            if(InvAberto[idAlvo]) AtualizarInventarioGrid(idAlvo);

            SalvarInventario(playerid);
            SalvarInventario(idAlvo);

            // 4. MENSAGENS
            SendClientMessage(playerid, COR_VERDE_NEON, "Transacao realizada com sucesso via CPF!");
            
            new msg[128];
            format(msg, sizeof(msg), "Voce recebeu itens de alguem (CPF Remetente: %d). Verifique sua mochila.", Player[playerid][pCpf]);
            SendClientMessage(idAlvo, COR_V_CLARO, msg);
        }
        else
        {
            SendClientMessage(playerid, COR_ERRO, "A mochila do destinatario esta cheia!");
        }
        return 1;
    }

    // 1. VARIÁVEIS GERAIS (Para usar em qualquer dialog aqui dentro)
    new query[512];
    new nome[MAX_PLAYER_NAME];
    new arquivo[128]; 
    GetPlayerName(playerid, nome, sizeof(nome));
    
    // =========================================================================
    //            SISTEMA DE ACESSÓRIOS 2.0 (NOVO E LIMPO)
    // =========================================================================

    // --- 1. MENU DOS SLOTS ---
    if(dialogid == D_ACC_MENU)
    {
        if(!response) return 1; // Fecha o dialog e pronto.

        new slot = listitem;
        EditandoSlot[playerid] = slot; // Salva qual slot clicou

        // Se o slot estiver VAZIO -> Abre a Loja
        if(PlayerToys[playerid][slot][tSlotOcupado] == 0)
        {
            mysql_tquery(Conexao, "SELECT * FROM catalogo_acessorios", "OnAbrirLojaMySQL", "d", playerid);
            SendClientMessage(playerid, COR_V_CLARO, "Abrindo catalogo...");
        }
        // Se o slot estiver OCUPADO -> Abre Opções (Editar/Remover)
        else
        {
            ShowPlayerDialog(playerid, D_ACC_OPCOES, DIALOG_STYLE_LIST, "O que fazer?", 
                "1. Editar Posicao (TextDraw)\n2. Trocar Osso (Local)\n3. Remover Item", 
                "Selecionar", "Voltar");
        }
        return 1;
    }

    // --- 2. LOJA (CATÁLOGO) ---
    if(dialogid == D_ACC_LOJA)
    {
        if(!response) return cmd_acessorios(playerid); // Volta pro menu de slots

        // Pega o ID do texto "18921 - Oculos"
        new modeloCompra;
        if(sscanf(inputtext, "d", modeloCompra)) return SendClientMessage(playerid, COR_ERRO, "Erro ao ler o item.");

        new slot = EditandoSlot[playerid]; // Recupera o slot que clicou no começo

        // Define os dados
        PlayerToys[playerid][slot][tSlotOcupado] = 1;
        PlayerToys[playerid][slot][tModel] = modeloCompra;
        PlayerToys[playerid][slot][tBone] = 2; // Cabeça (Padrão)

        // Reseta posições e define escala 1.0
        PlayerToys[playerid][slot][tX] = 0.0; PlayerToys[playerid][slot][tY] = 0.0; PlayerToys[playerid][slot][tZ] = 0.0;
        PlayerToys[playerid][slot][tRX] = 0.0; PlayerToys[playerid][slot][tRY] = 0.0; PlayerToys[playerid][slot][tRZ] = 0.0;
        PlayerToys[playerid][slot][tSX] = 1.0; PlayerToys[playerid][slot][tSY] = 1.0; PlayerToys[playerid][slot][tSZ] = 1.0;

        // Aplica e Salva
        SetPlayerAttachedObject(playerid, slot, modeloCompra, 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        SalvarSlotUnico(playerid, slot);

        SendClientMessage(playerid, COR_VERDE_NEON, "Item comprado com sucesso!");
        
        // Abre opções direto para editar
        ShowPlayerDialog(playerid, D_ACC_OPCOES, DIALOG_STYLE_LIST, "O que fazer?", 
                "1. Editar Posicao (TextDraw)\n2. Trocar Osso (Local)\n3. Remover Item", 
                "Selecionar", "Voltar");
        return 1;
    }

    // --- 3. OPÇÕES (EDITAR/REMOVER) ---
    if(dialogid == D_ACC_OPCOES)
    {
        if(!response) return cmd_acessorios(playerid);

        new slot = EditandoSlot[playerid];

        // Opção 0: EDITAR (SEU TEXTDRAW)
        if(listitem == 0)
        {
            EditorAberto[playerid] = true;
            EditandoModo[playerid] = 0;
            EditStep[playerid] = 0.05;

            TextDrawShowForPlayer(playerid, TD_Edit_Fundo);
            for(new i=0; i < 9; i++) TextDrawShowForPlayer(playerid, TD_Edit_Botoes[i]);
            
            PlayerTextDrawSetString(playerid, PTD_Edit_Info[playerid], "Mover:~n~X / Y / Z");
            PlayerTextDrawShow(playerid, PTD_Edit_Info[playerid]);

            SelectTextDraw(playerid, 0xFF0000AA);
            SendClientMessage(playerid, COR_VERDE_NEON, "Editor Aberto.");
            return 1;
        }

        // Opção 1: TROCAR OSSO
        if(listitem == 1)
        {
            ShowPlayerDialog(playerid, D_ACC_OSSO, DIALOG_STYLE_LIST, "Escolha o local:", 
            "1. Costas\n2. Cabeca\n3. Mao Esquerda\n4. Mao Direita\n5. Mao Esq (Segurar)\n6. Mao Dir (Segurar)\n7. Boca\n8. Olhos", 
            "Escolher", "Voltar");
            return 1;
        }

        // Opção 2: REMOVER
        if(listitem == 2)
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, slot)) RemovePlayerAttachedObject(playerid, slot);
            
            PlayerToys[playerid][slot][tSlotOcupado] = 0;
            PlayerToys[playerid][slot][tModel] = 0;
            SalvarSlotUnico(playerid, slot);

            SendClientMessage(playerid, COR_V_CLARO, "Item removido.");
            cmd_acessorios(playerid);
            return 1;
        }
        return 1;
    }

    // --- 4. SELEÇÃO DE OSSO (EXTRA) ---
    if(dialogid == D_ACC_OSSO)
    {
        if(!response) return cmd_acessorios(playerid);
        
        new slot = EditandoSlot[playerid];
        new ossos[] = {1, 2, 5, 6, 15, 16, 17, 18}; // IDs dos ossos correspondentes
        new ossoEscolhido = ossos[listitem];

        PlayerToys[playerid][slot][tBone] = ossoEscolhido;
        
        // Re-aplica o objeto com o novo osso
        SetPlayerAttachedObject(playerid, slot, PlayerToys[playerid][slot][tModel], ossoEscolhido, 
            PlayerToys[playerid][slot][tX], PlayerToys[playerid][slot][tY], PlayerToys[playerid][slot][tZ], 
            PlayerToys[playerid][slot][tRX], PlayerToys[playerid][slot][tRY], PlayerToys[playerid][slot][tRZ], 
            PlayerToys[playerid][slot][tSX], PlayerToys[playerid][slot][tSY], PlayerToys[playerid][slot][tSZ]);
            
        SalvarSlotUnico(playerid, slot);
        SendClientMessage(playerid, COR_V_CLARO, "Local alterado!");
        return 1;
    }

    // -------------------------------------------------------------------------
    //                          SISTEMA DE GPS
    // -------------------------------------------------------------------------
    
// --- DIALOG 1: ESCOLHER CATEGORIA (GPS) ---
    if(dialogid == DIALOG_GPS_CAT)
    {
        if(!response) return 1;

        new File:fCat = fopen(ARQUIVO_CATS, io_read);
        if(!fCat) return SendClientMessage(playerid, COR_ERRO, "Erro: Arquivo Categorias.txt sumiu.");

        new string[128], linha = 0, achou = 0;
        
        while(fread(fCat, string))
        {
            if(linha == listitem)
            {
                // --- LIMPEZA AGRESSIVA ---
                // Corta a string assim que achar qualquer caractere estranho (\r ou \n)
                for(new i=0; i < strlen(string); i++)
                {
                    if(string[i] == '\r' || string[i] == '\n') 
                    {
                        string[i] = '\0'; // Corta a string aqui
                        break; 
                    }
                }
                
                format(TempGPS_Categoria[playerid], 64, "%s", string);
                achou = 1;
                break;
            }
            linha++;
        }
        fclose(fCat);

        if(achou == 0) return SendClientMessage(playerid, COR_ERRO, "Erro de seleção.");

        new caminho[64];
        format(caminho, sizeof(caminho), "GPS/%s.txt", TempGPS_Categoria[playerid]);
        
// --- CÓDIGO CORRIGIDO (GPS - SEM ERRO DE STRING) ---
        new msg_teste[128]; 
        format(msg_teste, sizeof(msg_teste), "{FFFF00}DEBUG: Tentando abrir o arquivo: [%s]", caminho);
        SendClientMessage(playerid, -1, msg_teste);

        new File:f = fopen(caminho, io_read);
        if(!f) 
        {
            SendClientMessage(playerid, COR_ERRO, "ERRO: O servidor nao encontrou o arquivo acima.");
            return 1;
        }

        // CORREÇÃO: Removemos 'string[128]' daqui porque ela já existe no topo!
        new lista[2000], nomeLocal[30]; 
        lista[0] = '\0';

        while(fread(f, string)) // Usa a 'string' que já existe na public
        {
            // Leitura simples: Pega o texto até a barra | e salva em 'nomeLocal'
            if(!sscanf(string, "p<|>s[30]{}", nomeLocal)) 
            {
                // Usa 'nomeLocal' na lista
                format(lista, sizeof(lista), "%s%s\n", lista, nomeLocal);
            }
        }
        fclose(f);

        if(strlen(lista) < 2) return SendClientMessage(playerid, COR_ERRO, "Esta categoria esta vazia.");

        ShowPlayerDialog(playerid, DIALOG_GPS_LOC, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha o Local", lista, "Marcar", "Voltar");
        return 1;
    }

    // --- DIALOG 2: ESCOLHER O LOCAL (GPS) ---
    if(dialogid == DIALOG_GPS_LOC)
    {
        if(!response) return cmd_gps(playerid);

        new caminho[64];
        format(caminho, sizeof(caminho), "GPS/%s.txt", TempGPS_Categoria[playerid]);

        new File:f = fopen(caminho, io_read);
        if(!f) return SendClientMessage(playerid, COR_ERRO, "Erro ao carregar local.");

        new string[128], contador = 0;
        
        // CORREÇÃO AQUI: Mudamos de 'nome' para 'nomeLocal' para não dar conflito
        new nomeLocal[30], Float:x, Float:y, Float:z; 

        while(fread(f, string))
        {
            if(contador == listitem) 
            {
                // Usa nomeLocal aqui também
                sscanf(string, "p<|>s[30]fff", nomeLocal, x, y, z);
                
                DisablePlayerCheckpoint(playerid); 
                SetPlayerCheckpoint(playerid, x, y, z, 5.0); 
                CheckpointAtivo[playerid] = 1;

                new msg[128];
                // Usa nomeLocal aqui também
                format(msg, sizeof(msg), "{00FF00}GPS:{FFFFFF} Destino marcado para {FFFF00}%s{FFFFFF}! Siga o ponto vermelho.", nomeLocal);
                SendClientMessage(playerid, -1, msg);
                
                PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
                break;
            }
            contador++;
        }
        fclose(f);
        return 1;
    }

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

    // ============================================================
    // 3. SISTEMA DE PIX
    // ============================================================
    if(dialogid == DIALOG_PIX_ID)
    {
        if(!response) return 1;
        new idDestino = strval(inputtext);
        
        if(!IsPlayerConnected(idDestino)) return SendClientMessage(playerid, COR_ERRO, "Jogador nao encontrado!");
        if(idDestino == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode fazer pix pra voce mesmo.");
        
        PixDestino[playerid] = idDestino; 
        
        ShowPlayerDialog(playerid, DIALOG_PIX_VALOR, DIALOG_STYLE_INPUT, "{00FF00}BPS PIX", "Digite o VALOR do Pix:", "Enviar", "Cancelar");
        return 1;
    }
    
    if(dialogid == DIALOG_PIX_VALOR)
    {
        if(!response) return 1;
        new valor = strval(inputtext);
        
        if(valor <= 0) return SendClientMessage(playerid, COR_ERRO, "Valor invalido.");
        if(GetPlayerMoney(playerid) < valor) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem esse dinheiro!");
        
        GivePlayerMoney(playerid, -valor);
        GivePlayerMoney(PixDestino[playerid], valor);
        SendClientMessage(playerid, COR_VERDE_NEON, "Pix enviado com sucesso!");
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

    // ============================================================
    // DIALOG REGISTRO
    // ============================================================
    if(dialogid == DIALOG_REGISTRO)
    {
        if(!response || strlen(inputtext) < 4) 
        {
            SendClientMessage(playerid, COR_ERRO, "Senha muito curta ou cancelada.");
            Kick(playerid); 
            return 1; 
        }

        // Prepara dados iniciais
        Player[playerid][pDinheiro] = 5000;
        Player[playerid][pScore] = 1;
        Player[playerid][pSkin] = 0; 
        Player[playerid][pCpf] = 100000 + random(899999); 
        Player[playerid][pBitcoin] = 0;
        
        format(Player[playerid][pSenha], 129, inputtext);

        // Insere no Banco (MySQL)
        mysql_format(Conexao, query, sizeof(query), 
            "INSERT INTO contas (nome, senha, dinheiro, admin, skin, cpf, bitcoin) VALUES ('%e', '%e', %d, 0, 0, %d, 0)",
            nome, inputtext, 5000, Player[playerid][pCpf]);
            
        mysql_tquery(Conexao, query);

        // Loga
        IsLogged[playerid] = true;
        Player[playerid][pLogado] = true;

        SendClientMessage(playerid, COR_V_CLARO, "Conta criada com sucesso! Bom jogo.");
        EsconderLogin(playerid); 

        // --- SPAWN CORRETO (Agora está dentro das chaves!) ---
        TogglePlayerSpectating(playerid, 0); 
        
        // Lógica da Skin
        if(Player[playerid][pSkin] > 0) SetPlayerSkin(playerid, Player[playerid][pSkin]);
        else SetPlayerSkin(playerid, 154);

        SetSpawnInfo(playerid, 0, Player[playerid][pSkin], 832.0, -1863.0, 12.9, 180.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        
        GivePlayerMoney(playerid, 5000);
        SetPlayerScore(playerid, 1);
        
        return 1;
    }

    // ============================================================
    // DIALOG LOGIN
    // ============================================================
    if(dialogid == DIALOG_LOGIN)
    {
        if(!response) return Kick(playerid);
        
        if(strcmp(inputtext, Player[playerid][pSenha], false) == 0)
        {
            SendClientMessage(playerid, COR_V_CLARO, "Senha correta! Carregando seus dados...");
            
            // Reutiliza a variável 'query' do topo (não cria nova)
            mysql_format(Conexao, query, sizeof(query), "SELECT * FROM contas WHERE nome = '%e' LIMIT 1", nome);
            mysql_tquery(Conexao, query, "CarregarConta", "d", playerid);
        }
        else
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF0000}Erro", "Senha Incorreta! Tente novamente:", "Logar", "Cancelar");
        }
        return 1;
    }
    return 0; // Retorno caso não seja nenhum dialog
} // <--- ESSA É A CHAVE MÁGICA QUE ESTÁ FALTANDO
    
// =============================================================================
//                      SISTEMA DE ADMINISTRAÇÃO (COMPLETO)
// =============================================================================
CMD:virarfundador(playerid, params[])
{
    // 1. Defina sua SENHA SECRETA aqui (Mude "Kong123" para algo dificil!)
    new SenhaSecreta[] = "Kong123"; 

    new input[32];
    if(sscanf(params, "s[32]", input)) return SendClientMessage(playerid, COR_ERRO, "Use: /virarfundador [Senha de Seguranca]");

    // 2. Verifica se a senha bate
    if(strcmp(input, SenhaSecreta, false) == 0)
    {
        // 3. Seta o Admin Nível 6 (Fundador)
        Player[playerid][pAdmin] = 6;
        
        // 4. CRIA O ARQUIVO NA PASTA ADMINS (Para salvar permanente)
        new nome[MAX_PLAYER_NAME], arquivo[64], data[32];
        GetPlayerName(playerid, nome, sizeof(nome));
        getdate(data[0], data[1], data[2]);
        format(data, sizeof(data), "%d/%d/%d", data[2], data[1], data[0]);

        format(arquivo, sizeof(arquivo), PASTA_ADMINS, nome);
        if(!DOF2_FileExists(arquivo)) DOF2_CreateFile(arquivo);
        
        DOF2_SetInt(arquivo, "Nivel", 6);
        DOF2_SetString(arquivo, "PromovidoPor", "CMD_SECRETO");
        DOF2_SetString(arquivo, "Data", data);
        DOF2_SaveFile();

        // 5. Avisa e toca som
        SendClientMessage(playerid, COR_VERDE_NEON, "SUCESSO: Voce agora e FUNDADOR (Nivel 6).");
        SendClientMessage(playerid, COR_V_CLARO, "O arquivo foi criado na pasta Admins.");
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    }
    else
    {
        // Se errar a senha
        SendClientMessage(playerid, 0xFF0000AA, "SENHA INCORRETA! Tentativa registrada.");
        // Opcional: Kick(playerid); se quiser mais segurança
    }
    return 1;
}

CMD:aa(playerid)
{
    // Verifica se é pelo menos Helper (Nível 1)
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Voce nao pertence a equipe de Administracao.");

    new string[2000]; // String grande para caber tudo

    // --- HELPER (Nivel 1) - Verde Neon ---
    strcat(string, "{00FF00}--- HELPER (Nivel 1) ---\n");
    strcat(string, "{FFFFFF}/tra /a /verid /repararcarro /aviso /ir /trazer /tv /tvoff\n\n");

    // --- ADMINISTRADOR (Nivel 2) - Azul Ciano ---
    strcat(string, "{00FFFF}--- ADMINISTRADOR (Nivel 2) ---\n");
    strcat(string, "{FFFFFF}/lo /kick /congelar /descongelar /tapa /idveh\n\n");

    // --- ADMIN MASTER (Nivel 3) - Roxo ---
    strcat(string, "{BF00FF}--- ADMIN MASTER (Nivel 3) ---\n");
    strcat(string, "{FFFFFF}/setarskin /darvida /setarcolete /setarhora /cadeia /soltarp /irmarca\n\n");

    // --- GERENTE (Nivel 4) - Laranja ---
    strcat(string, "{FFA500}--- GERENTE (Nivel 4) ---\n");
    strcat(string, "{FFFFFF}/ban /desban /cv /dv /rc /banip\n\n");

    // --- DONO (Nivel 5) - Vermelho Claro ---
    strcat(string, "{FF4500}--- DONO (Nivel 5) ---\n");
    strcat(string, "{FFFFFF}/av /dargrana /trazertodos /coletetodos /setarniveltodos /setarnivel\n\n");

    // --- FUNDADOR (Nivel 6) - Vermelho Escuro ---
    strcat(string, "{FF0000}--- FUNDADOR (Nivel 6) ---\n");
    strcat(string, "{FFFFFF}/daradmin /tiraradmin /desbanip /soltarpoff");

    // Mostra o Dialog
    // ID 6666 é aleatório, pode mudar se quiser
    ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_MSGBOX, "{00FF00}COMANDOS DA ADMINISTRACAO", string, "Fechar", "");
    return 1;
}

// --- COMANDO DE TRABALHO (Entrar/Sair de Admin) ---
CMD:tra(playerid)
{
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Apenas Equipe.");
    
    new str[144], nome[24], cargo[24];
    GetPlayerName(playerid, nome, 24);
    format(cargo, 24, "%s", GetCargoAdmin(playerid)); 

    if(Trabalhando[playerid])
    {
        // =========================================================
        //                 SAINDO DO MODO TRABALHO
        // =========================================================
        Trabalhando[playerid] = false;
        
        // 1. Apaga o Texto 3D da cabeça
        Delete3DTextLabel(TagAdmin[playerid]);
        
        // 2. FAZ O NICK ORIGINAL VOLTAR A APARECER PARA TODOS
        for(new i=0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                ShowPlayerNameTagForPlayer(i, playerid, 1); // 1 = Mostrar
            }
        }
        
        SetPlayerColor(playerid, 0xFFFFFFFF); // Volta a cor branca no TAB
        
        // Aviso Global
        format(str, sizeof(str), "| ADMIN | O %s %s saiu de modo de trabalho.", cargo, nome);
        SendClientMessageToAll(COR_ROSA_AVISO, str);
        
        SendClientMessage(playerid, COR_V_CLARO, "Voce voltou ao normal (Nome original restaurado).");
    }
    else
    {
        // =========================================================
        //                 ENTRANDO EM MODO TRABALHO
        // =========================================================
        Trabalhando[playerid] = true;
        
        // 1. ESCONDE O NICK ORIGINAL PARA TODOS (Desativa o LILO (0))
        for(new i=0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                ShowPlayerNameTagForPlayer(i, playerid, 0); // 0 = Esconder
            }
        }
        
        // 2. Cria o NOVO NOME (Texto 3D)
        // Formato: FUNDADOR (Rosa) LILO (Branco)
        new label[64];
        format(label, sizeof(label), "%s%s {FFFFFF}%s", HEX_ROSA, cargo, nome); 
        
        // Cria grudado no jogador
        TagAdmin[playerid] = Create3DTextLabel(label, 0xFFFFFFFF, 0.0, 0.0, 0.0, 30.0, 0, 1);
        Attach3DTextLabelToPlayer(TagAdmin[playerid], playerid, 0.0, 0.0, 0.45); // Ajuste a altura aqui se precisar
        
        SetPlayerColor(playerid, 0x00FF00FF); // Fica verde no TAB (opcional)
        SetPlayerHealth(playerid, 1000.0);
        
        // Aviso Global
        format(str, sizeof(str), "| ADMIN | O %s %s entrou em modo de trabalho.", cargo, nome);
        SendClientMessageToAll(COR_ROSA_AVISO, str);
        
        SendClientMessage(playerid, COR_VERDE_NEON, "Modo Trabalho Ativado! Seu nick original foi ocultado.");
    }
    return 1;
}

// --- RANK 1: HELPER ---

CMD:a(playerid, params[])
{
    if(Player[playerid][pAdmin] < 1) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COR_ERRO, "Use: /a [Texto]");
    
    new str[144], nome[24];
    GetPlayerName(playerid, nome, 24);
    format(str, sizeof(str), "[ADMIN CHAT] %s (%d): %s", nome, Player[playerid][pAdmin], params);
    
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdmin] >= 1) SendClientMessage(i, 0xFFFF00AA, str);
    }
    return 1;
}

CMD:verid(playerid, params[])
{
    VerificarAdmin(playerid, 1);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /verid [ID/Nome]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    new msg[100], nome[24];
    GetPlayerName(id, nome, 24);
    format(msg, sizeof(msg), "O ID de %s e: %d", nome, id);
    SendClientMessage(playerid, COR_VERDE_NEON, msg);
    return 1;
}

CMD:repararcarro(playerid)
{
    VerificarAdmin(playerid, 1);
    VerificarTra(playerid);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COR_ERRO, "Entre em um veiculo.");
    
    RepairVehicle(GetPlayerVehicleID(playerid));
    SendClientMessage(playerid, COR_VERDE_NEON, "Veiculo reparado.");
    return 1;
}

CMD:aviso(playerid, params[])
{
    VerificarAdmin(playerid, 1);
    VerificarTra(playerid);
    new id, motivo[64];
    if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, COR_ERRO, "Use: /aviso [ID] [Mensagem]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    new str[144];
    format(str, sizeof(str), "| ADMIN | Voce recebeu um aviso: %s", motivo);
    SendClientMessage(id, 0xFFFF00AA, str);
    SendClientMessage(playerid, COR_VERDE_NEON, "Aviso enviado.");
    return 1;
}

CMD:ir(playerid, params[])
{
    VerificarAdmin(playerid, 1);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /ir [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new veh = GetPlayerVehicleID(playerid);
        SetVehiclePos(veh, x+2, y+2, z);
        LinkVehicleToInterior(veh, GetPlayerInterior(id));
        SetVehicleVirtualWorld(veh, GetPlayerVirtualWorld(id));
    }
    else
    {
        SetPlayerPos(playerid, x+1, y+1, z);
    }
    SetPlayerInterior(playerid, GetPlayerInterior(id));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
    return 1;
}

CMD:trazer(playerid, params[])
{
    VerificarAdmin(playerid, 1);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /trazer [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(id, x+1, y, z);
    SetPlayerInterior(id, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
    
    SendClientMessage(id, COR_V_CLARO, "Um Admin puxou voce.");
    return 1;
}

CMD:tv(playerid, params[])
{
    VerificarAdmin(playerid, 1);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /tv [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");

    TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, id);
    if(IsPlayerInAnyVehicle(id)) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(id));
    
    PlayerSpectating[playerid] = id;
    SendClientMessage(playerid, COR_VERDE_NEON, "Voce esta assistindo o jogador.");
    return 1;
}

CMD:tvoff(playerid)
{
    VerificarAdmin(playerid, 1);
    TogglePlayerSpectating(playerid, 0);
    PlayerSpectating[playerid] = -1;
    SpawnPlayer(playerid); // Ou restaurar posição antiga se tiver sistema
    return 1;
}

CMD:lo(playerid)
{
    VerificarAdmin(playerid, 2);
    for(new i=0; i < 100; i++) SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(COR_VERDE_NEON, "Chat limpo pela Administracao.");
    return 1;
}

CMD:kick(playerid, params[])
{
    VerificarAdmin(playerid, 2);
    VerificarTra(playerid);
    new id, motivo[64];
    if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, COR_ERRO, "Use: /kick [ID] [Motivo]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    new str[144], nome[24], admin[24];
    GetPlayerName(id, nome, 24);
    GetPlayerName(playerid, admin, 24);
    
    format(str, sizeof(str), "O Admin %s Kickou %s. Motivo: %s", admin, nome, motivo);
    SendClientMessageToAll(0xFF0000AA, str);
    
    Kick(id); // Em versoes novas do SAMP use SetTimer para kickar com delay
    return 1;
}

CMD:congelar(playerid, params[])
{
    VerificarAdmin(playerid, 2);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /congelar [ID]");
    TogglePlayerControllable(id, 0);
    SendClientMessage(playerid, COR_VERDE_NEON, "Jogador congelado.");
    SendClientMessage(id, 0xFF0000AA, "Voce foi congelado por um Admin.");
    return 1;
}

CMD:descongelar(playerid, params[])
{
    VerificarAdmin(playerid, 2);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /descongelar [ID]");
    TogglePlayerControllable(id, 1);
    SendClientMessage(playerid, COR_VERDE_NEON, "Jogador descongelado.");
    return 1;
}

CMD:tapa(playerid, params[])
{
    VerificarAdmin(playerid, 2);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /tapa [ID]");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPos(id, x, y, z+5.0); // Joga 5 metros pra cima
    SendClientMessage(playerid, COR_VERDE_NEON, "Tapa aplicado!");
    return 1;
}

CMD:idveh(playerid)
{
    VerificarAdmin(playerid, 2);
    new veh = GetClosestVehicle(playerid); // Precisa de stock GetClosestVehicle (veja no final) ou usar GetPlayerVehicleID se tiver dentro
    if(IsPlayerInAnyVehicle(playerid)) veh = GetPlayerVehicleID(playerid);
    
    if(veh == 0) return SendClientMessage(playerid, COR_ERRO, "Nenhum veiculo proximo.");
    
    new str[64];
    format(str, sizeof(str), "ID do Veiculo: %d | Modelo: %d", veh, GetVehicleModel(veh));
    SendClientMessage(playerid, COR_VERDE_NEON, str);
    return 1;
}

CMD:setarskin(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    VerificarTra(playerid);
    new id, skin;
    if(sscanf(params, "ui", id, skin)) return SendClientMessage(playerid, COR_ERRO, "Use: /setarskin [ID] [SkinID]");
    if(skin < 0 || skin > 311) return SendClientMessage(playerid, COR_ERRO, "Skin invalida (0-311).");
    
    SetPlayerSkin(id, skin);
    SendClientMessage(playerid, COR_VERDE_NEON, "Skin definida.");
    return 1;
}

CMD:darvida(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    VerificarTra(playerid);
    new id;
    new Float:vida;
    if(sscanf(params, "uf", id, vida)) return SendClientMessage(playerid, COR_ERRO, "Use: /darvida [ID] [Quantia]");
    
    SetPlayerHealth(id, vida);
    SendClientMessage(playerid, COR_VERDE_NEON, "Vida definida.");
    return 1;
}

CMD:setarcolete(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    VerificarTra(playerid);
    new id;
    new Float:colete;
    if(sscanf(params, "uf", id, colete)) return SendClientMessage(playerid, COR_ERRO, "Use: /setarcolete [ID] [Quantia]");
    
    SetPlayerArmour(id, colete);
    SendClientMessage(playerid, COR_VERDE_NEON, "Colete definido.");
    return 1;
}

CMD:setarhora(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    new hora;
    if(sscanf(params, "i", hora)) return SendClientMessage(playerid, COR_ERRO, "Use: /setarhora [0-23]");
    
    SetWorldTime(hora);
    new str[64];
    format(str, sizeof(str), "Hora do mundo mudada para %d:00.", hora);
    SendClientMessageToAll(COR_V_CLARO, str);
    return 1;
}

CMD:cadeia(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    VerificarTra(playerid);
    
    new id, minutos, motivo[64];
    if(sscanf(params, "uis[64]", id, minutos, motivo)) return SendClientMessage(playerid, COR_ERRO, "Use: /cadeia [ID] [Minutos] [Motivo]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");

    // Configurações da Prisão
    ResetPlayerWeapons(id);
    SetPlayerInterior(id, 6); 
    SetPlayerPos(id, 264.6288, 77.5742, 1001.0391); // Cela
    
    // --- Salva na Pasta Presos (DOF2) ---
    new nome[MAX_PLAYER_NAME], arquivo[64], admin[24]; // Criei as variáveis que faltavam
    GetPlayerName(id, nome, sizeof(nome));
    GetPlayerName(playerid, admin, sizeof(admin));
    
    format(arquivo, sizeof(arquivo), PASTA_PRESOS, nome);
    
    // Cria o arquivo de prisão
    DOF2_CreateFile(arquivo);
    DOF2_SetInt(arquivo, "Tempo", minutos * 60); // Salva em segundos? Ou minutos? (Ajuste conforme seu timer)
    DOF2_SetString(arquivo, "Motivo", motivo);
    DOF2_SetString(arquivo, "Admin", admin);
    DOF2_SaveFile();
    
    // Avisa no chat
    new str[144];
    format(str, sizeof(str), "| CADEIA | O Admin %s prendeu %s por %d minutos. Motivo: %s", admin, nome, minutos, motivo);
    SendClientMessageToAll(0xFF0000AA, str);
    
    SendClientMessage(id, 0xFF0000AA, "Voce foi preso! Reflita sobre seus atos.");
    return 1;
}

CMD:soltarp(playerid, params[])
{
    VerificarAdmin(playerid, 3);
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /soltarp [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");

    // Remove da Prisão
    SpawnPlayer(id);
    SetPlayerInterior(id, 0);
    SetPlayerPos(id, 1543.0, -1675.0, 13.0); // Coloque a saída da DP aqui
    
    // Apaga o arquivo
    new nome[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerName(id, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), PASTA_PRESOS, nome);
    if(DOF2_FileExists(arquivo)) DOF2_RemoveFile(arquivo);

    SendClientMessage(playerid, COR_VERDE_NEON, "Jogador libertado.");
    SendClientMessage(id, COR_VERDE_NEON, "Voce foi solto da cadeia.");
    return 1;
}

CMD:ban(playerid, params[])
{
    VerificarAdmin(playerid, 4); // Rank 4+
    VerificarTra(playerid);
    
    new id, motivo[64];
    if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, COR_ERRO, "Use: /ban [ID] [Motivo]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");

    new nome[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64], data[32];
    GetPlayerName(id, nome, sizeof(nome));
    GetPlayerName(playerid, admin, sizeof(admin));
    getdate(data[0], data[1], data[2]); // Pega ano, mes, dia
    format(data, sizeof(data), "%d/%d/%d", data[2], data[1], data[0]);

    // Cria o arquivo na pasta Banidos
    format(arquivo, sizeof(arquivo), PASTA_BANIDOS, nome);
    DOF2_CreateFile(arquivo);
    DOF2_SetString(arquivo, "Admin", admin);
    DOF2_SetString(arquivo, "Motivo", motivo);
    DOF2_SetString(arquivo, "Data", data);
    DOF2_SaveFile();

    // Mensagem Global
    new str[144];
    format(str, sizeof(str), "| BAN | O Admin %s baniu %s. Motivo: %s", admin, nome, motivo);
    SendClientMessageToAll(0xFF0000AA, str);

    Kick(id); // Chuta do servidor
    return 1;
}

// BANIMENTO POR IP
CMD:banip(playerid, params[])
{
    VerificarAdmin(playerid, 4);
    
    new id, motivo[64];
    if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, COR_ERRO, "Use: /banip [ID] [Motivo]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");

    new ip[16], nome[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerIp(id, ip, sizeof(ip));
    GetPlayerName(id, nome, sizeof(nome));
    GetPlayerName(playerid, admin, sizeof(admin));

    // Cria arquivo na pasta BanidosIP (O nome do arquivo será o IP)
    format(arquivo, sizeof(arquivo), PASTA_BANIP, ip);
    DOF2_CreateFile(arquivo);
    DOF2_SetString(arquivo, "UltimoNick", nome);
    DOF2_SetString(arquivo, "Admin", admin);
    DOF2_SetString(arquivo, "Motivo", motivo);
    DOF2_SaveFile();

    new str[144];
    format(str, sizeof(str), "| BAN-IP | O IP de %s foi banido por %s.", nome, admin);
    SendClientMessageToAll(0xFF0000AA, str);

    Kick(id);
    return 1;
}

CMD:desban(playerid, params[])
{
    VerificarAdmin(playerid, 4);
    new nick[24], arquivo[64];
    
    if(sscanf(params, "s[24]", nick)) return SendClientMessage(playerid, COR_ERRO, "Use: /desban [Nick exato]");
    
    format(arquivo, sizeof(arquivo), PASTA_BANIDOS, nick);
    
    if(DOF2_FileExists(arquivo))
    {
        DOF2_RemoveFile(arquivo); // Deleta o arquivo de ban
        SendClientMessage(playerid, COR_VERDE_NEON, "Jogador desbanido com sucesso!");
    }
    else
    {
        SendClientMessage(playerid, COR_ERRO, "Este jogador nao esta banido (Arquivo nao encontrado).");
    }
    return 1;
}

CMD:dv(playerid, params[])
{
    VerificarAdmin(playerid, 4);
    VerificarTra(playerid);
    new id;
    if(sscanf(params, "i", id)) // Se nao digitar ID, tenta destruir o que esta dentro
    {
        if(IsPlayerInAnyVehicle(playerid)) id = GetPlayerVehicleID(playerid);
        else return SendClientMessage(playerid, COR_ERRO, "Use: /dv [ID]");
    }
    
    DestroyVehicle(id);
    SendClientMessage(playerid, COR_VERDE_NEON, "Veiculo destruido.");
    return 1;
}

CMD:rc(playerid)
{
    VerificarAdmin(playerid, 4);
    for(new i=1; i < MAX_VEHICLES; i++)
    {
        if(!IsVehicleOccupied(i)) SetVehicleToRespawn(i); // Precisa da stock IsVehicleOccupied
    }
    SendClientMessageToAll(COR_V_CLARO, "Todos veiculos vazios foram respawnados.");
    return 1;
}

CMD:av(playerid, params[])
{
    VerificarAdmin(playerid, 5);
    if(isnull(params)) return SendClientMessage(playerid, COR_ERRO, "Use: /av [Mensagem]");
    
    new str[144];
    format(str, sizeof(str), "| ANUNCIO | %s", params);
    GameTextForAll(params, 5000, 3); // Texto na tela
    SendClientMessageToAll(0x00FF00AA, str); // Texto no chat
    return 1;
}

CMD:dargrana(playerid, params[])
{
    VerificarAdmin(playerid, 5);
    new id, quantia;
    if(sscanf(params, "ui", id, quantia)) return SendClientMessage(playerid, COR_ERRO, "Use: /dargrana [ID] [Valor]");
    
    GivePlayerMoney(id, quantia);
    Player[id][pDinheiro] += quantia; // Salva na variavel
    SendClientMessage(playerid, COR_VERDE_NEON, "Dinheiro enviado.");
    return 1;
}

CMD:trazertodos(playerid)
{
    VerificarAdmin(playerid, 5);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && i != playerid)
        {
            SetPlayerPos(i, x+1, y+1, z);
        }
    }
    SendClientMessage(playerid, COR_VERDE_NEON, "Todos trazidos.");
    return 1;
}

CMD:coletetodos(playerid)
{
    VerificarAdmin(playerid, 5);
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i)) SetPlayerArmour(i, 100.0);
    }
    SendClientMessage(playerid, COR_VERDE_NEON, "Colete dado a todos.");
    return 1;
}

CMD:setarniveltodos(playerid, params[])
{
    VerificarAdmin(playerid, 5);
    new nivel;
    if(sscanf(params, "i", nivel)) return SendClientMessage(playerid, COR_ERRO, "Use: /setarniveltodos [Nivel]");
    
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i)) SetPlayerScore(i, nivel);
    }
    SendClientMessage(playerid, COR_VERDE_NEON, "Nivel setado para todos.");
    return 1;
}

CMD:setarnivel(playerid, params[])
{
    VerificarAdmin(playerid, 5);
    new id, nivel;
    if(sscanf(params, "ui", id, nivel)) return SendClientMessage(playerid, COR_ERRO, "Use: /setarnivel [ID] [Nivel]");
    
    SetPlayerScore(id, nivel);
    SendClientMessage(playerid, COR_VERDE_NEON, "Nivel definido.");
    return 1;
}

CMD:criaracc(playerid, params[])
{
    // Verificação de Admin (Descomente e ajuste se precisar)
    // if(Player[playerid][pAdmin] < 1) return 0;

    new modelo, nomeacc[30];
    if(sscanf(params, "ds[30]", modelo, nomeacc)) return SendClientMessage(playerid, COR_ERRO, "Use: /criaracc [ID Objeto] [Nome]");

    new query[150];
    mysql_format(Conexao, query, sizeof(query), "INSERT INTO catalogo_acessorios (modelo, nome) VALUES (%d, '%e')", modelo, nomeacc);
    mysql_tquery(Conexao, query);

    new msg[144];
    format(msg, sizeof(msg), "{00FF00}Sucesso: {FFFFFF}Acessorio '%s' (ID: %d) adicionado ao Catalogo MySQL!", nomeacc, modelo);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:acessorios(playerid)
{
    new lista[1024], string[128];
    lista[0] = '\0';

    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        if(PlayerToys[playerid][i][tSlotOcupado] == 1)
        {
            // Slot Ocupado
            format(string, sizeof(string), "{FFFF00}Slot %d: {FFFFFF}Item ID %d (Equipado)\n", i+1, PlayerToys[playerid][i][tModel]);
        }
        else
        {
            // Slot Vazio
            format(string, sizeof(string), "{00FF00}Slot %d: {A9A9A9}Vazio (Clique para Comprar)\n", i+1);
        }
        strcat(lista, string);
    }

    ShowPlayerDialog(playerid, D_ACC_MENU, DIALOG_STYLE_LIST, "{FFFFFF}Gerenciar Acessorios", lista, "Selecionar", "Fechar");
    return 1;
}

CMD:daradmin(playerid, params[])
{
    // Apenas Fundador (Nível 6) ou RCON Admin
    if(Player[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "Apenas Fundador.");
    
    new id, nivel;
    if(sscanf(params, "ui", id, nivel)) return SendClientMessage(playerid, COR_ERRO, "Use: /daradmin [ID] [Nivel 1-6]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    if(nivel < 1 || nivel > 6) return SendClientMessage(playerid, COR_ERRO, "Nivel invalido (1 a 6).");

    // 1. Seta na variável do jogo e salva na conta
    Player[id][pAdmin] = nivel;
    // SalvarConta(id); (Chame sua função de salvar conta normal aqui se tiver)

    // 2. CRIA ARQUIVO NA PASTA ADMINS (Para registro)
    new nome[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64], data[32];
    GetPlayerName(id, nome, sizeof(nome));
    GetPlayerName(playerid, admin, sizeof(admin));
    getdate(data[0], data[1], data[2]);
    format(data, sizeof(data), "%d/%d/%d", data[2], data[1], data[0]);

    format(arquivo, sizeof(arquivo), PASTA_ADMINS, nome);
    DOF2_CreateFile(arquivo);
    DOF2_SetInt(arquivo, "Nivel", nivel);
    DOF2_SetString(arquivo, "PromovidoPor", admin);
    DOF2_SetString(arquivo, "Data", data);
    DOF2_SaveFile();

    // Mensagens
    new str[128];
    format(str, sizeof(str), "Voce promoveu %s a Admin Nivel %d.", nome, nivel);
    SendClientMessage(playerid, COR_VERDE_NEON, str);
    
    format(str, sizeof(str), "PARABENS! Voce agora e Admin Nivel %d.", nivel);
    SendClientMessage(id, 0x00FFFFAA, str);
    return 1;
}

CMD:tiraradmin(playerid, params[])
{
    if(Player[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COR_ERRO, "Apenas Fundador.");
    
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /tiraradmin [ID]");
    
    // Remove in-game
    Player[id][pAdmin] = 0;
    // SalvarConta(id);
    
    // Remove o arquivo da pasta Admins
    new nome[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerName(id, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), PASTA_ADMINS, nome);
    
    if(DOF2_FileExists(arquivo)) 
    {
        DOF2_RemoveFile(arquivo);
        SendClientMessage(playerid, COR_VERDE_NEON, "Arquivo de Admin deletado e cargo removido.");
    }
    else
    {
        SendClientMessage(playerid, COR_V_CLARO, "Cargo removido (mas nao tinha arquivo na pasta Admins).");
    }
    
    SendClientMessage(id, 0xFF0000AA, "Seu cargo de Admin foi removido.");
    return 1;
}

CMD:desbanip(playerid, params[])
{
    if(Player[playerid][pAdmin] < 6) return SendClientMessage(playerid, COR_ERRO, "Apenas Fundador.");
    
    new ip[16];
    if(sscanf(params, "s[16]", ip)) return SendClientMessage(playerid, COR_ERRO, "Use: /desbanip [IP]");
    
    new str[64];
    format(str, sizeof(str), "unbanip %s", ip);
    SendRconCommand(str);
    SendRconCommand("reloadbans");
    
    SendClientMessage(playerid, COR_VERDE_NEON, "IP Desbanido.");
    return 1;
}

CMD:soltarpoff(playerid, params[])
{
    // Esse comando depende muito de como é seu sistema de salvamento (DOF2)
    // Basicamente voce precisa carregar o arquivo, mudar a variavel Preso pra 0 e salvar
    if(Player[playerid][pAdmin] < 6) return SendClientMessage(playerid, COR_ERRO, "Apenas Fundador.");
    
    new nick[24];
    if(sscanf(params, "s[24]", nick)) return SendClientMessage(playerid, COR_ERRO, "Use: /soltarpoff [Nick]");
    
    new file[64];
    format(file, sizeof(file), PASTA_CONTAS, nick);
    if(DOF2_FileExists(file))
    {
        DOF2_SetInt(file, "Preso", 0);
        DOF2_SaveFile();
        SendClientMessage(playerid, COR_VERDE_NEON, "Jogador offline solto.");
    }
    else
    {
        SendClientMessage(playerid, COR_ERRO, "Conta nao encontrada.");
    }
    return 1;
}


// ATALHO PARA DONO
CMD:virardono(playerid)
{
    Player[playerid][pAdmin] = 5;
    AdminTrabalhando[playerid] = true;
    SetPlayerColor(playerid, COR_STAFF);
    SetPlayerSkin(playerid, 217); 
    SalvarConta(playerid);
    SendClientMessage(playerid, COR_V_CLARO, "Voce agora e DONO (Nivel 5) e entrou em modo trabalho!");
    return 1;
}

// --- TRANCAR O VEÍCULO ---
CMD:trancar(playerid)
{
    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Chegue perto de um veiculo!");

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective); // 1 = Trancado
    
    GameTextForPlayer(playerid, "~r~Trancado", 2000, 3);
    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
    return 1;
}

CMD:criargps(playerid, params[])
{
    // Verifica se é Admin (Ajuste conforme seu sistema)
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem permissao.");

    new categoria[30], nome[30];
    if(sscanf(params, "s[30]S[30]", categoria, nome)) 
        return SendClientMessage(playerid, COR_ERRO, "Use: /criargps [Categoria] [NomeLocal] (Ex: /criargps Garagens Detran)");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // 1. ADICIONA A CATEGORIA NA LISTA (SE NÃO EXISTIR)
    new File:fCat = fopen(ARQUIVO_CATS, io_read);
    new bool:existe = false;
    new string[128];

    // Verifica se a categoria já está escrita no arquivo mestre
    if(fCat)
    {
        while(fread(fCat, string))
        {
            // Remove a quebra de linha para comparar
            if(string[strlen(string)-2] == '\r') string[strlen(string)-2] = '\0';
            else if(string[strlen(string)-1] == '\n') string[strlen(string)-1] = '\0';
            
            if(strcmp(string, categoria, true) == 0) existe = true;
        }
        fclose(fCat);
    }

    // Se não existe, escreve a nova categoria
    if(!existe)
    {
        fCat = fopen(ARQUIVO_CATS, io_append); // Modo Append (Adicionar no final)
        format(string, sizeof(string), "%s\r\n", categoria);
        fwrite(fCat, string);
        fclose(fCat);
    }

    // 2. SALVA O LOCAL DENTRO DO ARQUIVO DA CATEGORIA
    // O arquivo terá o nome da categoria. Ex: GPS/Garagens.txt
    new caminho[64];
    format(caminho, sizeof(caminho), "GPS/%s.txt", categoria);

    new File:fLoc = fopen(caminho, io_append);
    if(fLoc)
    {
        // Formato: Nome|X|Y|Z
        format(string, sizeof(string), "%s|%.2f|%.2f|%.2f\r\n", nome, x, y, z);
        fwrite(fLoc, string);
        fclose(fLoc);

        SendClientMessage(playerid, COR_VERDE_NEON, "GPS: Local Criado com Sucesso!");
        format(string, sizeof(string), "Categoria: %s | Local: %s", categoria, nome);
        SendClientMessage(playerid, -1, string);
    }
    else
    {
        SendClientMessage(playerid, COR_ERRO, "ERRO: Falha ao criar arquivo. Verifique a pasta 'scriptfiles/GPS'.");
    }
    return 1;
}

CMD:gps(playerid)
{
    // Abre o arquivo de categorias e lista no Dialog
    new File:f = fopen(ARQUIVO_CATS, io_read);
    if(!f) return SendClientMessage(playerid, COR_ERRO, "Nenhum local de GPS configurado ainda.");

    new string[128], lista[2000];
    lista[0] = '\0';

    while(fread(f, string))
    {
        strcat(lista, string); // Adiciona a categoria na lista do dialog
    }
    fclose(f);

    if(strlen(lista) < 2) return SendClientMessage(playerid, COR_ERRO, "A lista de categorias está vazia.");

    ShowPlayerDialog(playerid, DIALOG_GPS_CAT, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha a Categoria", lista, "Abrir", "Fechar");
    return 1;
}

CMD:criarfac(playerid, params[])
{
    if(Player[playerid][pAdmin] < 5) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono/Fundador.");

    new corHex, tipo, skin, nome[30];
    
    // Sintaxe Nova: /criarfac [Cor] [Tipo] [Skin] [Nome]
    // h = Hex, d = Int, i = Int, s = String
    if(sscanf(params, "hdis[30]", corHex, tipo, skin, nome))
    {
        SendClientMessage(playerid, COR_V_ESCURO, "USE: /criarfac [CorHEX] [Funcao] [SkinID] [Nome]");
        SendClientMessage(playerid, COR_BRANCO, "FUNCOES: 1=Lavagem | 2=Desmanche | 3=Comum");
        return 1;
    }

    if(tipo < 1 || tipo > 3) return SendClientMessage(playerid, COR_ERRO, "Tipo invalido! Use 1, 2 ou 3.");
    if(skin < 0 || skin > 311) return SendClientMessage(playerid, COR_ERRO, "ID de Skin invalido (0-311).");

    // Procura vaga na memória
    new id = -1;
    for(new i=1; i < MAX_ORGS; i++) {
        if(OrgInfo[i][oCriada] == 0) { id = i; break; }
    }
    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Limite de Orgs atingido!");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // INSERE NO MYSQL (COM A SKIN AGORA)
    new query[300];
    mysql_format(Conexao, query, sizeof(query), 
        "INSERT INTO organizacoes (nome, cor, tipo, skin, pos_x, pos_y, pos_z) VALUES ('%e', %d, %d, %d, %f, %f, %f)",
        nome, corHex, tipo, skin, x, y, z
    );
    mysql_tquery(Conexao, query, "OnFacCriada", "d", id);

    // Define visualmente temporário
    OrgInfo[id][oCriada] = 1;
    format(OrgInfo[id][oNome], 30, nome);
    OrgInfo[id][oCor] = corHex;
    OrgInfo[id][oTipo] = tipo;
    OrgInfo[id][oSkin] = skin; // Salva a skin na memória
    OrgInfo[id][oX] = x; OrgInfo[id][oY] = y; OrgInfo[id][oZ] = z;
    
    // Cria Pickup e Texto
    OrgInfo[id][oPickup] = CreatePickup(1239, 1, x, y, z, -1);
    
    new label[128], funcaoStr[20];
    if(tipo == 1) funcaoStr = "LAVAGEM";
    else if(tipo == 2) funcaoStr = "DESMANCHE";
    else funcaoStr = "GUERRA";

    format(label, sizeof(label), "{FFFFFF}HQ: %s\nFuncao: {FFFF00}%s\n{FFFFFF}Lider: Ninguem", nome, funcaoStr);
    OrgInfo[id][oLabel] = Create3DTextLabel(label, corHex, x, y, z+0.5, 20.0, 0, 0);

    new msg[144];
    format(msg, sizeof(msg), "Faccao criada! ID: %d | Skin Padrao: %d", id, skin);
    SendClientMessage(playerid, COR_VERDE_NEON, msg);
    return 1;
}

// Callback para pegar o ID real do banco
forward OnFacCriada(slotid);
public OnFacCriada(slotid)
{
    OrgInfo[slotid][oID] = cache_insert_id(); // Salva o ID real do banco (1, 2, 50...)
    return 1;
}

CMD:cancelargps(playerid)
{
    if(!CheckpointAtivo[playerid]) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem nenhum GPS ativo.");
    
    DisablePlayerCheckpoint(playerid);
    CheckpointAtivo[playerid] = 0;
    SendClientMessage(playerid, COR_V_CLARO, "GPS desligado.");
    return 1;
}

// --- ABRIR O VEÍCULO ---
CMD:abrir(playerid)
{
    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Chegue perto de um veiculo!");

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective); // 0 = Aberto
    
    GameTextForPlayer(playerid, "~g~Aberto", 2000, 3);
    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
    return 1;
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

// --- COMANDO DIA ---
CMD:dia(playerid)
{
    // Verifica se é Admin (Nivel 1 ou superior)
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem permissao!");

    SetWorldTime(12); // Define o mundo para 12:00 (Meio-dia)
    
    // Manda mensagem para todo mundo saber
    SendClientMessageToAll(COR_V_CLARO, "O Admin colocou o tempo para: DIA.");
    return 1;
}

// --- COMANDO NOITE ---
CMD:noite(playerid)
{
    // Verifica se é Admin
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem permissao!");

    SetWorldTime(0); // Define o mundo para 00:00 (Meia-noite)
    
    // Manda mensagem para todo mundo
    SendClientMessageToAll(COR_V_CLARO, "O Admin colocou o tempo para: NOITE.");
    return 1;
}

// --- COMANDO PARA ABRIR ---
CMD:mochila(playerid, params[])
{
    if(InvAberto[playerid] == false)
    {
        // ABRE
        InvAberto[playerid] = true;
        SlotSelecionado[playerid] = -1; // Reseta seleção ao abrir
        CriarInventarioGrid(playerid);
        AtualizarInventarioGrid(playerid);
        SelectTextDraw(playerid, 0xFFFFFFBD); // Mouse branco translúcido
    }
    else
    {
        // FECHA
        InvAberto[playerid] = false;
        DestruirInventarioGrid(playerid); // Função nova para limpar tudo
        CancelSelectTextDraw(playerid);
    }
    return 1;
}

// 1. TRABALHAR (Muda Skin p/ 217 e avisa o server)
CMD:trabalhar(playerid, params[])
{
    if(Player[playerid][pAdmin] < 1) return SendClientMessage(playerid, COR_ERRO, "Voce nao e Admin!");
    
    new nome[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, nome, sizeof(nome));

    if(AdminTrabalhando[playerid] == false)
    {
        AdminTrabalhando[playerid] = true;
        SetPlayerColor(playerid, COR_STAFF);
        SetPlayerSkin(playerid, 217); // Skin Staff
        
        format(string, sizeof(string), "{00D900}[STAFF INFO] {FFFFFF}O Admin {00D900}%s {FFFFFF}iniciou o atendimento!", nome);
        SendClientMessageToAll(COR_V_ESCURO, string);
        
        SendClientMessage(playerid, COR_V_CLARO, "Voce esta trabalhando com Skin Staff (217).");
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
    }
    else
    {
        AdminTrabalhando[playerid] = false;
        SetPlayerColor(playerid, COR_BRANCO);
        SetPlayerSkin(playerid, 26); // Volta Skin Civil
        
        format(string, sizeof(string), "{00D900}[STAFF INFO] {FFFFFF}O Admin {00D900}%s {FFFFFF}saiu do modo trabalho.", nome);
        SendClientMessageToAll(COR_V_ESCURO, string);
        SendClientMessage(playerid, COR_V_ESCURO, "Voce voltou a ser civil.");
    }
    return 1;
}

// 2. COMANDOSTAFF (Lista)
CMD:comandostaff(playerid)
{
    if(Player[playerid][pAdmin] < 1 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Voce precisa estar trabalhando (/trabalhar).");

    new string[500];
    strcat(string, "{FFFFFF}Nivel 1 (Ajudante):\n{00FF00}/ir /curar /colete /texto /trabalhar\n\n");
    strcat(string, "{FFFFFF}Nivel 2 (Moderador):\n{00FF00}/trazer /kick\n\n");
    strcat(string, "{FFFFFF}Nivel 3 (Admin):\n{00FF00}/v (Criar Carro)\n\n");
    strcat(string, "{FFFFFF}Nivel 4 (Dono):\n{00FF00}/skin (Mudar Roupa)\n\n");
    strcat(string, "{FFFFFF}Nivel 5 (Fundador):\n{00FF00}/daradmin /virardono");

    ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "{00D900}COMANDOS STAFF - BPS", string, "Fechar", "");
    return 1;
}
// 6. V (Criar Veículo)
CMD:v(playerid, params[])
{
    if(Player[playerid][pAdmin] < 3 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Erro: /trabalhar");
    
    new modelo;
    if(sscanf(params, "i", modelo)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /v [ID 400-611]");
    if(modelo < 400 || modelo > 611) return SendClientMessage(playerid, COR_ERRO, "ID Invalido! Use entre 400 e 611.");
    
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new carro = CreateVehicle(modelo, x, y, z, a, -1, -1, -1);
    PutPlayerInVehicle(playerid, carro, 0); // Coloca o admin dentro do carro
    
    SendClientMessage(playerid, COR_V_CLARO, "Veiculo criado!");
    return 1;
}

// 7. CURAR
CMD:curar(playerid, params[])
{
    if(Player[playerid][pAdmin] < 1 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Erro: /trabalhar");
    
    new id;
    if(sscanf(params, "u", id)) 
    {
        SetPlayerHealth(playerid, 100.0); // Cura a si mesmo
        SendClientMessage(playerid, COR_V_CLARO, "Voce curou sua vida.");
    }
    else
    {
        SetPlayerHealth(id, 100.0);
        SendClientMessage(playerid, COR_V_CLARO, "Voce curou o jogador.");
    }
    return 1;
}

// 8. COLETE
CMD:colete(playerid, params[])
{
    if(Player[playerid][pAdmin] < 1 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Erro: /trabalhar");
    
    new id;
    if(sscanf(params, "u", id)) 
    {
        SetPlayerArmour(playerid, 100.0); // Colete em si mesmo
        SendClientMessage(playerid, COR_V_CLARO, "Voce pegou colete.");
    }
    else
    {
        SetPlayerArmour(id, 100.0);
        SendClientMessage(playerid, COR_V_CLARO, "Voce deu colete ao jogador.");
    }
    return 1;
}

// 9. TEXTO (Anuncio Admin)
CMD:texto(playerid, params[])
{
    if(Player[playerid][pAdmin] < 1 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Erro: /trabalhar");
    
    new texto[100], string[144], nome[24];
    if(sscanf(params, "s[100]", texto)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /texto [Mensagem]");
    
    GetPlayerName(playerid, nome, 24);
    format(string, sizeof(string), "ADMIN %s: %s", nome, texto);
    SendClientMessageToAll(COR_GLOBAL, string);
    return 1;
}

CMD:criarorg(playerid, params[])
{
    if(Player[playerid][pAdmin] < 5) return SendClientMessage(playerid, COR_ERRO, "Apenas Dono.");

    new nome[30], corHex;
    // Ex: /criarorg 0xFF0000AA PCC (Cor Vermelha, Nome PCC)
    if(sscanf(params, "xs[30]", corHex, nome)) 
    {
        SendClientMessage(playerid, COR_V_ESCURO, "USE: /criarorg [CorHEX] [Nome]");
        SendClientMessage(playerid, COR_BRANCO, "Exemplos de Cores: Vermelho(FFFF0000) Azul(FF0000FF) Verde(FF00FF00)");
        return 1;
    }

    // Procura um ID livre (slot vazio)
    new id = -1;
    for(new i=1; i < MAX_ORGS; i++)
    {
        if(OrgInfo[i][oCriada] == 0)
        {
            id = i;
            break;
        }
    }

    if(id == -1) return SendClientMessage(playerid, COR_ERRO, "Limite de Orgs atingido!");

    // Pega a posição do admin
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // Salva na Memória
    format(OrgInfo[id][oNome], 30, nome);
    OrgInfo[id][oCor] = corHex;
    OrgInfo[id][oX] = x;
    OrgInfo[id][oY] = y;
    OrgInfo[id][oZ] = z;
    OrgInfo[id][oCriada] = 1;

    // Salva no Arquivo
    new file[64];
    format(file, sizeof(file), PASTA_ORGS, id);
    DOF2_CreateFile(file);
    DOF2_SetString(file, "Nome", nome);
    DOF2_SetInt(file, "Cor", corHex);
    DOF2_SetFloat(file, "X", x);
    DOF2_SetFloat(file, "Y", y);
    DOF2_SetFloat(file, "Z", z);
    DOF2_SaveFile();

    // Cria o visual no jogo na hora
    OrgInfo[id][oPickup] = CreatePickup(1239, 1, x, y, z, -1);
    
    new label[100];
    format(label, sizeof(label), "{FFFFFF}HQ: %s\n{FFFF00}Digite /menuorg", nome);
    Create3DTextLabel(label, corHex, x, y, z+0.5, 20.0, 0, 0);
    
    SetPlayerMapIcon(playerid, id, x, y, z, 31, 0, MAPICON_GLOBAL);

    new msg[128];
    format(msg, sizeof(msg), "Org %s (ID %d) criada com sucesso na sua posicao!", nome, id);
    SendClientMessage(playerid, COR_V_CLARO, msg);
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

// 11. SKIN (Mudar Roupa)
CMD:skin(playerid, params[])
{
    if(Player[playerid][pAdmin] < 4 || !AdminTrabalhando[playerid]) return SendClientMessage(playerid, COR_ERRO, "Erro: /trabalhar");
    
    new id, skinid;
    if(sscanf(params, "ui", id, skinid)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /skin [ID Jogador] [ID Skin]");
    
    if(skinid < 0 || skinid > 311) return SendClientMessage(playerid, COR_ERRO, "Skin invalida (0-311).");
    SetPlayerSkin(id, skinid);
    SendClientMessage(playerid, COR_V_CLARO, "Skin alterada.");
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

CMD:darlider(playerid, params[])
{
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Voce nao e Dono!");
    
    new id, orgid;
    if(sscanf(params, "ui", id, orgid)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /darlider [ID] [ID da Org]");
    
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    // Verifica se a org é válida (1 até MAX_ORGS)
    if(orgid <= 0 || orgid >= MAX_ORGS) return SendClientMessage(playerid, COR_ERRO, "ID de Org invalido.");
    if(OrgInfo[orgid][oCriada] == 0) return SendClientMessage(playerid, COR_ERRO, "Essa Org nao existe (Use /criarfac ou /criarorg).");
    
    // 1. ATUALIZA OS DADOS DO JOGADOR
    Player[id][pOrg] = orgid;
    Player[id][pLider] = 1; // 1 = Lider
    SetPlayerColor(id, OrgInfo[orgid][oCor]); // Muda cor do nick

    // --- NOVA LÓGICA: ATUALIZA A SKIN ---
    if(OrgInfo[orgid][oSkin] > 0)
    {
        SetPlayerSkin(id, OrgInfo[orgid][oSkin]);
        Player[id][pSkin] = OrgInfo[orgid][oSkin]; // Atualiza na variável
        SendClientMessage(id, COR_V_CLARO, "Voce recebeu o uniforme de Lider!");
    }
    // ------------------------------------

    SalvarConta(id); // Salva na tabela 'contas' (já com a skin e org novas)

    // 2. ATUALIZA A MEMÓRIA DA ORG
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(id, nome, sizeof(nome));
    
    // Copia o nome do jogador para a variável da Org
    format(OrgInfo[orgid][oLider], 24, "%s", nome);

    // 3. ATUALIZA O BANCO DE DADOS DA ORG (O PULO DO GATO!)
    new query[256];
    mysql_format(Conexao, query, sizeof(query), "UPDATE organizacoes SET lider='%e' WHERE id=%d", nome, OrgInfo[orgid][oID]);
    mysql_tquery(Conexao, query);
    
    // Avisos
    new msg[128];
    format(msg, sizeof(msg), "Voce setou %s como Lider da org %s (ID %d).", nome, OrgInfo[orgid][oNome], orgid);
    SendClientMessage(playerid, COR_VERDE_NEON, msg);
    
    format(msg, sizeof(msg), "Voce agora e LIDER da %s! Use /menuorg ou /convidar.", OrgInfo[orgid][oNome]);
    SendClientMessage(id, COR_V_CLARO, msg);
    
    return 1;
}

CMD:darsub(playerid, params[])
{
    // Apenas Lider da própria org ou Admin
    new minhaOrg = Player[playerid][pOrg];
    if(Player[playerid][pLider] == 0 && Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Lider ou Admin.");
    
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /darsub [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    // Se for Lider, só pode dar sub pra quem é da mesma org
    if(Player[playerid][pLider] == 1 && Player[id][pOrg] != minhaOrg) return SendClientMessage(playerid, COR_ERRO, "Este jogador nao e da sua org! Convide ele antes.");

    // Se for admin, usa a org que o player já está
    new orgAlvo = Player[id][pOrg];
    if(orgAlvo == 0) return SendClientMessage(playerid, COR_ERRO, "O jogador nao tem organizacao.");

    // 1. Atualiza Jogador
    Player[id][pLider] = 2; // Vamos usar 2 para Sub-Líder
    SalvarConta(id);

    // 2. Atualiza Memória da Org
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(id, nome, sizeof(nome));
    format(OrgInfo[orgAlvo][oSubLider], 24, "%s", nome);

    // 3. Atualiza MySQL da Org
    new query[256];
    mysql_format(Conexao, query, sizeof(query), "UPDATE organizacoes SET sublider='%e' WHERE id=%d", nome, OrgInfo[orgAlvo][oID]);
    mysql_tquery(Conexao, query);

    SendClientMessage(playerid, COR_VERDE_NEON, "Sub-Lider definido com sucesso!");
    SendClientMessage(id, COR_V_CLARO, "Voce foi promovido a Sub-Lider!");
    return 1;
}

// 2. CONVIDAR (Comando de Lider)
CMD:convidar(playerid, params[])
{
    if(Player[playerid][pLider] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao e Lider!");
    if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem Org!");

    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /convidar [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    if(Player[id][pOrg] != 0) return SendClientMessage(playerid, COR_ERRO, "Esse jogador ja tem Org/Faccao.");
    
    InviteOrg[id] = Player[playerid][pOrg]; // Salva qual org convidou
    
    new string[128], nome[24];
    GetPlayerName(playerid, nome, 24);
    
    format(string, sizeof(string), "O Lider %s te convidou para a %s. Digite /aceitar", nome, GetOrgName(Player[playerid][pOrg]));
    SendClientMessage(id, COR_V_CLARO, string);
    SendClientMessage(playerid, COR_V_CLARO, "Convite enviado.");
    return 1;
}

CMD:celular(playerid)
{
    if(CelularAberto[playerid] == false)
    {
        // ABRE O CELULAR
        CelularAberto[playerid] = true;
        
        // Atualiza o relógio para a hora certa antes de mostrar
        new hora, minuto, segundo; // Adicionei 'segundo' para evitar avisos
        gettime(hora, minuto, segundo);
        
        new strHora[10];
        format(strHora, sizeof(strHora), "%02d:%02d", hora, minuto);
        PlayerTextDrawSetString(playerid, Celular[playerid][2], strHora);

        // Mostra todas as peças
        for(new i=0; i < 16; i++) PlayerTextDrawShow(playerid, Celular[playerid][i]);
        
        SelectTextDraw(playerid, 0xFF0000FF); // Mouse Vermelho
    }
    else
    {
        // FECHA O CELULAR
        CelularAberto[playerid] = false;
        //for(new i=0; i < 16; i++) PlayerTextDrawHide(playerid, Celular[playerid][i]);
        
        // Esconde Banco se estiver aberto
        // TextDrawHideForPlayer(playerid, TD_BancoFundo);
        // TextDrawHideForPlayer(playerid, TD_BancoTitulo);
        // TextDrawHideForPlayer(playerid, TD_BtnPix);
        // TextDrawHideForPlayer(playerid, TD_BtnSair);
        // PlayerTextDrawHide(playerid, PTD_Saldo);
        
        CancelSelectTextDraw(playerid);
    }
    return 1;
}

CMD:aceitar(playerid)
{
    if(InviteOrg[playerid] == 0) return SendClientMessage(playerid, COR_ERRO, "Ninguem te convidou.");
    
    new orgid = InviteOrg[playerid];
    
    // Verifica se a org ainda existe
    if(OrgInfo[orgid][oCriada] == 0) return SendClientMessage(playerid, COR_ERRO, "Essa org nao existe mais.");

    Player[playerid][pOrg] = orgid;
    Player[playerid][pLider] = 0;
    InviteOrg[playerid] = 0;
    
    // Seta a cor da org
    SetPlayerColor(playerid, OrgInfo[orgid][oCor]);

    // --- NOVA LÓGICA: ATUALIZA A SKIN ---
    if(OrgInfo[orgid][oSkin] > 0)
    {
        SetPlayerSkin(playerid, OrgInfo[orgid][oSkin]);
        Player[playerid][pSkin] = OrgInfo[orgid][oSkin]; // Atualiza na variável para salvar no banco depois
        SendClientMessage(playerid, COR_V_CLARO, "Voce recebeu o uniforme da faccao!");
    }
    // ------------------------------------
    
    SalvarConta(playerid);
    
    new string[128];
    format(string, sizeof(string), "Parabens! Agora voce e membro da %s.", GetOrgName(orgid));
    SendClientMessage(playerid, COR_V_CLARO, string);
    return 1;
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

// 4. DEMITIR (Lider expulsa membro)
CMD:demitir(playerid, params[])
{
    if(Player[playerid][pLider] != 1 && Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Apenas Lideres.");
    
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /demitir [ID]");
    
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    // Verifica se é da mesma org (se não for admin)
    if(Player[playerid][pAdmin] < 4 && Player[id][pOrg] != Player[playerid][pOrg]) return SendClientMessage(playerid, COR_ERRO, "Ele nao e da sua faccao.");
    
    if(id == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode se demitir.");

    new orgid = Player[id][pOrg];

    // Se o cara era Sub-Líder, limpa o nome dele da tabela da Org
    if(Player[id][pLider] == 2)
    {
        format(OrgInfo[orgid][oSubLider], 24, "Ninguem");
        new query[128];
        mysql_format(Conexao, query, sizeof(query), "UPDATE organizacoes SET sublider='Ninguem' WHERE id=%d", OrgInfo[orgid][oID]);
        mysql_tquery(Conexao, query);
    }

    // Reseta o jogador
    Player[id][pOrg] = 0;
    Player[id][pLider] = 0;
    SetPlayerColor(id, 0xFFFFFFFF); // Branco
    SalvarConta(id); // Salva na tabela contas
    
    SendClientMessage(playerid, COR_V_CLARO, "Membro demitido.");
    SendClientMessage(id, COR_ERRO, "Voce foi demitido da organizacao.");
    return 1;
}

// 5. RADIO (/r)
CMD:r(playerid, params[])
{
    if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem org.");
    
    new texto[100];
    if(sscanf(params, "s[100]", texto)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /r [Mensagem]");
    
    new string[144], nome[24];
    GetPlayerName(playerid, nome, 24);
    
    // Pega o nome da org direto da memória do novo sistema
    new nomeOrg[30];
    new orgid = Player[playerid][pOrg];
    
    if(OrgInfo[orgid][oCriada] == 1) format(nomeOrg, 30, OrgInfo[orgid][oNome]);
    else format(nomeOrg, 30, "Org %d", orgid);

    format(string, sizeof(string), "(Radio %s) %s: %s", nomeOrg, nome, texto);
    
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pOrg] == orgid)
        {
            SendClientMessage(i, 0x87CEEBFF, string); // Cor Azul Claro padrão pra radio
        }
    }
    return 1;
}

CMD:darmoney(playerid, params[])
{
    // Verifica se é Admin Nível 4 ou superior
    if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, COR_ERRO, "Voce precisa ser Admin Nivel 4+.");
    
    new id, valor;
    // Verifica se digitou certo: /darmoney [ID] [QUANTIA]
    if(sscanf(params, "ui", id, valor)) return SendClientMessage(playerid, COR_V_ESCURO, "USE: /darmoney [ID] [Valor]");
    
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador offline.");
    
    // Dá o dinheiro
    GivePlayerMoney(id, valor);
    Player[id][pDinheiro] += valor; // Soma ao que ele já tem
    
    // Salva na hora para garantir
    SalvarConta(id);
    
    // Avisos
    new string[128], nome[24], nomeAdmin[24];
    GetPlayerName(playerid, nomeAdmin, 24);
    GetPlayerName(id, nome, 24);
    
    format(string, sizeof(string), "Voce deu R$ %d para o jogador %s.", valor, nome);
    SendClientMessage(playerid, COR_V_CLARO, string);
    
    format(string, sizeof(string), "O Admin %s te deu R$ %d. Aproveite!", nomeAdmin, valor);
    SendClientMessage(id, COR_V_CLARO, string);
    
    return 1;
}

// --- COLOCAR NO PORTA MALAS (SEQUESTRAR) ---
CMD:sequestrar(playerid, params[])
{
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /sequestrar [ID]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COR_ERRO, "Jogador desconectado.");
    if(id == playerid) return SendClientMessage(playerid, COR_ERRO, "Voce nao pode se sequestrar.");
    
    // Verifica distância
    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, x, y, z)) return SendClientMessage(playerid, COR_ERRO, "Chegue mais perto do jogador!");
    
    // Verifica veículo próximo
    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COR_ERRO, "Voces precisam estar perto de um carro!");
    
    // AÇÃO
    // Coloca no Banco de trás (ID 2 ou 3) para "simular" o porta malas
    PutPlayerInVehicle(id, vehicleid, 2); 
    TogglePlayerControllable(id, 0); // Congela
    
    // Mostra tela preta
    CriarVenda(id);
    PlayerTextDrawShow(id, TD_Venda[id]);
    
    SequestradoPor[id] = vehicleid;
    
    SendClientMessage(playerid, COR_VERDE_NEON, "Voce jogou o cidadao no porta-malas!");
    SendClientMessage(id, COR_ERRO, "Voce foi jogado no porta-malas!");
    return 1;
}

// --- TIRAR DO PORTA MALAS ---
CMD:liberar(playerid, params[])
{
    new id;
    if(sscanf(params, "u", id)) return SendClientMessage(playerid, COR_ERRO, "Use: /liberar [ID]");
    if(SequestradoPor[id] == 0) return SendClientMessage(playerid, COR_ERRO, "Este jogador nao esta sequestrado.");
    
    // Tira do carro e descongela
    RemovePlayerFromVehicle(id);
    TogglePlayerControllable(id, 1);
    PlayerTextDrawHide(id, TD_Venda[id]); // Tira a tela preta
    SequestradoPor[id] = 0;
    
    SendClientMessage(playerid, COR_VERDE_NEON, "Voce liberou o jogador.");
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

CMD:lavar(playerid)
{
    // 1. Verifica se tem Org e se é de Lavagem (Tipo 1)
    if(Player[playerid][pOrg] == 0) return SendClientMessage(playerid, COR_ERRO, "Voce nao pertence a uma faccao.");
    
    // Verifica o TIPO da org no banco de dados (que carregamos na memória)
    new orgid = Player[playerid][pOrg];
    if(OrgInfo[orgid][oTipo] != 1) return SendClientMessage(playerid, COR_ERRO, "Sua faccao nao trabalha com lavagem de dinheiro.");

    // 2. Verifica se está na HQ (Perto do Pickup da Org)
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, OrgInfo[orgid][oX], OrgInfo[orgid][oY], OrgInfo[orgid][oZ])) 
        return SendClientMessage(playerid, COR_ERRO, "Voce precisa estar na HQ para usar a maquina de lavar.");

    // 3. Procura o Dinheiro Sujo na Mochila
    new slot = -1;
    for(new i=0; i < MAX_INV_SLOTS; i++)
    {
        if(InvItem[playerid][i] == ITEM_DINHEIRO_SUJO)
        {
            slot = i;
            break;
        }
    }

    if(slot == -1) return SendClientMessage(playerid, COR_ERRO, "Voce nao tem Dinheiro Sujo na mochila.");

    // 4. A MÁGICA: Converte e Limpa
    new quantia = InvQtd[playerid][slot];
    
    // Remove o item da mochila
    InvItem[playerid][slot] = 0;
    InvQtd[playerid][slot] = 0;
    
    // Dá o dinheiro limpo na mão
    GivePlayerMoney(playerid, quantia);
    Player[playerid][pDinheiro] += quantia;
    
    // Atualiza o banco de dados (Salva mochila e conta)
    SalvarInventario(playerid);
    SalvarConta(playerid);

    // Visual e Som
    ApplyAnimation(playerid, "DEALER", "DEALER_DEAL", 4.1, 0, 0, 0, 0, 0, 0);
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0); // Som de caixa registradora
    
    new str[128];
    format(str, sizeof(str), "{00FF00}LAVAGEM CONCLUIDA: {FFFFFF}Voce limpou R$ %d. O dinheiro esta na sua mao.", quantia);
    SendClientMessage(playerid, -1, str);
    
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

// 6. orgs (/orgs)
CMD:orgs(playerid)
{
    new string[1500], linha[128], membros[MAX_ORGS];
    
    // Contar membros on
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pOrg] > 0)
            membros[Player[i][pOrg]]++;
    }

    strcat(string, "ID\tOrganizacao\tLider\tStatus\tMembros\n");

    for(new i=1; i < MAX_ORGS; i++)
    {
        if(OrgInfo[i][oCriada] == 1) // Só mostra se a org existe
        {
            // Pega nome do lider do arquivo de Lideres.ini (que já fizemos antes)
            new chaveLider[20];
            format(chaveLider, 20, "Lider%d", i); // Ex: Lider1, Lider2
            
            // Nota: Você precisará adaptar o sistema de salvamento de lider para usar IDs agora
            // Por enquanto, vamos mostrar "Desconhecido" se não tiver salvo ainda
            
            format(linha, sizeof(linha), "{FFFFFF}%d\t%s\t-\t-\t%d\n", i, OrgInfo[i][oNome], membros[i]);
            strcat(string, linha);
        }
    }
    ShowPlayerDialog(playerid, DIALOG_ORGS, DIALOG_STYLE_TABLIST_HEADERS, "Orgs do Servidor", string, "Fechar", "");
    return 1;
}
// Função para tocar a música com atraso (para dar tempo do jogo carregar)
forward TocarMusicaLogin(playerid);
public TocarMusicaLogin(playerid)
{
    if(IsPlayerConnected(playerid) && !IsLogged[playerid])
    {
        // Link de teste (Radio Antena 1 - Geralmente funciona bem em mobile)
        PlayAudioStreamForPlayer(playerid, "http://som.brasilplaygames.com.br/som/bem.mp3");
        
        // Mensagem de Debug para você saber que o servidor tentou tocar
        SendClientMessage(playerid, COR_V_CLARO, "Carregando musica de fundo...");
    }
    return 1;S
}
// --- SISTEMA 3: PAYDAY AUTOMÁTICO (CORRIGIDO E BONITO) ---
public RelogioPayday()
{
    // Esse loop roda em todos os jogadores a cada 1 minuto
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsLogged[i])
        {
            Player[i][pTempo]++; // Adiciona +1 minuto
            
            // Se chegou a 60 minutos (1 hora)
            // (Se quiser testar rápido, mude 60 para 2)
            if(Player[i][pTempo] >= 1)
            {
                Player[i][pTempo] = 0; // Zera o contador
                
                // --- CÁLCULOS ---
                new salario = 1500; // Salário Base de Civil
                new bonus = 0;
                
                // NOVO SISTEMA: Se o ID da Org for maior que 0, ele tem org.
                // Ganha bonus fixo independente do nome da org.
                if(Player[i][pOrg] > 0) bonus = 1200;
                
                // Bonus extra se for Admin
                if(Player[i][pAdmin] > 0) bonus += 500;

                new total = salario + bonus;
                
                // --- ENTREGA O DINHEIRO ---
                GivePlayerMoney(i, total);
                Player[i][pDinheiro] += total;
                SetPlayerScore(i, GetPlayerScore(i) + 1); // Ganha 1 de Score (Level)
                
                SalvarConta(i); // Salva tudo para garantir
                
                // --- MENSAGEM BONITA (VISUAL QUE VOCÊ PEDIU) ---
                SendClientMessage(i, COR_V_CLARO, "|__________________ PAYDAY BPS __________________|");
                SendClientMessage(i, -1, "Voce recebeu seu pagamento por jogar 1 hora!");
                
                new str[128];
                format(str, sizeof(str), "Salario Base: R$ %d | Bonus Org/Admin: R$ %d", salario, bonus);
                SendClientMessage(i, -1, str);
                
                format(str, sizeof(str), "{00FF00}TOTAL RECEBIDO: R$ %d  |  +1 RESPECT (Nivel)", total);
                SendClientMessage(i, -1, str);
                SendClientMessage(i, COR_V_CLARO, "|________________________________________________|");
                
                // Toca um som de dinheiro (Caixa Registradora)
                PlayerPlaySound(i, 1052, 0.0, 0.0, 0.0);
            }
        }
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
       
    

    // ============================================================
    // 5. SISTEMA DE CELULAR (EM MANUTENÇÃO / BLOQUEADO)
    // ============================================================
    
    // 1. BOTÃO HOME (ID 7) - ESSE PRECISA FUNCIONAR PRA FECHAR
    if(playertextid == Celular[playerid][7])
    {
        cmd_celular(playerid, ""); // Fecha o celular
        return 1;
    }

    // 2. NUBANK (ID 3) - DESATIVADO
    if(playertextid == Celular[playerid][3])
    {
        SendClientMessage(playerid, 0xFFFF00AA, "[CELULAR] App do Banco em manutencao tecnica.");
        return 1;
    }
    
    // 3. ZAP (ID 5) - DESATIVADO
    if(playertextid == Celular[playerid][5])
    {
        SendClientMessage(playerid, 0xFFFF00AA, "[CELULAR] WhatsApp atualizando... Aguarde.");
        return 1;
    }

    // 4. GPS (ID 13) - MANTIDO PELA COMPATIBILIDADE, MAS DESATIVADO
    // (Se no futuro der erro aqui, remova este bloco)
    if(playertextid == Celular[playerid][13])
    {
        SendClientMessage(playerid, 0xFFFF00AA, "[CELULAR] GPS sem sinal de satelite.");
        return 1;
    }
    
    return 0; // <--- ESTA CHAVE FALTAVA NO SEU CÓDIGO
}

stock CriarCelular(playerid)
{
    // Limpa anteriores para evitar duplicidade
    //for(new i=0; i < 20; i++) PlayerTextDrawDestroy(playerid, Celular[playerid][i]);

    // BASE X e Y (Canto Inferior Direito)
    new Float:BaseX = 510.0;
    new Float:BaseY = 230.0;

    return 1;
}

// --- FUNÇÃO PARA DESTRUIR TUDO AO FECHAR (LIMPEZA) ---
stock DestruirInventarioGrid(playerid)
{
    for(new i=0; i < 12; i++) PlayerTextDrawDestroy(playerid, TD_InvUI[playerid][i]);
    for(new i=0; i < MAX_INV_SLOTS; i++)
    {
        PlayerTextDrawDestroy(playerid, TD_InvSlotBG[playerid][i]);
        PlayerTextDrawDestroy(playerid, TD_InvSlotItem[playerid][i]);
        PlayerTextDrawDestroy(playerid, TD_InvSlotQtd[playerid][i]);
    }
    return 1;
}

stock CriarInventarioGrid(playerid)
{

    return 1;
}

stock AtualizarInventarioGrid(playerid)
{
    // 1. Mostra a interface base
    for(new i=0; i < 12; i++) PlayerTextDrawShow(playerid, TD_InvUI[playerid][i]);

    // 2. Loop para preencher os 16 slots
    for(new i=0; i < MAX_INV_SLOTS; i++)
    {
        if(InvItem[playerid][i] > 0)
        {
            // TEM ITEM NO SLOT: Mostra nome e quantidade
            new strQtd[10];
            format(strQtd, sizeof(strQtd), "%d", InvQtd[playerid][i]);
            PlayerTextDrawSetString(playerid, TD_InvSlotQtd[playerid][i], strQtd);

// --- BLOCO CORRIGIDO ---
            if(InvItem[playerid][i] == 1) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Celular");
            else if(InvItem[playerid][i] == 2) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Kit Rep.");
            else if(InvItem[playerid][i] == 4) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Din. Sujo");
            else if(InvItem[playerid][i] == ITEM_MOTOR) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Motor");
            else if(InvItem[playerid][i] == ITEM_CHASSI) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Chassi");
            else if(InvItem[playerid][i] == ITEM_RODAS) PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Rodas");
            
            // O "else" final fica aqui embaixo. Se não for nenhum dos de cima, vira "Item".
            else PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Item"); 
            // -----------------------
        }
        else
        {
            // SLOT VAZIO: Esconde a quantidade e põe "Vazio"
            PlayerTextDrawSetString(playerid, TD_InvSlotQtd[playerid][i], " ");
            PlayerTextDrawSetString(playerid, TD_InvSlotItem[playerid][i], "Vazio");
            PlayerTextDrawColor(playerid, TD_InvSlotItem[playerid][i], 0x888888FF); // Cinza se vazio
        }

        // Mostra as camadas do slot
        PlayerTextDrawShow(playerid, TD_InvSlotBG[playerid][i]);
        PlayerTextDrawShow(playerid, TD_InvSlotItem[playerid][i]);
        PlayerTextDrawShow(playerid, TD_InvSlotQtd[playerid][i]);
    }
    
    // SE TIVER UM SLOT SELECIONADO, PINTA ELE DE VERDE
    if(SlotSelecionado[playerid] != -1)
    {
         PlayerTextDrawBoxColor(playerid, TD_InvSlotBG[playerid][SlotSelecionado[playerid]], 0x00FF0055); // Verde transparente
         PlayerTextDrawShow(playerid, TD_InvSlotBG[playerid][SlotSelecionado[playerid]]); // Atualiza a cor
    }
    return 1;
}

// Cria a tela preta (Venda)
stock CriarVenda(playerid)
{
    TD_Venda[playerid] = CreatePlayerTextDraw(playerid, -20.0, -20.0, "_");
    PlayerTextDrawUseBox(playerid, TD_Venda[playerid], 1);
    PlayerTextDrawBoxColor(playerid, TD_Venda[playerid], 0x000000FF); // Preto Total
    PlayerTextDrawTextSize(playerid, TD_Venda[playerid], 660.0, 500.0); // Tela toda
    PlayerTextDrawLetterSize(playerid, TD_Venda[playerid], 0.0, 50.0);
    return 1;
}

// Pega o veículo mais perto do jogador (Raio de 3 metros)
stock GetClosestVehicle(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i=1; i < MAX_VEHICLES; i++)
    {
        if(GetVehicleModel(i) > 0) // Se o carro existe
        {
            if(GetVehicleDistanceFromPoint(i, x, y, z) < 4.0) return i;
        }
    }
    return INVALID_VEHICLE_ID;
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

stock AddItemMochila(playerid, itemid, quantidade)
{
    // 1. Tenta achar se já tem o item para somar (stack)
    for(new i=0; i < 16; i++) // 16 é o tamanho da mochila grid
    {
        if(InvItem[playerid][i] == itemid)
        {
            InvQtd[playerid][i] += quantidade;
            return 1; // Sucesso
        }
    }
    // 2. Se não tem, procura um slot vazio (0)
    for(new i=0; i < 16; i++)
    {
        if(InvItem[playerid][i] == 0)
        {
            InvItem[playerid][i] = itemid;
            InvQtd[playerid][i] = quantidade;
            return 1; // Sucesso
        }
    }
    return 0; // Mochila cheia
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
// Tecla H (Garagem)
    if(newkeys == KEY_CROUCH)
    {
        // Verifica se está a pé e perto de uma garagem
        if(!IsPlayerInAnyVehicle(playerid))
        {
            cmd_garagem(playerid, "");
        }
    }

    // Tecla H (Geralmente é KEY_CROUCH a pé ou KEY_CTRL_BACK)
    if(newkeys == KEY_CROUCH) 
    {
        // Verifica se está perto de um carro (mas fora dele)
        new vehicleid = GetClosestVehicle(playerid); // Usando a stock que criamos antes
        if(vehicleid != INVALID_VEHICLE_ID)
        {
            // Pega o estado da porta
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

            if(doors == 1) // 1 = TRANCADO
            {
                // Inicia o Minigame para tentar abrir
                SendClientMessage(playerid, COR_V_CLARO, "Iniciando Lockpick... Acerte o alvo!");
                ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 0, 0, 0); // Animação
                IniciarLockPick(playerid, vehicleid);
            }
            else // 0 = DESTRANCADO
            {
                // Tranca o carro (Para teste ou dono)
                SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
                GameTextForPlayer(playerid, "~r~Trancado", 2000, 3);
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
            }
        }
    }
    // Tecla N (KEY_NO) para abrir a Mochila
    if(newkeys == KEY_NO)
    {
        // Verifica se não está dirigindo (pra não abrir sem querer)
        if(!IsPlayerInAnyVehicle(playerid)) 
        {
            cmd_mochila(playerid, ""); // Chama o comando
        }
    }
    return 1;
}

// Função para pegar a velocidade em KM/H
stock GetVehicleSpeed(vehicleid)
{
    new Float:x, Float:y, Float:z;
    GetVehicleVelocity(vehicleid, x, y, z);
    return floatround(floatsqroot(x*x + y*y + z*z) * 180.0); // *180 aprox para KM/H
}

// Função para pegar o nome do carro
stock GetVehicleName(vehicleid)
{
    new nome[32];
    // Lista simplificada ou use uma include a_samp se tiver GetVehicleModelInfo
    // Aqui vou usar um método simples que retorna "Veiculo" se não tiver array de nomes
    format(nome, 32, "Veiculo ID: %d", GetVehicleModel(vehicleid)); 
    // OBS: Se você tiver a função ReturnVehicleModelName no seu GM, troque aqui!
    return nome;
}

stock CriarVelocimetro(playerid)
{
 

    return 1;
}

forward AtualizarVelocimetroGlobal();
public AtualizarVelocimetroGlobal()
{
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i))
        {
            new veiculo = GetPlayerVehicleID(i);
            new vel = GetVehicleSpeed(veiculo);
            new Float:vida;
            GetVehicleHealth(veiculo, vida);
            
            // ATUALIZA NOME (Opcional, se quiser tirar pra ficar mais leve pode)
            // PlayerTextDrawSetString(i, TD_Velocimetro[i][0], GetVehicleName(veiculo));

            // ATUALIZA VELOCIDADE (ID 1)
            new strVel[10];
            format(strVel, sizeof(strVel), "%d", vel);
            PlayerTextDrawSetString(i, TD_Velocimetro[i][1], strVel);
            
            // ATUALIZA BARRA DE VIDA (ID 3)
            // A barra começa no X=270. O tamanho total é 100.
            new Float:tamanhoBarra = (vida - 250.0) / 7.5; 
            if(tamanhoBarra < 0) tamanhoBarra = 0;
            if(tamanhoBarra > 100) tamanhoBarra = 100.0;
            
            // 270.0 é o ponto inicial da esquerda. Somamos a vida para crescer p/ direita.
            PlayerTextDrawTextSize(i, TD_Velocimetro[i][3], 270.0 + tamanhoBarra, 0.0);
            
            // Muda cor
            if(vida > 700) PlayerTextDrawBoxColor(i, TD_Velocimetro[i][3], 0x00FF00FF); // Verde
            else if(vida > 400) PlayerTextDrawBoxColor(i, TD_Velocimetro[i][3], 0xFFFF00FF); // Amarelo
            else PlayerTextDrawBoxColor(i, TD_Velocimetro[i][3], 0xFF0000FF); // Vermelho
            
            PlayerTextDrawShow(i, TD_Velocimetro[i][1]); // Atualiza numero
            PlayerTextDrawShow(i, TD_Velocimetro[i][3]); // Atualiza barra
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    // ENTROU NO CARRO (Como Motorista ou Passageiro)
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        // 1. Cria
        CriarVelocimetro(playerid);
        
        // 2. Define o nome do carro antes de mostrar
        // Se você tiver uma função que pega nome real, use aqui. Senão vai mostrar ID.
        // PlayerTextDrawSetString(playerid, TD_Velocimetro[playerid][1], NomeDoCarro(veiculo));
        
        // 3. Mostra tudo
        for(new i=0; i < 4; i++) PlayerTextDrawShow(playerid, TD_Velocimetro[playerid][i]);
    }
    
    // SAIU DO CARRO (Ou foi a pé)
    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        // Esconde e Destroi para liberar memória
        for(new i=0; i < 5; i++) 
        {
            PlayerTextDrawHide(playerid, TD_Velocimetro[playerid][i]);
            PlayerTextDrawDestroy(playerid, TD_Velocimetro[playerid][i]);
        }
    }
    
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

stock CriarConcePremium(playerid)
{
    // Destroi qualquer lixo anterior para garantir que não duplique
    FecharMenuConce(playerid); 
    ConceAberta[playerid] = true;

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

stock CriarGarageUI(playerid)
{
    // Limpa anterior para evitar sobreposição
    FecharGarageUI(playerid);
    GaragemAberta[playerid] = true;
    
    // 1. FUNDO TELA CHEIA (AGORA USANDO TEXTURA PARA GARANTIR COR)


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

// --- STOCKS ÚTEIS (COLE NO FINAL DO GM) ---

stock GetPlayerNameEx(playerid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    return nome;
}

stock IsVehicleOccupied(vehicleid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInVehicle(i, vehicleid)) return 1;
    }
    return 0;
}

forward AtualizarRodape();
public AtualizarRodape()
{
    // Pega a hora do servidor (VPS)
    new dia, mes, ano;
    new horas, minutos, segundos; 
    
    getdate(ano, mes, dia);
    gettime(horas, minutos, segundos);

    // --- CORREÇÃO DE FUSO HORÁRIO (BRASIL) ---
    horas = horas - 3; 
    if(horas < 0) horas += 24;
    // -----------------------------------------

    // Formata a String da Data (Esquerda)
    new strData[128];
    format(strData, sizeof(strData), "%02d DE %s %d~n~%02d:%02d:%02d", dia, NomeMeses[mes-1], ano, horas, minutos, segundos);

    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            // Atualiza Data/Hora
            PlayerTextDrawSetString(i, PTD_DataHora[i], strData);

            // Lógica do Payday
            if(pPaydayTempo[i] > 0) pPaydayTempo[i]--;

            // Converte segundos do Payday para Hora:Min:Seg
            new pdHora = pPaydayTempo[i] / 3600;
            new pdMin = (pPaydayTempo[i] % 3600) / 60;
            new pdSeg = (pPaydayTempo[i] % 3600) % 60;

            // Formata a String dos Stats (Direita)
            new strStats[150];
            
            // AGORA SIM: Mostrando CPF e Bitcoin oficiais
            format(strStats, sizeof(strStats), "CPF:%d  ~y~B:%d  ~w~RECOMPENSA: %02d:%02d:%02d", 
                Player[i][pCpf], Player[i][pBitcoin], pdHora, pdMin, pdSeg);

            PlayerTextDrawSetString(i, PTD_Stats[i], strStats);
        }
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
    new str[144], nome[24];
    GetPlayerName(playerid, nome, 24);

    // --- SE ESTIVER TRABALHANDO ---
    if(Trabalhando[playerid])
    {
        // Formato: Nome[ID] [CARGO] diz: Texto
        // Ex: Kong[0] [FUNDADOR] diz: teste
        format(str, sizeof(str), "%s[%d] {00FF00}[%s]{FFFFFF} diz: %s", nome, playerid, GetCargoAdmin(playerid), text);
        
        // Envia para quem está perto (Chat Local)
        SendClientMessageToAllXYZ(playerid, str); 
        
        return 0; // Bloqueia o chat padrão do SAMP para não duplicar
    }

    // --- SE ESTIVER FORA DE TRABALHO (CIVIL) ---
    // Formato: Nome[ID] diz: Texto
    format(str, sizeof(str), "%s[%d] diz: %s", nome, playerid, text);
    SendClientMessageToAllXYZ(playerid, str);

    return 0; // Retorna 0 para usar nosso sistema de chat e não o do SAMP
}

// --- FUNÇÃO AUXILIAR PARA MANDAR MENSAGEM SÓ PRA QUEM TÁ PERTO ---
// (Coloque no final do GM se não tiver)
stock SendClientMessageToAllXYZ(playerid, text[])
{
    new Float:Pos[3];
    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            if(IsPlayerInRangeOfPoint(i, 20.0, Pos[0], Pos[1], Pos[2])) // 20 metros de distancia
            {
                SendClientMessage(i, 0xFFFFFFFF, text);
            }
        }
    }
    return 1;
}

// Função para pegar o nome do cargo baseado no nível
stock GetCargoAdmin(playerid)
{
    new cargo[24];
    switch(Player[playerid][pAdmin])
    {
        case 1: cargo = "HELPER";
        case 2: cargo = "ADMINISTRADOR";
        case 3: cargo = "ADMIN MASTER";
        case 4: cargo = "GERENTE";
        case 5: cargo = "DONO";
        case 6: cargo = "FUNDADOR";
        default: cargo = "ERRO";
    }
    return cargo;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(CheckpointAtivo[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        CheckpointAtivo[playerid] = 0;
        SendClientMessage(playerid, COR_VERDE_NEON, "GPS: Voce chegou ao seu destino!");
        PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0); // Som de chegada
        return 1;
    }
    
    // ... Seus outros códigos de checkpoint (missões, etc) ...
    return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    // Se response = 1, o player clicou em Salvar
    if(response)
    {
        // Atualiza as variáveis com a nova posição que o player escolheu
        PlayerToys[playerid][index][tX] = fOffsetX;
        PlayerToys[playerid][index][tY] = fOffsetY;
        PlayerToys[playerid][index][tZ] = fOffsetZ;
        
        PlayerToys[playerid][index][tRX] = fRotX;
        PlayerToys[playerid][index][tRY] = fRotY;
        PlayerToys[playerid][index][tRZ] = fRotZ;
        
        PlayerToys[playerid][index][tSX] = fScaleX;
        PlayerToys[playerid][index][tSY] = fScaleY;
        PlayerToys[playerid][index][tSZ] = fScaleZ;
        
        // Reaplica o objeto com as novas coordenadas fixas
        SetPlayerAttachedObject(playerid, index, modelid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
        
        SalvarToys(playerid); // Salva no arquivo
        SendClientMessage(playerid, COR_VERDE_NEON, "Acessorio ajustado e salvo com sucesso!");
    }
    else
    {
        // Se clicou em cancelar, volta como estava antes (opcional, aqui vou deixar salvo apenas se confirmar)
        SendClientMessage(playerid, COR_V_CLARO, "Edicao cancelada.");
        
        // Recarrega a posição antiga salva
        new i = index;
        if(PlayerToys[playerid][i][tSlotOcupado])
        {
             SetPlayerAttachedObject(playerid, i, PlayerToys[playerid][i][tModel], PlayerToys[playerid][i][tBone], 
                PlayerToys[playerid][i][tX], PlayerToys[playerid][i][tY], PlayerToys[playerid][i][tZ], 
                PlayerToys[playerid][i][tRX], PlayerToys[playerid][i][tRY], PlayerToys[playerid][i][tRZ], 
                PlayerToys[playerid][i][tSX], PlayerToys[playerid][i][tSY], PlayerToys[playerid][i][tSZ]);
        }
    }
    return 1;
}

// --- CALLBACKS E FUNÇÕES DO SISTEMA DE CONTAS ---

forward VerificarConta(playerid);
public VerificarConta(playerid)
{
    // Se achou linhas, a conta EXISTE
    if(cache_num_rows() > 0)
    {
        // Pega a senha do banco e guarda na memória (pSenha)
        // Isso é essencial para o Login funcionar depois!
        cache_get_value_name(0, "senha", Player[playerid][pSenha], 129);
        
        SendClientMessage(playerid, COR_V_CLARO, "Bem-vindo de volta! Use o botao 'CONECTAR' para logar.");
        
        // Dica: Se quiser bloquear o botão "CRIAR" para quem já tem conta, faríamos aqui.
        // Mas por enquanto, apenas carregamos a senha para que a comparação funcione.
    }
    else
    {
        SendClientMessage(playerid, COR_AMARELO, "Voce nao possui conta. Use o botao 'CRIAR CONTA'.");
        
        // Zera a senha na memória para garantir
        Player[playerid][pSenha][0] = EOS;
    }
    return 1;
}

forward AoCriarConta(playerid);
public AoCriarConta(playerid)
{
    // Recupera o ID gerado pelo banco para esse novo jogador
    Player[playerid][pID] = cache_insert_id();
    
    Player[playerid][pLogado] = true;
    Player[playerid][pDinheiro] = 5000;
    Player[playerid][pScore] = 1;
    
    GivePlayerMoney(playerid, 5000);
    SetPlayerScore(playerid, 1);
    
    SendClientMessage(playerid, -1, "{00FF00}[BPS] {FFFFFF}Conta criada com sucesso! Bom jogo.");
    SpawnPlayer(playerid);
    return 1;
}

stock CarregarDadosJogador(playerid)
{
    // A query SELECT já foi feita no login, mas precisamos carregar o resto dos dados agora
    // Para garantir dados frescos, fazemos um novo select rápido pelo ID
    new query[128];
    mysql_format(Conexao, query, sizeof(query), "SELECT * FROM contas WHERE id = %d LIMIT 1", Player[playerid][pID]);
    mysql_tquery(Conexao, query, "FinalizarCarregamento", "i", playerid);
}

forward FinalizarCarregamento(playerid);
public FinalizarCarregamento(playerid)
{
    if(cache_num_rows() > 0) 
    {
        // Mapeia os dados do Banco para as Variáveis do jogo
        cache_get_value_name_int(0, "admin", Player[playerid][pAdmin]);
        cache_get_value_name_int(0, "vip", Player[playerid][pVip]);
        cache_get_value_name_int(0, "skin", Player[playerid][pSkin]);
        cache_get_value_name_int(0, "score", Player[playerid][pScore]);
        cache_get_value_name_int(0, "dinheiro", Player[playerid][pDinheiro]);
        
        // REATIVADO: Agora busca CPF e Bitcoin
        cache_get_value_name_int(0, "cpf", Player[playerid][pCpf]);
        cache_get_value_name_int(0, "bitcoin", Player[playerid][pBitcoin]);
        
        // Aplica no jogo
        SetPlayerScore(playerid, Player[playerid][pScore]);
        GivePlayerMoney(playerid, Player[playerid][pDinheiro]);
        
        Player[playerid][pLogado] = true;
        SendClientMessage(playerid, -1, "{00FF00}[BPS] {FFFFFF}Logado com sucesso!");
    }
}

stock SalvarConta(playerid)
{
    // Verifica se o jogador está logado antes de salvar
    if(Player[playerid][pLogado] == false) return 0;
    
    // Atualiza variáveis do jogo para a memória antes de enviar
    Player[playerid][pDinheiro] = GetPlayerMoney(playerid);
    Player[playerid][pScore] = GetPlayerScore(playerid);
    Player[playerid][pSkin] = GetPlayerSkin(playerid);

    new query[1024], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    
    // ATENÇÃO: Agora salvamos usando o NOME na cláusula WHERE.
    // Isso resolve o problema de não salvar logo após registrar.
    mysql_format(Conexao, query, sizeof(query), 
        "UPDATE contas SET admin=%d, vip=%d, skin=%d, score=%d, dinheiro=%d, cpf=%d, bitcoin=%d WHERE nome='%e'",
        Player[playerid][pAdmin],
        Player[playerid][pVip],
        Player[playerid][pSkin],
        Player[playerid][pScore],
        Player[playerid][pDinheiro],
        Player[playerid][pCpf],
        Player[playerid][pBitcoin],
        nome // Busca pelo nome
    
    
    mysql_tquery(Conexao, query);
    return 1;


forward CarregarConta(playerid);
public CarregarConta(playerid)
{
    // Se encontrou a conta no banco
    if(cache_num_rows() > 0) 
    {
        // 1. Pega os dados do banco e coloca nas variáveis
        cache_get_value_name_int(0, "id", Player[playerid][pID]);
        cache_get_value_name_int(0, "admin", Player[playerid][pAdmin]);
        cache_get_value_name_int(0, "vip", Player[playerid][pVip]);
        cache_get_value_name_int(0, "skin", Player[playerid][pSkin]);
        cache_get_value_name_int(0, "score", Player[playerid][pScore]);
        cache_get_value_name_int(0, "dinheiro", Player[playerid][pDinheiro]);
        cache_get_value_name_int(0, "cpf", Player[playerid][pCpf]);
        cache_get_value_name_int(0, "bitcoin", Player[playerid][pBitcoin]);
        cache_get_value_name_int(0, "cpf", Player[playerid][pCpf]);

        // 2. LIMPEZA E APLICAÇÃO (Correção do Dinheiro)
        ResetPlayerMoney(playerid); // Zera a carteira para não bugar
        GivePlayerMoney(playerid, Player[playerid][pDinheiro]); // Entrega o valor do banco
        SetPlayerScore(playerid, Player[playerid][pScore]);
        
        // 3. CORREÇÃO DA SKIN (Aqui está o segredo!)
        // Atualizamos o SpawnInfo COM A SKIN DO BANCO antes de spawnar
        // Assim, quando ele nascer, vai estar com a skin certa, e não a 26.
        SetSpawnInfo(playerid, 0, Player[playerid][pSkin], 832.0, -1863.0, 12.9, 180.0, 0, 0, 0, 0, 0, 0);
        
        // 4. Libera o jogo
        IsLogged[playerid] = true;
        Player[playerid][pLogado] = true; 
        
        EsconderLogin(playerid); 
        TogglePlayerSpectating(playerid, 0); 
        SpawnPlayer(playerid); // Agora ele nasce com a skin configurada no SetSpawnInfo acima
        
        SendClientMessage(playerid, COR_V_CLARO, "Dados carregados com sucesso! Bom jogo.");
    }
    else
    {
        SendClientMessage(playerid, COR_ERRO, "Erro critico: Conta nao encontrada no carregamento.");
        Kick(playerid);
        AtualizarTagCPF(playerid); 
        
    }
    return 1;
}

forward ForcarSkinCorreta(playerid);
public ForcarSkinCorreta(playerid)
{
    // Verifica se o jogador ainda está conectado e logado
    if(IsPlayerConnected(playerid) && Player[playerid][pLogado] == true)
    {
        // Pega a skin da variável (que veio do banco) e aplica no boneco
        SetPlayerSkin(playerid, Player[playerid][pSkin]);
    }
    return 1;
}

// Encaminhamento da função de resposta do MySQL
forward OnAcessoriosCarregados(playerid);
public OnAcessoriosCarregados(playerid)
{
    // 1. Limpa os slots visualmente antes de carregar (para evitar duplicatas)
    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
        PlayerToys[playerid][i][tSlotOcupado] = 0;
    }

    new rows = cache_num_rows();
    if(rows == 0) return 1; // Se não tem nada no banco, encerra aqui.

    new slot, model, bone;
    new Float:pX, Float:pY, Float:pZ;
    new Float:rX, Float:rY, Float:rZ;
    new Float:sX, Float:sY, Float:sZ;

    // 2. Loop por todos os resultados encontrados no banco
    for(new i=0; i < rows; i++)
    {
        cache_get_value_name_int(i, "slot", slot);
        
        // Proteção: Se o slot for inválido (maior que o limite), ignora
        if(slot < 0 || slot >= MAX_ACESSORIOS) continue;

        // Pega os dados do banco
        cache_get_value_name_int(i, "model", model);
        cache_get_value_name_int(i, "bone", bone);
        
        cache_get_value_name_float(i, "pos_x", pX);
        cache_get_value_name_float(i, "pos_y", pY);
        cache_get_value_name_float(i, "pos_z", pZ);
        
        cache_get_value_name_float(i, "rot_x", rX);
        cache_get_value_name_float(i, "rot_y", rY);
        cache_get_value_name_float(i, "rot_z", rZ);
        
        cache_get_value_name_float(i, "scl_x", sX);
        cache_get_value_name_float(i, "scl_y", sY);
        cache_get_value_name_float(i, 

        // 3. Salva na Variável (Memória do Jogo)
        PlayerToys[playerid][slot][tSlotOcupado] = 1;
        PlayerToys[playerid][slot][tModel] = model;
        PlayerToys[playerid][slot][tBone] = bone;
        
        PlayerToys[playerid][slot][tX] = pX; PlayerToys[playerid][slot][tY] = pY; PlayerToys[playerid][slot][tZ] = pZ;
        PlayerToys[playerid][slot][tRX] = rX; PlayerToys[playerid][slot][tRY] = rY; PlayerToys[playerid][slot][tRZ] = rZ;
        PlayerToys[playerid][slot][tSX] = sX; PlayerToys[playerid][slot][tSY] = sY; PlayerToys[playerid][slot][tSZ] = sZ;

        // 4. Aplica no Boneco IMEDIATAMENTE
        SetPlayerAttachedObject(playerid, slot, model, bone, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ);
    }
    
    SendClientMessage(playerid, COR_V_CLARO, "Seus acessorios foram carregados.");
    return 1;


// Salva TODOS os slots (Use no OnPlayerDisconnect)
stock SalvarToys(playerid)

    // Verifica se está logado para não salvar dados vazios em cima de dados bons
    if(!IsLogged[playerid]) return 0;

    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        // Só salva se o slot estiver ocupado (tSlotOcupado == 1)
        if(PlayerToys[playerid][i][tSlotOcupado] == 1)
        {
            SalvarSlotUnico(playerid, i);
        }
    }
    return 1;
}

// Adicione isso no final do GM para ver se deu erro no MySQL
forward OnToysSalvos();
public OnToysSalvos()
{
    if(mysql_errno(Conexao) != 0)
    {
        printf("[ERRO MYSQL] Falha ao salvar acessorio! Verifique a tabela.");
    }
}


// --- FUNÇÃO ÚNICA: LIMPAR DADOS (Reseta tudo ao conectar) ---
stock LimparDados(playerid)
{
    // 1. Reseta Variáveis do Player
    Player[playerid][pDinheiro] = 0;
    Player[playerid][pAdmin] = 0;
    Player[playerid][pSkin] = 0;
    Player[playerid][pCpf] = 0;
    Player[playerid][pScore] = 0;
    Player[playerid][pLogado] = false; // Garante que não logue bugado
    
    // 2. Reseta Dinheiro Visual
    ResetPlayerMoney(playerid);
    
    // 3. Reseta Acessórios (Evita o bug de itens fantasmas)
    for(new i=0; i < MAX_ACESSORIOS; i++)
    {
        PlayerToys[playerid][i][tSlotOcupado] = 0;
        PlayerToys[playerid][i][tModel] = 0;
        PlayerToys[playerid][i][tBone] = 0;
        
        // Remove visualmente se tiver algo grudado
        if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
    }
    
    return 1; // <--- O aviso "warning 209" sumirá por causa dessa linha!
}

forward OnAbrirLojaMySQL(playerid);
public OnAbrirLojaMySQL(playerid)
{
    new rows = cache_num_rows();
    if(rows == 0) return SendClientMessage(playerid, COR_ERRO, "Loja vazia! Use /criaracc para adicionar itens.");

    new lista[4096], modelo, nomeacc[30], linha[70];
    lista[0] = '\0';

    for(new i=0; i < rows; i++)
    {
        cache_get_value_name_int(i, "modelo", modelo);
        cache_get_value_name(i, "nome", nomeacc, 30);
        
        format(linha, sizeof(linha), "%d - %s\n", modelo, nomeacc);
        strcat(lista, linha);
    }
    
    ShowPlayerDialog(playerid, D_ACC_LOJA, DIALOG_STYLE_LIST, "Loja de Acessorios", lista, "Comprar", "Voltar");
    return 1;
}

// --- SALVAR UM ÚNICO SLOT (Versão Corrigida) ---
stock SalvarSlotUnico(playerid, slot)
{
    // CORREÇÃO: Verifica a variável certa (pLogado)
    if(!Player[playerid][pLogado]) 
    {
        printf("[DEBUG] Salvamento cancelado para %d (Nao esta logado).", playerid);
        return 0;
    }

    new query[1500], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    // DEBUG: Avisa que tentou salvar
    printf("[DEBUG] Tentando salvar Slot %d do player %s no MySQL...", slot, nome);

    mysql_format(Conexao, query, sizeof(query), 
        "INSERT INTO acessorios (nome, slot, model, bone, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, scl_x, scl_y, scl_z) \
        VALUES ('%e', %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f) \
        ON DUPLICATE KEY UPDATE \
        model=%d, bone=%d, \
        pos_x=%f, pos_y=%f, pos_z=%f, \
        rot_x=%f, rot_y=%f, rot_z=%f, \
        scl_x=%f, scl_y=%f, scl_z=%f",
        
        nome, slot, 
        PlayerToys[playerid][slot][tModel], PlayerToys[playerid][slot][tBone],
        PlayerToys[playerid][slot][tX], PlayerToys[playerid][slot][tY], PlayerToys[playerid][slot][tZ],
        PlayerToys[playerid][slot][tRX], PlayerToys[playerid][slot][tRY], PlayerToys[playerid][slot][tRZ],
        PlayerToys[playerid][slot][tSX], PlayerToys[playerid][slot][tSY], PlayerToys[playerid][slot][tSZ],
        
        // Update
        PlayerToys[playerid][slot][tModel], PlayerToys[playerid][slot][tBone],
        PlayerToys[playerid][slot][tX], PlayerToys[playerid][slot][tY], PlayerToys[playerid][slot][tZ],
        PlayerToys[playerid][slot][tRX], PlayerToys[playerid][slot][tRY], PlayerToys[playerid][slot][tRZ],
        PlayerToys[playerid][slot][tSX], PlayerToys[playerid][slot][tSY], PlayerToys[playerid][slot][tSZ]
    );
    
    // Adicionei um callback para ver se deu erro no SQL
    mysql_tquery(Conexao, query, "OnDebugSalvar", "di", playerid, slot); 
    return 1;
}

// --- CALLBACK PARA VER SE O MYSQL ACEITOU ---
forward OnDebugSalvar(playerid, slot);
public OnDebugSalvar(playerid, slot)
{
    if(mysql_errno(Conexao) != 0)
    {
        printf("[ERRO MYSQL] Falha ao salvar Slot %d! Erro ID: %d", slot, mysql_errno(Conexao));
    }
    else
    {
        printf("[SUCESSO MYSQL] Slot %d salvo com sucesso na tabela.", slot);
    }
    return 1;
}

// --- CARREGAR ACESSÓRIOS (Versão Corrigida) ---
stock CarregarToys(playerid)
{
    new query[128], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    printf("[DEBUG] Carregando acessorios para %s...", nome);

    mysql_format(Conexao, query, sizeof(query), "SELECT * FROM acessorios WHERE nome = '%e'", nome);
    mysql_tquery(Conexao, query, "OnToysCarregados", "d", playerid);
    return 1;
}

// --- CALLBACK QUE RECEBE OS DADOS ---
forward OnToysCarregados(playerid);
public OnToysCarregados(playerid)
{
    new rows = cache_num_rows();
    if(rows == 0) 
    {
        printf("[DEBUG] Nenhum acessorio encontrado no banco para %d.", playerid);
        return 1;
    }

    printf("[DEBUG] Encontrados %d acessorios para o player %d. Aplicando...", rows, playerid);

    for(new i=0; i < rows; i++)
    {
        new slot, model, bone;
        
        cache_get_value_name_int(i, "slot", slot);
        cache_get_value_name_int(i, "model", model);
        cache_get_value_name_int(i, "bone", bone);

        if(slot < 0 || slot >= MAX_ACESSORIOS) continue;

        PlayerToys[playerid][slot][tSlotOcupado] = 1;
        PlayerToys[playerid][slot][tModel] = model;
        PlayerToys[playerid][slot][tBone] = bone;

        cache_get_value_name_float(i, "pos_x", PlayerToys[playerid][slot][tX]);
        cache_get_value_name_float(i, "pos_y", PlayerToys[playerid][slot][tY]);
        cache_get_value_name_float(i, "pos_z", PlayerToys[playerid][slot][tZ]);

        cache_get_value_name_float(i, "rot_x", PlayerToys[playerid][slot][tRX]);
        cache_get_value_name_float(i, "rot_y", PlayerToys[playerid][slot][tRY]);
        cache_get_value_name_float(i, "rot_z", PlayerToys[playerid][slot][tRZ]);

        cache_get_value_name_float(i, "scl_x", PlayerToys[playerid][slot][tSX]);
        cache_get_value_name_float(i, "scl_y", PlayerToys[playerid][slot][tSY]);
        cache_get_value_name_float(i, "scl_z", PlayerToys[playerid][slot][tSZ]);

        if(model > 0)
        {
            SetPlayerAttachedObject(playerid, slot, model, bone,
                PlayerToys[playerid][slot][tX], PlayerToys[playerid][slot][tY], PlayerToys[playerid][slot][tZ],
                PlayerToys[playerid][slot][tRX], PlayerToys[playerid][slot][tRY], PlayerToys[playerid][slot][tRZ],
                PlayerToys[playerid][slot][tSX], PlayerToys[playerid][slot][tSY], PlayerToys[playerid][slot][tSZ]
            );
        }
    }
    return 1;
}

// =============================================================================
//                       SISTEMA DE INVENTÁRIO MYSQL
// =============================================================================

// --- SALVAR INVENTÁRIO COMPLETO ---
stock SalvarInventario(playerid)
{
    if(!Player[playerid][pLogado]) return 0;

    new query[256], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    for(new i=0; i < MAX_INV_SLOTS; i++)
    {
        // CASO 1: TEM ITEM NO SLOT? -> SALVA (OU ATUALIZA)
        if(InvItem[playerid][i] > 0)
        {
            mysql_format(Conexao, query, sizeof(query), 
                "INSERT INTO inventario (nome, slot, itemid, quantidade) VALUES ('%e', %d, %d, %d) \
                ON DUPLICATE KEY UPDATE itemid=%d, quantidade=%d",
                nome, i, InvItem[playerid][i], InvQtd[playerid][i],
                InvItem[playerid][i], InvQtd[playerid][i]
            );
            mysql_tquery(Conexao, query);
        }
        // CASO 2: O SLOT ESTÁ VAZIO? -> REMOVE DO BANCO (LIMPEZA)
        else
        {
            mysql_format(Conexao, query, sizeof(query), 
                "DELETE FROM inventario WHERE nome='%e' AND slot=%d",
                nome, i
            );
            mysql_tquery(Conexao, query);
        }
    }
    return 1;
}

// --- CARREGAR INVENTÁRIO ---
stock CarregarInventario(playerid)
{
    new query[128], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    // Limpa a mochila antes de carregar (para não duplicar)
    for(new i=0; i < MAX_INV_SLOTS; i++) {
        InvItem[playerid][i] = 0;
        InvQtd[playerid][i] = 0;
    }

    // Busca no banco
    mysql_format(Conexao, query, sizeof(query), "SELECT * FROM inventario WHERE nome = '%e'", nome);
    mysql_tquery(Conexao, query, "OnInventarioCarregado", "d", playerid);
    return 1;
}

// --- CALLBACK DO CARREGAMENTO ---
forward OnInventarioCarregado(playerid);
public OnInventarioCarregado(playerid)
{
    new rows = cache_num_rows();
    if(rows == 0) return 1; // Mochila vazia no banco

    for(new i=0; i < rows; i++)
    {
        new slot, item, qtd;
        
        cache_get_value_name_int(i, "slot", slot);
        cache_get_value_name_int(i, "itemid", item);
        cache_get_value_name_int(i, "quantidade", qtd);

        // Segurança para não bugar slots inválidos
        if(slot >= 0 && slot < MAX_INV_SLOTS)
        {
            InvItem[playerid][slot] = item;
            InvQtd[playerid][slot] = qtd;
        }
    }
    printf("[MYSQL] Inventario de %d carregado (%d itens).", playerid, rows);
    return 1
}

// Chame isso no OnGameModeInit no lugar do loop de DOF2
forward CarregarOrgsMySQL();
public CarregarOrgsMySQL()
{
    mysql_tquery(Conexao, "SELECT * FROM organizacoes", "OnOrgsCarregadas");
    return 1;
}

forward OnOrgsCarregadas();
public OnOrgsCarregadas()
{
    new rows = cache_num_rows();
    if(rows == 0) return print("[MYSQL] Nenhuma organizacao encontrada.");

    for(new i=0; i < rows; i++)
    {
        // Usamos i+1 porque o ID 0 geralmente é Civil
        new id = i + 1;
        if(id >= MAX_ORGS) break;

        OrgInfo[id][oCriada] = 1;
        
        cache_get_value_name_int(i, "id", OrgInfo[id][oID]);
        cache_get_value_name(i, "nome", OrgInfo[id][oNome], 32);
        cache_get_value_name_int(i, "cor", OrgInfo[id][oCor]);
        cache_get_value_name_int(i, "tipo", OrgInfo[id][oTipo]);
        cache_get_value_name_int(i, "skin", OrgInfo[id][oSkin]);
        cache_get_value_name(i, "lider", OrgInfo[id][oLider], 24);
        cache_get_value_name(i, "sublider", OrgInfo[id][oSubLider], 24);
        cache_get_value_name_int(i, "cofre", OrgInfo[id][oCofre]);
        
        cache_get_value_name_float(i, "pos_x", OrgInfo[id][oX]);
        cache_get_value_name_float(i, "pos_y", OrgInfo[id][oY]);
        cache_get_value_name_float(i, "pos_z", OrgInfo[id][oZ]);

        // Cria Visual
        OrgInfo[id][oPickup] = CreatePickup(1239, 1, OrgInfo[id][oX], OrgInfo[id][oY], OrgInfo[id][oZ], -1);
        
        new label[128], tipoStr[20];
        if(OrgInfo[id][oTipo] == TIPO_FAC_LAVAGEM) tipoStr = "LAVAGEM";
        else if(OrgInfo[id][oTipo] == TIPO_FAC_DESMANCHE) tipoStr = "DESMANCHE";
        else if(OrgInfo[id][oTipo] == TIPO_ORG_LEGAL) tipoStr = "LEGAL";
        else tipoStr = "GUERRA";

        format(label, sizeof(label), "{FFFFFF}HQ: %s\nTipo: {FFFF00}%s\n{FFFFFF}Lider: %s", OrgInfo[id][oNome], tipoStr, OrgInfo[id][oLider]);
        OrgInfo[id][oLabel] = Create3DTextLabel(label, OrgInfo[id][oCor], OrgInfo[id][oX], OrgInfo[id][oY], OrgInfo[id][oZ]+0.5, 20.0, 0, 0);
    }
    printf("[ORGS] %d Organizacoes carregadas do MySQL.", rows);
    return 1;
}

// Defina isso lá no topo junto com os outros defines
#define ITEM_DINHEIRO_SUJO 4 

// --- FUNÇÃO PARA ACHAR JOGADOR PELO CPF ---
stock GetPlayerIDByCPF(cpf_alvo)
{
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pLogado])
        
            if(Player[i][pCpf] == cpf_alvo) return i; // Retorna o ID se achar
        }
    }
    return -1; // Não achou ninguém com esse CPF online


// Essa função é chamada automaticamente pelo ZCMD quando alguém digita um comando
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    // Se success for falso (0), significa que o comando NÃO existe
    if(!success)
    {
        // 1. Mostra o TextDraw
        TextDrawShowForPlayer(playerid, TD_ErroComando);
        
        // 2. Toca um som de "Erro"
        PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
        
        // 3. Cria um timer para esconder a mensagem depois de 2 segundos
        SetTimerEx("EsconderErroCMD", 2000, false, "i", playerid);
        
        // Retorna 1 para NÃO aparecer a mensagem padrão branca "SERVER: Unknown command"
        return 1;
    }
    return 1;
}

// Timer para esconder o texto
forward EsconderErroCMD(playerid);
public EsconderErroCMD(playerid)
{
    TextDrawHideForPlayer(playerid, TD_ErroComando);
    return 1;
}

stock AtualizarTagCPF(playerid)
{
    // 1. Deleta a anterior se existir (para não duplicar)
    if(TagCPF[playerid]) 
    {
        Delete3DTextLabel(TagCPF[playerid]);
        TagCPF[playerid] = Text3D:0;
    }

    // 2. Só cria se o jogador tiver CPF carregado e estiver logado
    if(Player[playerid][pCpf] > 0 && Player[playerid][pLogado])
    {
        new labelCPF[64];
        // Azul Claro no título, Branco no número
        format(labelCPF, sizeof(labelCPF), "{00BFFF}CPF: {FFFFFF}%d", Player[playerid][pCpf]);

        // Cria e cola na cabeça
        TagCPF[playerid] = Create3DTextLabel(labelCPF, 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, 1);
        Attach3DTextLabelToPlayer(TagCPF[playerid], playerid, 0.0, 0.0, 0.4);
    }
    return 1;
}