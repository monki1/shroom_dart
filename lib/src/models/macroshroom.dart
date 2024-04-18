import 'package:sqlite3/sqlite3.dart';
import 'mushroom.dart';
import 'leaf.dart';

class MacroShroom extends Mushroom {
  String name;
  static String tableName = 'MacroShroomNames';
  static Database? _db;
  static void setDB(Database db) {
    _db = db;
  }

  MacroShroom(this.name, List<Leaf> leaves) : super(leaves);

  @override
  void save() {
    print('Saving MacroShroom');
    super.save();
    final insertSql = 'INSERT INTO $tableName (MushroomID, Name) VALUES (?, ?)';
    final insertStmt = _db!.prepare(insertSql);
    insertStmt.execute([id, name]);
    insertStmt.dispose();
  }

  @override
  void delete() {
    super.delete();
    final deleteSql = 'DELETE FROM $tableName WHERE MushroomID = ?';
    final deleteStmt = _db!.prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }

}
