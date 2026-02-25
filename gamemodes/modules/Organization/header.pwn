#define MAX_ORGS            (8)
#define MAX_ORGS_SKINS      (4)

#define INVALID_ORG_ID      (-1)

#define NO_LEADER_NAME      "Sem Lider"
#define NO_COLEADER_NAME    "Sem Colider"

enum (<<= 1)
{
    FLAG_ORG_CREATED = 1,
}

enum (<<= 1)
{
    FLAG_PLAYER_ON_WORK = 1,
}

enum ORG_TYPE
{
    //INVALID_ORG_TYPE = 0,
    ORG_TYPE_FAMILY = 1,
    ORG_TYPE_FACTION,
    ORG_TYPE_GANG,
    ORR_TYPE_POLICE,
    ORG_TYPE_ARMY,
    ORG_TYPE_MAFIA,
}

enum ORG_ROLES
{
    ORG_ROLE_NOVICE = 1,
    ORG_ROLE_JUNIOR,
    ORG_ROLE_SENIOR,
    ORG_ROLE_COLEADER,
    ORG_ROLE_LEADER,
}

#define INVALID_ORG_ROLE_ID     (ORG_ROLES:0)

new const Org::gTypeNames[][32] = 
{
    {"{cdcdcd}Sem Tipo"},
    {"{55ff55}Familia"},
    {"{ff5555}Faccao"},
    {"{ff9955}Gangue"},
    {"{99ffff}Policial"},
    {"{559955}Exercito"},
    {"{ff3399}Mafia/Triad"}
};

enum E_ORGS
{
    org::name[32],
    org::tag[4],
    org::color,
    org::zoneid,
    ORG_TYPE:org::type,
    org::skins[MAX_ORGS_SKINS],
    org::flags,
    org::leader[MAX_PLAYER_NAME],
    org::coleader[MAX_PLAYER_NAME],
    Float:org::funds,
    Float:org::sX, Float:org::sY, Float:org::sZ, Float:org::sA,
    STREAMER_TAG_PICKUP:org::pickupid,
    STREAMER_TAG_3D_TEXT_LABEL:org::labelid,
    STREAMER_TAG_MAP_ICON:org::iconid,
}

new Org[MAX_ORGS][E_ORGS];

enum E_PLAYER_ORG
{
    pyr::inviterid, pyr::invite_orgid,
    pyr::orgid,
    pyr::debts,
    pyr::flags,
    pyr::skinid,
    ORG_ROLES:pyr::role,
    STREAMER_TAG_3D_TEXT_LABEL:pyr::labelid,
}

new org::Player[MAX_PLAYERS][E_PLAYER_ORG];

new Float:Org::ZonesLimits[][4] =
{
    {2350.0046, -1725.9144, 2540.0547, -1628.9180},
    {1535.7251, -1725.2131, 1612.1938, -1600.0037}
};
