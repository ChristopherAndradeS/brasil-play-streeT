#include <YSI\YSI_Coding\y_hooks>


hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_PLAYING))return 1;

    new check = race::Player[playerid][race::checkid], lap = race::Player[playerid][race::lap];

    if(check == 0)
    {
        if(lap <= MAX_LAPS) lap++;
        else
        {
            //
        }
    }

    check += 1;

    if(check >= sizeof(gCheckpoints))
        check = 0;

    Race::UpdatePlayerCheck(playerid, laps, checkid);

    race::Player[playerid][race::checkid] = check;

    /* 

    Aqui deve fazer a logica de update dos checkpoint. Quando o jogador terminar antes da
    maquina de estados finalizar o game, deve remover o jogador do veículo, dar um Player::Spawn.
    
    Se o jogador terminar em 1, 2 ou 3, lugar enviar uma mensagem "Parabens voce terminou em Xº lugar, Aguarde a corrida para receber seu premio"
    Se não envie "Infelizmente voce nao se classificou :(, tente novamente para receber premios!"
    
    */
}