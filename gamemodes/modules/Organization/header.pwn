#define MAX_ORGS        (8)
#define MAX_ORGS_SKINS  (4)

enum (<<= 1)
{
    FLAG_ORG_CREATED,
}

enum _:ORG_TYPE
{
    INVALID_ORG_TYPE = 0,
    ORG_TYPE_FAMILY,
    ORG_TYPE_FACTION,
    ORG_TYPE_GANG,
    ORG_TYPE_MILITARY,
    ORG_TYPE_MAFIA,
}

enum E_ORGS
{
    org::name[32],
    org::color,
    org::type,
    org::skin,
    org::flags,
    org::leader[MAX_PLAYER_NAME],
    org::coleader[MAX_PLAYER_NAME],
    org::funds,
    Float:org::sX, Float:org::sY, Float:org::sZ,
    STREAMER_TAG_PICKUP:org::pickupid,
    STREAMER_TAG_3D_TEXT_LABEL:org::labelid,
    STREAMER_TAG_MAP_ICON:org::iconid,
}

new Organization[MAX_ORGS][E_ORGS];