#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerLogin(playerid)
{
    Game::ClearPlayer(playerid);
    return 1;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 1;

    if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
        if(IsValidVehicle(race::Player[playerid][race::vehicleid]))
            PutPlayerInVehicle(playerid, race::Player[playerid][race::vehicleid], 0);
    
    return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING)) return 1;

    new gameid = game::Player[playerid][pyr::gameid];
    new raceid = game::Player[playerid][pyr::raceid];
    
    if(gameid == INVALID_GAME_ID || raceid == INVALID_RACE_ID) return 1;

    new check = race::Player[playerid][race::checkid];
    new lap   = race::Player[playerid][race::lap];

    DisablePlayerCheckpoint(playerid);

    check++;

    if(check >= sizeof(Race::gCheckpoints))
    {
        PlayerPlaySound(playerid, 1139, 0.0, 0.0, 0.0);
        
        check = 0;
        lap++;

        if(lap == (MAX_LAPS))
            SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Essa é a última volta!");
    }

    else
        PlayerPlaySound(playerid, 1138, 0.0, 0.0, 0.0);

    if(lap > MAX_LAPS)
    {
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED);

        //Race::RemPodium(playerid, raceid, 0);
        game::Race[raceid][race::finisheds]++;

        RemovePlayerFromVehicle(playerid);
        Veh::Destroy(race::Player[playerid][race::vehicleid]);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Player::Spawn(playerid, true);

        if(game::Race[raceid][race::finisheds] >= 1 && game::Race[raceid][race::finisheds] <= 3)
        {
            SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Parabéns você terminou em {44ff66}%d| lugar{ffffff}, aguarde a corrida para receber seu prêmio.", game::Race[raceid][race::finisheds]);
        }
        else
            SendClientMessage(playerid, -1, "{ff5533}[ CORRIDA ] {ffffff}Infelizmente você não se classificou :( tente novamente para receber prêmios!");

        Game::SendMessageToAll(gameid, "{44ff66}[ CORRIDA ] {44ff66}%s {ffffff}terminou a corrida {44ff66}%s {ffffff}em {44ff66}%d| lugar", GetPlayerNameStr(playerid), game::Race[raceid][race::name], game::Race[raceid][race::finisheds]);

        new count = list_size(game::Race[raceid][race::podium]);

        if(game::Race[raceid][race::finisheds] >= count)
            Game[gameid][game::start_time] = 0;
        
        return 1;
    }

    Race::UpdatePodium(gameid);
    Race::UpdatePlayerCheck(playerid, lap, check);

    return 1;
}
