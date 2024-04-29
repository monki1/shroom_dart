import 'package:shroom/src/models/shroom_data.dart';
import 'package:sqlite3/sqlite3.dart';

extension Value on Database {
  ShroomData getValue(String type, int id) {
    String sql = 'SELECT * FROM ${ShroomData.getTableName(type)} WHERE id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      dynamic value = result.first['value'];
      return ShroomData(type, value);
    }
    throw Exception('Value not found');
  }

  int saveValue(String tableName, ShroomData value) {
    String sql = 'INSERT INTO $tableName (value) VALUES (?)';
    final stmt = prepare(sql);
    stmt.execute([value.value]);
    return lastInsertRowId;
  }

  deleteValue(String type, int id) {
    String sql = 'DELETE FROM ${ShroomData.getTableName(type)} WHERE id = ?';
    final stmt = prepare(sql);
    stmt.execute([id]);
    stmt.dispose();
  }
}
