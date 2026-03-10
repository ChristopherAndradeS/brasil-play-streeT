#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    /* GAS STATION 1 */
    Compy::Gas[0][0][gas::pX] = 1944.5725;
    Compy::Gas[0][1][gas::pX] = 1938.5725;
    Compy::Gas[0][0][gas::pY] = Compy::Gas[0][1][gas::pY] = -1772.6949;
    Compy::Gas[0][0][gas::pZ] = Compy::Gas[0][1][gas::pZ] = 13.55;

    Compy::Gas[0][0][gas::pickup] = CreateDynamicPickup(19621, 0, 1944.5725, -1772.6949, 13.55);
    Compy::Gas[0][1][gas::pickup] = CreateDynamicPickup(19621, 0, 1938.5725, -1772.6949, 13.55);
    
    new str[144];
    format(str, 144, "[ {ff9933}POSTO DE GASOLINA {ffffff}]\nDigite {ff9933}/abastecer");

    Compy::Gas[0][0][gas::label] = CreateDynamic3DTextLabel(str, -1, 1944.5725, -1772.6949, 13.55, 60.0);
    Compy::Gas[0][1][gas::label] = CreateDynamic3DTextLabel(str, -1, 1938.5725, -1772.6949, 13.55, 60.0);

    return 1;
}