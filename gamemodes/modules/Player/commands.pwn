YCMD:spawn(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    Player::Spawn(playerid, true);
    SendClientMessage(playerid, -1, "[ BPS ] {ffffff}Você foi enviado ao spawn!");
    return 1;
}

YCMD:dance(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    new danceid;

    if(sscanf(params, "i", danceid))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /dance {ff3333}[ ID ]");
    
    switch(danceid)
    {
        case 0:     ClearAnimations(playerid);
        case 1:     ApplyAnimation(playerid, "DANCING", "dnce_M_d", 4.1, true, false, false, false, 0, SYNC_ALL);
        case 2:     ApplyAnimation(playerid, "DANCING", "dnce_M_c", 4.1, true, false, false, false, 0, SYNC_ALL);
        default:    ApplyAnimation(playerid, "DANCING", "dance_loop", 4.1, true, false, false, false, 0, SYNC_ALL);
    }
    return 1;
}

YCMD:skin(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    new skinid;

    if(sscanf(params, "i", skinid))
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /skin {ff3333}[ SKINID ]");
    
    if(skinid < 0 || skinid > 311) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Erro do parâmetro: {ff3333}skinid {ffffff}[0 - 311]");
    
    SetPlayerSkin(playerid, skinid);

    
    DB::SetDataInt(db_entity, "players", "skinid", skinid, "name = '%q'", GetPlayerNameStr(playerid));

    SendClientMessage(playerid, -1, "{99ff99}[ SUCESSO ] {ffffff}Sua skin foi alterada com {99ff99}sucesso!");

    return 1;
}

YCMD:ajuda(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;
    
    return 1;
}

YCMD:acessorios(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;
    
    // if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME) && !GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED))
    //     return SendClientMessage(playerid, -1, "{ff5533}[ ERRO ] {ffffff}Você não pode mexer com acessórios durante o evento!");

    acs::ClearData(playerid);

    new msg[1024], name[MAX_PLAYER_NAME], modelid;
    
    GetPlayerName(playerid, name);

    format(msg, sizeof(msg), "{ffffff}Slot\t{ffffff}ID \t{ffffff}Status\n");

    for(new i = 0; i < MAX_PLAYER_ACESSORYS; i++)
    {
        if(DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, i))
        {
            DB::GetDataInt(db_entity, "acessorys", "modelid", modelid, "owner = '%q' AND slotid = %d", name, i);

            format(msg, sizeof(msg), "%s{ffffff}Slot: {9999ff}%d\t{ffffff}%d\t%s\n", 
            msg, i + 1, modelid,
            IsPlayerAttachedObjectSlotUsed(playerid, i) ? "{33ff33}[ EQUIPADO ]" : "{ff9933}[ DESEQUIPADO ]");
        }

        else
            format(msg, sizeof(msg), "%s{ffffff}Slot: {ff3333}%d\t\t{ff3333}[ VAZIO ]\n", msg, i + 1);
    }

    format(msg, sizeof(msg), "%s{cdcdcd}CLIQUE AQUI para comprar\t\t\n", msg);
    
    Dialog_ShowCallback(playerid, using public Response_ACC_MENU<iiiis>, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Gerenciar Acessorios", msg, "Selecionar", "Fechar");
    return 1;
}

YCMD:orgs(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    new msg[1024], line[128], org::members[MAX_ORGS];
    
    foreach(new i : Player)
    {
        if(!IsValidPlayer(i) || Player[i][pyr::orgid] == INVALID_ORG_TYPE) continue;
        org::members[Player[i][pyr::orgid]]++;
    }

    strcat(msg, "{ffffff}Organizacao\t{ff99ff}Lider\t{ffffff}Colider\t{ff99ff}Membros Online\n");

    for(new i = 1; i < MAX_ORGS; i++)
    {
        if(!GetFlag(Organization[i][org::flags], FLAG_ORG_CREATED)) continue;
        
        format(line, 128, "{%x}%s\t%s\t%s\t{ffffff}%d membros\n", Organization[i][org::color], Organization[i][org::name], 
        Organization[i][org::leader], Organization[i][org::coleader], org::members[i]);
        
        strcat(msg, line);
    }

    inline no_use_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused playerid1, dialogid, response, listitem, inputtext

        return 1;
    }
    

    Dialog_ShowCallback(playerid, using inline no_use_dialog, DIALOG_STYLE_TABLIST_HEADERS, "Orgs do Servidor", msg, "Fechar");
   
    return 1;
}

YCMD:veh(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    if(IsValidVehicle(Player[playerid][pyr::vehicleid]))
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você já possui um veículo criado. Use {ff3333}/dveh {ffffff}para destrui-lo e criar outro!");

    if(GetPlayerInterior(playerid) || GetPlayerVirtualWorld(playerid))
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você não pode criar veículos aqui!");

    new modelid, veh_name[32];
    if(sscanf(params, "i", modelid)) 
    {
        if(sscanf(params, "s[32]", veh_name)) 
            return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Use: /veh {ff3333}[ MODELID ou NOME]");
        
        modelid = GetVehicleModelByName(veh_name);
    }

    if(modelid < 400 || modelid > 605) 
        return SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}Parâmetro {ff3333}[ MODELID ou NOME ] {ffffff}Inválido!");
    
    new Float:pX, Float:pY, Float:pZ, Float:pA;
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pA);

    Player[playerid][pyr::vehicleid] = Veh::Create(modelid, pX, pY, pZ, pA, RandomMinMax(0, 10), RandomMinMax(0, 10), 0, 0, 0);
    PutPlayerInVehicle(playerid, Player[playerid][pyr::vehicleid], 0);

    SendClientMessage(playerid, -1, "{33ff33}[ VEH ] {ffffff}Veículo criado com sucesso!");

    return 1;
}

YCMD:dveh(playerid, params[], help)
{
    if(!GetFlag(Player[playerid][pyr::flags], MASK_PLAYER_LOGGED)) return 1;

    if(!IsValidVehicle(Player[playerid][pyr::vehicleid]))
        return SendClientMessage(playerid, -1, "{ff3333}[ VEH ] {ffffff}Você precisa criar um veículo antes. Use {ff3333}/veh [ MODELID ou NOME ] {ffffff}para isso!");

    Veh::Destroy(Player[playerid][pyr::vehicleid]);

    SendClientMessage(playerid, -1, "{33ff33}[ ADM ] {ffffff}Veículo destruído com sucesso!");

    return 1;
}