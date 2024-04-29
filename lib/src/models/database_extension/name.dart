import 'package:sqlite3/sqlite3.dart';

extension Name on Database {
  setName(String name, int mushroomID) {
    // Check if the name is already in the database
    final sql = 'SELECT MushroomID FROM MacroShroomNames WHERE Name = ?';
    final stmt = prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      if (result.first['MushroomID'] as int != mushroomID) {
        throw Exception('Name already exists');
      }
    }
    //upsert the name where mushroomID = id
    final upsertSql =
        'INSERT OR REPLACE INTO MacroShroomNames (MushroomID, Name) VALUES (?, ?)';
    final upsertStmt = prepare(upsertSql);
    upsertStmt.execute([mushroomID, name]);
    upsertStmt.dispose();
  }

  void deleteName(int mushroomID) {
    final deleteSql = 'DELETE FROM MacroShroomNames WHERE MushroomID = ?';
    final deleteStmt = prepare(deleteSql);
    deleteStmt.execute([mushroomID]);
    deleteStmt.dispose();
  }

  int getMushroomIDfromName(String name) {
    final sql = 'SELECT MushroomID FROM MacroShroomNames WHERE Name = ?';
    final stmt = prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      return result.first['MushroomID'] as int;
    } else {
      throw Exception('Name $name not found');
    }
  }

  String getNameFromMushroomID(int id) {
    final sql = 'SELECT Name FROM MacroShroomNames WHERE MushroomID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      return result.first['Name'] as String;
    } else {
      throw Exception('Mushroom with id $id not found');
    }
  }
}
