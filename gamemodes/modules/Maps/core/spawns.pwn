#include <YSI\YSI_Coding\y_hooks>

#define Ferris::			    FRS_
#define frs::			        frs_

#define NUM_FERRIS_CAGES        10
#define FERRIS_WHEEL_ID         18877
#define FERRIS_CAGE_ID          18879
#define FERRIS_BASE_ID          18878
#define FERRIS_DRAW_DISTANCE    300.0
#define FERRIS_WHEEL_SPEED      0.8
#define FERRIS_WHEEL_Z_ANGLE  	90.0

new const Float:gFerrisOrigin[3] = {848.020751, -1849.283203, 24.885394};

new const Float:gFerrisCageOffsets[NUM_FERRIS_CAGES][3] = 
{
    {0.0699, 0.0600, -9.7500},
    {-6.9100, -0.0899, -7.5000},
    {-11.1600, -0.0399, -1.6300},
    {-11.1600, -0.0399, 5.6499},
    {-6.9100, -0.0899, 11.4799},
    {0.0699, 0.0600, 13.7500},
    {7.0399, -0.0200, 11.3600},
    {11.1600, 0.0000, 5.6499},
    {11.1600, 0.0000, -1.6300},
    {6.9599, 0.0100, -7.5000}
};

enum E_MAP_FERRIS
{
    STREAMER_TAG_OBJECT:frs::wheelid,
    STREAMER_TAG_OBJECT:frs::baseid,
    STREAMER_TAG_OBJECT:frs::cage[NUM_FERRIS_CAGES],
    frs::step
}

new Ferris[E_MAP_FERRIS];

forward UpdateWheelsTarget();

hook OnGameModeInit()
{	
	Ferris[frs::wheelid] = CreateDynamicObject(6298, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2],
	0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, -1, -1, -1, 300.0, FERRIS_DRAW_DISTANCE);

    Ferris[frs::baseid] = CreateDynamicObject(6461, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2],
	0.0, 0.0, FERRIS_WHEEL_Z_ANGLE + 90.0, -1, -1, -1, 300.0, FERRIS_DRAW_DISTANCE);

    for(new i = 0; i < NUM_FERRIS_CAGES; i++)
    {
        Ferris[frs::cage][i] = CreateDynamicObject(FERRIS_CAGE_ID, 
        gFerrisOrigin[0] + gFerrisCageOffsets[i][1], 
        gFerrisOrigin[1] + gFerrisCageOffsets[i][0],
        gFerrisOrigin[2] + gFerrisCageOffsets[i][2],
	  	0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, -1, -1, -1, 300.0, FERRIS_DRAW_DISTANCE);
    }

    SetTimer("UpdateWheelsTarget", 12 * 1000, true);

	return 1;
}

hook OnGameModeExit()
{
    DestroyDynamicObject(Ferris[frs::wheelid]);
    DestroyDynamicObject(Ferris[frs::baseid]);

    for(new i = 0; i < NUM_FERRIS_CAGES; i++)
        DestroyDynamicObject(Ferris[frs::cage][i]);
	
	return 1;
}

public UpdateWheelsTarget()
{
    new idx = 0;

    for(new i = 0; i < NUM_FERRIS_CAGES; i++)
    {
        idx = i + Ferris[frs::step];
        
        if(idx >= NUM_FERRIS_CAGES) idx = (idx % NUM_FERRIS_CAGES);

        MoveDynamicObject(Ferris[frs::cage][i], 
        gFerrisOrigin[0] + gFerrisCageOffsets[idx][1], 
        gFerrisOrigin[1] + gFerrisCageOffsets[idx][0], 
        gFerrisOrigin[2] + gFerrisCageOffsets[idx][2], FERRIS_WHEEL_SPEED);
	}

    Ferris[frs::step] += 1;

    if(Ferris[frs::step] >= NUM_FERRIS_CAGES) Ferris[frs::step] = 0;
}

stock Spawn::RemoveGTAObjects(playerid)
{
    RemoveBuildingForPlayer(playerid, 638, 852.531, -1886.859, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 638, 820.585, -1860.089, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 638, 852.531, -1855.109, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 820.281, -1892.729, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 852.609, -1897.020, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 852.609, -1893.089, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 820.281, -1850.209, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 820.281, -1854.150, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 852.609, -1864.880, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1280, 852.609, -1860.949, 12.234, 0.250);
    RemoveBuildingForPlayer(playerid, 1461, 820.789, -1889.920, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1461, 852.734, -1883.349, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1461, 852.734, -1889.839, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1461, 820.789, -1857.160, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1461, 852.734, -1851.869, 12.539, 0.250);
    RemoveBuildingForPlayer(playerid, 1281, 821.812, -1879.920, 12.617, 0.250);
    RemoveBuildingForPlayer(playerid, 1281, 824.156, -1874.300, 12.617, 0.250);
    RemoveBuildingForPlayer(playerid, 1281, 821.812, -1868.979, 12.617, 0.250);
    RemoveBuildingForPlayer(playerid, 1231, 852.210, -1843.979, 14.539, 0.250);
    RemoveBuildingForPlayer(playerid, 792, 851.796, -1848.900, 12.171, 0.250);
}

stock Spawn::LoadMap()
{
    new tmpobjid;
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 11.621517, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 11.621517, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 11.921517, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 11.921517, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 12.221515, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 12.221515, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 12.521515, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 12.521515, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 12.821516, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 12.821516, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 13.121518, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 13.121518, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 13.421518, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 13.421518, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 13.721516, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 13.721516, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 14.021515, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 14.021515, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 14.321516, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 14.321516, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.017639, -1827.203247, 14.621518, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.617797, -1827.203247, 14.621518, 0.000000, 0.000022, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.003417, 14.921518, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 821.817749, -1827.403198, 14.921518, 0.000022, 0.000007, 89.999900, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.197753, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 822.197753, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.497680, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 822.497680, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 822.797729, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 822.797729, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 823.097656, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 823.097656, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 823.397766, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 823.397766, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 823.697692, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 823.697692, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 823.997741, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 823.997741, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 824.297668, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 824.297668, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 824.597778, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 824.597778, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 824.897705, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 824.897705, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 825.197753, -1827.003417, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 825.197753, -1827.403320, 14.951639, 89.999992, 171.967315, -81.967315, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 825.497680, -1827.203369, 15.151468, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 825.497680, -1827.203369, 14.751688, 0.000014, -90.000015, 179.999755, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 825.787902, -1827.003417, 14.951639, 89.999992, 175.964019, -85.963996, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 825.787902, -1827.403320, 14.951639, 89.999992, 175.964019, -85.963996, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.087829, -1827.203369, 15.151468, 0.000014, -90.000022, 179.999710, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.087829, -1827.203369, 14.751688, 0.000014, -90.000022, 179.999710, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.387878, -1827.003417, 14.951639, 89.999992, 175.964019, -85.963996, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.387878, -1827.403320, 14.951639, 89.999992, 175.964019, -85.963996, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.687805, -1827.203369, 15.151468, 0.000014, -90.000022, 179.999710, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.687805, -1827.203369, 14.751688, 0.000014, -90.000022, 179.999710, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.403198, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.403198, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.403198, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.403198, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.403198, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.727539, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 826.327697, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 826.527648, -1827.003417, 14.921518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.097106, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.697265, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.003417, 14.921518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 841.897216, -1827.403198, 14.921518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.277221, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 842.277221, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.577148, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 842.577148, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 842.877197, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 842.877197, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 843.177124, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 843.177124, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 843.477233, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 843.477233, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 843.777160, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 843.777160, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 844.077209, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 844.077209, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 844.377136, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 844.377136, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 844.677246, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 844.677246, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 844.977172, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 844.977172, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 845.277221, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 845.277221, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 845.577148, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 845.577148, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 845.867370, -1827.003417, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 845.867370, -1827.403320, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.167297, -1827.203369, 15.151468, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.167297, -1827.203369, 14.751688, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.467346, -1827.003417, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.467346, -1827.403320, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.767272, -1827.203369, 15.151468, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.767272, -1827.203369, 14.751688, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 11.621517, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 11.621517, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 11.921517, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.403198, 11.921517, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 12.221515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 12.221515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 12.521515, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.403198, 12.521515, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 12.821516, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 12.821516, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 13.121518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.403198, 13.121518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 13.421518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 13.421518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 13.721516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.403198, 13.721516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 14.021515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 14.021515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 14.321516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.403198, 14.321516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.807006, -1827.203247, 14.621518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 846.407165, -1827.203247, 14.621518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 846.607116, -1827.003417, 14.921518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 11.621517, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 11.921517, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 12.221515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 12.521515, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 12.821516, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 13.121518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 13.421518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 13.721516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 14.021515, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 14.321516, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.097106, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.697265, -1827.203247, 14.621518, 0.000000, 0.000037, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.003417, 14.921518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 831.897216, -1827.403198, 14.921518, 0.000037, 0.000007, 89.999855, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.277221, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 832.277221, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.577148, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 832.577148, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 832.877197, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 832.877197, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 833.177124, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 833.177124, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 833.477233, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 833.477233, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 833.777160, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 833.777160, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 834.077209, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 834.077209, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 834.377136, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 834.377136, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 834.677246, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 834.677246, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 834.977172, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 834.977172, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 835.277221, -1827.003417, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 835.277221, -1827.403320, 14.951639, 89.999992, 177.979522, -87.979476, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 835.577148, -1827.203369, 15.151468, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 835.577148, -1827.203369, 14.751688, 0.000014, -90.000030, 179.999664, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 835.867370, -1827.003417, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 835.867370, -1827.403320, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.167297, -1827.203369, 15.151468, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.167297, -1827.203369, 14.751688, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.467346, -1827.003417, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.467346, -1827.403320, 14.951639, 89.999992, 178.989471, -88.989402, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.767272, -1827.203369, 15.151468, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.767272, -1827.203369, 14.751688, 0.000014, -90.000038, 179.999618, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 11.621517, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 11.621517, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 11.921517, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.403198, 11.921517, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 12.221515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 12.221515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 12.521515, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.403198, 12.521515, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 12.821516, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 12.821516, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 13.121518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.403198, 13.121518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 13.421518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 13.421518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 13.721516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.403198, 13.721516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 14.021515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 14.021515, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 14.321516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.403198, 14.321516, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.807006, -1827.203247, 14.621518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1946, 836.407165, -1827.203247, 14.621518, 0.000000, 0.000051, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFFFFFFFF, 0);
    tmpobjid = CreateDynamicObject(1946, 836.607116, -1827.003417, 14.921518, 0.000051, 0.000007, 89.999809, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 833.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 833.264648, -1864.761596, 13.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19445, 834.349121, -1863.308715, 11.067187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19789, 833.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 833.264648, -1864.761596, 15.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 837.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 831.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 831.264648, -1864.761596, 15.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 831.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 831.264648, -1864.761596, 14.349308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19445, 830.139099, -1865.049194, 12.667187, 180.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19789, 833.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 832.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 832.264648, -1864.761596, 14.349308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 837.264648, -1864.761596, 15.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 837.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 837.264648, -1864.761596, 13.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 837.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 829.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 828.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 827.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 835.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 836.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19445, 834.349121, -1866.738647, 11.067187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19789, 827.264648, -1864.761596, 13.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 827.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19445, 825.158813, -1865.049194, 8.007184, 270.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19789, 828.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19426, 839.648193, -1863.848022, 11.067187, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.300842, -1864.537719, 11.067187, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.674072, -1866.199584, 11.067187, 0.000035, -0.000074, 133.499816, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.327331, -1865.579589, 11.067187, 0.000035, -0.000074, 133.499816, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 834.349121, -1865.049194, 12.667187, 180.000000, 90.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19789, 829.264648, -1864.761596, 14.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 829.264648, -1864.761596, 15.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 829.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 828.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 827.264648, -1864.761596, 16.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19445, 830.039123, -1863.308715, 11.067187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 830.039123, -1866.719238, 11.067187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 831.280456, -1864.196411, 12.667188, 180.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 837.605834, -1865.814941, 12.667188, 180.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 838.315734, -1865.114746, 12.667188, 180.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 837.995605, -1865.384765, 12.667188, 180.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 837.995605, -1864.654907, 12.667188, 180.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 838.290832, -1864.983764, 12.667188, 180.000000, 90.000000, 34.199993, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 838.405639, -1865.315185, 12.667188, 180.000000, 90.000000, 16.799991, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.170104, -1864.661376, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.046630, -1864.777954, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.923156, -1864.894775, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.850524, -1864.963623, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 838.942565, -1865.822143, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.029724, -1865.739746, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.312988, -1865.472167, 10.917186, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "black64", 0x00000000);
    tmpobjid = CreateDynamicObject(18656, 853.126342, -1873.934448, 10.156868, 45.400001, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(18656, 819.874572, -1873.934448, 10.241737, 45.399993, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19527, 834.273315, -1834.866210, 10.538399, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 835.264648, -1864.761596, 13.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 835.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(19789, 836.264648, -1864.761596, 12.849308, -0.000007, 0.000000, -89.999977, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 9525, "boigas_sfw", "GEwhite1_64", 0x00000000);
    SetDynamicObjectMaterialText(tmpobjid, 0, "None", 10, "Arial", 20, 0, 0x00000000, 0xFF0DF205, 0);
    tmpobjid = CreateDynamicObject(1256, 820.378417, -1853.117065, 12.497184, 0.000000, -0.000007, 179.999847, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "BPS", OBJECT_MATERIAL_SIZE_512x256, "Arial", 160, 1, -1, 0xFF0DF205, 1);
    tmpobjid = CreateDynamicObject(1256, 820.378417, -1858.187255, 12.497184, 0.000000, -0.000007, 179.999847, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterialText(tmpobjid, 0, "BPS", OBJECT_MATERIAL_SIZE_512x256, "Arial", 160, 1, -1, 0xFF0DF205, 1);
    tmpobjid = CreateDynamicObject(19123, 834.343017, -1835.101684, 10.929061, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 19297, "matlights", "invisible", 0x00000000);
    tmpobjid = CreateDynamicObject(19123, 838.963195, -1863.500976, 13.149060, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 19297, "matlights", "invisible", 0x00000000);
    tmpobjid = CreateDynamicObject(19123, 825.473083, -1863.500976, 13.149060, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 19297, "matlights", "invisible", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 830.039123, -1863.308715, 7.567187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 830.039123, -1866.719238, 7.567187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 834.349121, -1866.738647, 7.567187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.674072, -1866.199584, 7.567187, 0.000035, -0.000074, 133.499816, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.327331, -1865.579589, 7.567187, 0.000035, -0.000074, 133.499816, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 840.300842, -1864.537719, 7.567187, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19426, 839.648193, -1863.848022, 7.567187, 0.000004, 359.999938, 43.399986, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    tmpobjid = CreateDynamicObject(19445, 834.349121, -1863.308715, 7.567187, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // CreateDynamicObject(6298, 848.020751, -1849.283203, 24.735393, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18877, 848.020751, -1849.283203, 26.785394, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18878, 848.020751, -1849.283203, 26.785394, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1849.359497, 15.381015, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1842.449096, 17.521020, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1838.029663, 23.301027, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1838.179565, 30.531026, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1842.349609, 36.341022, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1849.200195, 38.571010, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1855.980957, 36.351005, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1860.301391, 30.391014, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    // CreateDynamicObject(18879, 847.995605, -1858.671386, 20.011011, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00);     
}
