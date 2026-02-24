#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    // Org::Create("Groove StreeT",   ORG_TYPE_GANG,   "SERVER", NO_LEADER_NAME, NO_LEADER_NAME,  {65, 105, 106, 195},  0x99FF99FF, 2495.33, -1690.26,   13.3438, 90.0);
    // Org::Create("Policia Militar", ORR_TYPE_POLICE, "SERVER", NO_COLEADER_NAME, NO_COLEADER_NAME,  {300, 301, 306, 309}, 0x99FFFFF, 1540.6760, -1675.6892, 13.5493, 90.0);

    for(new i = 1; i < MAX_ORGS; i++)
    {
        new result = Org::Load(i);

        if(result == -1) continue;
        
        else if(result == 0)
            printf("[ DB (ORG) ] Erro ao carregar organização orgid: %d!", i);
        else
            printf("[ DB (ORG) ] Organização %s carregada com sucesso!", Org[i][org::name]);
    }

    return 1;
}

stock Org::Load(orgid)
{
    if(!DB::Exists(db_stock, "organizations", "orgid = %d", orgid)) return -1;

    DB::GetDataString(db_stock, "organizations", "name", Org[orgid][org::name], 32, "orgid = %d", orgid);
    DB::GetDataInt(db_stock, "organizations", "type", Org[orgid][org::type], "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "leader", Org[orgid][org::leader], MAX_PLAYER_NAME, "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "coleader", Org[orgid][org::coleader], MAX_PLAYER_NAME, "orgid = %d", orgid);

    new skins[MAX_ORGS_SKINS];
    if(Org::GetSkins(orgid, skins)) return 0;

    Org[orgid][org::skins] = skins;

    DB::GetDataInt(db_stock, "organizations", "color", Org[orgid][org::color], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "funds", Org[orgid][org::funds], "orgid = %d", orgid);
    DB::GetDataInt(db_stock, "organizations", "flags", Org[orgid][org::flags], "orgid = %d", orgid);
    DB::GetDataString(db_stock, "organizations", "tag", Org[orgid][org::tag], 3, "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sX", Org[orgid][org::sX], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sY", Org[orgid][org::sY], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sZ", Org[orgid][org::sZ], "orgid = %d", orgid);
    DB::GetDataFloat(db_stock, "organizations", "sA", Org[orgid][org::sA], "orgid = %d", orgid);

    return 1;
}

stock Org::GetFreeSlot()
{
    for(new i = 1; i < MAX_ORGS; i++)
        if(!DB::Exists(db_stock, "organizations", "orgid = %d", i))
            return i;
        
    return INVALID_ORG_ID;
}

stock Org::Create(const name[], ORG_TYPE:type, const creator[], const tag[], const leader[], const coleader[], const skins[MAX_ORGS_SKINS], color, Float:sX, Float:sY, Float:sZ, Float:sA)
{
    new orgid = Org::GetFreeSlot();

    if(orgid == INVALID_ORG_ID)
    {
        printf("[ ORGS (DB) ] Não foi possível criar a organização %s! Aumente o valor de MAX_ORGS", name);
        return 0;
    }

    if(DB::Exists(db_stock, "organizations", "name = '%q'", name))
    {
        printf("[ ORGS (DB) ] Não foi possível criar a organização %s, pois já existia!", name);
        return 0;
    }

    new sucess = DB::Insert(db_stock, "organizations", 
    "orgid, name, type, creator, leader, coleader, skins, color, funds, flags, sX, sY, sZ, sA, tag", 
    "%i, '%q', %i, '%q', '%q', '%q', '%q', %i, %f, %i, %f, %f, %f, %f, '%q'", orgid,
    name, _:type, creator, leader, coleader, DB::GetIntListStr(skins, MAX_ORGS_SKINS), color, 0.0, FLAG_ORG_CREATED, sX, sY, sZ, sA,
    tag);
     
    if(sucess)
        printf("[ ORGS (DB) ] Organizacao %s | Lider: %s | Colider: %s criada com sucesso", name, leader, coleader);
    else
    {
        printf("[ ORGS (DB) ] Erro ao criar organizacao");
        return 0;
    }

    return 1;
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

stock Org::SetLeader(playerid, const name[], const admin_name[], orgid)
{
    if(!Player::Exists(name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador provavelmente não existe no {ff3333}banco de dados!");
        return 0;
    }

    new flags;
    DB::GetDataInt(db_entity, "players", "flags", flags, "name = '%q'", name);

    if(GetFlag(flags, FLAG_PLAYER_LEADER))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador {ff3333}já é lider {ffffff}de uma organização!");
        return 0;
    }

    new targetid = GetPlayerIDByName(name);

    if(IsValidPlayer(targetid))
    {
        org::Player[targetid][pyr::orgid] = orgid;
        org::Player[targetid][pyr::role] = ORG_ROLE_LEADER;
        SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_LEADER);
        SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_MEMBER);

        SetPlayerColor(targetid, Org[orgid][org::color]);
        
        new skins[MAX_ORGS_SKINS];
        Org::GetSkins(orgid, skins);

        SetPlayerSkin(targetid, skins[RandomMinMax(0, MAX_ORGS_SKINS - 1)]);

        SendClientMessage(targetid, -1, "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}líder\
        da organização {%x}%s", Org[orgid][org::color], Org[orgid][org::name]);

        DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
        DB::SetDataInt(db_entity, "players", "flags", Player[targetid][pyr::flags], "name = '%q'", name);

        SendClientMessage(targetid, -1, "{ffff33}[ ORGS ] {ffffff}Use {ffff33}/ajudaorg {ffffff}para ver o painel de comandos da sua organização.");
    }

    DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
    DB::SetDataInt(db_entity, "players", "flags", flags | FLAG_PLAYER_MEMBER | FLAG_PLAYER_LEADER, "name = '%q'", name);
    DB::SetDataString(db_stock, "organizations", "leader", name, "name = '%q'", Org[orgid][org::name]);

    printf("[ ORG (DB) ] O admin %s, setou %s como lider da organizacao %s", admin_name, name, Org[orgid][org::name]);
    return 1;
}

stock Org::SetCoLeader(playerid, const name[], const admin_name[], orgid)
{
    if(!Player::Exists(name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador provavelmente não existe no {ff3333}banco de dados!");
        return 0;
    }

    new flags;
    DB::GetDataInt(db_entity, "players", "flags", flags, "name = '%q'", name);

    if(GetFlag(flags, FLAG_PLAYER_COLEADER))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Esse jogador {ff3333}já é lider {ffffff}de uma organização!");
        return 0;
    }

    new targetid = GetPlayerIDByName(name);

    if(IsValidPlayer(targetid))
    {
        org::Player[targetid][pyr::orgid] = orgid;
        org::Player[targetid][pyr::role] = ORG_ROLE_COLEADER;
        SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_COLEADER);
        SetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_MEMBER);

        SetPlayerColor(targetid, Org[orgid][org::color]);

        new skins[MAX_ORGS_SKINS];
        Org::GetSkins(orgid, skins);

        SetPlayerSkin(targetid, skins[RandomMinMax(0, MAX_ORGS_SKINS - 1)]);

        SendClientMessage(targetid, -1, "{33ff33}[ ORGS ] {ffffff}Parabéns, você agora é {33ff33}Co-líder\
        da organização {%x}%s", Org[orgid][org::color], Org[orgid][org::name]);

        DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
        DB::SetDataInt(db_entity, "players", "flags", Player[targetid][pyr::flags], "name = '%q'", name);

        SendClientMessage(targetid, -1, "{ffff33}[ ORGS ] {ffffff}Use {ffff33}/ajudaorg {ffffff}para ver o painel de comandos da sua organização.");
    }

    DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
    DB::SetDataInt(db_entity, "players", "flags", flags | FLAG_PLAYER_MEMBER | FLAG_PLAYER_COLEADER, "name = '%q'", name);
    DB::SetDataString(db_stock, "organizations", "coleader", name, "name = '%q'", Org[orgid][org::name]);

    printf("[ ORG (DB) ] O admin %s, setou %s como colider da organizacao %s", admin_name, name, Org[orgid][org::name]);
    return 1;
}

stock Org::HasPermission(playerid, flag)
{
    if(org::Player[playerid][pyr::orgid] == INVALID_ORG_ID)
    {   
        SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Você não faz parte de uma {ff3333}organização!");
        return 0;
    }

    if(!GetFlag(Player[playerid][pyr::flags], flag))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORGS ] {ffffff}Você não tem {ff3333}permissão {ffffff}para usar esse comando!");
        return 0;
    }

    return 1;
}

stock Org::ValidTargetID(playerid, targetid, bool:self = false, bool:has_org = false, bool:same_org = true)
{
    if(!IsValidPlayer(targetid)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}O jogador {ff3333}nao esta online!");
        return 0;
    }

    if(Admin[playerid][adm::lvl] >= ROLE_ADM_MANAGER)
    {
        if(Adm::ValidTargetID(playerid, targetid, true)) return 1;

        return 0;
    }

    if(!self && (playerid == targetid))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Voce nao poder aplicar essa acao em {ff3333}si mesmo!");
        return 0;        
    }

    if(!has_org)
    {
        if(org::Player[targetid][pyr::orgid] != INVALID_ORG_ID)
        {
            SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador já está em uma organização!");
            return 0;  
        }
    }

    // F(ABCD) = !A + B + C && A + !B + C + D 
    if
    (  
        (GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_COLEADER) || GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_LEADER)) &&
        (GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LEADER) || GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_LEADER) || GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_COLEADER))
    )
    {
        if((self && (playerid == targetid))) return 1;

        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    }   

    if(same_org && org::Player[playerid][pyr::orgid] != org::Player[targetid][pyr::orgid])
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ORG ] {ffffff}Esse jogador é membro de outra organização");
        return 0;        
    }

    return 1;     
}

stock Org::IsPlayerUsingUniform(playerid, orgid)
{
    for(new i = 0; i < MAX_ORGS_SKINS; i++)
        if(Org[orgid][org::skins][i] == Player[playerid][pyr::skinid])
            return 1;
    return 0;
}

stock Org::SetPlayer(playerid, orgid, uniform = false)
{
    org::Player[playerid][pyr::orgid] = orgid;
    org::Player[playerid][pyr::invite] = INVALID_ORG_ID;
    org::Player[playerid][pyr::role] = ORG_ROLE_NOVICE;

    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_MEMBER);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_NOVICE | FLAG_PLAYER_JUNIOR | FLAG_PLAYER_SENIOR | FLAG_PLAYER_COLEADER | FLAG_PLAYER_LEADER);
    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_NOVICE);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    DB::SetDataInt(db_entity, "players", "orgid", orgid, "name = '%q'", name);
    DB::SetDataInt(db_entity, "players", "flags", Player[playerid][pyr::flags], "name = '%q'", name);

    if(uniform)
    {
        new str[144];
        format(str, 144, "{%06x}[ %s ]", Org[orgid][org::color] >>> 8, Org[orgid][org::tag]);
        org::Player[playerid][pyr::labelid] = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, 0.25, 70.0, playerid);

        if(!Org::IsPlayerUsingUniform(playerid, orgid))
        {
            Player[playerid][pyr::skinid] = Org[orgid][org::skins][RandomMinMax(0, MAX_ORGS_SKINS - 1)];
            SetPlayerSkin(playerid, Player[playerid][pyr::skinid]);
        }
    }
}

stock Org::UnSetPlayer(playerid)
{
    new orgid = org::Player[playerid][pyr::orgid];
    new role = _:org::Player[playerid][pyr::role];

    if(orgid != INVALID_ORG_ID)
    {
        if(role == ORG_ROLE_LEADER)
        {
            format(Org[orgid][org::leader], MAX_PLAYER_NAME, "%s", NO_LEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "leader", NO_LEADER_NAME, "orgid = %d", orgid);
        }
        else if(role == ORG_ROLE_COLEADER)
        {
            format(Org[orgid][org::coleader], MAX_PLAYER_NAME, "%s", NO_COLEADER_NAME);
            DB::SetDataString(db_stock, "organizations", "coleader", NO_COLEADER_NAME, "orgid = %d", orgid);
        }
    }

    org::Player[playerid][pyr::orgid] = INVALID_ORG_ID;
    org::Player[playerid][pyr::invite] = INVALID_ORG_ID;
    org::Player[playerid][pyr::role] = ORG_ROLE_NOVICE;

    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_MEMBER | FLAG_PLAYER_NOVICE | FLAG_PLAYER_JUNIOR | FLAG_PLAYER_SENIOR | FLAG_PLAYER_COLEADER | FLAG_PLAYER_LEADER);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    DB::SetDataInt(db_entity, "players", "orgid", INVALID_ORG_ID, "name = '%q'", name);
    DB::SetDataInt(db_entity, "players", "flags", Player[playerid][pyr::flags], "name = '%q'", name);

    DestroyDynamic3DTextLabel(org::Player[playerid][pyr::labelid]);

    //Limpar uniforme (skin)

    return 1;
}
