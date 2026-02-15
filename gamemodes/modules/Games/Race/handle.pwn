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
    {
        inline confirm_quit_dialog(playerid1, dialogid, response, listitem, string:inputtext[])
        {
            #pragma unused playerid1, dialogid, listitem, inputtext

            if(!response)
                return PutPlayerInVehicle(playerid, race::Player[playerid][race::vehicleid], 0);
            
            new gameid = game::Player[playerid][pyr::gameid];
            Race::EliminatePlayer(playerid, gameid);
            
            return 1;
        }

        Dialog_ShowCallback(playerid, using inline confirm_quit_dialog, DIALOG_STYLE_MSGBOX, 
        "{ff5533}ATENÇÃO", "{ff9933}[ ! ] {ffffff}Você tem certeza que deseja {ff9933}sair da corrida?", "Sim", "Não");
    }

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
        Player::Spawn(playerid);

        if(game::Race[raceid][race::finisheds] >= 1 && game::Race[raceid][race::finisheds] <= 3)
        {
            SendClientMessage(playerid, -1, "{44ff66}[ CORRIDA ] {ffffff}Parabéns você terminou em {44ff66}%d| lugar{ffffff}, aguarde a corrida para receber seu prêmio.", game::Race[raceid][race::finisheds]);
        }
        else
            SendClientMessage(playerid, -1, "{ff5533}[ CORRIDA ] {ffffff}Infelizmente você não se classificou :( tente novamente para receber prêmios!");

        Game::SendMessageToAll(gameid, "{44ff66}[ CORRIDA ] {44ff66}%s {ffffff}terminou a corrida {44ff66}%s {ffffff}em {44ff66}%d| lugar", GetPlayerNameStr(playerid), Game[gameid][game::name], game::Race[raceid][race::finisheds]);

        new count = list_size(game::Race[raceid][race::podium]);

        if(game::Race[raceid][race::finisheds] >= count)
            Game[gameid][game::start_time] = 0;
        
        return 1;
    }

    Race::UpdatePodium(gameid);
    Race::UpdatePlayerCheck(playerid, lap, check);

    return 1;
}
