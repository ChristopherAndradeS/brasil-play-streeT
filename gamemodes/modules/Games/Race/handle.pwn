#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING))
        return 1;

    new gameid = game::Player[playerid][pyr::gameid];
    new raceid = game::Player[playerid][pyr::raceid];

    if(gameid == INVALID_GAME_ID || raceid == INVALID_RACE_ID)
        return 1;

    new check = race::Player[playerid][race::checkid];
    new lap = race::Player[playerid][race::lap];

    check++;

    if(check >= sizeof(Race::gCheckpoints))
    {
        check = 0;
        lap++;
    }

    if(lap > MAX_LAPS)
    {
        DisablePlayerCheckpoint(playerid);
        ResetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING);
        SetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_FINISHED);
        Race::RemPodium(playerid, raceid, 0);
        Race::AddPodium(playerid, raceid);

        RemovePlayerFromVehicle(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        Player::Spawn(playerid);

        new place = Race::GetPodiumPlace(raceid, playerid);

        if(place >= 1 && place <= 3)
            SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Parabéns você terminou em {44ff66}%dº lugar{ffffff}, aguarde a corrida para receber seu prêmio.", place);
        else
            SendClientMessage(playerid, -1, "{ff5533}[ CORRIDA ] {ffffff}Infelizmente você não se classificou :( tente novamente para receber prêmios!");

        if(Game[gameid][game::players_count] > 0)
        {
            new finished;

            for(new i = 0; i < Game[gameid][game::max_players]; i++)
            {
                new targetid = Game[gameid][game::players][i];

                if(targetid != INVALID_PLAYER_ID && GetFlag(game::Player[targetid][pyr::flags], FLAG_PLAYER_FINISHED))
                    finished++;
            }

            if(finished >= Game[gameid][game::players_count])
                Game[gameid][game::start_time] = 0;
        }

        return 1;
    }

    Race::UpdatePlayerCheck(playerid, lap, check);
    return 1;
}
