#include <YSI/YSI_Coding/y_hooks>

forward OnPlayerInjury(playerid, killerid, WEAPON:reason);

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
{
    if(!IsValidPlayer(damagedid)) return 1;

    if(GetFlag(Player[damagedid][pyr::flags], FLAG_PLAYER_INJURED))  
    {
        GameTextForPlayer(playerid, "~r~~h~OVERKILL", 1000, 4);
        return -1;
    }

    if(GetFlag(Player[damagedid][pyr::flags], FLAG_PLAYER_INVUNERABLE)) return -1;

    if(org::Player[playerid][pyr::orgid] == org::Player[damagedid][pyr::orgid])
    {
        GameTextForPlayer(playerid, "~r~~h~FOGO AMIGO", 1000, 3);
        return -1;
    }

    Player::UpdateDamage(damagedid, playerid, amount, weaponid, bodypart);
    
    return 1;
}

hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
    if(!IsValidPlayer(playerid)) return 1;

    if(killerid == INVALID_PLAYER_ID) 
    {
        if(reason != WEAPON_DROWN && reason != WEAPON_COLLISION && reason != REASON_EXPLOSION)
        {
            printf("[ PVP ] Morte suspeita: %s (ID: %d) morreu sem assassino. Motivo: %d", GetPlayerNameStr(playerid), playerid, _:reason);
            return 0;
        }
    }

    else
    {
        printf("[ PVP ] Morte suspeita: %s (ID: %d) morreu por %s (ID: %d) Sem validação do SERVER.", GetPlayerNameStr(playerid), playerid, GetPlayerNameStr(killerid), killerid);
        printf("[ PVP ] Motivo: %d", _:reason);  
    }

    return 1;
}

hook OnPlayerInjury(playerid, killerid, WEAPON:reason)
{
    #pragma unused reason
    
    if(!IsValidPlayer(playerid) && !IsValidPlayer(killerid)) return 1;

    if(GetFlag(game::Player[playerid][pyr::flags], FLAG_PLAYER_INGAME))return 1;
    
    inline update()
    {
        new tick = Player[playerid][pyr::death_tick] - GetTickCount();

        if(!IsValidPlayer(playerid))
        {
            Player::KillTimer(playerid,pyr::TIMER_INJURY);
            DestroyDynamic3DTextLabel(Player[playerid][pyr::deathtag]);
            Player[playerid][pyr::deathtag] = INVALID_3DTEXT_ID;
            return 1;
        }

        new str[256];

        if(tick <= 0)
        {
            Player[playerid][pyr::health] = 50.0;
            SetPlayerHealth(playerid, 50.0);
            ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED);
            //ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
            
            Travel::ShowTDForPlayer(playerid, 
            "A emergencia chegou e~n~Voce foi para o hospital...",
            1182.2079 + RandomFloatMinMax(-2.0, 2.0), 
            -1323.2695 + RandomFloatMinMax(-2.0, 2.0), 13.5798, 270.0);
            
            Player::KillTimer(playerid,pyr::TIMER_INJURY);
            DestroyDynamic3DTextLabel(Player[playerid][pyr::deathtag]);
            Player[playerid][pyr::deathtag] = INVALID_3DTEXT_ID;

            //CallLoca

            return 1;
        }

        new second = (tick % 60000) / 1000, minute = tick / 60000;

        format(str, 256, 
        "[ {ff4444}FERIDO {ffffff}]\n\
        Use {ff4444}'F' {ffffff}ou {ff4444}/rev {ffffff}para socorrer\n\
        {ff4444}Emergencia {ffffff}chegara em: {ff4444}%02d{ffffff}:{ff4444}%02d", 
        minute, second);

        if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED))
        {
            Player[playerid][pyr::deathtag] = CreateDynamic3DTextLabel(str, -1, 0.0, 0.0, -0.3, 60.0, .attachedplayer = playerid, .testlos = 1);
            SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED);
        }

        else
        {
            UpdateDynamic3DTextLabelText(Player[playerid][pyr::deathtag], -1, str);

            GameTextForPlayer(playerid, 
            "~r~~h~Emergencia chegara em:~n~~w~%02d~r~~h~:~w~%02d", 
            900, 3, minute, second);
        }

        foreach (new i : StreamedPlayer[playerid])
        {
            Streamer_Update(i, STREAMER_TYPE_3D_TEXT_LABEL);
        }
    }
    
    TogglePlayerControllable(playerid, false);

    ClearAnimations(playerid, SYNC_ALL);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_OTHER);
    ApplyAnimation(playerid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_ALL);

    new time_sos = floatround(GetPlayerDistanceFromPoint(playerid, 1182.2079, -1323.2695, 13.5798) / 0.012);
    Player[playerid][pyr::death_tick] = GetTickCount() + time_sos;
    
    new count = floatround(time_sos / 1000.0, floatround_ceil);
    
    pyr::Timer[playerid][pyr::TIMER_INJURY] = Timer_CreateCallback(using inline update, 1000, count);

    return 1;
}
