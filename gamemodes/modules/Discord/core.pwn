stock DC::SendCustomEmbedMsg
(
const channel_name[], const title[], const thumb_icon[], color, const desc[],
const field_name[][], const field_value[][], const bool:finline[], 
const footer[], const footer_icon[], const fieldcount
)
{
    new DCC_Channel:channel = DCC_FindChannelById(channel_name);
    
    if(channel == DCC_INVALID_CHANNEL) return 0;

    new 
        DCC_Embed:embed = DCC_CreateEmbed()
    ;
    
    DCC_SetEmbedTitle(embed, title);
    DCC_SetEmbedDescription(embed, desc);
    DCC_SetEmbedThumbnail(embed, thumb_icon);
    DCC_SetEmbedColor(embed, color);

    for(new i = 0; i < fieldcount; i++)
        DCC_AddEmbedField(embed, field_name[i], field_value[i], finline[i]);
    
    DCC_SetEmbedFooter(embed, footer, footer_icon);

    DCC_SendChannelEmbedMessage(channel, embed);  

    return 1;  
}

stock DC::SendWarnMessage(const msg[])
{
    new DCC_Channel:channel = DCC_FindChannelById(DC_CHANNEL_ID_CHAT_ADM);
    
    if(channel == DCC_INVALID_CHANNEL) return 0;

    new str[512];
    format(str, 512, "> <:6371win11warningicon:1480412270151598180> <@&1472646753705787577>\n> ```%s```", msg);
    
    DCC_SendChannelMessage(channel, str);

    return 1;
}

stock DC::SendErrMessage(const msg[])
{
    new DCC_Channel:channel = DCC_FindChannelById(DC_CHANNEL_ID_CHAT_ADM);
    
    if(channel == DCC_INVALID_CHANNEL) return 0;

    new str[512];
    format(str, 512, "> <:3523win11erroicon:1480412302871101524> <@&1472646753705787577>\n> ```%s```", msg);
    
    DCC_SendChannelMessage(channel, str);

    return 1;
}