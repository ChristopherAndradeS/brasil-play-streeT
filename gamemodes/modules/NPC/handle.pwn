#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    for(new i = 0; i < MAX_NPCS; i++)
    {
        switch(E_NPC_NAME:i)
        {
            case NPC_LETICIA:
            {
                new npcid = NPC_Create("NPC_Leticia");

                NPC[i][npc::id] = npcid;

                NPC_Spawn(npcid);
                NPC_SetPos(npcid, 1177.370239, -1319.665161, 14.067344);
                NPC_SetFacingAngle(npcid, 270.0);
                NPC_SetSkin(npcid, 308);
                NPC_SetInvulnerable(npcid, true);
                NPC_ApplyAnimation(npcid, "COP_AMBIENT", "Coplook_loop", 4.1, true, false, false, false, 0);
                NPC[i][npc::nametag] = CreateDynamic3DTextLabel("{ff5522}[ SOS ]\n[ NPC ] {ffffff}Leticia", -1, 0.0, 0.0, 0.1, 60.0, npcid, .testlos = 1);
                SetFlag(NPC[i][npc::flags], FLAG_NPC_EXIST);

                printf("[ NPC ] NPC_Leticia criada com sucesso!\n");
                DC::LoadCountNpcs++;

            }

            case NPC_ROGERIO:
            {
                new npcid = NPC_Create("NPC_Rogerio");

                NPC[i][npc::id] = npcid;

                NPC_Spawn(npcid);
                NPC_SetPos(npcid, 1941.693359, -1814.557983, 13.564297);
                NPC_SetFacingAngle(npcid, 177.836853);
                NPC_SetSkin(npcid, 50);
                NPC_SetInvulnerable(npcid, true);
                NPC_ApplyAnimation(npcid, "SHOP","SHP_Serve_Loop", 4.1, true, false, false, false, 0);
                NPC[i][npc::nametag] = CreateDynamic3DTextLabel("{ff5599}[ MEC ]\n[ NPC ] {ffffff}Rogerio", -1, 0.0, 0.0, 0.1, 60.0, npcid, .testlos = 1);
                SetFlag(NPC[i][npc::flags], FLAG_NPC_EXIST);

                printf("[ NPC ] NPC_Rogerio criado com sucesso!\n");
                DC::LoadCountNpcs++;

            }

            default: continue;
        }
    }

    return 1;
}

hook OnGameModeExit()
{
    for(new i = 0; i < MAX_NPCS; i++)
    {
        new npcid = NPC[i][npc::id];
        NPC[i][npc::id] = INVALID_PLAYER_ID;
        NPC[i][npc::flags] = 0;

        DestroyDynamic3DTextLabel(NPC[i][npc::nametag]);
        NPC[i][npc::nametag] = INVALID_3DTEXT_ID;

        NPC_Destroy(npcid);
    }

    return 1;
}