CREATE TABLE Mushrooms (
    MushroomID INTEGER PRIMARY KEY
);

CREATE TABLE MacroShroomNames (
    MushroomID INTEGER PRIMARY KEY,
    Name TEXT UNIQUE,
    FOREIGN KEY (MushroomID) REFERENCES Mushrooms(MushroomID)
);

CREATE TABLE Trees (
    TreeID INTEGER PRIMARY KEY,
    Name TEXT UNIQUE
);

CREATE TABLE Leaves (
    LeafID INTEGER PRIMARY KEY,
    TreeID INTEGER,
    ValueType TEXT CHECK(ValueType IN ('int', 'float', 'string', 'mushroom', 'binary', 'list')),
    IntValue INTEGER,
    FloatValue REAL,
    StringValue TEXT,
    MushroomValue INTEGER,

    BinaryValue BLOB,
    BoolValue BIT,
--    
    FOREIGN KEY (TreeID) REFERENCES Trees(TreeID),
    FOREIGN KEY (MushroomValue) REFERENCES Mushrooms(MushroomID)
);

CREATE TABLE Mycelium (
    MyceliumID INTEGER PRIMARY KEY,
    MushroomID INTEGER,
    LeafID INTEGER,
    FOREIGN KEY (MushroomID) REFERENCES Mushrooms(MushroomID),
    FOREIGN KEY (LeafID) REFERENCES Leaves(LeafID)
);



CREATE TABLE ListItems (
    ListItemID INTEGER PRIMARY KEY,
    LeafID INTEGER,
    OrderIndex INTEGER,
    ValueType TEXT CHECK(ValueType IN ('int', 'float', 'string', 'mushroom', 'binary')),
    IntValue INTEGER,
    FloatValue REAL,
    StringValue TEXT,
    MushroomValue INTEGER,
    BinaryValue BLOB,
    BoolValue BIT,
    FOREIGN KEY (LeafID) REFERENCES Leaves(LeafID)
);
