#include <YSI\YSI_Coding\y_hooks>

#if defined ON_DEBUG_MODE

#else

hook OnGameModeInit()
{
    DC::LoadCountMaps = 0;
    DC::LoadCountVehicles = 0;
    DC::LoadCountRegions = 0;
    DC::LoadCountTextDraws = 0;
    DC::LoadCountNpcs = 0;
    DC::LoadCountOrgs = 0;
    DC::LoadEmbedSent = false;

    new 
        date[128]
    ;
    
    format(date, sizeof(date),
    "%02d de %s de %04d\n%02d:%02d:%02d (GMT %d)\n", 
    Server[srv::day], gMonths[Server[srv::month]],
    Server[srv::year], Server[srv::hour], Server[srv::minute], Server[srv::seconds],
    Server[srv::gmt]);

    new const field_name[][64] =
    {
        ":clock10: Horário:",
        ":information_source: Status:"
    };

    new field_value[2][128];

    format(field_value[0], 128, "%s", date);
    format(field_value[1], 128, "%s", ":green_circle: ***ONLINE***");

    new bool:finline[2] = {false, true};

    DC::SendCustomEmbedMsg
    (
        DC_CHANNEL_ID_SERVER_WARN,
        ":white_check_mark: Servidor ON\n",
        DC_THUMBNAIL_ICON, 0x55FF55, "",
        field_name, field_value, finline,
        "Sistema de Informação • Brasil Play StreeT",
        DC_FOOTER_ICON,
        2
    );

    return 1;
}

hook OnGameModeExit()
{
    new 
        date[128]
    ;

    format(date, sizeof(date),
        "%02d de %s de %04d\n%02d:%02d:%02d (GMT %d)\n", 
        Server[srv::day], gMonths[Server[srv::month]],
        Server[srv::year], Server[srv::hour], Server[srv::minute], Server[srv::seconds],
        Server[srv::gmt]);

    new const field_name[][64] =
    {
        ":clock10: Horário:",
        ":thinking: Motivo:",
        ":information_source: Status:"
    };

    new field_value[3][128];

    format(field_value[0], 128, "%s", date);
    format(field_value[1], 128, "%s", "Desligamento normal");
    format(field_value[2], 128, "%s", ":red_circle: ***OFFLINE***");

    new bool:finline[3] = {false, true, true};

    DC::SendCustomEmbedMsg
    (
        DC_CHANNEL_ID_SERVER_WARN,
        ":red_square: Servidor OFF\n",
        DC_THUMBNAIL_ICON, 0xFF5555, "",
        field_name, field_value, finline,
        "Sistema de Informação • Brasil Play StreeT",
        DC_FOOTER_ICON,
        3
    );

    return 1;
}

#endif
stock DC::SendLoadInitEmbed()
{
    if(DC::LoadEmbedSent) return 1;

    new const field_name[][64] =
    {
        ":map: Mapas",
        ":blue_car: Veiculos",
        ":world_map: Regioes",
        ":art: TextDraws",
        ":bust_in_silhouette: NPCs",
        ":shield: Organizacoes"
    };

    new field_value[6][128];
    format(field_value[0], 128, "%d mapas foram carregados", DC::LoadCountMaps);
    format(field_value[1], 128, "%d veiculos foram carregados", DC::LoadCountVehicles);
    format(field_value[2], 128, "%d regioes foram carregadas", DC::LoadCountRegions);
    format(field_value[3], 128, "%d textdraws foram carregadas", DC::LoadCountTextDraws);
    format(field_value[4], 128, "%d npcs foram carregados", DC::LoadCountNpcs);
    format(field_value[5], 128, "%d organizacoes foram carregadas", DC::LoadCountOrgs);

    new bool:finline[6] = {true, true, true, true, true, true};

    DC::SendCustomEmbedMsg
    (
        DC_CHANNEL_ID_CHAT_ADM,
        ":bar_chart: Carregamento de Entidades",
        DC_THUMBNAIL_ICON, 0x33AAFF,
        "Resumo do carregamento realizado na inicializacao do servidor.",
        field_name, field_value, finline,
        "Sistema de Informação • Brasil Play StreeT",
        DC_FOOTER_ICON,
        6
    );

    DC::LoadEmbedSent = true;
    return 1;
}
