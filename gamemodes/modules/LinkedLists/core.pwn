stock GetRegionFromXY(Float:x, Float:y)
{
    if(x < WORLD_MIN || x > WORLD_MAX || y < WORLD_MIN || y > WORLD_MAX) return INVALID_REGION_ID;

    new col = floatround((x - WORLD_MIN) / REGION_SIZE, floatround_floor);
    new row = floatround((y - WORLD_MIN) / REGION_SIZE, floatround_floor);

    if(col >= REGION_GRID_SIZE) col = REGION_GRID_SIZE - 1;
    if(row >= REGION_GRID_SIZE) row = REGION_GRID_SIZE - 1;

    return (row * REGION_GRID_SIZE) + col;
}

stock GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
        if(Areas[regionid] == areaid)
            return regionid;

    return INVALID_REGION_ID;
}

stock GetRegionCellX(regionid)
    return (regionid % REGION_GRID_SIZE);

stock GetRegionCellY(regionid)
    return (regionid / REGION_GRID_SIZE);
