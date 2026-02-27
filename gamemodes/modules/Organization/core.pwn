
stock Org::Load(orgid)
{
    if(!DB::Exists(db_stock, "organizations", "orgid = %d", orgid)) return -1;

    DB::GetDataString(db_stock, "organizations", "name", Org[orgid][org::name], 32, "orgid = %d", orgid);
    DB::GetDataInt(db_stock, "organizations", "type", _:Org[orgid][org::type], "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "leader", Org[orgid][org::leader], MAX_PLAYER_NAME, "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "coleader", Org[orgid][org::coleader], MAX_PLAYER_NAME, "orgid = %d", orgid);
    DB::GetDataInt(db_stock, "organizations", "color", Org[orgid][org::color], "orgid = %d", orgid);

    new skins[MAX_ORGS_SKINS];
    Org::GetSkins(orgid, skins);

    Org[orgid][org::skins] = skins;
    
    DB::GetDataFloat(db_stock, "organizations", "funds", Org[orgid][org::funds], "orgid = %d", orgid);
    DB::GetDataInt(db_stock, "organizations", "flags", Org[orgid][org::flags], "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "tag", Org[orgid][org::tag], 4, "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sX", Org[orgid][org::sX], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sY", Org[orgid][org::sY], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sZ", Org[orgid][org::sZ], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sA", Org[orgid][org::sA], "orgid = %d", orgid);

    Org[orgid][org::zoneid] = GangZoneCreate(Float:Org::ZonesLimits[orgid][0], Float:Org::ZonesLimits[orgid][1], 
        Float:Org::ZonesLimits[orgid][2], Float:Org::ZonesLimits[orgid][3]);
    
    new str[144];
    
    format(str, 144, "[ {%06x}%s {ffffff}]\nTipo: %s\n{ffffff}Lider: {%06x}%s | {ffffff}Colider: {%06x}%s",
    Org[orgid][org::color] >>> 8, Org[orgid][org::name], Org::gTypeNames[_:Org[orgid][org::type]],
    Org[orgid][org::color] >>> 8, Org[orgid][org::leader],
    Org[orgid][org::color] >>> 8, Org[orgid][org::coleader]);
    
    Org[orgid][org::labelid] = CreateDynamic3DTextLabel(str, -1, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 60.0, .testlos = 1);

    Org[orgid][org::pickupid] = CreateDynamicPickup(1314, 0, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ]);
    
    return 1;
}

stock Org::LoadPlayer(playerid)
{
    if(!DB::Exists(db_entity, "members", "name = '%q'", GetPlayerNameStr(playerid))) return 0;

    DB::GetDataInt(db_entity, "members", "orgid", org::Player[playerid][pyr::orgid], "name = '%q'", GetPlayerNameStr(playerid));
    DB::GetDataInt(db_entity, "members", "role", _:org::Player[playerid][pyr::role], "name = '%q'", GetPlayerNameStr(playerid));
    DB::GetDataInt(db_entity, "members", "flags", org::Player[playerid][pyr::flags], "name = '%q'", GetPlayerNameStr(playerid));
    DB::GetDataInt(db_entity, "members", "skinid", org::Player[playerid][pyr::skinid], "name = '%q'", GetPlayerNameStr(playerid));
    
    org::Player[playerid][pyr::invite_orgid] = INVALID_ORG_ID;
    org::Player[playerid][pyr::inviterid] = INVALID_PLAYER_ID;

    return 1;
}

stock Org::ClearPlayer(playerid)
{
    org::Player[playerid][pyr::invite_orgid] = INVALID_ORG_ID;
    org::Player[playerid][pyr::inviterid] = INVALID_PLAYER_ID;
    org::Player[playerid][pyr::orgid]  = INVALID_ORG_ID;
    org::Player[playerid][pyr::flags]  = 0;
    org::Player[playerid][pyr::skinid]  = 0;
    org::Player[playerid][pyr::role] = INVALID_ORG_ROLE_ID;
    
    if(IsValidDynamic3DTextLabel(org::Player[playerid][pyr::labelid]))
        DestroyDynamic3DTextLabel(org::Player[playerid][pyr::labelid]);

    org::Player[playerid][pyr::labelid] = INVALID_3DTEXT_ID;
}

stock Org::Create(const name[], ORG_TYPE:type, const creator[], const tag[], const leader[], const coleader[], const skins[MAX_ORGS_SKINS], color, Float:sX, Float:sY, Float:sZ, Float:sA)
{
    new orgid = Org::GetFreeSlot();

    if(orgid == INVALID_ORG_ID)
    {
        printf("[ ORGS (DB) ] Nao foi possivel criar a organizacao %s! Aumente o valor de MAX_ORGS\n", name);
        return 0;
    }

    if(DB::Exists(db_stock, "organizations", "name = '%q'", name))
    {
        printf("[ ORGS (DB) ] Nao foi possivel criar a organizacao %s, pois ja existia!\n", name);
        return 0;
    }

    new sucess = DB::Insert(db_stock, "organizations", 
    "orgid, name, type, creator, leader, coleader, skins, color, funds, flags, sX, sY, sZ, sA, tag", 
    "%i, '%q', %i, '%q', '%q', '%q', '%q', %i, %f, %i, %f, %f, %f, %f, '%q'", orgid,
    name, _:type, creator, leader, coleader, DB::GetIntListStr(skins, MAX_ORGS_SKINS), color, 0.0, FLAG_ORG_CREATED, sX, sY, sZ, sA,
    tag);
     
    if(sucess)
        printf("[ ORGS (DB) ] Organizacao %s | Lider: %s | Colider: %s criada com sucesso\n", name, leader, coleader);
    else
    {
        printf("[ ORGS (DB) ] Erro ao criar organizacao\n");
        return 0;
    }

    return 1;
}

stock Org::SetMember(playerid, targetid, orgid, ORG_ROLES:role)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(targetid, name);

    if(!Player::Exists(name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador provavelmente não existe no {ff3333}banco de dados!");
        return 0;
    }

    new crt_role = 0;
    
    if(DB::Exists(db_entity, "members", "name = '%q'", name))
    {
        DB::GetDataInt(db_entity, "members", "role", crt_role, "name = '%q'", name);

        if(crt_role == _:role)
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador {ff3333}já possui esse cargo {ffffff}na organização!");
            return 0;
        }

        DB::SetDataInt(db_entity, "members", "orgid", orgid, "name = '%q'", name);
        DB::SetDataInt(db_entity, "members", "role", _:role, "name = '%q'", name);    
        
        if(crt_role < _:role)
            SendClientMessage(targetid, -1, "{33ff33}[ ORGS ] {ffffff}Você agora foi {33ff33}promovido {ffffff}na sua organização");
        else
            SendClientMessage(targetid, -1, "{ff3333}[ ORGS ] {ffffff}Você agora foi {ff3333}rebaixado {ffffff}na sua organização");
    }   

    else
    {
        new skinid = RandomMinMax(0, MAX_ORGS_SKINS - 1);

        new success = DB::Insert(db_entity, "members", "name, orgid, flags, skinid, role", 
        "'%q', %i, 0, %i, %i", 
        name, orgid, Org[orgid][org::skins][skinid], _:role);

        if(!success)
        {
            printf("[ ORG MEMBER (DB) ] Erro ao criar membro da organização %s\n", Org[orgid][org::name]);
            return 0;
        }

        SendClientMessage(targetid, -1, 
        "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}membro {ffffff}da organização {%06x}%s", 
        Org[orgid][org::color] >>> 8, Org[orgid][org::name]); 
    }

    switch(role)
    {
        case ORG_ROLE_LEADER:
        {
            format(Org[orgid][org::leader], MAX_PLAYER_NAME, "%s", name);
            DB::SetDataString(db_stock, "organizations", "leader", Org[orgid][org::leader], "orgid = %d", orgid);
            
            SendClientMessage(targetid, -1, 
            "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}Líder {ffffff}da organização {%06x}%s", 
            Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

            Org::UpdateLabel(orgid);

            printf("[ ORG (DB) ] O admin %s, setou %s como lider da organizacao %s\n", GetPlayerNameStr(playerid), name, Org[orgid][org::name]);
        }

        case ORG_ROLE_COLEADER:
        {
            format(Org[orgid][org::coleader], MAX_PLAYER_NAME, "%s", name);
            DB::SetDataString(db_stock, "organizations", "coleader", Org[orgid][org::coleader], "orgid = %d", orgid);
            
            SendClientMessage(targetid, -1, 
            "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}Colíder {ffffff}da organização {%06x}%s", 
            Org[orgid][org::color] >>> 8, Org[orgid][org::name]);

            Org::UpdateLabel(orgid);

            printf("[ ORG (DB) ] O admin/líder %s, setou %s como colider da organizacao %s\n", GetPlayerNameStr(playerid), name, Org[orgid][org::name]);
        }
    }

    Org::LoadPlayer(targetid);
    Org::SetMemberTag(targetid);
    SendClientMessage(targetid, -1, "{ffff33}[ ORGS ] {ffffff}Use {ffff33}/ajudaorg {ffffff}para ver o painel de comandos da sua organização.");
    
    return 1;
}

stock Org::UnSetMember(targetid)
{
    if(!DB::Exists(db_entity, "members", "name = '%q'", GetPlayerNameStr(targetid))) return 0;

    new orgid = org::Player[targetid][pyr::orgid];
    new ORG_ROLES:role  = org::Player[targetid][pyr::role];

    switch(role)
    {
        case ORG_ROLE_LEADER:
        {
            format(Org[orgid][org::leader], MAX_PLAYER_NAME, "%s", NO_LEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "leader", NO_LEADER_NAME, "orgid = %d", orgid);
            Org::UpdateLabel(orgid);
        }

        case ORG_ROLE_COLEADER:
        {
            format(Org[orgid][org::coleader], MAX_PLAYER_NAME, "%s", NO_COLEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "coleader", NO_COLEADER_NAME, "orgid = %d", orgid);
            Org::UpdateLabel(orgid);
        }
    }

    DB::Delete(db_entity, "members", "name = '%q'", GetPlayerNameStr(targetid));

    Org::ClearPlayer(targetid);

    if(Org::IsPlayerUsingUniform(targetid, orgid))
        SetPlayerSkin(targetid, Player[targetid][pyr::skinid]);

    return 1;
}

stock Org::SetMemberOnWork(playerid)
{
    if(!DB::Exists(db_entity, "members", "name = '%q'", GetPlayerNameStr(playerid))) return 0;

    SetPlayerSkin(playerid, org::Player[playerid][pyr::skinid]);
    SetFlag(org::Player[playerid][pyr::flags], FLAG_PLAYER_ON_WORK);

    DB::SetDataInt(db_entity, "members", "flags", org::Player[playerid][pyr::flags], "name = '%q'", GetPlayerNameStr(playerid));
    
    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {ffffff}Você está em {ffff99}modo de trabalho!");
    return 1;
}

stock Org::UnSetMemberOnWork(playerid)
{
    if(!DB::Exists(db_entity, "members", "name = '%q'", GetPlayerNameStr(playerid))) return 0;

    SetPlayerSkin(playerid, Player[playerid][pyr::skinid]);
    ResetFlag(org::Player[playerid][pyr::flags], FLAG_PLAYER_ON_WORK);

    DB::SetDataInt(db_entity, "members", "flags", org::Player[playerid][pyr::flags], "name = '%q'", GetPlayerNameStr(playerid));
    
    SendClientMessage(playerid, -1, "{ffff99}[ ORG ] {ffffff}Você saiu do {ffff99}modo de trabalho!");
    return 1;
}

stock Org::GetFreeSlot()
{
    for(new i = 0; i < MAX_ORGS; i++)
        if(!DB::Exists(db_stock, "organizations", "orgid = %d", i))
            return i;
        
    return INVALID_ORG_ID;
}

stock DB::GetIntListStr(const list[], len = sizeof(list))
{
    new liststr[64];

    for(new i = 0; i < len; i++)
        format(liststr, 64, "%s%d ", liststr, list[i]);

    return liststr;
}

stock Org::GetSkins(orgid, output[MAX_ORGS_SKINS])
{
    new buffer[64];
    DB::GetDataString(db_stock, "organizations", "skins", buffer, 64, "orgid = %d", orgid);

    return sscanf(buffer, "a<i>["#MAX_ORGS_SKINS"]", output);
}

stock Org::HasPermission(playerid, ORG_ROLES:role)
{
    if(org::Player[playerid][pyr::orgid] == INVALID_ORG_ID)
    {   
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você não faz parte de uma {ff3333}organização!");
        return 0;
    }

    if(org::Player[playerid][pyr::role] < role)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Você não tem {ff3333}permissão {ffffff}para usar esse comando!");
        return 0;
    }

    return 1;
}

stock Org::ValidTargetID(playerid, targetid, bool:self = false, bool:in_org = false, bool:same_org = true)
{
    if(!IsValidPlayer(targetid)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}O jogador {ff3333}nao esta online!");
        return 0;
    }

    if(!in_org && org::Player[targetid][pyr::orgid] != INVALID_ORG_ID)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador já está em uma organização!");
        return 0;
    }

    if(in_org && org::Player[targetid][pyr::orgid] == INVALID_ORG_ID)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador não faz parte de uma organização!");
        return 0;
    }
  
    if(!self && (playerid == targetid))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Voce nao poder aplicar essa acao em {ff3333}si mesmo!");
        return 0;        
    }

    if(same_org && org::Player[playerid][pyr::orgid] != org::Player[targetid][pyr::orgid])
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador é membro de outra organização");
        return 0;        
    }

    if(org::Player[playerid][pyr::role] <= org::Player[targetid][pyr::role])
    {
        if((self && (playerid == targetid))) return 1;

        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    } 

    return 1;     
}

stock Org::IsPlayerUsingUniform(playerid, orgid)
{
    new skinid = GetPlayerSkin(playerid);

    for(new i = 0; i < MAX_ORGS_SKINS; i++)
        if(Org[orgid][org::skins][i] == skinid)
            return 1;
    return 0;
}

stock Org::UpdateLabel(orgid)
{
    new str[144];
    
    format(str, 144, "[ {%06x}%s {ffffff}]\nTipo: %s\n{ffffff}Lider: {%06x}%s | {ffffff}Colider: {%06x}%s",
    Org[orgid][org::color] >>> 8, Org[orgid][org::name], Org::gTypeNames[_:Org[orgid][org::type]],
    Org[orgid][org::color] >>> 8, Org[orgid][org::leader],
    Org[orgid][org::color] >>> 8, Org[orgid][org::coleader]);
    
    UpdateDynamic3DTextLabelText(Org[orgid][org::labelid] , -1, str);
}

stock Org::SetMemberTag(playerid)
{
    new orgid = org::Player[playerid][pyr::orgid];

    new str[32];

    if(org::Player[playerid][pyr::role] == ORG_ROLE_LEADER)
        format(str, 32, "{%06x}[ LIDER ][ %s ]", Org[orgid][org::color] >>> 8, Org[orgid][org::tag]);
    else if(org::Player[playerid][pyr::role] == ORG_ROLE_COLEADER)
        format(str, 32, "{%06x}[ COLIDER ][ %s ]", Org[orgid][org::color] >>> 8, Org[orgid][org::tag]);
    else if(org::Player[playerid][pyr::role] == ORG_ROLE_NOVICE)
        format(str, 32, "{%06x}[ NOVATO ][ %s ]", Org[orgid][org::color] >>> 8, Org[orgid][org::tag]);
    else 
        format(str, 32, "{%06x}[ %s ]", Org[orgid][org::color] >>> 8, Org[orgid][org::tag]);
    
    if(IsValidDynamic3DTextLabel(org::Player[playerid][pyr::labelid]))
        UpdateDynamic3DTextLabelText(org::Player[playerid][pyr::labelid], -1, str);
    else
        org::Player[playerid][pyr::labelid]  = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.1, 25.0, playerid, .testlos = 1);
}
