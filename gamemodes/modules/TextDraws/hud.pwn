#include <YSI\YSI_Coding\y_hooks>

        /* RODAPE */
new Text:TD_Rodape_Fundo; 
new Text:TD_Rodape_Linha; 
new Text:TD_Rodape_Logo;
new Text:TD_LogoBPS;
new Text:TD_DataHora;
new PlayerText:PTD_Stats[MAX_PLAYERS];

    /* VELOCÍMETRO */
new PlayerText:TD_Velocimetro[MAX_PLAYERS][4];

    /* VENDA (BANDANA) */
new PlayerText:TD_Venda[MAX_PLAYERS];

    /* ERRO (COMANDO) */
new Text:TD_ErroComando;

#define HUD::       h_

stock HUD::HideTDForPlayer(playerid, hudid)
{
    if(hudid == 1)
    {
        TextDrawHideForPlayer(playerid, TD_Rodape_Fundo);
        TextDrawHideForPlayer(playerid, TD_Rodape_Linha);
        TextDrawHideForPlayer(playerid, TD_Rodape_Logo);
        TextDrawHideForPlayer(playerid, TD_DataHora);
        PlayerTextDrawHide(playerid, PTD_Stats[playerid]);
    }

    if(hudid == 2)
    {
        for(new i = 0; i < 4; i++) 
            PlayerTextDrawHide(playerid, TD_Velocimetro[playerid][i]);
    
    }

    if(hudid == 3)
    {
        PlayerTextDrawHide(playerid, TD_Venda[playerid]);
    }

    if(hudid == 4)
    {
        TextDrawHideForPlayer(playerid, TD_ErroComando);
    }
}

stock HUD::ShowTDForPlayer(playerid, hudid)
{
    if(hudid == 1)
    {
        TextDrawShowForPlayer(playerid, TD_Rodape_Fundo);
        TextDrawShowForPlayer(playerid, TD_Rodape_Linha);
        TextDrawShowForPlayer(playerid, TD_Rodape_Logo);
        TextDrawShowForPlayer(playerid, TD_DataHora);
        PlayerTextDrawShow(playerid, PTD_Stats[playerid]);
    }

    if(hudid == 2)
    {
        for(new i = 0; i < 4; i++) 
            PlayerTextDrawShow(playerid, TD_Velocimetro[playerid][i]);
    }

    if(hudid == 3)
    {
        PlayerTextDrawShow(playerid, TD_Venda[playerid]);   
    }

    if(hudid == 4)
    {
        TextDrawShowForPlayer(playerid, TD_ErroComando);
    }
}

stock HUD::CreatePlayerTD(playerid, hudid)
{
    if(hudid == 1)
    {
        // 2. STATS (CPF, Bitcoin... Canto Direito)
        PTD_Stats[playerid] = CreatePlayerTextDraw(playerid, 630.0, 437.0, "CPF: Carregando...");
        PlayerTextDrawAlignment(playerid, PTD_Stats[playerid], TEXT_DRAW_ALIGN:3); 
        PlayerTextDrawFont(playerid, PTD_Stats[playerid], TEXT_DRAW_FONT:1);
        PlayerTextDrawColour(playerid, PTD_Stats[playerid], 0xAAAAAAFF);
        PlayerTextDrawLetterSize(playerid, PTD_Stats[playerid], 0.20, 0.9);
        PlayerTextDrawSetOutline(playerid, PTD_Stats[playerid], 1);
    }

    if(hudid == 2)
    {
        // POSIÇÃO CENTRALIZADA NO RODAPÉ
        // 320.0 é o meio exato da tela na horizontal
        // 380.0 é a altura (perto do fim da tela)
        new Float:BaseX = 320.0, Float:BaseY = 380.0;

        // 0. NOME DO VEÍCULO (Topo do velocímetro)
        TD_Velocimetro[playerid][0] = CreatePlayerTextDraw(playerid, BaseX, BaseY, "Veiculo");
        PlayerTextDrawAlignment(playerid, TD_Velocimetro[playerid][0], TEXT_DRAW_ALIGN:2); // 2 = Centralizado
        PlayerTextDrawColour(playerid, TD_Velocimetro[playerid][0], 0xCCCCCCFF); // Cinza Claro
        PlayerTextDrawFont(playerid, TD_Velocimetro[playerid][0], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_Velocimetro[playerid][0], 0.25, 1.2);
        PlayerTextDrawSetOutline(playerid, TD_Velocimetro[playerid][0], 1); // Borda preta pra ler melhor

        // 1. VELOCIDADE (Número Grande)
        TD_Velocimetro[playerid][1] = CreatePlayerTextDraw(playerid, BaseX, BaseY + 15.0, "000");
        PlayerTextDrawAlignment(playerid, TD_Velocimetro[playerid][1], TEXT_DRAW_ALIGN:2); // Centralizado
        PlayerTextDrawColour(playerid, TD_Velocimetro[playerid][1], COLOR_THEME_BPS); // Verde do Servidor
        PlayerTextDrawFont(playerid, TD_Velocimetro[playerid][1], TEXT_DRAW_FONT:2); // Fonte Impact
        PlayerTextDrawLetterSize(playerid, TD_Velocimetro[playerid][1], 0.7, 3.0); // Bem grande
        PlayerTextDrawSetOutline(playerid, TD_Velocimetro[playerid][1], 1);

        // 2. KM/H (Texto pequeno embaixo)
        TD_Velocimetro[playerid][2] = CreatePlayerTextDraw(playerid, BaseX, BaseY + 42.0, "KM/H");
        PlayerTextDrawAlignment(playerid, TD_Velocimetro[playerid][2], TEXT_DRAW_ALIGN:2); // Centralizado
        PlayerTextDrawColour(playerid, TD_Velocimetro[playerid][2], -1); // Branco
        PlayerTextDrawFont(playerid, TD_Velocimetro[playerid][2], TEXT_DRAW_FONT:2);
        PlayerTextDrawLetterSize(playerid, TD_Velocimetro[playerid][2], 0.20, 1.0);
        PlayerTextDrawSetOutline(playerid, TD_Velocimetro[playerid][2], 1);

        // 3. BARRA DE VIDA (Fina e embaixo de tudo)
        // Começa no X=270 e vai até 370 (Largura de 100px centralizada)
        TD_Velocimetro[playerid][3] = CreatePlayerTextDraw(playerid, BaseX - 50.0, BaseY + 55.0, "_");
        PlayerTextDrawUseBox(playerid, TD_Velocimetro[playerid][3], true);
        PlayerTextDrawBoxColour(playerid, TD_Velocimetro[playerid][3], 0x00FF00FF); // Verde
        PlayerTextDrawTextSize(playerid, TD_Velocimetro[playerid][3], BaseX + 50.0, 0.0); // Tamanho Maximo
        PlayerTextDrawLetterSize(playerid, TD_Velocimetro[playerid][3], 0.0, 0.4); // Bem fininha
    }

    if(hudid == 3)
    {
        TD_Venda[playerid] = CreatePlayerTextDraw(playerid, -20.0, -20.0, "_");
        PlayerTextDrawUseBox(playerid, TD_Venda[playerid], true);
        PlayerTextDrawBoxColour(playerid, TD_Venda[playerid], 0x000000FF); // Preto Total
        PlayerTextDrawTextSize(playerid, TD_Venda[playerid], 660.0, 500.0); // Tela toda
        PlayerTextDrawLetterSize(playerid, TD_Venda[playerid], 0.0, 50.0);
    }
}

stock HUD::CreateTD(hudid)
{
    if(hudid == 1)
    {
        // --- RODAPÉ (HUD) ---

        // 1. DATA E HORA
        TD_DataHora = TextDrawCreate(10.0, 430.0, "Carregando...");
        TextDrawFont(TD_DataHora, TEXT_DRAW_FONT:1);
        TextDrawColour(TD_DataHora, 0xFFFFFFFF);
        TextDrawLetterSize(TD_DataHora, 0.22, 0.9);
        TextDrawSetOutline(TD_DataHora, true);

        TD_Rodape_Fundo = TextDrawCreate(0.0, 435.0, "_");
        TextDrawUseBox(TD_Rodape_Fundo, true); TextDrawBoxColour(TD_Rodape_Fundo, 0x111111FF);
        TextDrawTextSize(TD_Rodape_Fundo, 640.0, 0.0); TextDrawLetterSize(TD_Rodape_Fundo, 0.0, 1.4);

        TD_Rodape_Linha = TextDrawCreate(0.0, 433.0, "_");
        TextDrawUseBox(TD_Rodape_Linha, true); TextDrawBoxColour(TD_Rodape_Linha, COLOR_THEME_BPS);
        TextDrawTextSize(TD_Rodape_Linha, 640.0, 0.0); TextDrawLetterSize(TD_Rodape_Linha, 0.0, 0.1);

        TD_Rodape_Logo = TextDrawCreate(320.0, 434.0, "BPS");
        TextDrawAlignment(TD_Rodape_Logo, TEXT_DRAW_ALIGN:2); TextDrawFont(TD_Rodape_Logo, TEXT_DRAW_FONT:2);
        TextDrawColour(TD_Rodape_Logo, COLOR_THEME_BPS); TextDrawLetterSize(TD_Rodape_Logo, 0.6, 1.5);
        TextDrawSetOutline(TD_Rodape_Logo, 1);

        // --- SISTEMA 2: LOGOTIPO BPS (Topo Central) ---
        TD_LogoBPS = TextDrawCreate(320.000000, 5.000000, "BPS"); // 320 é o meio da tela
        TextDrawAlignment(TD_LogoBPS, TEXT_DRAW_ALIGN:2); // Centralizado
        TextDrawBackgroundColour(TD_LogoBPS, 255);
        TextDrawFont(TD_LogoBPS, TEXT_DRAW_FONT:2); // Fonte estilo "Gang"
        TextDrawLetterSize(TD_LogoBPS, 0.600000, 2.400000);
        TextDrawColour(TD_LogoBPS, COLOR_THEME_BPS); // Verde do Servidor
        TextDrawSetOutline(TD_LogoBPS, true);
        TextDrawSetProportional(TD_LogoBPS, true);   
    }

    if(hudid == 4)
    {
        // --- TEXTDRAW DE ERRO DE COMANDO ---
        TD_ErroComando = TextDrawCreate(320.0, 360.0, "~r~COMANDO DESCONHECIDO"); // Fica no meio, embaixo
        TextDrawAlignment(TD_ErroComando, TEXT_DRAW_ALIGN:2); // 2 = Centralizado
        TextDrawColour(TD_ErroComando, 0xFF0000FF); // Vermelho
        TextDrawFont(TD_ErroComando, TEXT_DRAW_FONT:2); // Fonte mais grossa
        TextDrawLetterSize(TD_ErroComando, 0.4, 1.6);
        TextDrawSetOutline(TD_ErroComando, 1); // Borda preta
        TextDrawSetShadow(TD_ErroComando, 0);
    }
}