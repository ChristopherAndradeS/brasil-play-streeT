#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Compy::Mec[0][ofc::pX] = 1943.4880;
    Compy::Mec[0][ofc::pY] = -1810.5806;
    Compy::Mec[0][ofc::pZ] = 13.5663;

    Compy::Mec[0][ofc::pickup] = CreateDynamicPickup(19627, 0, 1943.4880, -1810.5806, 13.5663);

    format(str, 144, "[ {ff5599}OFICINA MECANICA{ffffff}]\nDigite {ff5599}/oficina");

    Compy::Mec[0][ofc::label] = CreateDynamic3DTextLabel(str, -1, 1943.4880, -1810.5806, 13.5663, 60.0);

    return 1;
}