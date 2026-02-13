#include <YSI\YSI_Coding\y_hooks>

#define abs(%0)                                 (((%0) < 0)?(-(%0)):((%0)))

stock ClearChat(playerid, cells = 15)
{
    for(new i = 0; i < cells; i++)
    {
        #pragma unused i
        SendClientMessage(playerid, -1, " ");
    }
}

stock SetFlag(&flag, tag_binary) 
    flag |= tag_binary;

stock GetFlag(flag, tag_binary) 
    return (flag & tag_binary) ? 1 : 0;

stock ResetFlag(&flag, tag_binary) 
    flag &= ~tag_binary;

stock IsFlagSet(flag, tag_binary) 
    return (flag & tag_binary) ? 1 : 0;

stock ClearAllFlags(&flag) 
    return (flag = 0x00000000);

stock GetISODate(timestr[], len, HourGMT, MinuteGMT = 0)
{
    new year, month, day, hour, minute, second;
    TimestampToDate(gettime(), year, month, day, hour, minute, second, HourGMT);
    format(timestr, len, "%04d-%02d-%02dT%02d:%02d:%02d%c%02d:%02d",
    year, month, day, hour, minute, second, HourGMT > 0 ? '+' : '-', abs(HourGMT), MinuteGMT);
}

stock TimestampToDate(Timestamp, &year, &month, &day, &hour, &minute, &second, HourGMT, MinuteGMT = 0)
{
    // Ajuste de fuso horário
    Timestamp += (HourGMT * 3600) + (MinuteGMT * 60);

    second = Timestamp % 60;
    new t_minute = Timestamp / 60;
    minute = t_minute % 60;
    new t_hour = t_minute / 60;
    hour = t_hour % 24;

    // Algoritmo de Howard Hinnant para dias
    new days = t_hour / 24;
    
    // Ajuste de época: Hinnant utiliza 01/03/0000 como base
    // Dias entre 01/01/1970 e 01/03/0000 = 719468
    days += 719468;

    new era = (days >= 0 ? days : days - 146096) / 146097;
    new doe = days - era * 146097;                                  // Dia da era (0-146096)
    new yoe = (doe - doe/1460 + doe/36524 - doe/146096) / 365;      // Ano da era (0-399)
    new y = yoe + era * 400;
    new doy = doe - (365 * yoe + yoe/4 - yoe/100);                  // Dia do ano (0-365)
    new mp = (5 * doy + 2) / 153;                                   // Mês (0-11, sendo 0 = Março)
    
    day = doy - (153 * mp + 2) / 5 + 1;
    month = mp + (mp < 10 ? 3 : -9);
    year = y + (month <= 2 ? 1 : 0);
}

stock GetWeekDayFromTimestamp(timestamp, Hour_GMT = -3)
{
    // 86400 segundos em um dia
    // Adicionamos 4 dias ao cálculo porque 01/01/1970 foi Quinta-feira (4º dia da semana)
    // Se você quer que Domingo seja 0, Segunda 1, etc.
    
    new dayOfWeek = (((timestamp + (Hour_GMT * 3600)) / 86400) + 4) % 7;
    
    return dayOfWeek; 
    // Retorna: 0 = Domingo, 1 = Segunda, 2 = Terça... 6 = Sábado
}

stock GetTimestampString(string[64], timestamp, HourGMT = -3)
{
    new year, month, day, hour, minute, second;
    
    TimestampToDate(timestamp, year, month, day, hour, minute, second, HourGMT);
    format(string, 64, "%02d de %s de %04d as %02d:%02d:%02d", day, gMonths[month], year, hour, minute, second);
}

stock IsValidPlayerName(name[], &issue)
{        
    if(strlen(name) < 3 || strlen(name) > MAX_PLAYER_NAME)
    {
        issue = 2;
        return 0;
    }

    issue = 1;

    for(new i = 0; name[i]; i++)
    {
        switch(name[i])
        {
            case '\0': continue;
            case 32: name[i] = '_';
            case 48..57: continue;
            case 65..90: continue;
            case 95: continue;
            case 97..122: continue;
            default: return 0;
        }
    }

    issue = 0;

    return 1;
} 

stock RemoveGraphicAccent(str[])
{
    for(new i = 0; str[i] != '\0'; i++)
    {
        // Usamos o valor numérico do caractere para evitar erros de encoding no compilador
        switch(str[i])
        {
            case 0xE0..0xE3: str[i] = 'a'; // à á â ã
            case 0xC0..0xC3: str[i] = 'A'; // À Á Â Ã
            
            case 0xE8..0xEA: str[i] = 'e'; // è é ê
            case 0xC8..0xCA: str[i] = 'E'; // È É Ê
            
            case 0xEC..0xEE: str[i] = 'i'; // ì í î
            case 0xCC..0xCE: str[i] = 'I'; // Ì Í Î
            
            case 0xF2..0xF5: str[i] = 'o'; // ò ó ô õ
            case 0xD2..0xD5: str[i] = 'O'; // Ò Ó Ô Õ
            
            case 0xF9..0xFB: str[i] = 'u'; // ù ú û
            case 0xD9..0xDB: str[i] = 'U'; // Ù Ú Û
            
            case 0xE7: str[i] = 'c'; // ç
            case 0xC7: str[i] = 'C'; // Ç
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

stock Float:floatclamp(Float:value, Float:min, Float:max)
{
    new Float:clamped;

    if(value < min)
        clamped = min;
    else if(value > max)
        clamped = max;
    else
        clamped = value;

    return clamped;
}

stock GetPlayerIDByName(const name[])
{
    new tmp_name[MAX_PLAYER_NAME];
   
    foreach(new i : Player)
    {
        GetPlayerName(i, tmp_name);

        if(!isnull(name) && !isnull(tmp_name) && strcmp(tmp_name, name) == 0)
            return i;
    }

    return INVALID_PLAYER_ID;
}

stock GetVehicleNameByModel(modelid, vehname[], len = sizeof(vehname))
{ 
    if(modelid < 400 || modelid > 611)
        format(vehname, len, "Modelo Invalido");
    
    else 
        format(vehname, len, "%s", g_arrVehicleNames[modelid - 400]);
}

stock GetPlayerNameEx(playerid)
{
	new
		name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME - 1);
	return name;
}
