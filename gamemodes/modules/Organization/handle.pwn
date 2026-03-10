#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    // Org::Create("Groove StreeT",   ORG_TYPE_GANG,   "SERVER", "GRV", NO_LEADER_NAME, NO_COLEADER_NAME,  {65, 105, 106, 195}, 0x66FF66FF, 2512.6948, -1672.7095, 13.5, 93.2823);
    // Org::Create("Policia Militar", ORR_TYPE_POLICE, "SERVER", "PF", NO_LEADER_NAME, NO_COLEADER_NAME,  {300, 301, 306, 309}, 0x66FFFFFF, 1540.6760, -1675.6892, 13.5493, 90.0);

    for(new i = 0; i < MAX_ORGS; i++)
    {
        new result = Org::Load(i);

        if(result == -1) continue;
        
        else if(result == 0)
            DC::Log(LOG_TYPE_ERR, "[ DB (ORG) ] Erro ao carregar organizacao orgid: %d!", i);
        else
        {
            printf("[ DB (ORG) ] Organizacao %s carregada com sucesso!\n", Org[i][org::name]);
            DC::LoadCountOrgs++;
        }
    }

    DC::SendLoadInitEmbed();

    return 1;
}

hook OnGameModeExit()
{
    for(new orgid = 0; orgid < MAX_ORGS; orgid++)
    {
        DestroyDynamicPickup(Org[orgid][org::pickupid]);
        DestroyDynamic3DTextLabel(Org[orgid][org::labelid]);
    }

    return 1;
}

hook OnPlayerLogin(playerid)
{
    for(new orgid = 0; orgid < MAX_ORGS; orgid++)
    {
        if(!GetFlag(Org[orgid][org::flags], FLAG_ORG_CREATED)) continue;
    
        GangZoneShowForPlayer(playerid, Org[orgid][org::zoneid], (Org[orgid][org::color] & 0xFFFFFF00) | 0xAA);

        switch(Org[orgid][org::type])
        {
            case ORG_TYPE_FAMILY:   SetPlayerMapIcon(playerid, 0, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 52, 0, MAPICON_LOCAL);
            case ORG_TYPE_FACTION:  SetPlayerMapIcon(playerid, 1, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 19, 0, MAPICON_LOCAL);
            case ORG_TYPE_GANG:     SetPlayerMapIcon(playerid, 2, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 62, 0, MAPICON_LOCAL);
            case ORR_TYPE_POLICE:   SetPlayerMapIcon(playerid, 3, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 30, 0, MAPICON_LOCAL);
            case ORG_TYPE_ARMY:     SetPlayerMapIcon(playerid, 4, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 18, 0, MAPICON_LOCAL);
            case ORG_TYPE_MAFIA:    SetPlayerMapIcon(playerid, 5, Org[orgid][org::sX], Org[orgid][org::sY], Org[orgid][org::sZ], 43, 0, MAPICON_LOCAL);
        }
    }

    Org::ClearPlayer(playerid);

    if(!Org::LoadPlayer(playerid)) return 1;

    Org::SetMemberTag(playerid);
    
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    RemovePlayerMapIcon(playerid, 0);
    RemovePlayerMapIcon(playerid, 1);
    RemovePlayerMapIcon(playerid, 2);
    RemovePlayerMapIcon(playerid, 3);
    RemovePlayerMapIcon(playerid, 4);
    RemovePlayerMapIcon(playerid, 5);

    if(org::Player[playerid][pyr::orgid] == INVALID_ORG_ID)return 1;

    DB::SetDataInt(db_entity, "members", "flags", org::Player[playerid][pyr::flags], "name = '%q'", GetPlayerNameStr(playerid));

    Org::ClearPlayer(playerid);

    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if(org::Player[playerid][pyr::orgid] != 0) return 1;
    
    if(!IsPlayerInRangeOfPoint(playerid, 15.0, 2463.862597, -1658.594145, 14.169431)) return 1;

    new Float:pX, Float:pY, Float:pZ;

    GetDynamicObjectPos(Org[0][org::gate_objectid], pX, pY, pZ);

    if((_:newkeys & 0x2) && !(_:oldkeys & 0x2))
    {
        //14.169431
        if(pZ <= 15.0)
        {
            MoveDynamicObject(Org[0][org::gate_objectid], 2463.862597, -1658.594145, 17.819431, 2.5);
        }
        //17.819431
        else if(pZ >= 17.0)
        {
            MoveDynamicObject(Org[0][org::gate_objectid], 2463.862597, -1658.594145, 14.169431, 2.5);
        }
    }

    return 1;
}