#define DC_CHANNEL_ID_SERVER_WARN   "1480405300694483151"
#define DC_CHANNEL_ID_CHAT_ADM      "1472647164470624402"
#define DC_THUMBNAIL_ICON           "https://cdn.discordapp.com/avatars/1471999192044933140/037708b10ce6de6ee9797642e669db1f.png?size=2048"
#define DC_FOOTER_ICON              DC_THUMBNAIL_ICON

new
    DC::LoadCountMaps,
    DC::LoadCountVehicles,
    DC::LoadCountRegions,
    DC::LoadCountTextDraws,
    DC::LoadCountNpcs,
    DC::LoadCountOrgs
;

new bool:DC::LoadEmbedSent;

forward DC::SendLoadInitEmbed();
