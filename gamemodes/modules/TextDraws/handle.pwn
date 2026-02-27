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
    printf("[ TEXTDRAW ] TextDraw: Administracao\n");

    Veh::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Velocimetro\n");

    return 1;
}

hook OnGameModeExit()
{
    Login::DestroyPublicTD();
    Baseboard::DestroyPublicTD();
    Acessory::DestroyPublicTD();
    Adm::DestroyPublicTD();
    Veh::DestroyPublicTD();

    return 1;
}
