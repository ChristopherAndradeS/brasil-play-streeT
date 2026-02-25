#include <YSI\YSI_Coding\y_hooks>

hook OnPlayerInjury(playerid, killerid, WEAPON:reason)
{
    new gameid = game::Player[playerid][pyr::gameid];

    if(!IsValidPlayer(playerid) || gameid == INVALID_GAME_ID || Game[gameid][game::type] != GAME_TYPE_ARENA) return 1;
    
    if(!map_has_key(Arena[gameid][arena::participant], playerid)) return 0;

    Arena::RegisterDeath(playerid, killerid, reason);

    Game::SendMessageToAll(gameid, "{ff5577}[ ARENA ] {ffffff}%s {ff5577}matou {ffffff}%s", GetPlayerNameStr(killerid), GetPlayerNameStr(playerid));

    new victim[E_ARENA_SEAT];
    map_get_arr(Arena[gameid][arena::participant], playerid, victim);

    victim[arena::respawn_timer] = SetTimerEx("ARN_DoRespawn", ARENA_RESPAWN_TIME_MS, false, "ii", playerid, gameid);

    map_set_arr(Arena[gameid][arena::participant], playerid, victim);

    TogglePlayerSpectating(playerid, true);
    PlayerSpectatePlayer(playerid, killerid);

    return 1;
}
