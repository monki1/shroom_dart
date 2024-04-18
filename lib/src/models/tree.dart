import 'package:sqlite3/sqlite3.dart';

class Tree {
  static Database? _db;
  String name;
  int? id;
  static String tableName = 'Trees';

  static void setDB(Database db) {
    _db = db;
  }

  Tree(this.name){
    _save();
  }



  void _checkAndCreateId() {
    if (_db == null) {
      throw Exception('Database not set.');
    }

    if (id == null) {
      final sql = 'SELECT TreeID FROM $tableName WHERE Name = ?';
      final stmt = _db!.prepare(sql);
      final result = stmt.select([name]);
      if (result.isNotEmpty) {
        id = result.first['TreeID'] as int?;
      } else {
        stmt.dispose();
        final insertSql = 'INSERT INTO $tableName (Name) VALUES (?)';
        final insertStmt = _db!.prepare(insertSql);
        insertStmt.execute([name]);
        id = _db!.lastInsertRowId;
        insertStmt.dispose();
      }
    }
  }

  void _save()  {
    _checkAndCreateId();
  }

  void delete()  {
    // Check if the tree still has leaves
    final sql = 'SELECT COUNT(*) FROM Leaves WHERE TreeID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty && result.first['COUNT(*)'] as int > 0) {
    //   throw Exception('Tree still has leaves');
     return;
    }

    // Delete the tree
    final deleteSql = 'DELETE FROM $tableName WHERE TreeID = ?';
    final deleteStmt = _db!.prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }

  static Tree? getTreeById(int id) {
    final sql = 'SELECT Name FROM $tableName WHERE TreeID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      return Tree(result.first['Name'] as String);
    }
    return null;
  }
}
