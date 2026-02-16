#define FILTERSCRIPT
 
#include <open.mp> // WAJIB!

#include <zcmd> // Command Processor
 
new Text:IntInfo[MAX_PLAYERS]; // Textdraw
 
public OnFilterScriptInit()
{
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
				IntInfo[i] = TextDrawCreate(500.000000, 109.000000, "Inteior ID: ");
                TextDrawBackgroundColor(IntInfo[i], 255);
                TextDrawFont(IntInfo[i], 1);
                TextDrawLetterSize(IntInfo[i], 0.400000, 1.000000);
                TextDrawColor(IntInfo[i], -1);
                TextDrawSetOutline(IntInfo[i], 0);
                TextDrawSetProportional(IntInfo[i], 1);
                TextDrawSetShadow(IntInfo[i], 1);
        }
        return 1;
}
 
public OnFilterScriptExit()
{
		for(new i = 0; i < MAX_PLAYERS; i++)
        {
			TextDrawHideForPlayer(i, IntInfo[i]);
        }
        return 1;
}
 
public OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
        TextDrawShowForPlayer(playerid, IntInfo[playerid]);
        new str[56];
        if(newkeys & KEY_FIRE) // Mouse Kanan
        {
                GotoInterior(playerid, GetPVarInt(playerid, "CariInterior") + 1);
                SetPVarInt(playerid, "CariInterior", GetPVarInt(playerid, "CariInterior") + 1);
                GameTextForPlayer(playerid, "~r~Left mouse~w~ Untuk Lanjut ke Interior Berikutnya~n~~r~Right mouse~w~ Untuk Mundur", 3000, 5);
                if(GetPVarInt(playerid, "CariInterior") == 145) { GotoInterior(playerid, 0), SetPVarInt(playerid, "CariInterior", 0);}
        }
        if(newkeys & KEY_HANDBRAKE) // Mouse Kiri
        {
            GotoInterior(playerid, GetPVarInt(playerid, "CariInterior") - 1);
            SetPVarInt(playerid, "CariInterior", GetPVarInt(playerid, "CariInterior") - 1);
            GameTextForPlayer(playerid, "~r~Left mouse~w~ Untuk Lanjut ke Interior Berikutnya~n~~r~Right mouse~w~ Untuk Mundur", 3000, 5);
            if(GetPVarInt(playerid, "CariInterior") == 0) { GotoInterior(playerid, 145), SetPVarInt(playerid, "CariInterior", 145);}
        }
        format(str, sizeof(str), "Interior ID: %d", GetPVarInt(playerid, "CariInterior"));
        TextDrawSetString(IntInfo[playerid], str);
        return 1;
}
 
CMD:inte(playerid, params[])
{
        new id;
        if(isnull(params)) return SendClientMessage(playerid, 0xFFFFFFAA, "/gotoint (1-120)");
		id  = strval(params); // String > value
        SetPVarInt(playerid, "CariInterior", id);
        GotoInterior(playerid, id);
       
        new str[56];
        format(str, sizeof(str), "Interior ID: %d", GetPVarInt(playerid, "CariInterior"));
        TextDrawSetString(IntInfo[playerid], str);
        return 1;
}
        // if(id ==  ) {SetPlayerInterior(playerid, ), SetPlayerPos(playerid, );}
 
stock GotoInterior(playerid, id) // Stock
{
		if(id == 0) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 1523.5098, -47.8211, 1002.2699);}
        if(id == 1) {SetPlayerInterior(playerid, 11), SetPlayerPos(playerid, 2003.1178, 1015.1948, 36.008);}
        if(id == 2) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 770.8033, -0.7033, 1000.7267);}
        if(id == 3) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 974.0177, -9.5937, 1001.1484 );}
        if(id == 4) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 961.9308, -51.9071, 1001.1172);}
        if(id == 5) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 830.6016, 5.9404, 1004.1797 );}
        if(id == 6) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 1037.8276, 0.397, 1001.2845 );}
        if(id == 7) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 1212.1489, -28.5388, 1000.9531);}
        if(id == 8) {SetPlayerInterior(playerid, 18), SetPlayerPos(playerid, 1290.4106, 1.9512, 1001.0201);}
        if(id == 9) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 1412.1472, -2.2836, 1000.9241);}
        if(id == 10) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 1527.0468, -12.0236, 1002.0971);}
 
        if(id ==  11) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 612.2191, -123.9028, 997.9922);}
        if(id ==  12) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 512.9291, -11.6929, 1001.5653);}
        if(id ==  13) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 418.4666, -80.4595, 1001.8047);}
        if(id ==  14) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 386.5259, 173.6381, 1008.3828);}
        if(id ==  15) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 288.4723, 170.0647, 1007.1794);}
        if(id ==  16) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 206.4627, -137.7076, 1003.0938);}
        if(id ==  17) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, -100.2674, -22.9376, 1000.7188);}
        if(id ==  18) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, -201.2236, -43.2465, 1002.2734);}
        if(id ==  19) {SetPlayerInterior(playerid, 17), SetPlayerPos(playerid, -202.9381, -6.7006, 1002.2734);}
        if(id ==  20) {SetPlayerInterior(playerid, 17), SetPlayerPos(playerid, -25.7220, -187.8216, 1003.5469);}
 
		if(id ==  21) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 454.9853, -107.2548, 999.4376);}
		if(id ==  22) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 372.5565, -131.3607, 1001.4922);}
		if(id ==  23) {SetPlayerInterior(playerid, 17), SetPlayerPos(playerid, 378.026, -190.5155, 1000.6328);}
		if(id ==  24) {SetPlayerInterior(playerid, 7), SetPlayerPos(playerid, 315.244, -140.8858, 999.6016);}
		if(id ==  25) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 225.0306, -9.1838, 1002.218);}
		if(id ==  26) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 611.3536, -77.5574, 997.9995);}
		if(id ==  27) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 246.0688, 108.9703, 1003.2188);}
		if(id ==  28) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 6.0856, -28.8966, 1003.5494);}
		if(id ==  29) {SetPlayerInterior(playerid, 7), SetPlayerPos(playerid, 773.7318, -74.6957, 1000.6542);}
		if(id ==  30) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 621.4528, -23.7289, 1000.9219);}
	 
		if(id ==  31) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 445.6003, -6.9823, 1000.7344);}
		if(id ==  32) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 285.8361, -39.0166, 1001.5156);}
		if(id ==  33) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 204.1174, -46.8047, 1001.8047);}
		if(id ==  34) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 245.2307, 304.7632, 999.1484);}
		if(id ==  35) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 290.623, 309.0622, 999.1484);}
		if(id ==  36) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 322.5014, 303.6906, 999.1484);}
		if(id ==  37) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, -2041.2334, 178.3969, 28.8465);}
		if(id ==  38) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, -1402.6613, 106.3897, 1032.2734);}
		if(id ==  39) {SetPlayerInterior(playerid, 7), SetPlayerPos(playerid, -1403.0116, -250.4526, 1043.5341);}
		if(id ==  40) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 1204.6689, -13.5429, 1000.9219);}
	 
		if(id ==  41) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 2016.1156, 1017.1541, 996.875);}
		if(id ==  42) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, -741.8495, 493.0036, 1371.9766);}
		if(id ==  43) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 2447.8704, -1704.4509, 1013.5078);}
		if(id ==  44) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 2527.0176, -1679.2076, 1015.4986);}
		if(id ==  45) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, -1129.8909, 1057.5424, 1346.4141);}
		if(id ==  46) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 2496.0549, -1695.1749, 1014.7422);}
		if(id ==  47) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid,366.0248, -73.3478, 1001.5078 );}
		if(id ==  48) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 2233.9363, 1711.8038, 1011.6312);}
		if(id ==  49) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 269.6405, 305.9512, 999.1484);}
		if(id ==  50) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 414.2987, -18.8044, 1001.8047);}
	 
		if(id ==  51) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 1.1853, -3.2387, 999.4284);}
		if(id ==  52) {SetPlayerInterior(playerid, 18), SetPlayerPos(playerid, -30.9875, -89.6806, 1003.5469);}
		if(id ==  53) {SetPlayerInterior(playerid, 18), SetPlayerPos(playerid, 161.4048, -94.2416, 1001.8047);}
		if(id ==  54) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, -2638.8232, 1407.3395, 906.4609);}
		if(id ==  55) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 1267.8407, -776.9587, 1091.9063);}
		if(id ==  56) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 2536.5322, -1294.8425, 1044.125);}
		if(id ==  57) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 2350.1597, -1181.0658, 1027.9766);}
		if(id ==  58) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, -2158.6731, 642.09, 1052.375);}
		if(id ==  59) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 419.8936, 2537.1155, 10);}
		if(id ==  60) {SetPlayerInterior(playerid, 14), SetPlayerPos(playerid,256.9047, -41.6537, 1002.0234);}
	 
		if(id ==  61) {SetPlayerInterior(playerid, 14), SetPlayerPos(playerid, 204.1658, -165.7678, 1000.5234);}
		if(id ==  62) {SetPlayerInterior(playerid, 12), SetPlayerPos(playerid, 1133.35, -7.8462, 1000.6797);}
		if(id ==  63) {SetPlayerInterior(playerid, 14), SetPlayerPos(playerid, -1420.4277, 1616.9221, 1052.5313);}
		if(id ==  64) {SetPlayerInterior(playerid, 17), SetPlayerPos(playerid, 493.1443, -24.2607, 1000.6797);}
		if(id ==  65) {SetPlayerInterior(playerid, 18), SetPlayerPos(playerid, 1727.2853, -1642.9451, 20.2254);}
		if(id ==  66) {SetPlayerInterior(playerid, 16), SetPlayerPos(playerid, -202.842, -24.0325, 1002.2734);}
		if(id ==  67) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 2233.6919, -1112.8107, 1050.8828);}
		if(id ==  68) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 2194.7900, -1204.3500, 1049.0234);}
		if(id ==  69) {SetPlayerInterior(playerid, 9), SetPlayerPos(playerid, 2319.1272, -1023.9562, 1050.2109);}
		if(id ==  70) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 2261.0977, -1137.8833, 1050.6328);}
	 
		if(id ==  71) {SetPlayerInterior(playerid, 17), SetPlayerPos(playerid, -944.2402, 1886.1536, 5.0051);}
		if(id ==  72) {SetPlayerInterior(playerid, 16), SetPlayerPos(playerid, -26.1856, -140.9164, 1003.5469);}
		if(id ==  73) {SetPlayerInterior(playerid, 15), SetPlayerPos(playerid, 2217.281, -1150.5349, 1025.7969);}
		if(id ==  74) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 1.5491, 23.3183, 1199.5938);}
		if(id ==  75) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 681.6216, -451.8933, -25.6172);}
		if(id ==  76) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 234.6087, 1187.8195, 1080.2578);}
		if(id ==  77) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 225.5707, 1240.0643, 1082.1406);}
		if(id ==  78) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 224.288, 1289.1907, 1082.1406);}
		if(id ==  79) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 239.2819, 1114.1991, 1080.9922);}
		if(id ==  80) {SetPlayerInterior(playerid, 15), SetPlayerPos(playerid, 207.5219, -109.7448, 1005.1328);}
	 
		if(id ==  81) {SetPlayerInterior(playerid, 15), SetPlayerPos(playerid, 295.1391, 1473.3719, 1080.2578);}
		if(id ==  82) {SetPlayerInterior(playerid, 15), SetPlayerPos(playerid, -1417.8927, 932.4482, 1041.5313);}
		if(id ==  83) {SetPlayerInterior(playerid, 12), SetPlayerPos(playerid, 446.3247, 509.9662, 1001.4195);}
		if(id ==  84) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 2306.3826, -15.2365, 26.7496);}
		if(id ==  85) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 2331.8984, 6.7816, 26.5032);}
		if(id ==  86) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 663.0588, -573.6274, 16.3359);}
		if(id ==  87) {SetPlayerInterior(playerid, 18), SetPlayerPos(playerid, -227.5703, 1401.5544, 27.7656);}
		if(id ==  88) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, -688.1496, 942.0826, 13.6328);}
		if(id ==  89) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, -1916.1268, 714.8617, 46.5625);}
		if(id ==  90) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 818.7714, -1102.8689, 25.794);}
	 
		if(id ==  91) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 255.2083, -59.6753, 1.5703);}
		if(id ==  92) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 446.626, 1397.738, 1084.3047);}
		if(id ==  93) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 318.5645, 1118.2079, 1083.8828);}
		if(id ==  94) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 227.7559, 1114.3844, 1080.9922);}
		if(id ==  95) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, 261.1165, 1287.2197, 1080.2578);}
		if(id ==  96) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, 286.1490, -84.5633, 1001.5156);}
		if(id ==  97) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, 449.0172, -88.9894, 999.5547);}
		if(id ==  98) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, -27.844, -26.6737, 1003.5573);}
		if(id ==  99) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 2135.2004, -2276.2815, 20.6719);}
		if(id ==  100) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, 306.1966, 307.819, 1003.3047);}
	 
		if(id ==  101) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 24.3769, 1341.1829, 1084.375);}
		if(id ==  102) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 963.0586, 2159.7563, 1011.0303);}
		if(id ==  103) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 2548.4807, 2823.7429, 10.8203);}
		if(id ==  104) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 215.1515, 1874.0579, 13.1406);}
		if(id ==  105) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, 221.6766, 1142.4962, 1082.6094);}
		if(id ==  106) {SetPlayerInterior(playerid, 12), SetPlayerPos(playerid, 2323.7063, -1147.6509, 1050.7101);}
		if(id ==  107) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 344.9984, 307.1824, 999.1557);}
		if(id ==  108) {SetPlayerInterior(playerid, 12), SetPlayerPos(playerid, 411.9707, -51.9217, 1001.8984);}
		if(id ==  109) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, -1421.5618, -663.8262, 1059.5569);}
		if(id ==  110) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 773.8887, -47.7698, 1000.5859);}
	 
		if(id ==  111) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 246.6695, 65.8039, 1003.6406);}
		if(id ==  112) {SetPlayerInterior(playerid, 14), SetPlayerPos(playerid, -1864.9434, 55.7325, 1055.5276);}
		if(id ==  113) {SetPlayerInterior(playerid, 4), SetPlayerPos(playerid, -262.1759, 1456.6158, 1084.3672);}
		if(id ==  114) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 22.861, 1404.9165, 1084.4297);}
		if(id ==  115) {SetPlayerInterior(playerid, 5), SetPlayerPos(playerid, 140.3679, 1367.8837, 1083.8621);}
		if(id ==  116) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, 1494.8589, 1306.48, 1093.2953);}
		if(id ==  117) {SetPlayerInterior(playerid, 14), SetPlayerPos(playerid, -1813.213, -58.012, 1058.9641);}
		if(id ==  118) {SetPlayerInterior(playerid, 16), SetPlayerPos(playerid, -1401.067, 1265.3706, 1039.8672);}
		if(id ==  119) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 234.2826, 1065.229, 1084.2101);}
		if(id ==  120) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, -68.5145, 1353.8485, 1080.2109);}
	 
		if(id ==  121) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, -2240.1028, 136.973, 1035.4141);}
		if(id ==  122) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 297.144, -109.8702, 1001.5156);}
		if(id ==  123) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 316.5025, -167.6272, 999.5938);}
		if(id ==  124) {SetPlayerInterior(playerid, 15), SetPlayerPos(playerid, -285.2511, 1471.197, 1084.375);}
		if(id ==  125) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, -26.8339, -55.5846, 1003.5469);}
		if(id ==  126) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 442.1295, -52.4782, 999.7167);}
		if(id ==  127) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 2182.2017, 1628.5848, 1043.8723);}
		if(id ==  128) {SetPlayerInterior(playerid, 6), SetPlayerPos(playerid, 748.4623, 1438.2378, 1102.9531);}
		if(id ==  129) {SetPlayerInterior(playerid, 8), SetPlayerPos(playerid, 2807.3604, -1171.7048, 1025.5703);}
		if(id ==  130) {SetPlayerInterior(playerid, 9), SetPlayerPos(playerid, 366.0002, -9.4338, 1001.8516);}
	 
		if(id ==  131) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 2216.1282, -1076.3052, 1050.4844);}
		if(id ==  132) {SetPlayerInterior(playerid, 1), SetPlayerPos(playerid, 2268.5156, 1647.7682, 1084.2344);}
		if(id ==  133) {SetPlayerInterior(playerid, 2), SetPlayerPos(playerid, 2236.6997, -1078.9478, 1049.0234);}
		if(id ==  134) {SetPlayerInterior(playerid, 3), SetPlayerPos(playerid, -2031.1196, -115.8287, 1035.1719);}
		if(id ==  135) {SetPlayerInterior(playerid, 8), SetPlayerPos(playerid, 2365.1089, -1133.0795, 1050.875);}
		if(id ==  136) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, 1168.512, 1360.1145, 10.9293);}
		if(id ==  137) {SetPlayerInterior(playerid, 9), SetPlayerPos(playerid, 315.4544, 976.5972, 1960.8511);}
		if(id ==  138) {SetPlayerInterior(playerid, 10), SetPlayerPos(playerid, 1893.0731, 1017.8958, 31.8828);}
		if(id ==  139) {SetPlayerInterior(playerid, 11), SetPlayerPos(playerid, 501.9578, -70.5648, 998.7578);}
		if(id ==  140) {SetPlayerInterior(playerid, 8), SetPlayerPos(playerid, -42.5267, 1408.23, 1084.4297);}
	 
		if(id ==  141) {SetPlayerInterior(playerid, 11), SetPlayerPos(playerid, 2282.9099, -1138.2900, 1050.8984);}
		if(id ==  142) {SetPlayerInterior(playerid, 9), SetPlayerPos(playerid, 84.9244, 1324.2983, 1083.8594);}
		if(id ==  143) {SetPlayerInterior(playerid, 9), SetPlayerPos(playerid, 260.7421, 1238.2261, 1084.2578);}
		if(id ==  144) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, -1658.1656, 1215.0002, 7.25);}
		if(id ==  145) {SetPlayerInterior(playerid, 0), SetPlayerPos(playerid, -1961.6281, 295.2378, 35.4688);}
		return 1;
}