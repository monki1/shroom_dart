import 'package:sqlite3/sqlite3.dart';

extension Tree on Database {
  int getTreeIDfromName(String name) {
    final sql = 'SELECT TreeID FROM Trees WHERE Name = ?';
    final stmt = prepare(sql);
    final result = stmt.select([name]);
    if (result.isNotEmpty) {
      return result.first['TreeID'] as int;
    } else {
      stmt.dispose();
      final insertSql = 'INSERT INTO Trees (Name) VALUES (?)';
      final insertStmt = prepare(insertSql);
      insertStmt.execute([name]);
      insertStmt.dispose();
      return lastInsertRowId;
    }
  }

  String getTreeNameFromID(int id) {
    final sql = 'SELECT Name FROM Trees WHERE TreeID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      return result.first['Name'] as String;
    } else {
      throw Exception('Tree with id $id not found');
    }
  }

  void deleteTreeByName(String name) {
    int id = getTreeIDfromName(name);
    // Check if the tree still has leaves
    final sql = 'SELECT COUNT(*) FROM Leaves WHERE TreeID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty && result.first['COUNT(*)'] as int > 0) {
      //   throw Exception('Tree still has leaves');
      return;
    }
    // Delete the tree
    final deleteSql = 'DELETE FROM Trees WHERE  TreeID = ?';
    final deleteStmt = prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }
}
