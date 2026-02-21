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
#define Adm::               ADM_
#define adm::               adm_
#define Garage::            GRG_
#define grg::               grg_
#define Veh::               VEH_
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
#define DB::                DTB_
#define Baseboard::         bboard_
#define Group::             GP_
#define Prision::           PRS_
#define Game::              Game_
#define game::              game_
#define Race::              Race_
#define race::              race_
#define Arena::             ARN_
#define arena::             arn_
#define Ammu::              AMM_
#define House::             HOS_


/*          DEFINES          */
#define DISCORD_LINK        "https://discord.gg/Czq6DWDvcB"
#define LOGIN_MUSIC_URL     "https://files.catbox.moe/gqya30.mp3"
#define LOGIN_MUSIC_MS      (203000)

    /*          COLORS          */
#define COLOR_THEME_BPS         0x0DF205FF
#define COLOR_LIGHT_GREEN       0x88FF88FF
#define COLOR_SUCESS            0x33FF33FF
#define COLOR_ERRO              0xFF3333FF
#define COLOR_WARNING           0xFFF9933FF  

#define FCOLOR_THEME_BPS        "{0df205}"
#define FCOLOR_LIGHT_GREEN      "{88FF88}"
#define FCOLOR_SUCESS           "{33FF33}"
#define FCOLOR_ERRO             "{FF3333}"
#define FCOLOR_WARNING          "{FFFF33}"  

/*          FOWARDS          */
forward Float:floatclamp(Float:value, Float:min, Float:max);

enum _:OWNER_TYPES
{
    OWNER_TYPE_PLAYER = 1,
    OWNER_TYPE_VEHICLE,
}

new const gMonths[][16] = 
{   
    "INVALID_MONTH", "Janeiro", "Fevereiro", "Marco", 
    "Abril", "Maio", "Junho", 
    "Julho", "Agosto", "Setembro", 
    "Outubro", "Novembro", "Dezembro" 
};

new const gWeekDays[][16] = 
{
    "Domingo", "Segunda", "Terca", 
    "Quarta", "Quinta", "Sexta", "Sabado"
};

new const g_arrVehicleNames[][] = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",
    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
}; 
