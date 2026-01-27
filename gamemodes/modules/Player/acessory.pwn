#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerConnect(playerid)
{
    Acessory::ClearData(playerid);
    return 1;
}

YCMD:acessorios(playerid, params[], help)
{
    #pragma unused params, help

    new str[1024];
    
    format(str, sizeof(str), "Slot\tID do Modelo\tStatus\n");

    for(new i = 0; i < MAX_ACESSORYS, i++)
    {
        if(!Acessory::Exist(playerid, i))
        {
            format(str, sizeof(str), "{ffffff}Slot: {ffff33}%d\t{ffffff}%d\t%s\n", 
            i + 1,
            Acessory::LoadDataInt(playerid, slotid, "modelid"),
            IsPlayerAttachedObjectSlotUsed(playerid, i) : "{33ff33}[EQUIPADO]" : "{33ff33}[DESEQUIPADO]");
        }

        else
        {
            format(str, sizeof(str), "{ffffff}Slot: {ff3333}%d\t{ff3333}Vazio\t{a9a9a9}(Clique para \
            Comprar\n", i + 1);
        }

        strcat(str, str);
    }

    inline D_ACC_MENU()
    {
        if(!response) 
            return 1;

        new slotid = listitem;

        Player::SetFlag(playerid, acs::Player[playerid][acs::flags], MASK_EDITING_ACS);

        // Se o slot estiver VAZIO -> Abre a Loja
        if(IsPlayerAttachedObjectSlotUsed(playerid, slotid))
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

            inline D_ACC_LOJA()
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
            
            ShowPlayerDialog(playerid, D_ACC_LOJA, DIALOG_STYLE_LIST, "Loja de Acessorios", lista, "Comprar", "Voltar");

            SendClientMessage(playerid, COR_V_CLARO, "Abrindo catalogo...");
        }
        // Se o slot estiver OCUPADO -> Abre Opções (Editar/Remover)
        else
        {
            inline D_ACC_OPCOES()
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

            ShowPlayerDialog(playerid, D_ACC_OPCOES, DIALOG_STYLE_LIST, "O que fazer?", 
                "1. Editar Posicao (TextDraw)\n2. Trocar Osso (Local)\n3. Remover Item", 
                "Selecionar", "Voltar");
        }

        return 1;
    }

    ShowPlayerDialog(playerid, D_ACC_MENU, DIALOG_STYLE_LIST, "{FFFFFF}Gerenciar Acessorios", lista, "Selecionar", "Fechar");
    return 1;
}

stock Acessory::ClearData(playerid)
{
    acs::Player[playerid][acs::modelid] = INVALID_OBJECT_ID;
    acs::Player[playerid][acs::boneid] = 0;
    acs::Player[playerid][acs::pX] = 0.0;
    acs::Player[playerid][acs::pY] = 0.0;
    acs::Player[playerid][acs::pZ] = 0.0;
    acs::Player[playerid][acs::rX] = 0.0;
    acs::Player[playerid][acs::rY] = 0.0;
    acs::Player[playerid][acs::rZ] = 0.0;
    acs::Player[playerid][acs::sX] = 0.0;
    acs::Player[playerid][acs::sY] = 0.0;
    acs::Player[playerid][acs::sZ] = 0.0;
}

