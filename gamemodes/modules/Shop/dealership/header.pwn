enum E_SHOP
{
    dsp::vehicleid,
    dsp::idex,
    dsp::categoryid,
    dsp::color1, 
    dsp::color2
}

new dsp::Player[MAX_PLAYERS][E_SHOP];

new Dealership::gCategoryCount[7] =
{
    10, 13, 18, 3, 7, 9, 5
};

new Dealership::gCategoryName[7][32] = 
{
    {"Bikes"},
    {"Compactos (2 portas)"},
    {"Familiar (4 portas)"},
    {"Off Roads"},
    {"Conversiveis"},
    {"Esportivos"},
    {"Luxuosos"}
};

stock GetVehicleShopData(cat, index, &modelid, &Float:price) 
{
    modelid = 0, price = 0.0;

    switch(cat)
    {
        case 0: 
        {
            switch(index) 
            {
                case 0: modelid = 581, price = 20000.0; case 1: modelid = 509, price = 1200.0; 
                case 2: modelid = 481, price = 1500.0; case 3: modelid = 462, price = 6500.0; 
                case 4: modelid = 521, price = 35000.0; case 5: modelid = 463, price = 20000.0; 
                case 6: modelid = 510, price = 3000.0; case 7: modelid = 522, price = 95000.0; 
                case 8: modelid = 461, price = 35000.0; case 9: modelid = 468, price = 48000.0;
            }
        }

        case 1: 
        {
            switch(index) 
            {
                case 0: modelid = 602, price = 25000.0; case 1: modelid = 596, price = 26000.0; 
                case 2: modelid = 401, price = 30000.0; case 3: modelid = 518, price = 34000.0; 
                case 4: modelid = 527, price = 26000.0; case 5: modelid = 589, price = 39000.0; 
                case 6: modelid = 419, price = 27000.0; case 7: modelid = 587, price = 30000.0; 
                case 8: modelid = 533, price = 27000.0; case 9: modelid = 526, price = 34000.0;
                case 10: modelid = 545, price = 41000.0; case 11: modelid = 517, price = 40000.0; 
                case 12: modelid = 410, price = 45000.0;
            }
        }

        case 2: 
        {
            switch(index) 
            {
                case 0: modelid = 445, price = 55500.0; case 1: modelid = 604, price = 67500.0; 
                case 2: modelid = 507, price = 88000.0; case 3: modelid = 585, price = 76000.0; 
                case 4: modelid = 466, price = 56500.0; case 5: modelid = 492, price = 89000.0; 
                case 6: modelid = 546, price = 93500.0; case 7: modelid = 551, price = 95500.0; 
                case 8: modelid = 516, price = 29500.0; case 9: modelid = 467, price = 65500.0;
                case 10: modelid = 426, price = 69500.0; case 11: modelid = 547, price = 73000.0; 
                case 12: modelid = 405, price = 59500.0; case 13: modelid = 580, price = 70000.0; 
                case 14: modelid = 550, price = 54500.0; case 15: modelid = 565, price = 83000.0; 
                case 16: modelid = 540, price = 67000.0; case 17: modelid = 421, price = 89500.0;
            }
        }
        case 3: 
        {
            switch(index) 
            { 
                case 0: modelid = 471, price = 55000.0; 
                case 1: modelid = 500, price = 67000.0; 
                case 2: modelid = 424, price = 88000.0; 
            }
        }

        case 4:
        {
            switch(index) 
            {
                case 0: modelid = 536, price = 65500.0; case 1: modelid = 575, price = 69500.0; 
                case 2: modelid = 534, price = 64000.0; case 3: modelid = 567, price = 63500.0;
                case 4: modelid = 535, price = 66500.0; case 5: modelid = 576, price = 66000.0; 
                case 6: modelid = 412, price = 62500.0;
            }
        }

        case 5: 
        {
            switch(index) 
            {
                case 0: modelid = 402, price = 101000.0; case 1: modelid = 475, price = 110000.0; 
                case 2: modelid = 429, price = 105000.0; case 3: modelid = 541, price = 103500.0;
                case 4: modelid = 415, price = 100500.0; case 5: modelid = 480, price = 102500.0; 
                case 6: modelid = 562, price = 109000.0; case 7: modelid = 559, price = 105000.0; 
                case 8: modelid = 560, price = 110000.0;
            }
        }

        case 6: 
        {
            switch(index) 
            { 
                case 0: modelid = 506, price = 151000.0; case 1: modelid = 451, price = 143000.0; 
                case 2: modelid = 558, price = 134000.0; case 3: modelid = 477, price = 125500.0; 
                case 4: modelid = 603, price = 120500.0; 
            }
        }
    }
}

forward DSP_UpdateCarRotate(playerid, vehicleid);
