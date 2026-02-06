// =============================================================================
//       BRASIL PLAY STREET (BPS) - VERSÃO HÍBRIDA (MySQL + DOF2)
//       DC (DISCORD) @Koongg444 Wpp (WhatsApp) 81985089075
// =============================================================================
#include <a_samp>
#include <DOF2>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <a_mysql>

new MySQL:Conexao;

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

enum pInfo 
{
    pSenha[129], pID, pDinheiro, pAdmin, pLevel, pVip, pSkin, pScore,
    pCpf, pBitcoin, pOrg, pLider, pMatou, pMorreu, pTempo,
    bool:pLogado
};

new Player[MAX_PLAYERS][pInfo];
new bool:IsLogged[MAX_PLAYERS];

// VARIÁVEIS DE SISTEMA
new bool:Trabalhando[MAX_PLAYERS];
new bool:AdminTrabalhando[MAX_PLAYERS];
new InviteOrg[MAX_PLAYERS];
new TempGPS_Categoria[MAX_PLAYERS][64];
new CheckpointAtivo[MAX_PLAYERS];
new TimerVelocimetro;
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
forward AtualizarVelocimetroGlobal();
forward AnimarLockPick(playerid);
forward FinalizarDesmanche(playerid, vehicleid);
forward TocarMusicaLogin(playerid);
forward VerificarConta(playerid);
forward AoCriarConta(playerid);
forward FinalizarCarregamento(playerid);
forward CarregarConta(playerid);
forward OnDebugSalvar(playerid, slot);
forward OnAbrirLojaMySQL(playerid);
forward ForcarSkinCorreta(playerid);

main()
{
	print("-----------------------------------");
	print(" Brasil Play Street - v1.0 COMPLETO");
	print("-----------------------------------");
}

public OnGameModeInit()
{
    TimerVelocimetro = SetTimer("AtualizarVelocimetroGlobal", 200, true);

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
    
    // Se não existir arquivo de lideres, cria
    if(!DOF2_FileExists(ARQUIVO_ORGS))
    {
        DOF2_CreateFile(ARQUIVO_ORGS);
        DOF2_SetString(ARQUIVO_ORGS, "LiderPM", "Ninguem");
        DOF2_SaveFile();
    }
    
    CarregarOrgsMySQL();

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

    // --- ADICIONE ISTO AQUI NO TOPO ---
    new nome[MAX_PLAYER_NAME];
    new ip[16];
    GetPlayerName(playerid, nome, sizeof(nome));
    GetPlayerIp(playerid, ip, sizeof(ip));
    ----------------------------------
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][2], "Registro");
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][0], "Andrade");
    PlayerTextDrawSetString(playerid, Login::PlayerTD[playerid][1], "Digite_sua_senha");
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
    CelularAberto[playerid] = false; 
    BancoAberto[playerid] = false;   
    Player[playerid][pTempo] = 0;    
    InvAberto[playerid] = false;
    SlotSelecionado[playerid] = -1;  

    CriarCelular(playerid); 

    for (new i = 0; i < 20; i++) SendClientMessage(playerid, -1, " ");
    
    // MOSTRAR TELA DE LOGIN
 
    // Ýcones do Mapa
    for(new i=1; i < MAX_ORGS; i++)
    {
        if(OrgInfo[i][oCriada] == 1)
        {
            SetPlayerMapIcon(playerid, i, OrgInfo[i][oX], OrgInfo[i][oY], OrgInfo[i][oZ], 31, 0, MAPICON_GLOBAL);
        }
    }

    SetTimerEx("TocarMusicaLogin", 2000, false, "i", playerid);

    // === AQUI ESTÝ A MÝGICA: VERIFICAR NO MYSQL ===
    // Pergunta ao banco se esse nome já existe
    new query[128];
    mysql_format(Conexao, query, sizeof(query), "SELECT senha FROM contas WHERE nome = '%e' LIMIT 1", nome);
    mysql_tquery(Conexao, query, "VerificarConta", "d", playerid);    
    === REMOÇÃO DE OBJETOS DO MAPA (COMEÇO) ===
        
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

    LimparDados(playerid);
    IsLogged[playerid] = false;

    // Esconde nick de admins trabalhando
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Trabalhando[i])
        {
            ShowPlayerNameTagForPlayer(playerid, i, 0); 
        }
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
        SalvarConta(playerid);
        
        SalvarInventario(playerid); // <--- ADICIONE ISSO AQUI
    }
    
    // 1. SALVAR TUDO ANTES DE QUALQUER COISA
    if(IsLogged[playerid])
    {
        SalvarConta(playerid); // Salva dinheiro, level, etc.
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
   
    if(Player[playerid][pLogado])
    {
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

    return 0;
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