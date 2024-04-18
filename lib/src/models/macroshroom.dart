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
Future<void> save() async {
  super.save();

  // Prepare the SQL queries for checking, inserting, and updating
  final checkSql = 'SELECT MushroomID FROM $tableName WHERE Name = ?';
  final insertSql = 'INSERT INTO $tableName (MushroomID, Name) VALUES (?, ?)';
  final updateSql = 'UPDATE $tableName SET Name = ? WHERE MushroomID = ?';
  final deleteOldNameSql = 'DELETE FROM $tableName WHERE Name = ?';

  // Prepare the statement for checking the existing mushroom
  final checkStmt = _db!.prepare(checkSql);
  final existingEntry = checkStmt.select([name]);

  if (existingEntry.isNotEmpty) {
    // There is an entry with the same name
    final existingMushroomId = existingEntry.first['MushroomID'];
    if (existingMushroomId != id) {
      // The existing mushroom name is associated with a different ID
      throw Exception('YOU CANNOT TAKE ANOTHER MUSHROOM\'S NAME');
    }
    // If ID is the same and name is the same, do nothing
  } else {
    // No existing entry with the same name
    // Check if there is an existing mushroom with the same ID but different name
    final currentEntry = checkStmt.select([id]);
    if (currentEntry.isNotEmpty) {
      // If current entry exists with the same ID, update the name
      final updateStmt = _db!.prepare(updateSql);
      updateStmt.execute([name, id]);
      updateStmt.dispose();
    } else {
      // Insert new mushroom name
      final insertStmt = _db!.prepare(insertSql);
      insertStmt.execute([id, name]);
      insertStmt.dispose();
    }
  }

  // Clean up the statement
  checkStmt.dispose();
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
