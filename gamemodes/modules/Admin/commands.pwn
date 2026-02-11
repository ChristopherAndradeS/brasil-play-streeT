#include <YSI\YSI_Coding\y_hooks>

YCMD:mkfnd(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid)) return 0;

    new level = floatround(floatlog(float(FLAG_ADM_FOUNDER), 2.0));

    new sucess = Adm::SetPlayer(playerid, "SERVER", level);

    if(!sucess)
        SendClientMessage(playerid, COLOR_ERRO, "[ ADM ] {ffffff}Erro ao setar voce como fundador!");
    
    return 1;
}

YCMD:aa(playerid, params[], help)
{
    //if(!Adm::HasPermission(playerid, FLAG_ADM_APPRENTICE_STAFF)) return 1;
    
    new str[512];
    
    strcat(str, Command_GetPlayer(YCMD:aw, playerid) ? "aw\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:ir, playerid) ? "ir\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:verid, playerid) ? "verid\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:aviso, playerid) ? "aviso\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:congelar, playerid) ? "congelar\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:descongelar, playerid) ? "descongelar\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:lchat, playerid) ? "lchat\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:kick, playerid) ? "kick\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:setarskin, playerid) ? "setarskin\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:setarvida, playerid) ? "setarvida\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:setarcolete, playerid) ? "setarcolete\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:megafone, playerid) ? "megafone\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:cronometro, playerid) ? "cronometro\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:prender, playerid) ? "prender\n" : " ");
    strcat(str, Command_GetPlayer(YCMD:soltar, playerid) ? "soltar" : " ");
    //strcat(str, Command_GetPlayer(YCMD:prenderoff, playerid) ? "prenderoff\n" : " ");
    //strcat(str, Command_GetPlayer(YCMD:soltaroff, playerid) ? "soltaroff\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:criargps, playerid) ? "criargps\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:criarorg, playerid) ? "criarorg\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:ban, playerid) ? "ban\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:banip, playerid) ? "banip\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:desban, playerid) ? "desban\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:desbanip, playerid) ? "desbanip\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:setadm, playerid) ? "setadm\n" : " ");
    // strcat(str, Command_GetPlayer(YCMD:remadm, playerid) ? "remadm\n" : " ");

    inline no_use_dialog(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, listitem

        if(!response) return 1;
        Command_ReProcess(playerid, inputtext, true);
        return 1;
    }

    format(str, 512, "{ffffff}%s", str);

    Dialog_ShowCallback(playerid, using inline no_use_dialog, DIALOG_STYLE_LIST, 
    "{00FF00}Comandos Admin", str, "Selecionar", "Fechar");

    return 1;
}

YCMD:aw(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Entrar no modo de trabalho");
        return 1;
    }

    if(!Adm::HandleWork(playerid))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Nenhum jogador online para entrar em modo de trabalho!"); 
    
    return 1;
}

YCMD:ir(playerid, params[], help)
{
    //if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Selecionar jogador para espectar");
        return 1;
    }

    new targetid;

    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /ir {ff3333}[ ID ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    if(!Adm::SpectatePlayer(playerid, targetid))
        return SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Nao foi possivel espectar!");

    SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Espectando jogador %s ID: %d!", GetPlayerNameEx(targetid), targetid);

    return 1;
}

YCMD:verid(playerid, params[], help)
{
    //if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Ver ID de jogador pelo nome");
        return 1;
    }

    new name[MAX_PLAYER_NAME];

    if(sscanf(params, "s[24]", name)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /verid {ff3333}[ NOME ]");

    new targetid = GetPlayerIDByName(name);

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    SendClientMessage(playerid, -1, 
    "{ffff33}[ ADM ] {ffffff}O jogador {ffff33}%s {ffffff}possui ID: {ffff33}%d", 
    GetPlayerNameEx(targetid), targetid);

    return 1;
}

YCMD:aviso(playerid, params[], help)
{
    //if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Enviar aviso personalizado ao jogador");
        return 1;
    }

    new targetid, reason[64];

    if(sscanf(params, "us[64]", targetid, reason)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /aviso {ff3333}[ ID ] [ MSG ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    SendClientMessage(targetid, -1, "{ff9933}[ AVISO ADMIN ] {ffffff}%s", reason);
    SendClientMessage(playerid, COLOR_SUCESS, "{ffff33}[ ADM ] {ffffff}Aviso {ffff33}enviado.");

    return 1;
}

YCMD:congelar(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Congela um jogador");
        return 1;
    }

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /congelar {ff3333}[ ID ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    if(!IsPlayerControllable(targetid))
    {
        SendClientMessage(playerid, -1, "{ff9933}[ ADM ] {ffffff}O jogador {ff9933}%s \
        {ffffff}ja esta congelado.", GetPlayerNameEx(targetid));
    }
    else
    {
        TogglePlayerControllable(targetid, false);
        SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}O jogador {33ff33}%s \
        {ffffff}foi congelado!", GetPlayerNameEx(targetid));
        SendClientMessage(targetid, -1, "{ff9933}[ AVISO ] {ffffff}Voce foi congelado por um adm");
    }

    return 1;
}

YCMD:descongelar(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Descongela um jogador");
        return 1;
    }

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /descongelar {ff3333}[ ID ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    if(IsPlayerControllable(targetid))
    {
        SendClientMessage(playerid, -1, "{ff9933}[ ADM ] {ffffff}O jogador {ff9933}%s \
        {ffffff}ja esta descongelado.", GetPlayerNameEx(targetid));
    }

    else
    {
        TogglePlayerControllable(targetid, false);
        SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}O jogador {33ff33}%s \
        {ffffff}foi descongelado!", GetPlayerNameEx(targetid));
        SendClientMessage(targetid, -1, "{ff9933}[ AVISO ] {ffffff}Voce foi descongelado por um admin");
    }

    return 1;
}

YCMD:tp(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Teleporta para uma posição X, Y, Z no mundo");
        return 1;
    }

    new Float:pX, Float:pY, Float:pZ, interiorid, vw;
    if(sscanf(params, "fffii", pX, pY, pZ, interiorid, vw)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /tp {ff3333}[ X ] [ Y ] [ Z ] [ INTERIORID ] [ VIRTUAL WORLD ]");

    SetPlayerPos(playerid, pX, pY, pZ);
    SetPlayerInterior(playerid, interiorid);
    SetPlayerVirtualWorld(playerid, vw);

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Teleportado com sucesso!");

    return 1;
}

YCMD:lchat(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Limpa o Chat de todos os jogadores");
        return 1;
    }

    ClearChat(playerid, 45);
    SendClientMessageToAll(-1, "{33ff33}[ ADM ] {ffffff}Chat limpo! :)");
    return 1;
}

YCMD:kick(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Kika um jogador");
        return 1;
    }
    
    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /kick {ff3333}[ ID ] [ MOTIVO ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;
    
    new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME];
    GetPlayerName(targetid, name);
    GetPlayerName(playerid, admin);
    
    SendClientMessageToAll(-1, "{ff3399}[ ADM PUNICAO ] {ffffff}%s {ff3399}kickou {ffffff}%s.", admin, name);
    SendClientMessageToAll(-1, "{ff3399}[ ADM PUNICAO ] {ff3399}Motivo: {ffffff}%s", reason);
    
    Kick(targetid);

    return 1;
}

YCMD:setarskin(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Altera o skinid de um jogador");
        return 1;
    }

    new targetid, skinid;
    if(sscanf(params, "ui", targetid, skinid))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /kick {ff3333}[ ID ] [ SKINID ]");
    
    if(skinid < 0 || skinid > 311) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Erro do parâmetro: {ff3333}skinid {ffffff}[0 - 311]");
    
    if(!Adm::ValidTargetID(playerid, targetid, true)) return 1;

    SetPlayerSkin(targetid, skinid);

    SendClientMessage(targetid, -1, "{ff9933}[ AVISO ] {ffffff}Um admin alterou sua skin.");
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Você alterou a {33ff33}skin {ffffff}de %s. skinid : %d ", GetPlayerNameEx(targetid), skinid);
 
    return 1;
}

YCMD:setarvida(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Altera o valor de vida de um jogador");
        return 1;
    }

    new targetid, Float:health;
    if(sscanf(params, "uf", targetid, health))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /setarvida {ff3333}[ ID ] [ VIDA ]");
   
    if(!Adm::ValidTargetID(playerid, targetid, true)) return 1;

    health = floatclamp(health, 0.0, 100.0);
    SetPlayerHealth(targetid, health);

    SendClientMessage(targetid, -1, "{ff9933}[ AVISO ] {ffffff}Um admin alterou sua vida para %.1f%%.", health);
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce alterou a {33ff33}vida {ffffff}de %s para %.1f%%.", GetPlayerNameEx(targetid), health);

    return 1;
}

YCMD:setarcolete(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Altera o valor de colete de um jogador");
        return 1;
    }
    
    new targetid, Float:armour;
    if(sscanf(params, "uf", targetid, armour))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /setarcolete {ff3333}[ ID ] [ COLETE ]");
   
    if(!Adm::ValidTargetID(playerid, targetid, true)) return 1;

    armour = floatclamp(armour, 0.0, 100.0);
    SetPlayerArmour(targetid, floatclamp(armour, 0.0, 100.0));

    SendClientMessage(targetid, -1, "{ff9933}[ AVISO ] {ffffff}Um admin alterou seu colete para %.1f%%.", armour);
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce alterou o {33ff33}colete {ffffff}de %s para %.1f%%.", GetPlayerNameEx(targetid), armour);

    return 1;
}

YCMD:megafone(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Envia uma gametext personalizada para todos");
        return 1;
    }

    new msg[144], time;
    if(sscanf(params, "is[144]", time, msg))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /megafone {ff3333}[ MSG ] [ DURACAO (segundos) ]");
    
    time = clamp(time, 1, 15);

    GameTextForAll("~g~~h~~h~%s", time * 1000, 3, msg);
    SendClientMessageToAll(-1, "{ff3399}[ ANUNCIO ADM ] {ffffff}%s", msg);

    return 1;
}

YCMD:cronometro(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Envia uma gametext cronometrada para todos");
        return 1;
    }

    if(Server[srv::is_count_down])
        return SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Ja existe um cronometro rodando!");
      
    new time;
    if(sscanf(params, "i", time))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /cronometro {ff3333}[ TEMPO (segundos) ]");
    
    time = clamp(time, 3, 120);

    inline CountDown()
    {
        if(time < 0)
        {
            GameTextForAll("~r~Tempo Acabou", 1500, 3);
            Server[srv::is_count_down] = 0;
            Timer_KillCallback(srv::Timer[srv::TIMER_COUNT_DOWN]);
        }
        else
        {
            GameTextForAll("~g~~h~~h~%02d:%02d", 990, 3, floatround(time/60), time % 60);
            time--;
        }
    }

    GameTextForAll("~y~Iniciando Contagem...", 1000, 3);
    srv::Timer[srv::TIMER_COUNT_DOWN] = Timer_CreateCallback(using inline CountDown, 1000, 1000, time + 2);
    Server[srv::is_count_down] = 1;

    return 1;
}

YCMD:prender(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Prende um delinquente na cadeia staff por um tempo em minutos/horas");
        return 1;
    }

    new targetid, minutes, reason[64];
    if(sscanf(params, "uis[64]", targetid, minutes, reason)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /prender {ff3333}[ ID ] [ TEMPO (minutos) ] [ MOTIVO ]");
    
    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    ResetPlayerWeapons(targetid);
    
    new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME]; 
    GetPlayerName(targetid, name, sizeof(name));
    GetPlayerName(playerid, admin, sizeof(admin));

    new result = Punish::SetJail(name, admin, reason, minutes * 60000);

    if(result == 0)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Houve um erro ao registrar prisão!");
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Provalmente o jogador não existe nos banco de dados!");
        return 1;
    }

    else if(result < 0)
    {
        // SendClientMessageToAll(-1, "{ff3399}[ ILHA ] %s {ffffff}ficará na ilha abandonada por mais tempo: {ff3399}%d {ffffff}minutos", name, minutes);
        // SendClientMessageToAll(-1, "{ff3399}[ ILHA ] Motivo: {ffffff}%s", reason);
        Punish::UpdatePlayerJail(targetid, minutes * 60000);
        return 1;
    }

    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] %s {ffffff}foi para ilha abandonada e ficara lá por {ff3399}%d {ffffff}minutos", name, minutes);
    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] Motivo: {ffffff}%s", reason);

    if(targetid != INVALID_PLAYER_ID)
    {
        Punish::SendPlayerToJail(targetid, minutes * 60000);
        SendClientMessage(targetid, -1, "{ff3333}[ ILHA ] {ffffff}Bem vindo a ilha abandonada! Aqui você vai refletir suas más ações");
    }

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce prendeu {33ff33}%s {ffffff}por {33ff33}%d {ffffff}minutos com sucesso.", name, minutes);

    return 1;
}

YCMD:soltar(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Solta um arrependido da cadeia staff");
        return 1;
    }

    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /soltar {ff3333}[ ID ]");
    
    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    new result = Punish::UnsetJail(targetid);

    if(result == 0)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Jogador Offline, tente /soltaroff!");
        return 1;
    }

    else if(result == -1)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Erro ao remover jogador %s da cadeia staff!", GetPlayerNameEx(targetid));
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Reporte esse erro à um programador imediatamente!");
        return 1;
    }

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce soltou {33ff33}%s.", GetPlayerNameEx(targetid));
    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] O jogador {ff3399}%s foi {ffffff}perdoado e foi embora da ilha", GetPlayerNameEx(targetid));
    return 1;
}

YCMD:prenderoff(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Prende um delinquente offline na cadeia staff por um tempo em minutos/horas");
        return 1;
    }

    new name[MAX_PLAYER_NAME], minutes, reason[64];
    if(sscanf(params, "s[24]is[64]", name, minutes, reason)) 
        return SendClientMessage(playerid, -1, 
        "{ff3333}[ CMD ] {ffffff}Use: /prenderoff {ff3333}[ NOME ] [ TEMPO (minutos) ] [ MOTIVO ]");
    
    new admin_name[24];
    GetPlayerName(playerid, admin_name);

    if(!Adm::IsValidTargetName(admin_name, name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 1;
    }

    new targetid = GetPlayerIDByName(name);
    
    if(targetid != INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] Jogador %s está online! {ffffff}Seu ID é {ff3333}%d", name, targetid);

    if(Punish::SetJail(name, GetPlayerNameEx(playerid), reason, minutes * 60000) == 0)
        return SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Houve um erro. Provalmente o jogador não existe nos dados!");
  
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce definiu {33ff33}%d {ffffff}minutos de cadeia para {33ff33}%s {ffffff}com sucesso.", minutes, name);

    return 1;
}

// YCMD:ban(playerid, params[], help)
// {
//     VerificarAdmin(playerid, 4); // Rank 4+
//     VerificarTra(playerid);
    
//     new id, motivo[64];
//     if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, -1, "Use: /ban [ID] [Motivo]");
//     if(!IsValidPlayer(id)) return SendClientMessage(playerid, -1, "Jogador offline.");

//     new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64], data[32];
//     GetPlayerName(id, name, sizeof(name));
//     GetPlayerName(playerid, admin, sizeof(admin));
//     getdate(data[0], data[1], data[2]); // Pega ano, mes, dia
//     format(data, sizeof(data), "%d/%d/%d", data[2], data[1], data[0]);

//     // Cria o arquivo na pasta Banidos
//     format(arquivo, sizeof(arquivo), PASTA_BANIDOS, name);
//     DOF2_CreateFile(arquivo);
//     DOF2_SetString(arquivo, "Admin", admin);
//     DOF2_SetString(arquivo, "Motivo", motivo);
//     DOF2_SetString(arquivo, "Data", data);
//     DOF2_SaveFile();

//     // Mensagem Global
//     new str[144];
//     format(str, "| BAN | O Admin %s baniu %s. Motivo: %s", admin, name, motivo);
//     SendClientMessageToAll(0xFF0000AA, str);

//     Kick(id); // Chuta do servidor
//     return 1;
// }

// // BANIMENTO POR IP
// YCMD:banip(playerid, params[], help)
// {
//     VerificarAdmin(playerid, 4);
    
//     new id, motivo[64];
//     if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, -1, "Use: /banip [ID] [Motivo]");
//     if(!IsValidPlayer(id)) return SendClientMessage(playerid, -1, "Jogador offline.");

//     new ip[16], name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64];
//     GetPlayerIp(id, ip, sizeof(ip));
//     GetPlayerName(id, name, sizeof(name));
//     GetPlayerName(playerid, admin, sizeof(admin));

//     // Cria arquivo na pasta BanidosIP (O name do arquivo será o IP)
//     format(arquivo, sizeof(arquivo), PASTA_BANIP, ip);
//     DOF2_CreateFile(arquivo);
//     DOF2_SetString(arquivo, "UltimoNick", name);
//     DOF2_SetString(arquivo, "Admin", admin);
//     DOF2_SetString(arquivo, "Motivo", motivo);
//     DOF2_SaveFile();

//     new str[144];
//     format(str, "| BAN-IP | O IP de %s foi banido por %s.", name, admin);
//     SendClientMessageToAll(0xFF0000AA, str);

//     Kick(id);
//     return 1;
// }

// YCMD:desban(playerid, params[], help)
// {
//     VerificarAdmin(playerid, 4);
//     new nick[24], arquivo[64];
    
//     if(sscanf(params, "s[24]", nick)) return SendClientMessage(playerid, -1, "Use: /desban [Nick exato]");
    
//     format(arquivo, sizeof(arquivo), PASTA_BANIDOS, nick);
    
//     if(DOF2_FileExists(arquivo))
//     {
//         DOF2_RemoveFile(arquivo); // Deleta o arquivo de ban
//         SendClientMessage(playerid, COLOR_SUCESS, "Jogador desbanido com sucesso!");
//     }
//     else
//     {
//         SendClientMessage(playerid, -1, "Este jogador nao esta banido (Arquivo nao encontrado).");
//     }
//     return 1;
// }

// YCMD:dv(playerid, params[], help)
// {
//     VerificarAdmin(playerid, 4);
//     VerificarTra(playerid);
//     new id;
//     if(sscanf(params, "i", id)) // Se nao digitar ID, tenta destruir o que esta dentro
//     {
//         if(IsPlayerInAnyVehicle(playerid)) id = GetPlayerVehicleID(playerid);
//         else return SendClientMessage(playerid, -1, "Use: /dv [ID]");
//     }
    
//     DestroyVehicle(id);
//     SendClientMessage(playerid, COLOR_SUCESS, "Veiculo destruido.");
//     return 1;
// }

// YCMD:setadm(playerid, params[], help)
// {
//     // Apenas Fundador (Nível 6) ou RCON Admin
//     if(Player[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Apenas Fundador.");
    
//     new id, nivel;
//     if(sscanf(params, "ui", id, nivel)) return SendClientMessage(playerid, -1, "Use: /daradmin [ID] [Nivel 1-6]");
//     if(!IsValidPlayer(id)) return SendClientMessage(playerid, -1, "Jogador offline.");
//     if(nivel < 1 || nivel > 6) return SendClientMessage(playerid, -1, "Nivel invalido (1 a 6).");

//     // 1. Seta na variável do jogo e salva na conta
//     Player[id][pAdmin] = nivel;
//     // SalvarConta(id); (Chame sua função de salvar conta normal aqui se tiver)

//     // 2. CRIA ARQUIVO NA PASTA ADMINS (Para registro)
//     new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME], arquivo[64], data[32];
//     GetPlayerName(id, name, sizeof(name));
//     GetPlayerName(playerid, admin, sizeof(admin));
//     getdate(data[0], data[1], data[2]);
//     format(data, sizeof(data), "%d/%d/%d", data[2], data[1], data[0]);

//     format(arquivo, sizeof(arquivo), PASTA_ADMINS, name);
//     DOF2_CreateFile(arquivo);
//     DOF2_SetInt(arquivo, "Nivel", nivel);
//     DOF2_SetString(arquivo, "PromovidoPor", admin);
//     DOF2_SetString(arquivo, "Data", data);
//     DOF2_SaveFile();

//     // Mensagens
//     new str[128];
//     format(str, "Voce promoveu %s a Admin Nivel %d.", name, nivel);
//     SendClientMessage(playerid, COLOR_SUCESS, str);
    
//     format(str, "PARABENS! Voce agora e Admin Nivel %d.", nivel);
//     SendClientMessage(id, 0x00FFFFAA, str);
//     return 1;
// }

// YCMD:remadm(playerid, params[], help)
// {
//     if(Player[playerid][pAdmin] < 6 && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Apenas Fundador.");
    
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, -1, "Use: /tiraradmin [ID]");
    
//     // Remove in-game
//     Player[id][pAdmin] = 0;
//     // SalvarConta(id);
    
//     // Remove o arquivo da pasta Admins
//     new name[MAX_PLAYER_NAME], arquivo[64];
//     GetPlayerName(id, name, sizeof(name));
//     format(arquivo, sizeof(arquivo), PASTA_ADMINS, name);
    
//     if(DOF2_FileExists(arquivo)) 
//     {
//         DOF2_RemoveFile(arquivo);
//         SendClientMessage(playerid, COLOR_SUCESS, "Arquivo de Admin deletado e cargo removido.");
//     }
//     else
//     {
//         SendClientMessage(playerid, COLOR_SUCESS, "Cargo removido (mas nao tinha arquivo na pasta Admins).");
//     }
    
//     SendClientMessage(id, 0xFF0000AA, "Seu cargo de Admin foi removido.");
//     return 1;
// }

// YCMD:desbanip(playerid, params[], help)
// {
//     if(Player[playerid][pAdmin] < 6) return SendClientMessage(playerid, -1, "Apenas Fundador.");
    
//     new ip[16];
//     if(sscanf(params, "s[16]", ip)) return SendClientMessage(playerid, -1, "Use: /desbanip [IP]");
    
//     new str[64];
//     format(str, "unbanip %s", ip);
//     SendRconCommand(str);
//     SendRconCommand("reloadbans");
    
//     SendClientMessage(playerid, COLOR_SUCESS, "IP Desbanido.");
//     return 1;
// }

// YCMD:soltaroff(playerid, params[], help)
// {
//     // Esse comando depende muito de como é seu sistema de salvamento (DOF2)
//     // Basicamente voce precisa carregar o arquivo, mudar a variavel Preso pra 0 e salvar
//     if(Player[playerid][pAdmin] < 6) return SendClientMessage(playerid, -1, "Apenas Fundador.");
    
//     new nick[24];
//     if(sscanf(params, "s[24]", nick)) return SendClientMessage(playerid, -1, "Use: /soltarpoff [Nick]");
    
//     new file[64];
//     format(file, sizeof(file), PASTA_CONTAS, nick);
//     if(DOF2_FileExists(file))
//     {
//         DOF2_SetInt(file, "Preso", 0);
//         DOF2_SaveFile();
//         SendClientMessage(playerid, COLOR_SUCESS, "Jogador offline solto.");
//     }
//     else
//     {
//         SendClientMessage(playerid, -1, "Conta nao encontrada.");
//     }
//     return 1;
// }

// YCMD:criargps(playerid, params[], help)
// {
//     // Verifica se é Admin (Ajuste conforme seu sistema)
//     if(Player[playerid][pAdmin] < 4) return SendClientMessage(playerid, -1, "Voce nao tem permissao.");

//     new categoria[30], name[30];
//     if(sscanf(params, "s[30]S[30]", categoria, name)) 
//         return SendClientMessage(playerid, -1, "Use: /criargps [Categoria] [NomeLocal] (Ex: /criargps Garagens Detran)");

//     new Float:x, Float:y, Float:z;
//     GetPlayerPos(playerid, x, y, z);

//     // 1. ADICIONA A CATEGORIA NA LISTA (SE NÃO EXISTIR)
//     new File:fCat = fopen(ARQUIVO_CATS, io_read);
//     new bool:existe = false;
//     new string[128];

//     // Verifica se a categoria já está escrita no arquivo mestre
//     if(fCat)
//     {
//         while(fread(fCat, string))
//         {
//             // Remove a quebra de linha para comparar
//             if(string[strlen(string)-2] == '\r') string[strlen(string)-2] = '\0';
//             else if(string[strlen(string)-1] == '\n') string[strlen(string)-1] = '\0';
            
//             if(strcmp(string, categoria, true) == 0) existe = true;
//         }
//         fclose(fCat);
//     }

//     // Se não existe, escreve a nova categoria
//     if(!existe)
//     {
//         fCat = fopen(ARQUIVO_CATS, io_append); // Modo Append (Adicionar no final)
//         format(string, sizeof(string), "%s\r\n", categoria);
//         fwrite(fCat, string);
//         fclose(fCat);
//     }

//     // 2. SALVA O LOCAL DENTRO DO ARQUIVO DA CATEGORIA
//     // O arquivo terá o name da categoria. Ex: GPS/Garagens.txt
//     new caminho[64];
//     format(caminho, sizeof(caminho), "GPS/%s.txt", categoria);

//     new File:fLoc = fopen(caminho, io_append);
//     if(fLoc)
//     {
//         // Formato: Nome|X|Y|Z
//         format(string, sizeof(string), "%s|%.2f|%.2f|%.2f\r\n", name, x, y, z);
//         fwrite(fLoc, string);
//         fclose(fLoc);

//         SendClientMessage(playerid, COLOR_SUCESS, "GPS: Local Criado com Sucesso!");
//         format(string, sizeof(string), "Categoria: %s | Local: %s", categoria, name);
//         SendClientMessage(playerid, -1, string);
//     }
//     else
//     {
//         SendClientMessage(playerid, -1, "ERRO: Falha ao criar arquivo. Verifique a pasta 'scriptfiles/GPS'.");
//     }
//     return 1;
// }

// YCMD:criarfac(playerid, params[], help)
// {
//     if(Player[playerid][pAdmin] < 5) return SendClientMessage(playerid, -1, "Apenas Dono/Fundador.");

//     new corHex, tipo, skin, name[30];
    
//     // Sintaxe Nova: /criarfac [Cor] [Tipo] [Skin] [Nome]
//     // h = Hex, d = Int, i = Int, s = String
//     if(sscanf(params, "hdis[30]", corHex, tipo, skin, name))
//     {
//         SendClientMessage(playerid, COR_V_ESCURO, "USE: /criarfac [CorHEX] [Funcao] [SkinID] [Nome]");
//         SendClientMessage(playerid, COR_BRANCO, "FUNCOES: 1=Lavagem | 2=Desmanche | 3=Comum");
//         return 1;
//     }

//     if(tipo < 1 || tipo > 3) return SendClientMessage(playerid, -1, "Tipo invalido! Use 1, 2 ou 3.");
//     if(skin < 0 || skin > 311) return SendClientMessage(playerid, -1, "ID de Skin invalido (0-311).");

//     // Procura vaga na memória
//     new id = -1;
//     for(new i=1; i < MAX_ORGS; i++) {
//         if(OrgInfo[i][oCriada] == 0) { id = i; break; }
//     }
//     if(id == -1) return SendClientMessage(playerid, -1, "Limite de Orgs atingido!");

//     new Float:x, Float:y, Float:z;
//     GetPlayerPos(playerid, x, y, z);

//     // INSERE NO MYSQL (COM A SKIN AGORA)
//     new query[300];
//     mysql_format(Conexao, query, sizeof(query), 
//         "INSERT INTO organizacoes (name, cor, tipo, skin, pos_x, pos_y, pos_z) VALUES ('%e', %d, %d, %d, %f, %f, %f)",
//         name, corHex, tipo, skin, x, y, z
//     );
//     mysql_tquery(Conexao, query, "OnFacCriada", "d", id);

//     // Define visualmente temporário
//     OrgInfo[id][oCriada] = 1;
//     format(OrgInfo[id][oNome], 30, name);
//     OrgInfo[id][oCor] = corHex;
//     OrgInfo[id][oTipo] = tipo;
//     OrgInfo[id][oSkin] = skin; // Salva a skin na memória
//     OrgInfo[id][oX] = x; OrgInfo[id][oY] = y; OrgInfo[id][oZ] = z;
    
//     // Cria Pickup e Texto
//     OrgInfo[id][oPickup] = CreatePickup(1239, 1, x, y, z, -1);
    
//     new label[128], funcaoStr[20];
//     if(tipo == 1) funcaoStr = "LAVAGEM";
//     else if(tipo == 2) funcaoStr = "DESMANCHE";
//     else funcaoStr = "GUERRA";

//     format(label, sizeof(label), "{FFFFFF}HQ: %s\nFuncao: {FFFF00}%s\n{FFFFFF}Lider: Ninguem", name, funcaoStr);
//     OrgInfo[id][oLabel] = Create3DTextLabel(label, corHex, x, y, z+0.5, 20.0, 0, 0);

//     new msg[144];
//     format(msg, sizeof(msg), "Faccao criada! ID: %d | Skin Padrao: %d", id, skin);
//     SendClientMessage(playerid, COLOR_SUCESS, msg);
//     return 1;
// }


// YCMD:criarorg(playerid, params[], help)
// {
//     if(Player[playerid][pAdmin] < 5) return SendClientMessage(playerid, -1, "Apenas Dono.");

//     new name[30], corHex;
//     // Ex: /criarorg 0xFF0000AA PCC (Cor Vermelha, Nome PCC)
//     if(sscanf(params, "xs[30]", corHex, name)) 
//     {
//         SendClientMessage(playerid, COR_V_ESCURO, "USE: /criarorg [CorHEX] [Nome]");
//         SendClientMessage(playerid, COR_BRANCO, "Exemplos de Cores: Vermelho(FFFF0000) Azul(FF0000FF) Verde(FF00FF00)");
//         return 1;
//     }

//     // Procura um ID livre (slot vazio)
//     new id = -1;
//     for(new i=1; i < MAX_ORGS; i++)
//     {
//         if(OrgInfo[i][oCriada] == 0)
//         {
//             id = i;
//             break;
//         }
//     }

//     if(id == -1) return SendClientMessage(playerid, -1, "Limite de Orgs atingido!");

//     // Pega a posição do admin
//     new Float:x, Float:y, Float:z;
//     GetPlayerPos(playerid, x, y, z);

//     // Salva na Memória
//     format(OrgInfo[id][oNome], 30, name);
//     OrgInfo[id][oCor] = corHex;
//     OrgInfo[id][oX] = x;
//     OrgInfo[id][oY] = y;
//     OrgInfo[id][oZ] = z;
//     OrgInfo[id][oCriada] = 1;

//     // Salva no Arquivo
//     new file[64];
//     format(file, sizeof(file), PASTA_ORGS, id);
//     DOF2_CreateFile(file);
//     DOF2_SetString(file, "Nome", name);
//     DOF2_SetInt(file, "Cor", corHex);
//     DOF2_SetFloat(file, "X", x);
//     DOF2_SetFloat(file, "Y", y);
//     DOF2_SetFloat(file, "Z", z);
//     DOF2_SaveFile();

//     // Cria o visual no jogo na hora
//     OrgInfo[id][oPickup] = CreatePickup(1239, 1, x, y, z, -1);
    
//     new label[100];
//     format(label, sizeof(label), "{FFFFFF}HQ: %s\n{FFFF00}Digite /menuorg", name);
//     Create3DTextLabel(label, corHex, x, y, z+0.5, 20.0, 0, 0);
    
//     SetPlayerMapIcon(playerid, id, x, y, z, 31, 0, MAPICON_GLOBAL);

//     new msg[128];
//     format(msg, sizeof(msg), "Org %s (ID %d) criada com sucesso na sua posicao!", name, id);
//     SendClientMessage(playerid, COLOR_SUCESS, msg);
//     return 1;
// }

// YCMD:a(playerid, params[], help)
// {
//     if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

//     if(strlen(params) <= 0 ||  strlen(params) >= 84)
//         return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /a {ff3333}[ TEXTO ]");
    
//     Adm::SendMsgToAllTagged(FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER, 0xFFFF33AA, 
//     "[ ADM CHAT ] %s%s {ffffff}: {ffff33}%s", 
//     Adm::GetColorString(Admin[playerid][adm::lvl]), GetPlayerNameEx(playerid), params);

//     return 1;
// }
 
 // ARRUMAR QUANTO TIVER COMANDO DE VEICULO
// YCMD:repcar(playerid, params[], help)
// {
//     if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

//     new vehicleid;

//     if(!IsPlayerInAnyVehicle(playerid)) 
//         return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Se quiser reparar um {ff3333}veículo específico, {ffffff}entre nele!");

//     vehicleid = GetPlayerVehicleID(playerid);
    
//     new vehname[32], Float:old_health;

//     GetVehicleNameByModel(GetVehicleModel(vehicleid), vehname, 32);
//     GetVehicleHealth(vehicleid, old_health);
//     RepairVehicle(vehicleid);

//     SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Veiculo {ffff33}%s {ffffff}\
//     [ ID: {ffff33}%d {ffffff}] foi reparado!", vehname, vehicleid);
//     SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Estava com {ffff33}%.1f {ffffff}de vida", old_health);

//     return 1;
// }


// YCMD:trazer(playerid, params[], help)
// {
//     #pragma unused help
//     new targetid;
//     if(sscanf(params, "u", targetid)) 
//         return SendClientMessage(playerid, -1, "Use: /trazer [ID]");
//     if(!IsValidPlayer(targetid)) 
//         return SendClientMessage(playerid, -1, "Jogador offline.");
    
//     new Float:x, Float:y, Float:z;
//     GetPlayerPos(playerid, x, y, z);
//     SetPlayerPos(targetid, x + 1, y, z);
//     SetPlayerInterior(targetid, GetPlayerInterior(playerid));
//     SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
    
//     SendClientMessage(targetid, COLOR_SUCESS, "Um Admin puxou voce.");
//     return 1;
// }