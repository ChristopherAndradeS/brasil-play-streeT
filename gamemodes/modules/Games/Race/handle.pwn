#include <YSI\YSI_Coding\y_hooks>

hook OnVehicleHealthChance(vehicleid, Float:new_health, Float:old_health)
{
    #pragma unused old_health

    new raceid, playerid;
    if(!Race::IsRaceVehicle(vehicleid, raceid, playerid)) return 1;

    if(Game[raceid][game_state] != GAME_STATE_STARTED)
        return 1;

    if(new_health < 2000.0)
        Race::ProtectVehicle(vehicleid);

    return 1;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 1;

    new raceid = game::Player[playerid][pyr::gameid];

    if(raceid == INVALID_GAME_ID) return 0;
    if(!map_valid(Race[raceid][race::participant])) return 0;
    if(!map_has_key(Race[raceid][race::participant], playerid)) return 0;

    new data[E_RACE_SEAT];
    map_get_arr(Race[raceid][race::participant], playerid, data);   

    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
        if(IsValidVehicle(data[race::vehicleid]))
            PutPlayerInVehicle(playerid, data[race::vehicleid], 0);
    
    return 1;
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
    if(!GetFlag(game::Player[forplayerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 1;

    new raceid = game::Player[forplayerid][pyr::gameid];

    if(raceid == INVALID_GAME_ID) return 0;
    if(!map_valid(Race[raceid][race::participant])) return 0;
    if(!map_has_key(Race[raceid][race::participant], forplayerid)) return 0;

    new data[E_RACE_SEAT];
    map_get_arr(Race[raceid][race::participant], forplayerid, data);   

    if(GetPVarInt(forplayerid, "PutPlayerInVehicle") && vehicleid == data[race::vehicleid])
    {
        PutPlayerInVehicle(forplayerid, data[race::vehicleid], 0);
        DeletePVar(forplayerid, "PutPlayerInVehicle");
    }

    return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 1;

    new raceid = game::Player[playerid][pyr::gameid];

    if(raceid == INVALID_GAME_ID) return 0;
    if(!map_valid(Race[raceid][race::participant])) return 0;
    if(!map_has_key(Race[raceid][race::participant], playerid)) return 0;

    new data[E_RACE_SEAT];
    map_get_arr(Race[raceid][race::participant], playerid, data);   

    DisablePlayerCheckpoint(playerid);

    data[race::checkid]++;

    if(data[race::checkid] >= sizeof(Race::gCheckpoints))
    {
        data[race::checkid] = 0;
        data[race::laps]++;

        if(data[race::laps] > Race[raceid][race::lap])
        {
            ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME);
            ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
            SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED);

            Race[raceid][race::finisheds]++;

            Game::SendMessageToAll(raceid, 
            "{3399ff}[ CORRIDA ] {3399ff}%s {ffffff}terminou a corrida {3399ff}%s {ffffff}em {3399ff}%d| lugar", 
            GetPlayerNameStr(playerid), Game[raceid][game::name], Race[raceid][race::finisheds]);

            Game::RemovePlayer(raceid, playerid);
        
            return 1;
        }

        else if(data[race::laps] == Race[raceid][race::lap])
        {
            GameTextForPlayer(playerid, "~p~ULTIMA VOLTA", 1500, 3);
            SendClientMessage(playerid, -1, "{3399ff}[ CORRIDA ] Você está na sua {3399ff}última volta!");
            PlayerPlaySound(playerid, 1139, 0.0, 0.0, 0.0);
        }

        else
        {
            GameTextForPlayer(playerid, "~p~LAP %d/%d", 1500, 3, data[race::laps], Race[raceid][race::lap]);
            PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);
        }
    }

    else
        PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);

    Race::UpdatePodium(raceid);

    Race::UpdatePlayerCheck(playerid, data);

    return 1;
}
