import './models';

const String schemaFilePath = 'lib/src/sql/schema.sql';

class ShroomBase {
  static init(String path) {
    //init db
    Database dbManager = DatabaseManager(
      schemaFilePath: schemaFilePath,
      databaseFilePath: databaseFilePath,
    );
    dbManager.initDatabase();
    Tree.setDB(dbManager.getDatabase());
    Leaf.setDB(dbManager.getDatabase());
    Mushroom.setDB(dbManager.getDatabase());
    MacroShroom.setDB(dbManager.getDatabase());
  }
}
