#include <YSI\YSI_Coding\y_hooks>

/*          NAMESPACES          */

#define Player::            PYR_
#define pyr::               pyr_
#define Punish::            PNH_
#define pnh::               pnh_
#define Acessory::          ACS_
#define acs::               asc_
#define Inventory::         INV_
#define inv::               inv_
#define Admin::             ADM_
#define adm::               adm_
#define Garage::            GRG_
#define grg::               grg_
#define Vehicle::           VEH_
#define veh::               veh_
#define Org::               ORG_ 
#define org::               org_
#define Officine::          OFC_
#define ofc::               ofc_
#define Dealership::        DSP_
#define dsp::               dsp_
#define Server::            SRV_
#define srv::               srv_
#define Ferris::		    FRS_
#define frs::			    frs_
#define Payday::		    PDY_
#define pdy::		        pdy_
#define Login::             LGN_
#define lgn::               lgn_
#define Bank::              BK_
#define Spawn::             SPW_  
#define Square::            SQR_
#define Store::             SRR_
#define Database::          DTB_
#define Baseboard::         bboard_

/*          DEFINES          */
#define DB_NAME             "bps_server.db"
#define DISCORD_LINK        "https://discord.gg/Czq6DWDvcB"

#define LOGIN_MUSIC_URL     "https://files.catbox.moe/gqya30.mp3"
#define LOGIN_MUSIC_MS      (203000)

    /*          COLORS          */
#define COLOR_THEME_BPS     0x0DF205FF
#define COLOR_LIGHT_GREEN   0x88FF88FF
#define COLOR_SUCESS        0x33FF33FF
#define COLOR_ERRO          0xFF3333FF
#define COLOR_WARNING       0xFFFF33FF  

#define FCOLOR_THEME_BPS     "{0df205}"
#define FCOLOR_LIGHT_GREEN   "{88FF88}"
#define FCOLOR_SUCESS        "{33FF33}"
#define FCOLOR_ERRO          "{FF3333}"
#define FCOLOR_WARNING       "{FFFF33}"  

/*          FOWARDS          */
forward Float:Database::LoadDataFloat(const table[], const uid_field[], const uid[], const field[]);

/*          VARIABLES          */
new DB:db_handle;

new const gMonths[][16] = 
{   
    "INVALID_MONTH", "Janeiro", "Fevereiro", "Março", 
    "Abril", "Maio", "Junho", 
    "Julho", "Agosto", "Setembro", 
    "Outubro", "Novembro", "Dezembro" 
};