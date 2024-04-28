

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
    MushroomID INTEGER,
    -- 
    ValueType TEXT CHECK(ValueType IN ('int', 'float', 'string', 'mushroom', 'binary', 'list', 'bool')),
    ValueID INTEGER, 
--    
    FOREIGN KEY (TreeID) REFERENCES Trees(TreeID),
    FOREIGN KEY (MushroomID) REFERENCES Mushrooms(MushroomID)
);
-- Table for storing integer values
CREATE TABLE int (
    id INTEGER PRIMARY KEY,
    value INTEGER
);

-- Table for storing float values
CREATE TABLE float (
    id INTEGER PRIMARY KEY,
    value REAL
);

-- Table for storing string values
CREATE TABLE string (
    id INTEGER PRIMARY KEY,
    value TEXT
);

-- Table for storing mushroom values; the value is a foreign key reference to the Mushrooms table
CREATE TABLE mushroom (
    id INTEGER PRIMARY KEY,
    value INTEGER,
    FOREIGN KEY(value) REFERENCES Mushrooms(id)
);

-- Table for storing binary values
CREATE TABLE binary (
    id INTEGER PRIMARY KEY,
    value BLOB

);

-- Table for storing boolean values
CREATE TABLE bool (
    id INTEGER PRIMARY KEY,
    value BIT

);


CREATE TABLE list_item (
    id INTEGER PRIMARY KEY,
    -- 
    leaf_id INTEGER,
    super_list_item_id INTEGER,
    -- 
    position INTEGER,
    -- 
    ValueType TEXT CHECK(ValueType IN ('int', 'float', 'string', 'mushroom', 'binary', 'list', 'bool')),
    ValueID INTEGER,
    -- 
    FOREIGN KEY (leaf_id) REFERENCES Leaves(LeafID),
    FOREIGN KEY (super_list_item_id) REFERENCES list_item(id)    
);
