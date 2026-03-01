#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Login::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Login carregada\n");

    Baseboard::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Rodape carregada\n");

    Acessory::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Editor de acessorios carregada\n");

    Adm::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Administracao carregada\n");

    Veh::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Velocimetro carregada\n");

    Dealership::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Concessionaria carregada\n");

    Garage::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Garagem carregada\n");

    return 1;
}

hook OnGameModeExit()
{
    Login::DestroyPublicTD();
    Baseboard::DestroyPublicTD();
    Acessory::DestroyPublicTD();
    Adm::DestroyPublicTD();
    Veh::DestroyPublicTD();
    Dealership::DestroyPublicTD();
    Garage::DestroyPublicTD();

    return 1;
}
