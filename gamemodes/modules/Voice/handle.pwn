#include <YSI\YSI_Coding\y_hooks>

new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };

public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid, SV_UINT:keyid) 
{
    if (keyid == 0x42 && lstream[playerid]) SvAttachSpeakerToStream(lstream[playerid], playerid);
    //if (keyid == 0x5A && gstream) SvAttachSpeakerToStream(gstream, playerid);
    return 1;
}

public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid, SV_UINT:keyid)
{
    if (keyid == 0x42 && lstream[playerid]) SvDetachSpeakerFromStream(lstream[playerid], playerid);
    //if (keyid == 0x5A && gstream) SvDetachSpeakerFromStream(gstream, playerid);
    return 1;
}

hook OnPlayerConnect(playerid)
{
    if(SvGetVersion(playerid) == SV_NULL)
        SendClientMessage(playerid, -1, "{ff3333}[ VOICE ] {ffffff}Não foi possível localizar o plugin sampvoice.");
    
    else if (SvHasMicro(playerid) == SV_FALSE)
        SendClientMessage(playerid, -1, "{ff9933}[ VOICE ] {ffffff}Não foi possível identificar seu microfone.");
    
    else if ((lstream[playerid] = SvCreateDLStreamAtPlayer(70.0, SV_INFINITY, playerid, 0xFF8888FF, "[ LOCAL ]")))
    {
        SendClientMessage(playerid, -1, "{33ff33}[ VOICE ] {ffffff}Seu microfone foi encontrado com {33ff33}sucesso.");
        
        if(IsPlayerUsingOfficialClient(playerid))
            SendClientMessage(playerid, -1, "{33ff33}[ VOICE ] {ffffff}Aperte Tecla {33ff33}'B' {ffffff}para falar no chat local.");
        
        SvAddKey(playerid, 0x42);
    }

    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    if(lstream[playerid])
    {
        SvDetachListenerFromStream(lstream[playerid], playerid);
        SvDetachSpeakerFromStream(lstream[playerid], playerid);
        SvDeleteStream(lstream[playerid]);
        lstream[playerid] = SV_NULL;
    }

    return 1;
}