#include <a_samp>
#include <DOF2>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <a_mysql>

new MySQL:Conexao;

#define MAX_PLAYER_VEHICLES 10
#define MAX_DESMANCHES      50
#define MAX_MECANICAS       50
#define MAX_OFICINAS        20
#define MAX_INV_SLOTS       16
#define MAX_VEHICLE_SLOTS   3

#define DIALOG_TUNING 60
#define DIALOG_RODAS 61
#define DIALOG_NEON 62
#define DIALOG_MALAS 1500
#define DIALOG_MALAS_ACAO 1501
#define DIALOG_MENU_MECANICO 2010
#define ITEM_DINHEIRO_SUJO 4

#define ARQUIVO_DESMANCHE "Desmanches/Desmanche_%d.ini"

new bool:InvAberto[MAX_PLAYERS];
new InvItem[MAX_PLAYERS][MAX_INV_SLOTS];
new InvQtd[MAX_PLAYERS][MAX_INV_SLOTS];
new SlotSelecionado[MAX_PLAYERS] = {-1, ...};
new bool:BancoAberto[MAX_PLAYERS];
new SequestradoPor[MAX_PLAYERS];
new TimerLockPick[MAX_PLAYERS];
new bool:IsPicking[MAX_PLAYERS];
new LockPickCarro[MAX_PLAYERS];
new Float:LockCursorX[MAX_PLAYERS];
new Float:LockAlvoX[MAX_PLAYERS];
new bool:LockDir[MAX_PLAYERS];

enum dsInfo { Float:dsX, Float:dsY, Float:dsZ, dsCriado }
new DesmancheInfo[MAX_DESMANCHES][dsInfo];
new Text3D:DesmancheLabel[MAX_DESMANCHES];
new TimerDesmanche[MAX_PLAYERS];

new NeonEsq[MAX_VEHICLES]; new NeonDir[MAX_VEHICLES];

enum vInfo { vArmaId[MAX_VEHICLE_SLOTS], vMunicao[MAX_VEHICLE_SLOTS] }
new VehicleData[MAX_VEHICLES][vInfo];

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

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
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