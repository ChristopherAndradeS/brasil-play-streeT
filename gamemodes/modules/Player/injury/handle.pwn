#include <YSI/YSI_Coding/y_hooks>

forward OnPlayerInjury(playerid);

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

public OnPlayerInjury(playerid)
{
    new tick = Player[playerid][pyr::death_tick] - GetTickCount();

    if(!IsValidPlayer(playerid))
    {
        Player::KillTimer(playerid, pyr::TIMER_INJURY);
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
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
        Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        
        Travel::ShowTDForPlayer(playerid, 
        "A emergencia chegou e~n~Voce foi para o hospital...",
        1182.2079 + RandomFloatMinMax(-2.0, 2.0), 
        -1323.2695 + RandomFloatMinMax(-2.0, 2.0), 13.5798, 270.0);
        
        Player::KillTimer(playerid, pyr::TIMER_INJURY);
        DestroyDynamic3DTextLabel(Player[playerid][pyr::deathtag]);
        Player[playerid][pyr::deathtag] = INVALID_3DTEXT_ID;

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

    return 1;
}

public OnPlayerReviveFinished(playerid, targetid)
{
    Player::KillTimer(playerid, pyr::TIMER_RESUSCITATION);

    if(!IsValidPlayer(playerid) || !IsValidPlayer(targetid))
    {
        if(IsValidPlayer(playerid))
        {
            ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
            ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
            Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        }

        if(IsValidPlayer(targetid))
        {
            ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
            Player[targetid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        }

        return 1;
    }

    if(!GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED))
    {
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid, SYNC_ALL);

        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

        Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        Player[targetid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        return 1;
    }

    Player::KillTimer(targetid, pyr::TIMER_INJURY);

    if(IsValidDynamic3DTextLabel(Player[targetid][pyr::deathtag]))
        DestroyDynamic3DTextLabel(Player[targetid][pyr::deathtag]);
    Player[targetid][pyr::deathtag] = INVALID_3DTEXT_ID;

    Player[targetid][pyr::health] = 50.0;
    SetPlayerHealth(targetid, 50.0);

    ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED);
    ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
    ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

    Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
    Player[targetid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;

    TogglePlayerControllable(targetid, true);
    TogglePlayerControllable(playerid, true);

    ClearAnimations(targetid, SYNC_ALL);
    ClearAnimations(playerid, SYNC_ALL);

    SendClientMessage(playerid, -1, "{33ff99}[ SOS ] {ffffff}Reavivamento concluído com sucesso.");
    SendClientMessage(targetid, -1, "{33ff99}[ SOS ] {ffffff}Você foi reanimado e está estável.");

    return 1;
}
