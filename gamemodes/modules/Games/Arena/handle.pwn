#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerDied(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid)) return 1;

    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid == INVALID_GAME_ID) return 1;
    if(Game[gameid][game::type] != GAME_TYPE_ARENA) return 1;

    Arena::RegisterDeath(playerid, killerid, reason);

    return 1;
}

hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid)) return 1;

    new gameid = game::Player[playerid][pyr::gameid];

    if(gameid == INVALID_GAME_ID) return 1;
    if(Game[gameid][game::type] != GAME_TYPE_ARENA) return 1;

    if(killerid == INVALID_PLAYER_ID && reason != WEAPON_DROWN && reason != WEAPON_COLLISION && reason != REASON_EXPLOSION)
    {
        printf("[ ARENA ] Morte suspeita barrada no OnPlayerDeath: %s (%d), motivo: %d", GetPlayerNameStr(playerid), playerid, _:reason);
        return 0;
    }

    return 1;
}
