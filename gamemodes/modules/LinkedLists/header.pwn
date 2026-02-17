#define REGION_GRID_SIZE        (10)
#define REGION_COUNT            (100)
#define REGION_SIZE             (750.0)
#define WORLD_MIN               (-3750.0)
#define WORLD_MAX               (3750.0)
#define INVALID_REGION_ID       (-1)

new LinkedList:veh::Region[REGION_COUNT];
new LinkedList:pyr::Region[REGION_COUNT];

new STREAMER_TAG_AREA:Areas[REGION_COUNT];
