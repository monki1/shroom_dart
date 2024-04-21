import 'package:sqlite3/sqlite3.dart';
import 'mushroom.dart';

class MacroShroom extends Mushroom {
  String? name;
  static String tableName = 'MacroShroomNames';
  static Database? _db;
  static void setDB(Database db) {
    _db = db;
  }

  MacroShroom({int? id}) : super(id: id);

  static Future<MacroShroom> fromMushroom(
      String name, Mushroom mushroom) async {
    var macroShroom = MacroShroom(id: mushroom.id!);
    try {
      await macroShroom.setName(name);
    } catch (e) {
      mushroom.delete();
      throw Exception('Name already exists');
    }
    return macroShroom;
  }

  Future<void> setName(String name) async {
    this.name = name;

    // Check if the name is already in the database
    final sql = 'SELECT MushroomID FROM $tableName WHERE Name = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      if (result.first['MushroomID'] as int != id) {
        throw Exception('Name already exists');
      }
    }
    //upsert the name where mushroomID = id
    final upsertSql =
        'INSERT OR REPLACE INTO $tableName (MushroomID, Name) VALUES (?, ?)';
    final upsertStmt = _db!.prepare(upsertSql);
    upsertStmt.execute([id, name]);
    upsertStmt.dispose();
  }

  void deleteName() {
    final deleteSql = 'DELETE FROM $tableName WHERE MushroomID = ?';
    final deleteStmt = _db!.prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }

  @override
  Future<void> delete() async {
    deleteName();
    super.delete();
  }
}
