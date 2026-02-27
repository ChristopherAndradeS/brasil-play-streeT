#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    new count;

    for(new row = 0; row < REGION_GRID_SIZE; row++)
    {
        for(new col = 0; col < REGION_GRID_SIZE; col++)
        {
            new regionid = (row * REGION_GRID_SIZE) + col;

            veh::Region[regionid] = linked_list_new();
            pyr::Region[regionid] = linked_list_new();
            
            new Float:min_x = WORLD_MIN + (float(col) * REGION_SIZE);
            new Float:min_y = WORLD_MIN + (float(row) * REGION_SIZE);
            new Float:max_x = min_x + REGION_SIZE;
            new Float:max_y = min_y + REGION_SIZE;

            Areas[regionid] = CreateDynamicRectangle(min_x, min_y, max_x, max_y);
            count++;
        }
    }

    printf("[ AREAS ]   %d areas globais de %.1fx%.1f (m) foram criadas com sucesso\n", count, REGION_SIZE, REGION_SIZE);
    printf("[ REGIONS ] %d regioes de jogadores foram criadas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de veiculos foram criadas com sucesso\n", count);

    return 1;
}
