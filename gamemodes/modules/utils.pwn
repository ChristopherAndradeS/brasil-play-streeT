#include <YSI\YSI_Coding\y_hooks>

public KickDelay(playerid, const msg[], GLOBAL_TAG_TYPES:...) 
{
    inline const KickPlayer(pid)
    {
        Kick(pid);
    }

    SendClientMessage(playerid, -1 , FCOLOR_ERRO "[ KICK ] {ffffff}%s", msg, ___(2));
    new timerid = Timer_CreateCallback(using inline KickPlayer<i>, 750, 1);
    Timer_KillCallback(timerid);
}

stock ClearChat(playerid, cells = 15)
{
    for(new i = 0; i < cells; i++)
    {
        #pragma unused i
        SendClientMessage(playerid, -1, " ");
    }
}

stock GetTimestampString(string[64], timestamp, HourGMT = -3)
{
    new year, month, day, hour, minute, second;
    
    TimestampToDate(timestamp, year, month, day, hour, minute, second, HourGMT);
    format(string, 64, "%02d de %s de %04d às %02d:%02d:%02d", day, gMonths[month], year, hour, minute, second);
}

stock IsValidPlayerName(name[], &issue)
{        
    if(strlen(name) < 3 || strlen(name) > 20)
    {
        issue = 3;
        return 0;
    }

    issue = 1;

    for(new i = 0; name[i]; i++)
    {
        switch(name[i])
        {
            case '\0': continue;
            case 32: name[i] = '_';
            case 48..57:
            {
                issue = 2;
                return 0;
            }
            case 65..90: continue;
            case 95: continue;
            case 97..122: continue;
            default: return 0;
        }
    }

    issue = 0;

    return 1;
} 

stock HasGraphicAccent(const str[])
{
    for (new i = 0; str[i] != '\0'; i++)
        if(str[i] > 127)
            return 1;

    return 0;
}

stock RemoveGraphicAccent(str[])
{
    for(new i = 0; str[i] != '\0'; i++)
    {
        switch(str[i])
        {
            case 'á', 'à', 'â', 'ã': str[i] = 'a';
            case 'Á', 'À', 'Â', 'Ã': str[i] = 'A';
     
            case 'é', 'è', 'ê': str[i] = 'e';
            case 'É', 'È', 'Ê': str[i] = 'E';

            case 'í', 'ì', 'î': str[i] = 'I';
            case 'Í', 'Ì', 'Î': str[i] = 'i';

            case 'ó', 'ò', 'ô', 'õ': str[i] = 'o';
            case 'Ó', 'Ò', 'Ô', 'Õ': str[i] = 'O';

            case 'ú', 'ù', 'û': str[i] = 'u';
            case 'Ú', 'Ù', 'Û': str[i] = 'U';

            case 'ç': str[i] = 'c';
            case 'Ç': str[i] = 'C';
        }
    }
}

stock norm_hash(hash)
{
    if(hash < 0)
        hash = -hash;
    return hash;
}

stock hashname(const name[])
{
    new hash = 0;

    for(new i = 0; name[i]; i++)
    {
        hash = hash * 131 ^ name[i];
    }

    return hash;
}
