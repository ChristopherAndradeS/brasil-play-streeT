#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    if(!fexist("entitys.db"))
    {
        printf("[ DB ] Arquivo \"entitys.db\" não encontrado, gerando um novo...\n");

        db_entity = DB_Open("entitys.db");

        DB::CreateTable(db_entity, "players", 
        "uid             INTEGER PRIMARY KEY AUTOINCREMENT,\
        name            VARCHAR(24) NOT NULL UNIQUE,\
        pass            CHAR(60) NOT NULL,\
        ip              VARCHAR(16) NOT NULL,\
        payday_tleft    INTEGER,\
        bitcoin         INTEGER,\
        money           FLOAT,\
        pX FLOAT, pY FLOAT, pZ FLOAT,\
        pA              FLOAT,\
        score           INTEGER,\
        skinid          INTEGER,\
        orgid           INTEGER");

        DB::CreateTable(db_entity, "punishments", 
        "name       VARCHAR(24) NOT NULL UNIQUE,\
        ip          VARCHAR(16),\
        punished_by VARCHAR(24),\
        level       INTEGER,\
        reason      VARCHAR(64),\
        date        VARCHAR(64),\
        left_tstamp INTEGER");

        // DB::CreateTable(db_entity, "vehicles", 
        // "owner      VARCHAR(24),\
        // owner_type  INTEGER, \
        // slotid      INTEGER,\
        // modelid     INTEGER,\
        // pX FLOAT pY FLOAT, pZ FLOAT,\
        // pA FLOAT, color1 INTEGER, color2 INTEGER");

        DB::CreateTable(db_entity, "acessorys", 
        "owner      VARCHAR(24),\
        slotid      INTEGER,\
        owner_type  INTEGER, \
        flags       INTEGER, \
        price       FLOAT, \
        modelid     INTEGER,\
        boneid      INTEGER,\
        pX FLOAT, pY FLOAT, pZ FLOAT,\
        rX FLOAT, rY FLOAT, rZ FLOAT,\
        sX FLOAT, sY FLOAT, sZ FLOAT,\
        color1 INTEGER, color2 INTEGER");

        DB::CreateTable(db_entity, "admins", 
        "name        VARCHAR(24),\
        level        INTEGER,\
        promoter     VARCHAR(24),\
        promote_date VARCHAR(32)\
        ");
    }

    if(!fexist("stocks.db"))
    {
        printf("[ DB ] Arquivo \"stocks.db\" não encontrado, gerando um novo...\n");

        db_stock = DB_Open("stocks.db");

        DB::CreateTable(db_stock, "acessorys", 
        "uid INT NOT NULL UNIQUE,\
        name VARCHAR(32),\
        creator VARCHAR(24),\
        price FLOAT,\
        modelid INTEGER,\
        boneid INTEGER,\
        pX FLOAT, pY FLOAT, pZ FLOAT,\
        rX FLOAT, rY FLOAT, rZ FLOAT,\
        sX FLOAT, sY FLOAT, sZ FLOAT,\
        color1 INTEGER, color2 INTEGER");

        DB::CreateTable(db_stock, "locations", 
        "name VARCHAR(32),\
        category VARCHAR(32),\
        creator VARCHAR(24),\
        pX FLOAT, pY FLOAT, pZ FLOAT");
    }

    else db_stock = DB_Open("stocks.db");

    return 1;
}
