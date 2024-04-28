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

  // checkMushroomExists(int id) {
  //   final selectSql =
  //         'SELECT MushroomID FROM Mushrooms WHERE MushroomID = ?';
  //     final selectStmt = prepare(selectSql);
  //     final results = selectStmt.select([id]);
  //     if (results.isEmpty) {
  //       throw Exception('Mushroom with id $this.id not found');
  //     }
  // }

  void deleteMushroom(int id) {
    final deleteSql = 'DELETE FROM Mushrooms WHERE MushroomID = ?';
    final deleteStmt = prepare(deleteSql);
    deleteStmt.execute([id]);
    deleteStmt.dispose();
  }
}
