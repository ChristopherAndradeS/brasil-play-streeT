enum(<<= 1)
{
    FLAG_NPC_EXIST = 1,
}

enum E_NPC
{
    npc::id,
    npc::flags,
    STREAMER_TAG_3D_TEXT_LABEL:npc::nametag
}

enum E_NPC_NAME
{
    NPC_LETICIA = 1,
}

#define NPC_INVALID (E_NPC_NAME:0)

new NPC[MAX_NPCS][E_NPC];