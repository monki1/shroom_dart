import 'models/macroshroom.dart';
import 'models/mushroom.dart';
import 'models/leaf.dart';
import 'models/tree.dart';
import 'sql/db.dart';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath =
    'lib/src/test_database' + DateTime.now().toString() + '.db';

class ShroomBase {
//A WRAPPER CLASS FOR MUSHROOM, MACROSHROOM
  static late DatabaseManager dbManager;
  late Mushroom mushroom;

  static init(String path) {
    //init db
    dbManager = DatabaseManager(
      schemaFilePath: schemaFilePath,
      databaseFilePath: databaseFilePath,
    );
    dbManager.initDatabase();
    Tree.setDB(dbManager.getDatabase());
    Leaf.setDB(dbManager.getDatabase());
    Mushroom.setDB(dbManager.getDatabase());
    MacroShroom.setDB(dbManager.getDatabase());
  }

  ShroomBase(this.mushroom);
//IMPLEMENT THESE
  //create macroshroom from name
  static Future<ShroomBase> createShroomMacro(String name) async {
    Mushroom aMushroom =
        (await MacroShroom.fromMushroom(name, Mushroom())) as Mushroom;
    return ShroomBase(aMushroom);
  }

  static ShroomBase createShroom() {
    Mushroom aMushroom = Mushroom();
    return ShroomBase(aMushroom);
  }

  //get mushroom by id
  static Future<ShroomBase> getShroomById(int id) async {
    Mushroom aMushroom = Mushroom(id: id);
    //check if mushroom is macroshroom
    final db = dbManager.getDatabase();
    final sql = 'SELECT * FROM MacroShroomNames WHERE MushroomID = ?';
    final stmt = db.prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      return ShroomBase(
          await MacroShroom.fromMushroom(result.first['Name'], aMushroom));
    } else {
      return ShroomBase(aMushroom);
    }
  }

  //get macroshroom by name

  static Future<ShroomBase?> getShroomByName(String name) async {
    //get mushroomID from MacroShroomNames
    final db = dbManager.getDatabase();
    final sql = 'SELECT * FROM MacroShroomNames WHERE Name = ?';
    final stmt = db.prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      return ShroomBase(await MacroShroom.fromMushroom(
          name, Mushroom(id: result.first['MushroomID'])));
    }
  }

  static removeDatabase() {
    dbManager.removeDatabase();
  }
}
