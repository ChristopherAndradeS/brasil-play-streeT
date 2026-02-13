#include <YSI\YSI_Coding\y_hooks>

forward ban_input_dialog(playerid, dialogid, response, listitem, string:inputtext[]);

public ban_input_dialog(playerid, dialogid, response, listitem, string:inputtext[])
{
    if(!response) return 1;

    new name[MAX_PLAYERS], days, reason[64];

    if(sscanf(inputtext, "s[24]is[64]", name, days, reason)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADMIN ] {ffffff}Escreva separando por espaço: {ff3333}NOME + DIAS + MOTIVO {ffffff}para banir");
        SendClientMessage(playerid, -1, "{ff3333}[ ADMIN ] {ffffff}Ou escreva: {ff3333}NOME + [-1] + MOTIVO {ffffff}para banir permanentemente");
        return 1;
    }

    new admin_name[24];
    GetPlayerName(playerid, admin_name);

    if(!Adm::IsValidTargetName(playerid, admin_name, name)) return 1;
    
    new sucess, admin[MAX_PLAYER_NAME];
    GetPlayerName(playerid, admin);

    if(days != -1) sucess = Punish::SetBan(admin, name, clamp(days, 1, 60), reason);
    else           sucess = Punish::SetPermaban(admin, name, reason);

    if(sucess)
    {
        new msg[32];
        if(days != -1)  format(msg, 32, "%d {ffffff}dia(s)", days);
        else            format(msg, 32, "Tempo Indeterminado");
        SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Você baniu {33ff33}%s \
        {ffffff}por {33ff33}%s", name, msg);
    
        SendClientMessageToAll(-1, "{ff3399}[ ADM PUNICAO ] {ffffff}%s {ff3399}baniu {ffffff}%s por {ff3399}%s.", GetPlayerNameEx(playerid), name, msg);
        SendClientMessageToAll(-1, "{ff3399}[ ADM PUNICAO ] {ff3399}Motivo: {ffffff}%s", reason);

        new targetid = GetPlayerIDByName(name);
        if(targetid != INVALID_PLAYER_ID)
            Kick(targetid);
    }

    else
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}O jogador {ff3333}%s {ffffff}não está registrado no bando de dados!", name);
        if(days == -1)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Ou o jogador já foi banido permanentemente");
    }

    return 1;
}

YCMD:mkfnd(playerid, params[], help)
{
    if(!IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}O comando \'mkfnd\' nao existe"); 
        return 1;
    }
    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!Adm::Set(name, "SERVER", 9))
        SendClientMessage(playerid, COLOR_ERRO, "[ ADM ] {ffffff}Erro Fatal ao setar voce como fundador!");
    
    return 1;
}

YCMD:aa(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Ajuda Admin - Lista de comandos disponiveis");
        return 1;
    }

    if(!IsFlagSet(Admin[playerid][adm::flags], FLAG_IS_ADMIN)) 
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem permissao para isso!");
        return 1;
    }

    new str[512];
    
    if(Admin[playerid][adm::lvl] >= ROLE_ADM_APR_HELPER)
        strcat(str, "aa\naw\nir\nverid\naviso\n");
    if(Admin[playerid][adm::lvl] >= ROLE_ADM_APR_STAFF)
        strcat(str, "congelar\ndescongelar\nkick\n");
    if(Admin[playerid][adm::lvl] >= ROLE_ADM_FOREMAN)
        strcat(str, "cronometro\nmegafone\nprender\nprenderoff\nsoltar\nsoltaroff\n");
    if(Admin[playerid][adm::lvl] >= ROLE_ADM_MANAGER)
        strcat(str, "tp\nlchat\nsetarskin\nsetarvida\nsetarcolete\n");
    if(Admin[playerid][adm::lvl] >= ROLE_ADM_CEO)
        strcat(str, "ban\ndesban\nsetadm\nremadm\n");

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

    if(!IsFlagSet(Admin[playerid][adm::flags], FLAG_IS_ADMIN)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem permissao para isso!");
        return 1;
    }

    if(!Adm::HandleWork(playerid))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Nenhum jogador online para entrar em modo de trabalho!"); 
    
    return 1;
}

YCMD:ir(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Selecionar jogador para espectar");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_HELPER)) return 1;

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
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Ver ID de jogador pelo nome");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_HELPER)) return 1;

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
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Enviar aviso personalizado ao jogador");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_HELPER)) return 1;

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

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_STAFF)) return 1;

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

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_STAFF)) return 1;

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

YCMD:kick(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Kika um jogador");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_APR_STAFF)) return 1;

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

YCMD:megafone(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Envia uma gametext personalizada para todos");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

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

    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

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
    
    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

    new targetid, minutes, reason[64];
    if(sscanf(params, "uis[64]", targetid, minutes, reason)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /prender {ff3333}[ ID ] [ TEMPO (minutos) ] [ MOTIVO ]");
    
    if(!Adm::ValidTargetID(playerid, targetid)) return 1;

    ResetPlayerWeapons(targetid);
    
    new name[MAX_PLAYER_NAME], admin[MAX_PLAYER_NAME]; 
    GetPlayerName(targetid, name, sizeof(name));
    GetPlayerName(playerid, admin, sizeof(admin));

    minutes = clamp(minutes * 60000, 180000, 18000000);

    new result = Punish::SetJail(name, admin, reason, minutes);

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
        Punish::UpdatePlayerJail(targetid, minutes);
        return 1;
    }

    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] %s {ffffff}foi para ilha abandonada e ficara lá por {ff3399}%d {ffffff}minutos", name, minutes);
    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] Motivo: {ffffff}%s", reason);

    if(targetid != INVALID_PLAYER_ID)
    {
        Punish::SendPlayerToJail(targetid, minutes);
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

    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

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

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce soltou {33ff33}%s {ffffff}com sucesso.", GetPlayerNameEx(targetid));
    SendClientMessageToAll(-1, "{ff3399}[ ILHA ] O jogador {ff3399}%s foi {ffffff}perdoado e foi embora da ilha", GetPlayerNameEx(targetid));
    return 1;
}

YCMD:prenderoff(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Prende um delinquente offline, na cadeia staff por um tempo em minutos/horas");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

    new name[MAX_PLAYER_NAME], minutes, reason[64];
    if(sscanf(params, "s[24]is[64]", name, minutes, reason)) 
        return SendClientMessage(playerid, -1, 
        "{ff3333}[ CMD ] {ffffff}Use: /prenderoff {ff3333}[ NOME ] [ TEMPO (minutos) ] [ MOTIVO ]");
    
    new admin_name[24];
    GetPlayerName(playerid, admin_name);

    if(!Adm::IsValidTargetName(playerid, admin_name, name)) return 1;

    new targetid = GetPlayerIDByName(name);
    
    if(targetid != INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] Jogador %s está online! {ffffff}Seu ID é {ff3333}%d", name, targetid);

    if(!Punish::SetJail(name, GetPlayerNameEx(playerid), reason, clamp(minutes * 60000, 180000, 18000000)))
        return SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Houve um erro. Provalmente o jogador não existe nos dados!");
  
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce definiu {33ff33}%d {ffffff}minutos de cadeia para {33ff33}%s {ffffff}com sucesso.", minutes, name);

    return 1;
}

YCMD:soltaroff(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Solta um arrependido offline, da cadeia staff");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_FOREMAN)) return 1;

    new name[MAX_PLAYER_NAME];
    if(sscanf(params, "s[24]", name)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /soltaroff {ff3333}[ NAME ]");
    
    new admin_name[24];
    GetPlayerName(playerid, admin_name);

    if(!Adm::IsValidTargetName(playerid, admin_name, name)) return 1;

    if(!DB::Delete(db_entity, "punishments", "name = '%q' AND level = 1", name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Não foi possível soltar o jogador {ff3333}%s{ffffff}, pois ele não está preso!", name);
        printf("[ DB (ERRO) ] Erro ao remover cadeia de %s", name);
        return -1;
    }

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce soltou {33ff33}%s {ffffff}com sucesso.", name);
    
    return 1;
}

YCMD:tp(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Teleporta para uma posição X, Y, Z no mundo");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;
 
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
    
    if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;

    ClearChat(playerid, 45);
    SendClientMessageToAll(-1, "{33ff33}[ ADM ] {ffffff}Chat limpo! :)");
    return 1;
}


YCMD:setarskin(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Altera o skinid de um jogador");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;

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

    if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;

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
    
    if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;

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

YCMD:ban(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Bane um delinquente por uma quantidade de dias.");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_CEO)) return 1;

    Dialog_ShowCallback(playerid, using public ban_input_dialog<iiiis>, DIALOG_STYLE_INPUT, 
    "{ffff33}Banimentos", "{ffff33}>> {ffffff}Digite baixo as informações para realizar um banimento:\n\n\
    {ffff33}[ i ] Se você digitar {ffff33}[ NOME ] + [ TEMPO DIA(S) ] + [ MOTIVO ] {ffffff}banira um jogador por alguns dias\n\n\
    {ffff33}[ i ] Se você digitar {ffff33}[ NOME ] + [ -1 ] + [ MOTIVO ] {ffffff}banira um jogador permanentemente\n\n\
    {ff9933}[ ! ] {ffffff}Se o jogador já estiver banido, o motivo e tempo serão {ff9933}redefinidos\n\n", "Banir", "Fechar");

    return 1;
}

YCMD:desban(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Desbane um jogador.");
        return 1;
    }

    if(!Adm::HasPermission(playerid, ROLE_ADM_CEO)) return 1;

    new name[24];
    
    if(sscanf(params, "s[24]", name)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /desban {ff3333}[ NOME ]");
    
    new admin_name[24];
    GetPlayerName(playerid, admin_name);

    if(!Adm::IsValidTargetName(playerid, admin_name, name)) return 1;
    
    if(!DB::Exists(db_entity, "punishments", "name", "name = '%q' AND level = 2", name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Não foi possível desbanir o jogador {ff3333}%s{ffffff}, pois ele não está banido!", name);
        return 1;
    }

    DB::SetDataInt(db_entity, "punishments", "left_tstamp", 0, "name = '%q' AND level = 2", name);

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce desbaniu {33ff33}%s {ffffff}com sucesso.", name);
    printf("[ PUNICOES ] O admin %s desbaniu %s.", admin_name, name);

    return 1;
}

YCMD:setadm(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Promove/Rebaixa um jogador a um cargo de administração.");
        return 1;
    }

    if(!IsPlayerAdmin(playerid)) return 1;
    
    new name[MAX_PLAYER_NAME], level;
    if(sscanf(params, "s[24]i", name, level)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /setadm {ff3333}[ NOME ] [ CARGO <1 - 9>]");
    
    new admin_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, admin_name);

    level = clamp(level, 1, 9);

    if(!Adm::Set(name, admin_name, level))
        return SendClientMessage(playerid, COLOR_ERRO, "[ ADM ] {ffffff}Erro Fatal ao setar voce como fundador, procure um programador!");

    Adm::Load(playerid);

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce promoveu {33ff33}%s {ffffff}com sucesso.", name);
    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Cargo de promoção: %s%s", Adm::GetColorString(level), Adm::gRoleNames[level]);
    return 1;
}

YCMD:remadm(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Remove um jogador a um cargo de administração.");
        return 1;
    }

    if(!IsPlayerAdmin(playerid)) return 1;
    
    new name[MAX_PLAYER_NAME];
    if(sscanf(params, "s[24]", name)) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /remadm {ff3333}[ NOME ]");
    
    if(!Adm::Exists(name, _))
        return SendClientMessage(playerid, -1, "{ff3333}[ ADM ] %s {ffffff}não faz parte da administração!", name);
    
    new admin_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, admin_name);

    if(!Adm::Set(name, admin_name, 0))
        return SendClientMessage(playerid, COLOR_ERRO, "[ ADM ] {ffffff}Erro Fatal ao remover admin, procure um programador!");

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Voce removeu {33ff33}%s {ffffff}com sucesso.", name);

    return 1;
}

YCMD:cgps(playerid, params[], help)
{
    if(help)
    {
        SendClientMessage(playerid, -1, "{ffff33}[ AJUDA ADM ] {ffffff}Cria uma localização no GPS Global.");
        return 1;
    }    

    //if(!Adm::HasPermission(playerid, ROLE_ADM_MANAGER)) return 1;

    new name[32], category[32], msg[512];

    inline create_gps_name_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, listitem
        if(!response) return 1;

        if(isnull(inputtext)) 
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve inserir um nome válido");

        if(sscanf(inputtext, "s[32]", name)) 
            return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve inserir um nome válido");

        new DBResult:result = DB_ExecuteQuery(db_stock, "SELECT DISTINCT category FROM locations ORDER BY category ASC;");

        if(result)
        {
            do
            {
                DB_GetFieldStringByName(result, "category", category);
                format(msg, sizeof(msg), "%s%s\n", msg, category);
            }
            while (DB_SelectNextRow(result));

            DB_FreeResultSet(result);
        }

        format(msg, sizeof(msg), "%sCRIAR CATEGORIA NOVA", isnull(msg) ? "" : msg);

        inline select_gps_cat_dialog(playerid2, dialogid2, response2, listitem2, string:inputtext2[])
        {
            #pragma unused playerid2, dialogid2, listitem2
            if(!response2)
            {
                msg[0] = EOS;
                Dialog_ShowCallback(playerid, using inline create_gps_name_dialog, DIALOG_STYLE_INPUT, 
                "{ff5555}>> {ffffff}Digite o nome do local que deseja criar no GPS global\n\
                {ffff33}[ i ] {ffffff}Certifique-se de estar {ff3333}posicionado corretamente!", "", 
                "Avançar", "Voltar");
                return 1;
            }

            if(sscanf(inputtext2, "s[32]", category))
                return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve selecionar uma categoria válida");

            new admin[MAX_PLAYER_NAME];
            GetPlayerName(playerid, admin);

            if(!strcmp(category, "CRIAR CATEGORIA NOVA", true))
            {
                inline create_gps_cat_dialog(playerid3, dialogid3, response3, listitem3, string:inputtext3[]) 
                {
                    #pragma unused playerid3, dialogid3, listitem3
                    if(!response3)
                    {
                        msg[0] = EOS;
                        Dialog_ShowCallback(playerid, using inline select_gps_cat_dialog, DIALOG_STYLE_LIST, "{00FF00}GPS - Escolha a Categoria", msg, "Selecionar", "Voltar");
                        return 1;
                    }

                    if(isnull(inputtext3)) 
                        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve inserir um nome válido");

                    if(sscanf(inputtext3, "s[32]", category)) 
                        return SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Você deve inserir um nome válido");

                    Adm::CreateLocation(playerid, name, category, admin);
                    return 1;
                }

                Dialog_ShowCallback(playerid, using inline create_gps_cat_dialog, DIALOG_STYLE_INPUT,
                "{ff5555}>> {ffffff}Digite o nome da {ff5555}nova categoria:\n\n", "", "Criar", "Voltar");            
            }

            else
                Adm::CreateLocation(playerid, name, category, admin);
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline select_gps_cat_dialog, DIALOG_STYLE_LIST,
        "{00FF00}GPS - Escolha a Categoria", msg, "Selecionar", "Voltar");
        
        return 1;
    }
    
    Dialog_ShowCallback(playerid, using inline create_gps_name_dialog, DIALOG_STYLE_INPUT,
    "{ff5555}>> {ffffff}Digite o nome do local que deseja criar no GPS global\n\
    {ffff33}[ i ] {ffffff}Certifique-se de estar {ff3333}posicionado corretamente!", "", 
    "Avançar", "Voltar");

    return 1;
}

stock Adm::CreateLocation(playerid, const name[], const category[], const admin[])
{
    if(DB::Exists(db_stock, "locations", "name, category", "name = '%q' AND category = '%q'", name, category))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Esse o nome '%s', já existe na categoria \"%s\"", name, category);
        return 1;
    }

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    DB::Insert(db_stock, "locations", "name, category, creator, pX, pY, pZ", "'%q', '%q', '%q', %f, %f, %f", 
    name, category, admin, pX, pY, pZ);

    printf("[ GPS ] O Admin %s criou uma nova localização: name: %s categoria: %s", admin, name, category);

    return 1;
}

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
