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
    if(!Adm::HasPermission(playerid, FLAG_ADM_APPRENTICE_STAFF)) return 1;

    new string[1024];

    //--- HELPER   (Nivel 1 / 2)   ---
    strcat(string, FCOLOR_ADM_HELPER  "--- (APRENDIZ) HELPER (Nivel 1 / 2) ---\n");
    strcat(string, "{ffffff}/tra /a /verid /repararcarro /aviso /ir /trazer /tv /tvoff\n\n");
    //--- STAFF    (Nivel 3 / 4)   ---
    strcat(string, FCOLOR_ADM_STAFF   "--- (APRENDIZ) STAFF  (Nivel 3 / 4) ---\n");
    strcat(string, "{ffffff}/lo /kick /congelar /descongelar /tapa /idveh\n\n");
    //--- RESPONSAVEL (Nivel 5)       ---
    strcat(string, FCOLOR_ADM_FOREMAN "--- RESPONSAVEL       (Nivel 5) ---\n");
    strcat(string, "{ffffff}/setarskin /darvida /setarcolete /setarhora /cadeia /soltarp /irmarca\n\n");
    //--- MASTER   (Nivel 6)   ---
    strcat(string, FCOLOR_ADM_MASTER  "--- MASTER            (Nivel 6) ---\n");
    strcat(string, "{ffffff}/ban /desban /cv /dv /rc /banip\n\n");
    //--- GERENTE  (Nivel 7)   ---
    strcat(string, FCOLOR_ADM_MANAGER "--- GERENTE           (Nivel 7) ---\n");
    strcat(string, "{ffffff}/ban /desban /cv /dv /rc /banip\n\n");
    //--- DONO     (Nivel 8)       ---
    strcat(string, FCOLOR_ADM_CEO     "--- DONO              (Nivel 8) ---\n");
    strcat(string, "{ffffff}/av /dargrana /trazertodos /coletetodos /setarniveltodos /setarnivel\n\n");
    //--- FUNDADOR (Nivel 9)       ---
    strcat(string, FCOLOR_ADM_FOUNDER "--- FUNDADOR           (Nivel 9) ---\n");
    strcat(string, "{ffffff}/daradmin /tiraradmin /desbanip /soltarpoff");

    inline no_use_dialog(targetid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused targetid, dialogid, response, listitem, inputtext
        return 1;
    }

    Dialog_ShowCallback(playerid, using inline no_use_dialog, DIALOG_STYLE_MSGBOX, "{00FF00}COMANDOS DA ADMINISTRACAO", string, "Fechar");

    return 1;
}

YCMD:aw(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_APPRENTICE_HELPER)) return 1;

    Adm::SetInWork(playerid);

    return 1;
}

YCMD:a(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    if(strlen(params) <= 0 ||  strlen(params) >= 84)
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /a {ff3333}[ TEXTO ]");
    
    Adm::SendMsgToAllTagged(FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER, 0xFFFF33AA, 
    "[ ADM CHAT ] %s%s {ffffff}: {ffff33}%s", 
    Adm::GetColorString(Admin[playerid][adm::lvl]), GetPlayerNameEx(playerid), params);

    return 1;
}

YCMD:verid(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    if(help) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /verid {ff3333}[ NOME ]");

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

// ARRUMAR QUANTO TIVER COMANDO DE VEICULO
YCMD:repcar(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    new vehicleid;

    if(!IsPlayerInAnyVehicle(playerid)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Se quiser reparar um {ff3333}veículo específico, {ffffff}entre nele!");

    vehicleid = GetPlayerVehicleID(playerid);
    
    new vehname[32], Float:old_health;

    GetVehicleNameByModel(GetVehicleModel(vehicleid), vehname, 32);
    GetVehicleHealth(vehicleid, old_health);
    RepairVehicle(vehicleid);

    SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Veiculo {ffff33}%s {ffffff}\
    [ ID: {ffff33}%d {ffffff}] foi reparado!", vehname, vehicleid);
    SendClientMessage(playerid, -1, "{ffff33}[ ADM ] {ffffff}Estava com {ffff33}%.1f {ffffff}de vida", old_health);

    return 1;
}

YCMD:aviso(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    new targetid, reason[64];

    if(sscanf(params, "us[64]", targetid, reason)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /aviso {ff3333}[ playerid ] [ MSG ]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    SendClientMessage(targetid, 0xFFFF00AA, "| ADMIN | Voce recebeu um aviso: %s", reason);
    SendClientMessage(playerid, COLOR_SUCESS, "{ffff33}[ ADM ] {ffffff}Aviso {ffff33}enviado.");
    return 1;
}

YCMD:ir(playerid, params[], help)
{
    if(!Adm::HasPermission(playerid, FLAG_ADM_WORKING | FLAG_ADM_APPRENTICE_HELPER)) return 1;

    new targetid;

    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "Use: /ir [ID]");

    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    if(IsAndroidPlayer(playerid))
        Adm::SpectatePlayer(playerid, targetid);
    
    else
    { 
        new Float:pX, Float:pY, Float:pZ;
        GetPlayerCameraPos(targetid, pX, pY, pZ);
        CallRemoteFunction("MovePlayerCamFly", "ifff", playerid, pX, pY, pZ);
        printf("oi3");
    }

    printf("oi2");

    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

    return 1;
}

YCMD:trazer(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "Use: /trazer [ID]");
    if(!IsValidPlayer(targetid)) 
        return SendClientMessage(playerid, -1, "Jogador offline.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(targetid, x + 1, y, z);
    SetPlayerInterior(targetid, GetPlayerInterior(playerid));
    SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
    
    SendClientMessage(targetid, COLOR_SUCESS, "Um Admin puxou voce.");
    return 1;
}

YCMD:tv(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "Use: /tv [ID]");
    if(!IsValidPlayer(targetid)) 
        return SendClientMessage(playerid, -1, "Jogador offline.");

    CallRemoteFunction("CancelFlyMode", "i", playerid);

    TogglePlayerSpectating(playerid, true);
    PlayerSpectatePlayer(playerid, targetid);

    if(IsPlayerInAnyVehicle(targetid))
         PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    else
        PlayerSpectatePlayer(playerid, targetid);

    SendClientMessage(playerid, COLOR_SUCESS, "Voce esta assistindo o jogador.");

    return 1;
}

YCMD:tvoff(playerid, params[], help)
{
    #pragma unused help

    TogglePlayerSpectating(playerid, false);

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);
    
    CallRemoteFunction("FlyMode", "fff", pX, pY, pZ);

    return 1;
}

YCMD:lchat(playerid, params[], help)
{
    #pragma unused help

    ClearChat(playerid, 35);
    SendClientMessageToAll(COLOR_SUCESS, "Chat limpo pela Administracao.");
    return 1;
}

YCMD:kick(playerid, params[], help)
{
    #pragma unused help
    
    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason))
        return SendClientMessage(playerid, -1, "Use: /kick [ID] [Motivo]");
    if(!IsValidPlayer(targetid)) 
        return SendClientMessage(playerid, -1, "Jogador offline.");
    
    new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME];
    GetPlayerName(targetid, name);
    GetPlayerName(playerid, admin);
    
    SendClientMessageToAll(0xFF0000AA, "O Admin %s Kickou %s. Motivo: %s", admin, name, reason);
    
    Kick(targetid);

    return 1;
}

YCMD:congelar(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "Use: /congelar [ID]");

    TogglePlayerControllable(targetid, FALSE);

    SendClientMessage(playerid, COLOR_SUCESS, "Jogador congelado.");
    SendClientMessage(targetid, 0xFF0000AA, "Voce foi congelado por um Admin.");
    return 1;
}

YCMD:descongelar(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
        return SendClientMessage(playerid, -1, "Use: /descongelar [ID]");

    TogglePlayerControllable(targetid, true);
    SendClientMessage(playerid, COLOR_SUCESS, "Jogador descongelado.");
    
    return 1;
}

YCMD:setarskin(playerid, params[], help)
{
    #pragma unused help
    new targetid, skin;
    if(sscanf(params, "ui", targetid, skin))
        return SendClientMessage(playerid, -1, "Use: /setarskin [ID] [SkinID]");
    if(skin < 0 || skin > 311) 
        return SendClientMessage(playerid, -1, "Skin invalida (0-311).");
    
    SetPlayerSkin(targetid, skin);
    SendClientMessage(playerid, COLOR_SUCESS, "Skin definida.");
    return 1;
}

YCMD:darvida(playerid, params[], help)
{
    #pragma unused help
    new targetid, Float:health;
    if(sscanf(params, "uf", targetid, health))
        return SendClientMessage(playerid, -1, "Use: /darvida [ID] [Quantia]");
    
    SetPlayerHealth(targetid, health);
    SendClientMessage(playerid, COLOR_SUCESS, "Vida definida.");
    return 1;
}

YCMD:setarcolete(playerid, params[], help)
{
    #pragma unused help
    new targetid, Float:armour;
    if(sscanf(params, "uf", targetid, armour))
        return SendClientMessage(playerid, -1, "Use: /setarcolete [ID] [Quantia]");
    
    SetPlayerArmour(targetid, armour);
    SendClientMessage(playerid, COLOR_SUCESS, "Colete definido.");
    return 1;
}

// YCMD:cadeia(playerid, params[], help)
// {
//     new target, minutos, motivo[64];
//     if(sscanf(params, "uis[64]", id, minutos, motivo)) return SendClientMessage(playerid, -1, "Use: /cadeia [ID] [Minutos] [Motivo]");
//     if(!IsValidPlayer(id)) return SendClientMessage(playerid, -1, "Jogador offline.");

//     // Configurações da Prisão
//     ResetPlayerWeapons(id);
//     SetPlayerInterior(id, 6); 
//     SetPlayerPos(id, 264.6288, 77.5742, 1001.0391); // Cela
    
//     // --- Salva na Pasta Presos (DOF2) ---
//     new name[MAX_PLAYER_NAME], arquivo[64], admin[24]; // Criei as variáveis que faltavam
//     GetPlayerName(id, name, sizeof(name));
//     GetPlayerName(playerid, admin, sizeof(admin));
    
//     format(arquivo, sizeof(arquivo), PASTA_PRESOS, name);
    
//     // Cria o arquivo de prisão
//     DOF2_CreateFile(arquivo);
//     DOF2_SetInt(arquivo, "Tempo", minutos * 60); // Salva em segundos? Ou minutos? (Ajuste conforme seu timer)
//     DOF2_SetString(arquivo, "Motivo", motivo);
//     DOF2_SetString(arquivo, "Admin", admin);
//     DOF2_SaveFile();
    
//     // Avisa no chat
//     new str[144];
//     format(str, sizeof(str), "| CADEIA | O Admin %s prendeu %s por %d minutos. Motivo: %s", admin, name, minutos, motivo);
//     SendClientMessageToAll(0xFF0000AA, str);
    
//     SendClientMessage(id, 0xFF0000AA, "Voce foi preso! Reflita sobre seus atos.");
//     return 1;
// }

// YCMD:soltarp(playerid, params[], help)
// {
//     VerificarAdmin(playerid, 3);
//     new id;
//     if(sscanf(params, "u", id)) return SendClientMessage(playerid, -1, "Use: /soltarp [ID]");
//     if(!IsValidPlayer(id)) return SendClientMessage(playerid, -1, "Jogador offline.");

//     // Remove da Prisão
//     SpawnPlayer(id);
//     SetPlayerInterior(id, 0);
//     SetPlayerPos(id, 1543.0, -1675.0, 13.0); // Coloque a saída da DP aqui
    
//     // Apaga o arquivo
//     new name[MAX_PLAYER_NAME], arquivo[64];
//     GetPlayerName(id, name, sizeof(name));
//     format(arquivo, sizeof(arquivo), PASTA_PRESOS, name);
//     if(DOF2_FileExists(arquivo)) DOF2_RemoveFile(arquivo);

//     SendClientMessage(playerid, COLOR_SUCESS, "Jogador libertado.");
//     SendClientMessage(id, COLOR_SUCESS, "Voce foi solto da cadeia.");
//     return 1;
// }

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
//     format(str, sizeof(str), "| BAN | O Admin %s baniu %s. Motivo: %s", admin, name, motivo);
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
//     format(str, sizeof(str), "| BAN-IP | O IP de %s foi banido por %s.", name, admin);
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


YCMD:av(playerid, params[], help)
{
    #pragma unused help
    if(isnull(params)) 
        return SendClientMessage(playerid, -1, "Use: /av [Mensagem]");

    GameTextForAll(params, 5000, 3);
    SendClientMessageToAll(0x00FF00AA, "| ANUNCIO | %s", params);
    return 1;
}

YCMD:setarnivel(playerid, params[], help)
{
    #pragma unused help
    new targetid, score;
    if(sscanf(params, "ui", targetid, score)) 
        return SendClientMessage(playerid, -1, "Use: /setarnivel [ID] [Nivel]");
    
    SetPlayerScore(targetid, score);
    SendClientMessage(playerid, COLOR_SUCESS, "Nivel definido.");
    return 1;
}

// YCMD:daradmin(playerid, params[], help)
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
//     format(str, sizeof(str), "Voce promoveu %s a Admin Nivel %d.", name, nivel);
//     SendClientMessage(playerid, COLOR_SUCESS, str);
    
//     format(str, sizeof(str), "PARABENS! Voce agora e Admin Nivel %d.", nivel);
//     SendClientMessage(id, 0x00FFFFAA, str);
//     return 1;
// }

// YCMD:tiraradmin(playerid, params[], help)
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
//     format(str, sizeof(str), "unbanip %s", ip);
//     SendRconCommand(str);
//     SendRconCommand("reloadbans");
    
//     SendClientMessage(playerid, COLOR_SUCESS, "IP Desbanido.");
//     return 1;
// }

// YCMD:soltarpoff(playerid, params[], help)
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


// 7. CURAR
YCMD:curar(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
    {
        SetPlayerHealth(playerid, 100.0); 
        SendClientMessage(playerid, COLOR_SUCESS, "Voce curou sua vida.");
    }
    else
    {
        SetPlayerHealth(targetid, 100.0);
        SendClientMessage(playerid, COLOR_SUCESS, "Voce curou o jogador.");
    }
    return 1;
}

// 8. COLETE
YCMD:colete(playerid, params[], help)
{
    #pragma unused help
    new targetid;
    if(sscanf(params, "u", targetid)) 
    {
        SetPlayerArmour(playerid, 100.0); // Colete em si mesmo
        SendClientMessage(playerid, COLOR_SUCESS, "Voce pegou colete.");
    }
    else
    {
        SetPlayerArmour(targetid, 100.0);
        SendClientMessage(playerid, COLOR_SUCESS, "Voce deu colete ao jogador.");
    }
    return 1;
}

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