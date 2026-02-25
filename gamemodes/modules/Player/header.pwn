#include <YSI\YSI_Coding\y_hooks>

#define MAX_PLAYER_ACESSORYS    (5)
#define MAX_STOCK_ACESSORYS     (8)
#define MAX_PLAYER_VEHICLES     (5)

#define INVALID_SLOTID          (-1)

enum (<<= 1)
{
    FLAG_PLAYER_LOGGED = 1,   
    FLAG_PLAYER_IS_PARDON,     
    FLAG_PLAYER_IN_REGISTER,  
    FLAG_PLAYER_IN_LOGIN,
    FLAG_PLAYER_SPECTATING,
    FLAG_PLAYER_IN_JAIL,
    FLAG_PLAYER_CHECKPOINT,
    FLAG_PLAYER_DEATH,
    FLAG_PLAYER_INVUNERABLE,
}

enum E_PLAYER 
{
    pyr::pass[BCRYPT_HASH_LENGTH],
    pyr::bitcoin,
    Float:pyr::money,
    Float:pyr::health,
    pyr::skinid,
    pyr::gender,
    pyr::score,
    pyr::flags,
    pyr::regionid,
    pyr::vehicleid,
    Text3D:pyr::cpf_tag,
}

new Player[MAX_PLAYERS][E_PLAYER];

/*                  PLAYER TIMERS                 */

enum _:E_PLAYER_TIMERS
{
    pyr::TIMER_LOGIN_KICK,
    pyr::TIMER_PAYDAY,
    pyr::TIMER_JAIL,
    pyr::TIMER_SPEEDOMETER,
    pyr::TIMER_DEATH
}

new pyr::Timer[MAX_PLAYERS][E_PLAYER_TIMERS];

forward Player::Kick(playerid, timerid, const msg[]);
