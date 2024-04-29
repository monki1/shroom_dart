import 'package:sqlite3/sqlite3.dart';

extension MushroomExtension on Database {
  int createEmptyMushroom() {
    final insertSql = 'INSERT INTO Mushrooms DEFAULT VALUES';
    final insertStmt = prepare(insertSql);
    insertStmt.execute();
    final id = lastInsertRowId;
    insertStmt.dispose();
    return id;
  }

  void deleteMushroom(int id) {
    final deleteSql = 'DELETE FROM Mushrooms WHERE MushroomID = ?';
    final deleteStmt = prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }

  bool checkMushroomExists(int id) {
    final sql = 'SELECT MushroomID FROM Mushrooms WHERE MushroomID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    return result.isNotEmpty;
  }
}
