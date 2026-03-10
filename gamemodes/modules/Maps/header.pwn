enum _:E_MAP_SQUARE
{
    MAP_SQUARE_HP = 1,
    MAP_SQUARE_LS
}

enum _:E_MAP_MEC
{
    MAP_MEC_LS = 1,
    MAP_MEC_AIRPORT,
    MAP_MEC_DROP,
}

enum _:E_MAP_STORE
{
    MAP_STORE_247 = 1,
    MAP_STORE_BINCO,
}

enum _:E_MAP_BANK
{
    MAP_BANK_NU = 1,
    MAP_BANK_LOTTERY,
}

enum E_MAP_GAS
{
    Float:gas::pX, Float:gas::pY, Float:gas::pZ,
    STREAMER_TAG_PICKUP:gas::pickup,
    STREAMER_TAG_3D_TEXT_LABEL:gas::label,
}

enum E_MECANIC
{
    Float:ofc::pX, Float:ofc::pY, Float:ofc::pZ, 
    STREAMER_TAG_PICKUP:ofc::pickup,
    STREAMER_TAG_3D_TEXT_LABEL:ofc::label,
}

new Gas[2][E_MAP_GAS];

new Mec[E_MECANIC];
