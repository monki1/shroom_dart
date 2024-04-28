import 'package:sqlite3/sqlite3.dart';

class Tree {
  static Database? _db;
  late String name;
  late int id;
  static String tableName = 'Trees';

  static void setDB(Database db) {
    _db = db;
  }

  static int _getIDfromName(String name) {
    final sql = 'SELECT TreeID FROM $tableName WHERE Name = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      return result.first['TreeID'] as int;
    } else {
      stmt.dispose();
      final insertSql = 'INSERT INTO $tableName (Name) VALUES (?)';
      final insertStmt = _db!.prepare(insertSql);
      insertStmt.execute([name]);
      insertStmt.dispose();
      return _db!.lastInsertRowId;
    }
  }

  static String _getNameFromID(int id) {
    final sql = 'SELECT Name FROM $tableName WHERE TreeID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      return result.first['Name'] as String;
    } else {
      throw Exception('Tree with id $id not found');
    }
  }

  Tree({String? name, int? id}) {
    if (name != null) {
      this.name = name;
      this.id = _getIDfromName(name);
    } else if (id != null) {
      this.id = id;
      this.name = _getNameFromID(id);
    } else {
      throw ArgumentError('Name or id must be provided');
    }
  }

  void delete() {
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
}
