#include <YSI\YSI_Coding\y_hooks>

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

new Float:LockAlvoX[MAX_PLAYERS];
new Float:LockCursorX[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    GUI::CreateTD(8);
    GUI::CreatePlayerTD(playerid, 8);
    GUI::ShowTDForPlayer(playerid, 8);
    return 1;
}

stock GUI::UpdateTDForPlayer(playerid, guiid)
{
    return 1;
}

stock GUI::HideTDForPlayer(playerid, guiid)
{
    if(guiid == 1)
    {
        TextDrawHideForPlayer(playerid, TD_Edit_Fundo);

        for(new i = 0; i < 9; i++) 
            TextDrawHideForPlayer(playerid, TD_Edit_Botoes[i]);

        PlayerTextDrawHide(playerid, PTD_Edit_Info[playerid]);
    }

    if(guiid == 2)
    {
        for(new i = 0; i < 16; i++) 
            PlayerTextDrawHide(playerid, Celular[playerid][i]);     
    }

    if(guiid == 3)
    {
        for(new i = 0; i < 12; i++) 
            PlayerTextDrawHide(playerid, TD_InvUI[playerid][i]);

        for(new i = 0; i < MAX_INV_SLOTS; i++)
        {
            PlayerTextDrawHide(playerid, TD_InvSlotBG[playerid][i]);
            PlayerTextDrawHide(playerid, TD_InvSlotItem[playerid][i]);
            PlayerTextDrawHide(playerid, TD_InvSlotQtd[playerid][i]);
        }        
    }

    if(guiid == 4)
    {
        for(new i = 0; i < 5; i++) 
            PlayerTextDrawHide(playerid, TD_LockGame[playerid][i]);
    }

    if(guiid == 5)
    {
        PlayerTextDrawHide(playerid, TD_Gar_Fundo);
        PlayerTextDrawHide(playerid, TD_Gar_Header);
        PlayerTextDrawHide(playerid, TD_Gar_Preview);
        PlayerTextDrawHide(playerid, TD_Gar_Nome);
        PlayerTextDrawHide(playerid, TD_Gar_Status);
        PlayerTextDrawHide(playerid, TD_Gar_BtnAnt);
        PlayerTextDrawHide(playerid, TD_Gar_BtnProx);
        PlayerTextDrawHide(playerid, TD_Gar_BtnSpawn);
        PlayerTextDrawHide(playerid, TD_Gar_BtnStore);
        PlayerTextDrawHide(playerid, TD_Gar_BtnSair);
    }

    if(guiid == 6)
    {
        PlayerTextDrawHide(playerid, TD_Shop_Fundo);
        PlayerTextDrawHide(playerid, TD_Shop_Header);
        PlayerTextDrawHide(playerid, TD_Shop_Preview);
        PlayerTextDrawHide(playerid, TD_Shop_Nome);
        PlayerTextDrawHide(playerid, TD_Shop_Preco);
        PlayerTextDrawHide(playerid, TD_Shop_BtnEsq);
        PlayerTextDrawHide(playerid, TD_Shop_BtnDir);
        PlayerTextDrawHide(playerid, TD_Shop_BtnComp);
        PlayerTextDrawHide(playerid, TD_Shop_BtnSair);
    }

    if(guiid == 7)
    {
        TextDrawHideForPlayer(playerid, TD_Login_Fundo);
        TextDrawHideForPlayer(playerid, TD_Login_LogoPequena);
        TextDrawHideForPlayer(playerid, TD_Login_LogoGrande);
        TextDrawHideForPlayer(playerid, TD_Login_BoxUser);
        TextDrawHideForPlayer(playerid, TD_Login_BoxSenha);
        TextDrawHideForPlayer(playerid, TD_Login_IconUser);
        TextDrawHideForPlayer(playerid, TD_Login_IconPass);
        TextDrawHideForPlayer(playerid, TD_Login_Esqueci);
        TextDrawHideForPlayer(playerid, TD_Login_BtnConectar);
        TextDrawHideForPlayer(playerid, TD_Login_BtnCriar);
        PlayerTextDrawHide(playerid, PTD_Login_Nome[playerid]);
    }

    if(guiid == 8)
    {
        TextDrawHideForPlayer(playerid, TD_BancoFundo); 
        TextDrawHideForPlayer(playerid, TD_BancoTitulo);
        TextDrawHideForPlayer(playerid, TD_BtnPix); 
        TextDrawHideForPlayer(playerid, TD_BtnSair);
        //PlayerTextDrawHide(playerid, PTD_Saldo[playerid]);        
    }

    CancelSelectTextDraw(playerid);
}

stock GUI::ShowTDForPlayer(playerid, guiid)
{
    if(guiid == 1)
    {
        TextDrawShowForPlayer(playerid, TD_Edit_Fundo);
        for(new i = 0; i < 9; i++) 
            TextDrawShowForPlayer(playerid, TD_Edit_Botoes[i]);
            
        PlayerTextDrawSetString(playerid, PTD_Edit_Info[playerid], "Mover:~n~X / Y / Z");
        PlayerTextDrawShow(playerid, PTD_Edit_Info[playerid]);

        SelectTextDraw(playerid, 0xFF0000AA);
    }

    if(guiid == 2)
    {
        new hora, minuto, segundo; // Adicionei 'segundo' para evitar avisos
        gettime(hora, minuto, segundo);
        
        new strHora[10];
        format(strHora, sizeof(strHora), "%02d:%02d", hora, minuto);
        PlayerTextDrawSetString(playerid, Celular[playerid][2], strHora);

        for(new i = 0; i < 8; i++) 
            PlayerTextDrawShow(playerid, Celular[playerid][i]); 

        SelectTextDraw(playerid, 0xFF0000AA);
    }

    if(guiid == 3)
    {
        for(new i = 0; i < 12; i++) 
            PlayerTextDrawShow(playerid, TD_InvUI[playerid][i]);

        for(new i = 0; i < MAX_INV_SLOTS; i++)
        {
            PlayerTextDrawShow(playerid, TD_InvSlotBG[playerid][i]);
            PlayerTextDrawShow(playerid, TD_InvSlotItem[playerid][i]);
            PlayerTextDrawShow(playerid, TD_InvSlotQtd[playerid][i]);
        }   

        SelectTextDraw(playerid, 0xFF0000AA);
    }

    if(guiid == 4)
    {
        for(new i = 0; i < 5; i++) 
            PlayerTextDrawShow(playerid, TD_LockGame[playerid][i]);

        SelectTextDraw(playerid, 0xFFFFFF55); // Mouse
    }

    if(guiid == 5)
    {
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

        SelectTextDraw(playerid, 0xFF0000AA);
    }

    if(guiid == 6)
    {
        PlayerTextDrawShow(playerid, TD_Shop_Fundo);
        PlayerTextDrawShow(playerid, TD_Shop_Header);
        PlayerTextDrawShow(playerid, TD_Shop_Preview);
        PlayerTextDrawShow(playerid, TD_Shop_Nome);
        PlayerTextDrawShow(playerid, TD_Shop_Preco);
        PlayerTextDrawShow(playerid, TD_Shop_BtnEsq);
        PlayerTextDrawShow(playerid, TD_Shop_BtnDir);
        PlayerTextDrawShow(playerid, TD_Shop_BtnComp);
        PlayerTextDrawShow(playerid, TD_Shop_BtnSair);

        SelectTextDraw(playerid, 0xFF0000AA);
    }

    if(guiid == 7)
    {
        TextDrawShowForPlayer(playerid, TD_Login_Fundo);
        TextDrawShowForPlayer(playerid, TD_Login_LogoPequena);
        TextDrawShowForPlayer(playerid, TD_Login_LogoGrande);
        TextDrawShowForPlayer(playerid, TD_Login_BoxUser);
        TextDrawShowForPlayer(playerid, TD_Login_BoxSenha);
        TextDrawShowForPlayer(playerid, TD_Login_IconUser);
        TextDrawShowForPlayer(playerid, TD_Login_IconPass);
        TextDrawShowForPlayer(playerid, TD_Login_Esqueci);
        TextDrawShowForPlayer(playerid, TD_Login_BtnConectar);
        TextDrawShowForPlayer(playerid, TD_Login_BtnCriar);
        PlayerTextDrawShow(playerid, PTD_Login_Nome[playerid]);

        SelectTextDraw(playerid, COR_V_CLARO);    
    }

    if(guiid == 8)
    {
        TextDrawShowForPlayer(playerid, TD_BancoFundo); 
        TextDrawShowForPlayer(playerid, TD_BancoTitulo);
        TextDrawShowForPlayer(playerid, TD_BtnPix); 
        TextDrawShowForPlayer(playerid, TD_BtnSair);
        //PlayerTextDrawShow(playerid, PTD_Saldo[playerid]);        

        SelectTextDraw(playerid, COR_V_CLARO); 
    }
}

stock GUI::CreatePlayerTD(playerid, guiid)
{
    if(guiid == 1)
    {
        PTD_Edit_Info[playerid] = CreatePlayerTextDraw(playerid, 590.0, 160.0, "POSICAO");
        PlayerTextDrawAlignment(playerid, PTD_Edit_Info[playerid], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, PTD_Edit_Info[playerid], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, PTD_Edit_Info[playerid], 0.3, 1.0);
        PlayerTextDrawColour(playerid, PTD_Edit_Info[playerid], -1);
    }

    if(guiid == 2)
    {
        new Float:BaseX = 510.0;
        new Float:BaseY = 230.0;

        // 0. CAPA DO CELULAR (Fundo Preto)
        Celular[playerid][0] = CreatePlayerTextDraw(playerid, BaseX, BaseY, "_");
        PlayerTextDrawUseBox(playerid, Celular[playerid][0], true);
        PlayerTextDrawBoxColour(playerid, Celular[playerid][0], 0x111111FF); 
        PlayerTextDrawTextSize(playerid, Celular[playerid][0], BaseX + 120.0, 0.0); // Largura Total 120
        PlayerTextDrawLetterSize(playerid, Celular[playerid][0], 0.0, 22.0); // Altura Total

        // 1. TELA (Papel de Parede Cinza)
        Celular[playerid][1] = CreatePlayerTextDraw(playerid, BaseX + 5.0, BaseY + 5.0, "_");
        PlayerTextDrawUseBox(playerid, Celular[playerid][1], true);
        PlayerTextDrawBoxColour(playerid, Celular[playerid][1], 0x252525FF); 
        PlayerTextDrawTextSize(playerid, Celular[playerid][1], BaseX + 115.0, 0.0);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][1], 0.0, 18.0);

        // 2. RELÓGIO (Topo)
        Celular[playerid][2] = CreatePlayerTextDraw(playerid, BaseX + 60.0, BaseY + 8.0, "12:00");
        PlayerTextDrawAlignment(playerid, Celular[playerid][2], TEXT_DRAW_ALIGN:2); // Centralizado
        PlayerTextDrawFont(playerid, Celular[playerid][2], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][2], 0.25, 1.0);
        PlayerTextDrawColour(playerid, Celular[playerid][2], -1);

        // === ÍCONE 1: NUBANK (Esquerda) ===
        // Posição: X + 15 | Tamanho: 35x35
        Celular[playerid][3] = CreatePlayerTextDraw(playerid, BaseX + 15.0, BaseY + 40.0, "LD_SPAC:WHITE");
        PlayerTextDrawFont(playerid, Celular[playerid][3], TEXT_DRAW_FONT:4); // 4 = Sprite/Imagem
        PlayerTextDrawColour(playerid, Celular[playerid][3], 0x820AD1FF); // Roxo Nubank
        PlayerTextDrawTextSize(playerid, Celular[playerid][3], 35.0, 35.0); // <--- AQUI É O SEGREDO (LARGURA x ALTURA)
        PlayerTextDrawSetSelectable(playerid, Celular[playerid][3], true); // Clicável

        // Texto Nubank (Não clicável)
        Celular[playerid][4] = CreatePlayerTextDraw(playerid, BaseX + 32.5, BaseY + 75.0, "Nubank");
        PlayerTextDrawAlignment(playerid, Celular[playerid][4], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, Celular[playerid][4], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][4], 0.2, 0.8);
        
        // === ÍCONE 2: WHATSAPP (Direita) ===
        // Posição: X + 70 (Bem longe do primeiro para não roubar clique)
        Celular[playerid][5] = CreatePlayerTextDraw(playerid, BaseX + 70.0, BaseY + 40.0, "LD_SPAC:WHITE");
        PlayerTextDrawFont(playerid, Celular[playerid][5], TEXT_DRAW_FONT:4);
        PlayerTextDrawColour(playerid, Celular[playerid][5], 0x25D366FF); // Verde Zap
        PlayerTextDrawTextSize(playerid, Celular[playerid][5], 35.0, 35.0); // Tamanho exato 35x35
        PlayerTextDrawSetSelectable(playerid, Celular[playerid][5], true); // Clicável

        // Texto Zap
        Celular[playerid][6] = CreatePlayerTextDraw(playerid, BaseX + 87.5, BaseY + 75.0, "Whats");
        PlayerTextDrawAlignment(playerid, Celular[playerid][6], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, Celular[playerid][6], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][6], 0.2, 0.8);

        // === ÍCONE 3: GPS (Embaixo do Nubank) ===
        Celular[playerid][13] = CreatePlayerTextDraw(playerid, BaseX + 15.0, BaseY + 100.0, "LD_SPAC:WHITE");
        PlayerTextDrawFont(playerid, Celular[playerid][13], TEXT_DRAW_FONT:4);
        PlayerTextDrawColour(playerid, Celular[playerid][13], 0xFFA500FF); // Laranja
        PlayerTextDrawTextSize(playerid, Celular[playerid][13], 35.0, 35.0);
        PlayerTextDrawSetSelectable(playerid, Celular[playerid][13], true);

        // Texto GPS
        Celular[playerid][14] = CreatePlayerTextDraw(playerid, BaseX + 32.5, BaseY + 135.0, "GPS");
        PlayerTextDrawAlignment(playerid, Celular[playerid][14], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, Celular[playerid][14], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][14], 0.2, 0.8);

        // === BOTÃO HOME (Redondo embaixo) ===
        Celular[playerid][7] = CreatePlayerTextDraw(playerid, BaseX + 60.0, BaseY + 180.0, "O");
        PlayerTextDrawAlignment(playerid, Celular[playerid][7], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, Celular[playerid][7], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, Celular[playerid][7], 0.5, 2.0);
        PlayerTextDrawColour(playerid, Celular[playerid][7], 0xAAAAAAFF);
        PlayerTextDrawSetSelectable(playerid, Celular[playerid][7], true);
        // Correção do clique do botão Home (Texto precisa de TextSize X e Y diferente de Sprite)
        // No alinhamento 2 (centro), X é a largura e Y é a altura sensível (aproximadamente)
        PlayerTextDrawTextSize(playerid, Celular[playerid][7], 20.0, 20.0);     
    }

    if(guiid == 3)
    {
        // Aumentei um pouco a BaseX para centralizar melhor
        new Float:BaseX = 210.0, Float:BaseY = 120.0;

        // 1. FUNDO GERAL (AGORA SÓLIDO E PRETO)
        TD_InvUI[playerid][0] = CreatePlayerTextDraw(playerid, BaseX, BaseY, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][0], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][0], 0x000000FF); // <--- PRETO TOTAL (SEM TRANSPARÊNCIA)
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][0], BaseX + 225.0, 230.000); // Mais largo para caber o espaçamento
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][0], 0.0, 25.0); // Altura Ajustada

        // 2. HEADER (Barra de Título Verde Escuro para combinar com o servidor)
        TD_InvUI[playerid][1] = CreatePlayerTextDraw(playerid, BaseX, BaseY, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][1], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][1], 0x004400FF); // <--- VERDE ESCURO NO TOPO
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][1], BaseX + 225.0, 20.000);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][1], 0.0, 2.2);

        // 3. TÍTULO "INVENTÁRIO"
        TD_InvUI[playerid][2] = CreatePlayerTextDraw(playerid, BaseX + 112.5, BaseY + 5.0, "MOCHILA");
        PlayerTextDrawAlignment(playerid, TD_InvUI[playerid][2], TEXT_DRAW_ALIGN:2); 
        PlayerTextDrawColour(playerid, TD_InvUI[playerid][2], -1);
        PlayerTextDrawFont(playerid, TD_InvUI[playerid][2], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][2], 0.25, 1.2);

        // --- O LOOP DA GRADE 4x4 (CORRIGIDO O CLIQUE) ---
        new Float:SlotX, Float:SlotY;
        for(new i=0; i < MAX_INV_SLOTS; i++)
        {
            // NOVA MATEMÁTICA: Mais espaço entre os quadrados
            // Largura do quadrado: 45.0 | Espaço entre eles: 50.0 (5.0 de folga)
            SlotX = BaseX + 15.0 + ((i % 4) * 50.0); 
            SlotY = BaseY + 35.0 + ((i / 4) * 45.0);

            // O QUADRADINHO DE FUNDO DO SLOT
            TD_InvSlotBG[playerid][i] = CreatePlayerTextDraw(playerid, SlotX, SlotY, "_");
            PlayerTextDrawUseBox(playerid, TD_InvSlotBG[playerid][i], true);
            PlayerTextDrawBoxColour(playerid, TD_InvSlotBG[playerid][i], 0x333333FF); // <--- CINZA MAIS CLARO PARA DESTACAR DO FUNDO PRETO
            // TextSize define a área do clique. Ajustei para bater exato com o visual.
            PlayerTextDrawTextSize(playerid, TD_InvSlotBG[playerid][i], SlotX + 44.0, 40.0); 
            PlayerTextDrawLetterSize(playerid, TD_InvSlotBG[playerid][i], 0.0, 4.4); // Altura visual
            PlayerTextDrawSetSelectable(playerid, TD_InvSlotBG[playerid][i], true); 

            // O TEXTO DO ITEM
            TD_InvSlotItem[playerid][i] = CreatePlayerTextDraw(playerid, SlotX + 22.0, SlotY + 14.0, "Vazio");
            PlayerTextDrawAlignment(playerid, TD_InvSlotItem[playerid][i], TEXT_DRAW_ALIGN:2); 
            PlayerTextDrawFont(playerid, TD_InvSlotItem[playerid][i], TEXT_DRAW_FONT:1);
            PlayerTextDrawLetterSize(playerid, TD_InvSlotItem[playerid][i], 0.16, 0.7); // Letra menor pra não vazar
            PlayerTextDrawColour(playerid, TD_InvSlotItem[playerid][i], 0xAAAAAAFF);

            // A QUANTIDADE
            TD_InvSlotQtd[playerid][i] = CreatePlayerTextDraw(playerid, SlotX + 40.0, SlotY + 30.0, "0");
            PlayerTextDrawAlignment(playerid, TD_InvSlotQtd[playerid][i], TEXT_DRAW_ALIGN:3);
            PlayerTextDrawFont(playerid, TD_InvSlotQtd[playerid][i], TEXT_DRAW_FONT:1);
            PlayerTextDrawLetterSize(playerid, TD_InvSlotQtd[playerid][i], 0.15, 0.7);
        }

        // --- BARRA DE PESO (FOOTER) ---
        TD_InvUI[playerid][3] = CreatePlayerTextDraw(playerid, BaseX + 15.0, BaseY + 220.0, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][3], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][3], 0x222222FF);
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][3], BaseX + 210.0, 8.0);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][3], 0.0, 1.0);

        TD_InvUI[playerid][4] = CreatePlayerTextDraw(playerid, BaseX + 15.0, BaseY + 220.0, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][4], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][4], 0x00FF00AA); // Verde Neon Transparente
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][4], BaseX + 100.0, 8.0);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][4], 0.0, 1.0);

        TD_InvUI[playerid][5] = CreatePlayerTextDraw(playerid, BaseX + 112.5, BaseY + 219.0, "10/20KG");
        PlayerTextDrawAlignment(playerid, TD_InvUI[playerid][5], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, TD_InvUI[playerid][5], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][5], 0.18, 0.8);

        // --- OS 3 BOTÕES ColourIDOS (REPOSICIONADOS) ---
        new Float:BtnY = BaseY + 235.0;

        // BOTÃO USAR (Verde)
        TD_InvUI[playerid][6] = CreatePlayerTextDraw(playerid, BaseX + 10.0, BtnY, "_"); 
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][6], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][6], 0x2ECC71FF); 
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][6], BaseX + 70.0, 20.0);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][6], 0.0, 2.0);
        PlayerTextDrawSetSelectable(playerid, TD_InvUI[playerid][6], true);

        TD_InvUI[playerid][9] = CreatePlayerTextDraw(playerid, BaseX + 40.0, BtnY + 5.0, "USAR");
        PlayerTextDrawAlignment(playerid, TD_InvUI[playerid][9], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, TD_InvUI[playerid][9], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][9], 0.20, 1.0);

        // BOTÃO ENVIAR (Era INFO - Agora Roxo/Azul)
        TD_InvUI[playerid][7] = CreatePlayerTextDraw(playerid, BaseX + 80.0, BtnY, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][7], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][7], 0x0000FFFF); // <--- AZUL
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][7], BaseX + 140.0, 20.0);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][7], 0.0, 2.0);
        PlayerTextDrawSetSelectable(playerid, TD_InvUI[playerid][7], true);

        // Texto mudado para ENVIAR
        TD_InvUI[playerid][10] = CreatePlayerTextDraw(playerid, BaseX + 110.0, BtnY + 5.0, "ENVIAR");
        PlayerTextDrawAlignment(playerid, TD_InvUI[playerid][10], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, TD_InvUI[playerid][10], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][10], 0.20, 1.0);

        // BOTÃO DROP (Vermelho)
        TD_InvUI[playerid][8] = CreatePlayerTextDraw(playerid, BaseX + 150.0, BtnY, "_");
        PlayerTextDrawUseBox(playerid, TD_InvUI[playerid][8], true);
        PlayerTextDrawBoxColour(playerid, TD_InvUI[playerid][8], 0xE74C3CFF);
        PlayerTextDrawTextSize(playerid, TD_InvUI[playerid][8], BaseX + 210.0, 20.0);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][8], 0.0, 2.0);
        PlayerTextDrawSetSelectable(playerid, TD_InvUI[playerid][8], true);

        TD_InvUI[playerid][11] = CreatePlayerTextDraw(playerid, BaseX + 180.0, BtnY + 5.0, "DROP");
        PlayerTextDrawAlignment(playerid, TD_InvUI[playerid][11], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, TD_InvUI[playerid][11], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_InvUI[playerid][11], 0.20, 1.0);        
    }

    if(guiid == 4)
    {
        LockAlvoX[playerid] = 250.0 + random(100); 
        LockCursorX[playerid] = 250.0; // Começa na esquerda

        // 0. FUNDO DA BARRA (Cinza Escuro)
        TD_LockGame[playerid][0] = CreatePlayerTextDraw(playerid, 245.0, 300.0, "_");
        PlayerTextDrawUseBox(playerid, TD_LockGame[playerid][0], true);
        PlayerTextDrawBoxColour(playerid, TD_LockGame[playerid][0], 0x222222FF);
        PlayerTextDrawTextSize(playerid, TD_LockGame[playerid][0], 405.0, 20.0); // Largura total
        PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][0], 0.0, 3.0);

        // 1. ALVO (Zona Vermelha - Onde tem que acertar)
        // Usamos a variável LockAlvoX para definir onde ele aparece
        TD_LockGame[playerid][1] = CreatePlayerTextDraw(playerid, LockAlvoX[playerid], 300.0, "_");
        PlayerTextDrawUseBox(playerid, TD_LockGame[playerid][1], true);
        PlayerTextDrawBoxColour(playerid, TD_LockGame[playerid][1], 0xFF0000FF); // Vermelho
        PlayerTextDrawTextSize(playerid, TD_LockGame[playerid][1], LockAlvoX[playerid] + 20.0, 20.0); // Tamanho do alvo
        PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][1], 0.0, 3.0);

        // 2. CURSOR (Barra Branca que se mexe)
        TD_LockGame[playerid][2] = CreatePlayerTextDraw(playerid, 250.0, 295.0, "|");
        PlayerTextDrawAlignment(playerid, TD_LockGame[playerid][2], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, TD_LockGame[playerid][2], -1);
        PlayerTextDrawFont(playerid, TD_LockGame[playerid][2], TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][2], 0.5, 4.0);

        // 3. BOTÃO GIRAR (Para clicar)
        TD_LockGame[playerid][3] = CreatePlayerTextDraw(playerid, 290.0, 340.0, "_");
        PlayerTextDrawUseBox(playerid, TD_LockGame[playerid][3], true);
        PlayerTextDrawBoxColour(playerid, TD_LockGame[playerid][3], COR_VERDE_NEON);
        PlayerTextDrawTextSize(playerid, TD_LockGame[playerid][3], 360.0, 20.0);
        PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][3], 0.0, 2.5);
        PlayerTextDrawSetSelectable(playerid, TD_LockGame[playerid][3], true);

        TD_LockGame[playerid][4] = CreatePlayerTextDraw(playerid, 325.0, 345.0, "GIRAR (H)");
        PlayerTextDrawAlignment(playerid, TD_LockGame[playerid][4], TEXT_DRAW_ALIGN:2);
        PlayerTextDrawFont(playerid, TD_LockGame[playerid][4], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_LockGame[playerid][4], 0.3, 1.2);
        PlayerTextDrawSetSelectable(playerid, TD_LockGame[playerid][4], false); // Texto não clicavel, só a caixa        
    }

    if(guiid == 5)
    {
        TD_Gar_Fundo = CreatePlayerTextDraw(playerid, 0.0, 0.0, "ld_spac:white"); // Carrega um quadrado branco
        PlayerTextDrawFont(playerid, TD_Gar_Fundo, TEXT_DRAW_FONT:4); // Fonte 4 = Modo Desenho/Sprite
        PlayerTextDrawColour(playerid, TD_Gar_Fundo, 0x000000FF); // Pinta o quadrado de PRETO
        PlayerTextDrawTextSize(playerid, TD_Gar_Fundo, 640.0, 480.0); // Estica na tela inteira

        // 3. PREVIEW 3D (Grande no Centro)
        TD_Gar_Preview = CreatePlayerTextDraw(playerid, 220.0, 80.0, "_");
        PlayerTextDrawTextSize(playerid, TD_Gar_Preview, 200.0, 150.0);
        PlayerTextDrawFont(playerid, TD_Gar_Preview, TEXT_DRAW_FONT:5); // 3D
        PlayerTextDrawUseBox(playerid, TD_Gar_Preview, true);
        PlayerTextDrawBoxColour(playerid, TD_Gar_Preview, 0x222222FF); // Cinza escuro atrás do carro
        PlayerTextDrawBackgroundColour(playerid, TD_Gar_Preview, 0x00000000);

        // 4. INFORMAÇÕES
        TD_Gar_Nome = CreatePlayerTextDraw(playerid, 320.0, 240.0, "NOME VEICULO");
        PlayerTextDrawAlignment(playerid, TD_Gar_Nome, TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, TD_Gar_Nome, -1);
        PlayerTextDrawFont(playerid, TD_Gar_Nome, TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_Gar_Nome, 0.4, 1.5);

        TD_Gar_Status = CreatePlayerTextDraw(playerid, 320.0, 260.0, "STATUS: GUARDADO");
        PlayerTextDrawAlignment(playerid, TD_Gar_Status, TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, TD_Gar_Status, 0x00FF00FF);
        PlayerTextDrawFont(playerid, TD_Gar_Status, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Gar_Status, 0.3, 1.2);

        // 5. BOTÕES DE NAVEGAÇÃO (< e >)
        TD_Gar_BtnAnt = CreatePlayerTextDraw(playerid, 160.0, 130.0, "<");
        PlayerTextDrawFont(playerid, TD_Gar_BtnAnt, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Gar_BtnAnt, 0.8, 3.0);
        PlayerTextDrawSetSelectable(playerid, TD_Gar_BtnAnt, true);
        PlayerTextDrawTextSize(playerid, TD_Gar_BtnAnt, 190.0, 30.0); // Área de clique segura

        TD_Gar_BtnProx = CreatePlayerTextDraw(playerid, 450.0, 130.0, ">");
        PlayerTextDrawFont(playerid, TD_Gar_BtnProx, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Gar_BtnProx, 0.8, 3.0);
        PlayerTextDrawSetSelectable(playerid, TD_Gar_BtnProx, true);
        PlayerTextDrawTextSize(playerid, TD_Gar_BtnProx, 480.0, 30.0); // Área de clique segura

        // 6. BOTÕES DE AÇÃO (CORRIGIDOS COM ALIGN 1 PARA NÃO BUGAR O TOQUE)
        // Usamos Align 1 (Esquerda) definindo inicio e fim exatos.
        
        // RETIRAR (Verde)
        TD_Gar_BtnSpawn = CreatePlayerTextDraw(playerid, 250.0, 300.0, "RETIRAR");
        PlayerTextDrawUseBox(playerid, TD_Gar_BtnSpawn, true);
        PlayerTextDrawBoxColour(playerid, TD_Gar_BtnSpawn, 0x008000FF); // Verde Sólido
        PlayerTextDrawTextSize(playerid, TD_Gar_BtnSpawn, 390.0, 30.0); // Vai do X 250 até o X 390
        PlayerTextDrawAlignment(playerid, TD_Gar_BtnSpawn, TEXT_DRAW_ALIGN:1); // <--- SEGGREDO DO TOQUE PERFEITO
        PlayerTextDrawLetterSize(playerid, TD_Gar_BtnSpawn, 0.3, 1.8); // Altura da caixa
        PlayerTextDrawSetSelectable(playerid, TD_Gar_BtnSpawn, true);
        
        // GUARDAR (Laranja) - Mais afastado (Y 345)
        TD_Gar_BtnStore = CreatePlayerTextDraw(playerid, 250.0, 345.0, "GUARDAR");
        PlayerTextDrawUseBox(playerid, TD_Gar_BtnStore, true);
        PlayerTextDrawBoxColour(playerid, TD_Gar_BtnStore, 0xFF8C00FF); // Laranja Sólido
        PlayerTextDrawTextSize(playerid, TD_Gar_BtnStore, 390.0, 30.0);
        PlayerTextDrawAlignment(playerid, TD_Gar_BtnStore, TEXT_DRAW_ALIGN:1);
        PlayerTextDrawLetterSize(playerid, TD_Gar_BtnStore, 0.3, 1.8);
        PlayerTextDrawSetSelectable(playerid, TD_Gar_BtnStore, true);

        // FECHAR (Vermelho) - Bem mais afastado (Y 390)
        TD_Gar_BtnSair = CreatePlayerTextDraw(playerid, 250.0, 390.0, "FECHAR");
        PlayerTextDrawUseBox(playerid, TD_Gar_BtnSair, true);
        PlayerTextDrawBoxColour(playerid, TD_Gar_BtnSair, 0xFF0000FF); // Vermelho Sólido
        PlayerTextDrawTextSize(playerid, TD_Gar_BtnSair, 390.0, 30.0);
        PlayerTextDrawAlignment(playerid, TD_Gar_BtnSair, TEXT_DRAW_ALIGN:1);
        PlayerTextDrawLetterSize(playerid, TD_Gar_BtnSair, 0.3, 1.8);
        PlayerTextDrawSetSelectable(playerid, TD_Gar_BtnSair, true);

        // Dica Visual: O texto não fica centralizado automático no Align 1.
        // Ajustei o X (250) para parecer centralizado.        
    }

    if(guiid == 6)
    {
        // --- CONFIGURAÇÃO VISUAL ---
        new Float:BaseX = 200.0;
        new Float:BaseY = 120.0;

        // 1. FUNDO GERAL (Preto Fosco Elegante)
        TD_Shop_Fundo = CreatePlayerTextDraw(playerid, BaseX, BaseY, "_");
        PlayerTextDrawUseBox(playerid, TD_Shop_Fundo, true);
        PlayerTextDrawBoxColour(playerid, TD_Shop_Fundo, 0x111111EE); // Cinza Quase Preto
        PlayerTextDrawTextSize(playerid, TD_Shop_Fundo, BaseX + 240.0, 260.0); // Largura 240px
        PlayerTextDrawLetterSize(playerid, TD_Shop_Fundo, 0.0, 28.0); // Altura

        // 2. HEADER (Faixa Verde no Topo)
        TD_Shop_Header = CreatePlayerTextDraw(playerid, BaseX, BaseY, "_");
        PlayerTextDrawUseBox(playerid, TD_Shop_Header, true);
        PlayerTextDrawBoxColour(playerid, TD_Shop_Header, 0x00FF00FF); // VERDE NEON
        PlayerTextDrawTextSize(playerid, TD_Shop_Header, BaseX + 240.0, 10.0); 
        PlayerTextDrawLetterSize(playerid, TD_Shop_Header, 0.0, 0.2); // Faixa fina

        // 3. PREVIEW 3D (O Carro)
        TD_Shop_Preview = CreatePlayerTextDraw(playerid, BaseX + 20.0, BaseY + 40.0, "_");
        PlayerTextDrawTextSize(playerid, TD_Shop_Preview, 200.0, 130.0); // Tamanho da imagem
        PlayerTextDrawFont(playerid, TD_Shop_Preview, TEXT_DRAW_FONT:5); // 3D
        PlayerTextDrawUseBox(playerid, TD_Shop_Preview, true);
        PlayerTextDrawBoxColour(playerid, TD_Shop_Preview, 0x333333FF); // Fundo cinza do carro
        PlayerTextDrawBackgroundColour(playerid, TD_Shop_Preview, 0x00000000); 

        // 4. INFO DO CARRO
        TD_Shop_Nome = CreatePlayerTextDraw(playerid, BaseX + 120.0, BaseY + 15.0, "NOME DO VEICULO");
        PlayerTextDrawAlignment(playerid, TD_Shop_Nome, TEXT_DRAW_ALIGN:2); // Centralizado
        PlayerTextDrawColour(playerid, TD_Shop_Nome, -1);
        PlayerTextDrawFont(playerid, TD_Shop_Nome, TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_Shop_Nome, 0.35, 1.4);
        PlayerTextDrawSetOutline(playerid, TD_Shop_Nome, 1);

        TD_Shop_Preco = CreatePlayerTextDraw(playerid, BaseX + 120.0, BaseY + 180.0, "R$ 00.000");
        PlayerTextDrawAlignment(playerid, TD_Shop_Preco, TEXT_DRAW_ALIGN:2);
        PlayerTextDrawColour(playerid, TD_Shop_Preco, 0x00FF00FF); // Verde Dinheiro
        PlayerTextDrawFont(playerid, TD_Shop_Preco, TEXT_DRAW_FONT:3); // Fonte estilo "Banco"
        PlayerTextDrawLetterSize(playerid, TD_Shop_Preco, 0.5, 2.0);
        PlayerTextDrawSetOutline(playerid, TD_Shop_Preco, 1);

        // 5. BOTÕES DE NAVEGAÇÃO (< >)
        TD_Shop_BtnEsq = CreatePlayerTextDraw(playerid, BaseX + 10.0, BaseY + 100.0, "<");
        PlayerTextDrawFont(playerid, TD_Shop_BtnEsq, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Shop_BtnEsq, 0.6, 3.0);
        PlayerTextDrawColour(playerid, TD_Shop_BtnEsq, 0xAAAAAAFF);
        PlayerTextDrawSetSelectable(playerid, TD_Shop_BtnEsq, true);
        PlayerTextDrawTextSize(playerid, TD_Shop_BtnEsq, BaseX + 30.0, 30.0); // Área de clique

        TD_Shop_BtnDir = CreatePlayerTextDraw(playerid, BaseX + 215.0, BaseY + 100.0, ">");
        PlayerTextDrawFont(playerid, TD_Shop_BtnDir, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Shop_BtnDir, 0.6, 3.0);
        PlayerTextDrawColour(playerid, TD_Shop_BtnDir, 0xAAAAAAFF);
        PlayerTextDrawSetSelectable(playerid, TD_Shop_BtnDir, true);
        PlayerTextDrawTextSize(playerid, TD_Shop_BtnDir, BaseX + 240.0, 30.0);

        // // 6. BOTÃO COMPRAR (Caixa Grande Verde)
        // TD_Shop_BtnComp = CreatePlayerTextDraw(playerid, BaseX + 120.0, BaseY + 215.0, "COMPRAR");
        // PlayerTextDrawAlignment(playerid, TD_Shop_BtnComp, TEXT_DRAW_ALIGN:2);
        // PlayerTextDrawUseBox(playerid, TD_Shop_BtnComp, true);
        // PlayerTextDrawBoxColour(playerid, TD_Shop_BtnComp, 0x008000FF); // Fundo Verde
        // PlayerTextDrawTextSize(playerid, TD_Shop_BtnComp, 25.0, 100.0); // OBS: Em Align 2, Y é largura, X é altura (bug do samp)
        // PlayerTextDrawLetterSize(playerid, TD_Shop_BtnComp, 0.4, 1.8);
        // PlayerTextDrawSetSelectable(playerid, TD_Shop_BtnComp, true);
        // // Correção da área de clique para Align 2 (O SAMP é chato com isso, se não clicar, avise)
        // PlayerTextDrawDestroy(playerid, TD_Shop_BtnComp);
        
        // Recriando botão Comprar de forma segura (Align 0) para clique perfeito
        TD_Shop_BtnComp = CreatePlayerTextDraw(playerid, BaseX + 60.0, BaseY + 215.0, "COMPRAR");
        PlayerTextDrawUseBox(playerid, TD_Shop_BtnComp, true);
        PlayerTextDrawBoxColour(playerid, TD_Shop_BtnComp, 0x008000FF);
        PlayerTextDrawTextSize(playerid, TD_Shop_BtnComp, BaseX + 180.0, 30.0); // Vai até X=180
        PlayerTextDrawAlignment(playerid, TD_Shop_BtnComp, TEXT_DRAW_ALIGN:2); // Centraliza texto
        PlayerTextDrawLetterSize(playerid, TD_Shop_BtnComp, 0.4, 1.8);
        PlayerTextDrawSetSelectable(playerid, TD_Shop_BtnComp, true);

        // 7. BOTÃO SAIR (X Vermelho no topo)
        TD_Shop_BtnSair = CreatePlayerTextDraw(playerid, BaseX + 220.0, BaseY + 5.0, "X");
        PlayerTextDrawColour(playerid, TD_Shop_BtnSair, 0xFF0000FF);
        PlayerTextDrawFont(playerid, TD_Shop_BtnSair, TEXT_DRAW_FONT:1);
        PlayerTextDrawLetterSize(playerid, TD_Shop_BtnSair, 0.4, 1.5);
        PlayerTextDrawSetSelectable(playerid, TD_Shop_BtnSair, true);
        PlayerTextDrawTextSize(playerid, TD_Shop_BtnSair, BaseX + 240.0, 20.0);        
    }

    if(guiid == 7)
    {
        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name);
        PTD_Login_Nome[playerid] = CreatePlayerTextDraw(playerid, 80.0, 198.0, name);
        PlayerTextDrawFont(playerid, PTD_Login_Nome[playerid], TEXT_DRAW_FONT:1);
        PlayerTextDrawColour(playerid, PTD_Login_Nome[playerid], -1);
        PlayerTextDrawLetterSize(playerid, PTD_Login_Nome[playerid], 0.35, 1.4);
    }
}

stock GUI::CreateTD(guiid)
{
    if(guiid == 1)
    {
        // --- EDITOR DE ACESSÓRIOS ---
        TD_Edit_Fundo = TextDrawCreate(500.0, 150.0, "_");
        TextDrawUseBox(TD_Edit_Fundo, true); TextDrawBoxColour(TD_Edit_Fundo, 0x000000AA);
        TextDrawTextSize(TD_Edit_Fundo, 630.0, 0.0); TextDrawLetterSize(TD_Edit_Fundo, 0.0, 14.0);

        TD_Edit_Botoes[0] = TextDrawCreate(510.0, 160.0, "X-");
        TD_Edit_Botoes[1] = TextDrawCreate(550.0, 160.0, "X+");
        TD_Edit_Botoes[2] = TextDrawCreate(510.0, 180.0, "Y-");
        TD_Edit_Botoes[3] = TextDrawCreate(550.0, 180.0, "Y+");
        TD_Edit_Botoes[4] = TextDrawCreate(510.0, 200.0, "Z-");
        TD_Edit_Botoes[5] = TextDrawCreate(550.0, 200.0, "Z+");
        
        TD_Edit_Botoes[6] = TextDrawCreate(510.0, 230.0, "MODO"); 
        TextDrawColour(TD_Edit_Botoes[6], 0xFFFF00FF);
        
        TD_Edit_Botoes[7] = TextDrawCreate(510.0, 250.0, "SALVAR"); 
        TextDrawColour(TD_Edit_Botoes[7], 0x00FF00FF);
        
        TD_Edit_Botoes[8] = TextDrawCreate(510.0, 265.0, "SAIR"); 
        TextDrawColour(TD_Edit_Botoes[8], 0xFF0000FF);

        for(new i=0; i < 9; i++) {
            TextDrawAlignment(TD_Edit_Botoes[i], TEXT_DRAW_ALIGN:0); 
            TextDrawFont(TD_Edit_Botoes[i], TEXT_DRAW_FONT:2);
            TextDrawLetterSize(TD_Edit_Botoes[i], 0.4, 1.2); 
            TextDrawSetSelectable(TD_Edit_Botoes[i], true);
            TextDrawSetOutline(TD_Edit_Botoes[i], 1);
            // Ajustes de tamanho de clique (simplificado para o código não ficar gigante aqui)
            if(i < 6) 
                TextDrawTextSize(TD_Edit_Botoes[i], 540.0 + (i%2)*40.0, 10.0);
                
            else TextDrawTextSize(TD_Edit_Botoes[i], 580.0, 10.0);
        }
    }

    if(guiid == 7)
    {
        // ============================================================
        //              NOVA TELA DE LOGIN - CORRIGIDA
        // ============================================================

        // 1. FUNDO SÓLIDO (Cobre a tela toda com Cinza Chumbo)
        TD_Login_Fundo = TextDrawCreate(0.0, 0.0, "ld_spac:white");
        TextDrawFont(TD_Login_Fundo, TEXT_DRAW_FONT:4); // <--- Corrigido: TextDrawFont (sem Player)
        TextDrawColour(TD_Login_Fundo, COR_FUNDO_SOLIDO); 
        TextDrawTextSize(TD_Login_Fundo, 640.0, 480.0); 

        // 2. TEXTO PEQUENO "LOGIN" (Mantém cinza claro)
        TD_Login_LogoPequena = TextDrawCreate(50.0, 130.0, "LOGIN");
        TextDrawFont(TD_Login_LogoPequena, TEXT_DRAW_FONT:1);
        TextDrawColour(TD_Login_LogoPequena, 0xAAAAAAFF);
        TextDrawLetterSize(TD_Login_LogoPequena, 0.25, 1.0);
        TextDrawSetOutline(TD_Login_LogoPequena, 1);

        // 3. LOGO GRANDE (AGORA VERDE)
        TD_Login_LogoGrande = TextDrawCreate(50.0, 140.0, "BPS"); // Mude "BPS" para o nome do seu server se quiser
        TextDrawFont(TD_Login_LogoGrande, TEXT_DRAW_FONT:2);
        TextDrawColour(TD_Login_LogoGrande, COR_VERDE_TEMA); // <--- VERDE AQUI
        TextDrawLetterSize(TD_Login_LogoGrande, 0.8, 3.5);
        TextDrawSetOutline(TD_Login_LogoGrande, 0);
        TextDrawSetShadow(TD_Login_LogoGrande, 0);

        // 4. CAIXA DO USUÁRIO (Agora Cinza Mais Claro para destacar)
        TD_Login_BoxUser = TextDrawCreate(50.0, 190.0, "_");
        TextDrawUseBox(TD_Login_BoxUser, true);
        TextDrawBoxColour(TD_Login_BoxUser, 0x333333FF); // <--- MUDAMOS PARA CINZA CLARO
        TextDrawTextSize(TD_Login_BoxUser, 220.0, 0.0);
        TextDrawLetterSize(TD_Login_BoxUser, 0.0, 3.5);

        // Ícone de Usuário
        TD_Login_IconUser = TextDrawCreate(55.0, 195.0, " "); 
        TextDrawFont(TD_Login_IconUser, TEXT_DRAW_FONT:1); 
        TextDrawColour(TD_Login_IconUser, 0x999999FF); // Ícone mais claro também
        TextDrawLetterSize(TD_Login_IconUser, 0.5, 2.0);

        // 5. CAIXA DA SENHA (Agora Cinza Mais Claro para destacar)
        TD_Login_BoxSenha = TextDrawCreate(50.0, 235.0, "_");
        TextDrawUseBox(TD_Login_BoxSenha, true);
        TextDrawBoxColour(TD_Login_BoxSenha, 0x333333FF); // <--- MUDAMOS PARA CINZA CLARO
        TextDrawTextSize(TD_Login_BoxSenha, 220.0, 0.0);
        TextDrawLetterSize(TD_Login_BoxSenha, 0.0, 3.5);

        // Texto "DIGITAR SENHA"
        TD_Login_IconPass = TextDrawCreate(60.0, 242.0, "DIGITAR SENHA");
        TextDrawFont(TD_Login_IconPass, TEXT_DRAW_FONT:1);
        TextDrawColour(TD_Login_IconPass, 0xAAAAAAFF); // Texto mais visível
        TextDrawLetterSize(TD_Login_IconPass, 0.25, 1.2);
        TextDrawSetSelectable(TD_Login_IconPass, true);
        TextDrawTextSize(TD_Login_IconPass, 220.0, 10.0);

        // 6. TEXTO "Esqueci minha senha" (Com detalhes Verdes)
        // Mudamos o ~r~ (vermelho) para ~g~ (verde)
        // TD_Login_Esqueci = TextDrawCreate(50.0, 275.0, "~g~O ~w~Esqueci minha ~g~Senha");
        // TextDrawFont(TD_Login_Esqueci, TEXT_DRAW_FONT:1);
        // TextDrawLetterSize(TD_Login_Esqueci, 0.20, 1.0);
        // TextDrawSetSelectable(TD_Login_Esqueci, true);

        // 7. BOTÃO CONECTAR (Fundo Verde)
        TD_Login_BtnConectar = TextDrawCreate(135.0, 298.0, "CONECTAR");
        TextDrawAlignment(TD_Login_BtnConectar, TEXT_DRAW_ALIGN:2);
        TextDrawUseBox(TD_Login_BtnConectar, true);
        TextDrawBoxColour(TD_Login_BtnConectar, COR_VERDE_BOTAO); // <--- FUNDO VERDE AQUI
        TextDrawTextSize(TD_Login_BtnConectar, 30.0, 170.0);
        TextDrawFont(TD_Login_BtnConectar, TEXT_DRAW_FONT:2);
        TextDrawLetterSize(TD_Login_BtnConectar, 0.35, 1.6);
        TextDrawSetSelectable(TD_Login_BtnConectar, true);

        // 8. TEXTO "Nao tem conta?" (Com detalhe Verde)
        TD_Login_BtnCriar = TextDrawCreate(50.0, 340.0, "Nao tem ~g~Conta?"); // ~g~ aqui
        TextDrawFont(TD_Login_BtnCriar, TEXT_DRAW_FONT:1);
        TextDrawLetterSize(TD_Login_BtnCriar, 0.25, 1.0);
        TextDrawSetSelectable(TD_Login_BtnCriar, true);        
    }

    if(guiid == 8)
    {
        // --- BANCO ---
        TD_BancoFundo = TextDrawCreate(505.0, 255.0, "_");
        TextDrawUseBox(TD_BancoFundo, true); TextDrawBoxColour(TD_BancoFundo, 0x004000FF);
        TextDrawTextSize(TD_BancoFundo, 605.0, 0.0); TextDrawLetterSize(TD_BancoFundo, 0.0, 16.5);

        TD_BancoTitulo = TextDrawCreate(555.0, 260.0, "BPS BANK");
        TextDrawAlignment(TD_BancoTitulo, TEXT_DRAW_ALIGN:2); TextDrawFont(TD_BancoTitulo, TEXT_DRAW_FONT:2);
        TextDrawLetterSize(TD_BancoTitulo, 0.4, 1.5); TextDrawColour(TD_BancoTitulo, COR_V_CLARO);

        TD_BtnPix = TextDrawCreate(520.0, 330.0, "> FAZER PIX <");
        TextDrawAlignment(TD_BtnPix, TEXT_DRAW_ALIGN:2); TextDrawFont(TD_BtnPix, TEXT_DRAW_FONT:2);
        TextDrawLetterSize(TD_BtnPix, 0.25, 1.2); TextDrawColour(TD_BtnPix, -1);
        TextDrawUseBox(TD_BtnPix, true); TextDrawBoxColour(TD_BtnPix, COR_V_ESCURO);
        TextDrawTextSize(TD_BtnPix, 15.0, 50.0); TextDrawSetSelectable(TD_BtnPix, true);

        TD_BtnSair = TextDrawCreate(555.0, 380.0, "SAIR");
        TextDrawAlignment(TD_BtnSair, TEXT_DRAW_ALIGN:2); TextDrawFont(TD_BtnSair, TEXT_DRAW_FONT:2);
        TextDrawLetterSize(TD_BtnSair, 0.3, 1.2); TextDrawSetSelectable(TD_BtnSair, true);
    }
}