stock Acessory::SetPlayerEditor(playerid, slotid)
{
    Acessory::ShowTDForPlayer(playerid);
    Acessory::LoadOnPlayer(playerid, slotid);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);
    
    SetFlag(acs::Player[playerid][acs::flags], FLAG_EDITING_ACS);
    acs::Player[playerid][acs::pOffset] = 0.025;
    acs::Player[playerid][acs::aOffset] = 25.0;
    acs::Player[playerid][acs::sOffset] = 0.15;
    acs::Player[playerid][acs::pAxis]   = AXIS_TYPE_X;
    acs::Player[playerid][acs::aAxis]   = AXIS_TYPE_X;
    acs::Player[playerid][acs::sAxis]   = AXIS_TYPE_X;
    acs::Player[playerid][acs::camid]   = 0;
    
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_POS, "OFFSET:~n~~y~%.3f m", acs::Player[playerid][acs::pOffset]);
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_ANG, "OFFSET:~n~~y~%.1f graus", acs::Player[playerid][acs::aOffset]);
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_OFFSET_SCL, "OFFSET:~n~~y~%.3f m", acs::Player[playerid][acs::sOffset]);
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_POS_AXIS, "%s", gAxisName[acs::Player[playerid][acs::pAxis]]);
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_ANG_AXIS, "%s", gAxisName[acs::Player[playerid][acs::aAxis]]);
    Acessory::UpdateTDForPlayer(playerid, PTD_ACS_SCL_AXIS, "%s", gAxisName[acs::Player[playerid][acs::sAxis]]);
    Acessory::UpdateColorPTD(playerid, PTD_ACS_POS_AXIS_BTN, 0xFF000090);
    Acessory::UpdateColorPTD(playerid, PTD_ACS_ANG_AXIS_BTN, 0xFF000090);
    Acessory::UpdateColorPTD(playerid, PTD_ACS_SCL_AXIS_BTN, 0xFF000090);

    TogglePlayerControllable(playerid, false);
    Acessory::UpdateEditorCam(playerid, true);

    SendClientMessage(playerid, -1, "{ff9933}[ EDITOR ACS ] {ffffff}Editor de Acessorios {ff9933}aberto.");
}

stock Acessory::UnSetPlayerEditor(playerid)
{
    Acessory::HideTDForPlayer(playerid);
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    acs::ClearData(playerid);
    SendClientMessage(playerid, -1, "{ff9933}[ EDITOR ACS ] {ffffff}Editor de Acessorios {ff9933}fechado.");
}

stock Acessory::LoadOnPlayer(playerid, slotid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    DB::GetDataInt(db_entity, "acessorys", "modelid", acs::Player[playerid][acs::modelid], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataInt(db_entity, "acessorys", "boneid", acs::Player[playerid][acs::boneid], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pX", acs::Player[playerid][acs::pX], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pY", acs::Player[playerid][acs::pY], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "pZ", acs::Player[playerid][acs::pZ], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rX", acs::Player[playerid][acs::rX], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rY", acs::Player[playerid][acs::rY], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "rZ", acs::Player[playerid][acs::rZ], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sX", acs::Player[playerid][acs::sX], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sY", acs::Player[playerid][acs::sY], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataFloat(db_entity, "acessorys", "sZ", acs::Player[playerid][acs::sZ], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataInt(db_entity, "acessorys", "color1", acs::Player[playerid][acs::color1], "owner = '%q' AND slotid = %d", name, slotid);
    DB::GetDataInt(db_entity, "acessorys", "color2", acs::Player[playerid][acs::color2], "owner = '%q' AND slotid = %d", name, slotid);

    if(IsPlayerAttachedObjectSlotUsed(playerid, slotid))
        RemovePlayerAttachedObject(playerid, slotid);

    SetPlayerAttachedObject(playerid, slotid, 
    acs::Player[playerid][acs::modelid], acs::Player[playerid][acs::boneid], 
    acs::Player[playerid][acs::pX], acs::Player[playerid][acs::pY], acs::Player[playerid][acs::pZ],
    acs::Player[playerid][acs::rX], acs::Player[playerid][acs::rY], acs::Player[playerid][acs::rZ],
    acs::Player[playerid][acs::sX], acs::Player[playerid][acs::sY], acs::Player[playerid][acs::sZ],
    acs::Player[playerid][acs::color1], acs::Player[playerid][acs::color2]);

    return 1;
}

stock Acessory::UpdateForPlayer(playerid, slotid)
{
    if(!IsPlayerAttachedObjectSlotUsed(playerid, slotid))
        return 1;
    
    RemovePlayerAttachedObject(playerid, slotid);

    SetPlayerAttachedObject(playerid, slotid, 
    acs::Player[playerid][acs::modelid], acs::Player[playerid][acs::boneid], 
    acs::Player[playerid][acs::pX], acs::Player[playerid][acs::pY], acs::Player[playerid][acs::pZ],
    acs::Player[playerid][acs::rX], acs::Player[playerid][acs::rY], acs::Player[playerid][acs::rZ],
    acs::Player[playerid][acs::sX], acs::Player[playerid][acs::sY], acs::Player[playerid][acs::sZ],
    acs::Player[playerid][acs::color1], acs::Player[playerid][acs::color2]);

    return 1;
}

stock Acessory::ChangeBone(playerid, slotid, new_boneid)
{
    new old_boneid;

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    DB::GetDataInt(db_entity, "acessorys", "boneid", old_boneid, "owner = '%q' AND slotid = %d", name, slotid);

    if(old_boneid == new_boneid) 
        return 0;

    acs::Player[playerid][acs::boneid] = new_boneid;
    DB::SetDataInt(db_entity, "acessorys", "boneid", acs::Player[playerid][acs::boneid], "owner = '%q' AND slotid = %d", name, slotid);

    if(IsPlayerAttachedObjectSlotUsed(playerid, slotid))
        RemovePlayerAttachedObject(playerid, slotid);

    Acessory::LoadOnPlayer(playerid, slotid);

    return 1;
}

stock Acessory::UpdateEditorCam(playerid, init = false)
{
    if(!GetFlag(acs::Player[playerid][acs::flags], FLAG_EDITING_ACS))
        return 1;
    
    acs::Player[playerid][acs::camid] += init ? 0 : 1;

    if(acs::Player[playerid][acs::camid] >= 14)
        acs::Player[playerid][acs::camid] = 0;  
    
    new Float:pX, Float:pY, Float:pZ, idx;

    idx = acs::Player[playerid][acs::camid];

    GetPlayerPos(playerid, pX, pY, pZ);
    
    SetPlayerCameraPos(playerid, 
    pX - Acessory::gCamOffset[idx][0], 
    pY - Acessory::gCamOffset[idx][1], 
    pZ - Acessory::gCamOffset[idx][2]);
    
    SetPlayerCameraLookAt(playerid, 
    pX - Acessory::gCamOffset[idx][0] + Acessory::gCamOffset[idx][3], 
    pY - Acessory::gCamOffset[idx][1] + Acessory::gCamOffset[idx][4],
    pZ - Acessory::gCamOffset[idx][2] + Acessory::gCamOffset[idx][5]);

    return 1;
}

stock Acessory::GetFreeSlot(playerid)
{    
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    for(new i = 0; i < MAX_PLAYER_ACESSORYS; i++)
        if(!DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, i))
            return i;
    
    return -1;
}

stock Acessory::SaveData(playerid, slotid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(!DB::Exists(db_entity, "acessorys", "owner = '%q' AND slotid = %d", name, slotid))
        return 0;

    if(!IsPlayerAttachedObjectSlotUsed(playerid, slotid))
        return 0;

    new modelid, boneid, Float:pX, Float:pY, Float:pZ, Float:rX, Float:rY, Float:rZ, Float:sX, Float:sY, Float:sZ;

    if(modelid == INVALID_OBJECT_ID)
        return 0;

    GetPlayerAttachedObject(playerid, slotid, acs::Player[playerid][acs::modelid], boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, _, _);

    //MENSAGEM PERSONALIZADA
    if(sX == 0.0 || sY == 0.0 || sZ == 0.0)
    {
        printf("[ ERRO ACS ] ERRO FATAL: Ao salvar informações do acessório!");
        return 1;
    }

    DB::SetDataInt(db_entity, "acessorys", "boneid", boneid, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "pX", pX, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "pY", pY, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "pZ", pZ, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rX", rX, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rY", rY, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "rZ", rZ, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sX", sX, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sY", sY, "owner = '%q' AND slotid = %d", name, slotid);
    DB::SetDataFloat(db_entity, "acessorys", "sZ", sZ, "owner = '%q' AND slotid = %d", name, slotid);

    SendClientMessage(playerid, -1, "{33ff33}[ ACS ] {ffffff}Acessorio {33ff33}#%d salvo {ffffff}com sucesso.", slotid + 1);
        
    return 1;
}

stock Acessory::GivePlayerStock(playerid, slotid, stockid)
{
    new name[MAX_PLAYER_NAME], modelid, boneid, Float:price,
        Float:pX, Float:pY, Float:pZ, 
        Float:rX, Float:rY, Float:rZ,
        Float:sX, Float:sY, Float:sZ, color1, color2;

    GetPlayerName(playerid, name);

    DB::GetDataInt(db_stock, "acessorys", "modelid", modelid, "uid = %d", stockid);
    DB::GetDataInt(db_stock, "acessorys", "boneid", boneid, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "price", price, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pX", pX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pX", pX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pY", pY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "pZ", pZ, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rX", rX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rY", rY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "rZ", rZ, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sX", sX, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sY", sY, "uid = %d", stockid);
    DB::GetDataFloat(db_stock, "acessorys", "sZ", sZ, "uid = %d", stockid);
    DB::GetDataInt(db_stock, "acessorys", "color1", color1, "uid = %d", stockid);
    DB::GetDataInt(db_stock, "acessorys", "color2", color2, "uid = %d", stockid);
    
    DB::Insert(db_entity, "acessorys", "owner, slotid, owner_type, flags, price, \
    modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, color1, color2", "'%q', %i, %i, 1, %f, \
    %i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %f, %i, %i", name, slotid, OWNER_TYPE_PLAYER, price,
    modelid, boneid, pX, pY, pZ, rX, rY, rZ, sX, sY, sZ, color1, color2);
    
    SendClientMessage(playerid, -1, "{33ff33}[ ACS LOJA ] {ffffff}Acessorio {33ff33}%s {ffffff}comprado com sucesso!", name);
    
    DB::Delete(db_stock, "acessorys", "uid = %d", stockid);

    acs::Player[playerid][acs::slotid] = slotid;

    Acessory::LoadOnPlayer(playerid, slotid);
}

stock Acessory::ChangeAxis(playerid, measure, axisid)
{
    acs::Player[playerid][acs::pAxis] = axisid;

    new color;

    switch(axisid)
    {   
        case AXIS_TYPE_X:  color = 0xFF000090;
        case AXIS_TYPE_Y:  color = 0x00FF0090;
        case AXIS_TYPE_Z:  color = 0x0000FF90;
    }

    switch(measure)
    {
        case MEA_TYPE_POSITION:
        {
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_POS_AXIS, "%s", gAxisName[axisid]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_POS_AXIS_BTN, color);
            acs::Player[playerid][acs::pAxis] = axisid;
        }

        case MEA_TYPE_ANGLE:
        {
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_ANG_AXIS, "%s", gAxisName[axisid]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_ANG_AXIS_BTN, color);
            acs::Player[playerid][acs::aAxis] = axisid;
        }

        case MEA_TYPE_SCALE:
        {
            Acessory::UpdateTDForPlayer(playerid, PTD_ACS_SCL_AXIS, "%s", gAxisName[axisid]);
            Acessory::UpdateColorPTD(playerid, PTD_ACS_SCL_AXIS_BTN, color);
            acs::Player[playerid][acs::sAxis] = axisid;
        }
    }
}

stock Acessory::VerifyInputOffset(measure, const str[], &Float:value)
{
    if(isnull(str) || sscanf(str, "f", value))
        return 0;
    
    switch(measure)
    {
        case MEA_TYPE_POSITION: return (value > 0.0 && value <= MAX_ACS_OFFSET_POS);
        case MEA_TYPE_ANGLE:    return (value > 0.0 && value <= MAX_ACS_OFFSET_ANG);
        case MEA_TYPE_SCALE:    return (value > 0.0 && value <= MAX_ACS_OFFSET_SCL);
    }

    return 1;
}

stock Acessory::GetNameByModelid(modelid, name[], len = sizeof(name))
{
    switch(modelid)
    {
        case 11745:         format(name, len, "Bolsa preta grande");
        case 18632:         format(name, len, "Vara de pesca");
        case 18634:         format(name, len, "Pe de cabra");
        case 18635:         format(name, len, "Martelo");
        case 18636:         format(name, len, "Bone de policia 1");
        case 18638:         format(name, len, "Capacete EPI");
        case 18645:         format(name, len, "Capacete de moto 1");
        case 18639:         format(name, len, "Chapeu de couro preto");
        case 18891..18910:  format(name, len, "Bandana #%d", 18911 - modelid);
        case 18911..18920:  format(name, len, "Mascara #%d", 18921 - modelid);
        case 18921..18925:  format(name, len, "Boina #%d", 18926 - modelid);
        case 18926..18935:  format(name, len, "Bone #%d", 18936 - modelid); 
        case 18936..18938:  format(name, len, "Capacete #%d", 18939 - modelid); 
        case 18939..18943:  format(name, len, "Bone pra tras #%d", 18944 - modelid);
        case 18944..18951:  format(name, len, "Chapeu mafioso #%d", 18952 - modelid);
        case 18952:         format(name, len, "Capacete Box");
        case 18953..18954:  format(name, len, "Gorro de la #%d", 18955 - modelid);
        case 18955..18959:  format(name, len, "Bone Pala #%d", 18960 - modelid);
        case 18960:         format(name, len, "Bone Pala Hip-Hop");
        case 18961:         format(name, len, "Bone de caminhoneiro");
        case 18962:         format(name, len, "Chapeu preto");
        case 18963:         format(name, len, "Cabeca CJ Elvis");
        case 18964..18966:  format(name, len, "Touca #%d", 18967 - modelid);
        case 18967..18969:  format(name, len, "Chapeu Pescador #%d", 18970 - modelid);
        case 18970..18973:  format(name, len, "Chapeu CowBoy #%d", 18974 - modelid);
        case 18974:         format(name, len, "Mascara do Zorro");
        case 18976:         format(name, len, "Capacete de ciclismo");
        case 18977..18979:  format(name, len, "Capacete de moto #%d", 18980 - modelid);
        case 19006..19035:  format(name, len, "Oculos #%d", 19036 - modelid);
        case 19039..19053:  format(name, len, "Relogio de pulso #%d", 19054 - modelid);
        case 19064..19066:  format(name, len, "Chapeu de natal #%d", 19067 - modelid);
        case 19067..19069:  format(name, len, "Gorro gangster #%d", 19070 - modelid);
        case 19078..19079:  format(name, len, "Papagaio #%d", 19080 - modelid);
        case 19085:         format(name, len, "Tapa-olho");
        case 19095..19098:  format(name, len, "Chapeu de matuto #%d", 19099 - modelid);
        case 19099..19100:  format(name, len, "Chapeu de policia #%d", 19101 - modelid);
        case 19101..19105:  format(name, len, "Chapeu de guerra com alca #%d", 19106 - modelid);
        case 19106..19110:  format(name, len, "Chapeu de guerra sem alca #%d", 19111 - modelid);
        case 19111..19120:  format(name, len, "Chapeu de guerra colorido #%d", 19121 - modelid);
        case 19136:         format(name, len, "Chapeu de pistoleiro");
        case 19137:         format(name, len, "Chapeu mascote de frango");
        case 19138..19140:  format(name, len, "Oculos Hybam #%d", 19141 - modelid);
        case 19141:         format(name, len, "Capacete Swat");
        case 19142:         format(name, len, "Colete Swat");
        case 19160:         format(name, len, "Bone DUDE");
        case 19161..19162:  format(name, len, "Bone de policia #%d", 19164 - modelid);
        case 19274:         format(name, len, "Peruca de Palhaco");
        case 19314:         format(name, len, "Chifre de corno");
        case 19317..19319:  format(name, len, "Guitarra #%d", 19320 - modelid);
        case 19330..19331:  format(name, len, "Capacete de bombeiro #%d", 19332 - modelid);
        case 19352:         format(name, len, "Cartola preta");
        case 19421..19424:  format(name, len, "Fones de ouvido #%d", 19425 - modelid);
        case 19469:         format(name, len, "Lenco de pescoco");
        case 19472:         format(name, len, "Mascara de gas");
        case 19487:         format(name, len, "Cartola branca");
        case 19488:         format(name, len, "Chapeu branco");
        case 19528:         format(name, len, "Chapeu de bruxa");
        case 19553:         format(name, len, "Chapeu de palha");
        case 19554:         format(name, len, "Gorro malandro");
        case 19555..19556:  format(name, len, "Luva de Box %s", modelid == 19555 ? "Esquerda" : "Direita");
        case 19558:         format(name, len, "Chapeu de pizza");
        case 19559:         format(name, len, "Mochila de camping");
        case 19878:         format(name, len, "Skate");
        case 19904:         format(name, len, "Colete EPI");
        case 19914:         format(name, len, "Taco de basebol");
        default:            return 0;
    }

    return 1;
}

stock acs::ClearData(playerid)
{
    acs::Player[playerid][acs::flags]   = 0x00000000;
    acs::Player[playerid][acs::modelid] = INVALID_OBJECT_ID;
    acs::Player[playerid][acs::slotid]  = INVALID_SLOTID;
    acs::Player[playerid][acs::boneid]  = 0;
    acs::Player[playerid][acs::pOffset] = 0.0;
    acs::Player[playerid][acs::aOffset] = 0.0;
    acs::Player[playerid][acs::sOffset] = 0.0;
    acs::Player[playerid][acs::pAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::aAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::sAxis]   = AXIS_TYPE_NONE;
    acs::Player[playerid][acs::camid]   = 0;
    acs::Player[playerid][acs::pX]      = 0.0;
    acs::Player[playerid][acs::pY]      = 0.0;
    acs::Player[playerid][acs::pZ]      = 0.0;
    acs::Player[playerid][acs::rX]      = 0.0;
    acs::Player[playerid][acs::rY]      = 0.0;
    acs::Player[playerid][acs::rZ]      = 0.0;
    acs::Player[playerid][acs::sX]      = 0.0;
    acs::Player[playerid][acs::sY]      = 0.0;
    acs::Player[playerid][acs::sZ]      = 0.0;
    acs::Player[playerid][acs::color1]  = -1;
    acs::Player[playerid][acs::color2]  = -1;
}
