import 'package:shroom/shroom.dart';
import 'package:sqlite3/sqlite3.dart';
import 'value.dart';

extension ListExtension on Database {
  ShroomData getList(int leafID) {
    String sql = 'SELECT * FROM list_item WHERE leaf_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([leafID]);
    Map<int, ShroomData> data = {};
    for (var item in result) {
      try {
        if (item['ValueType'] == 'list') {
          data[item["position"] as int] = _getSubList(item['id']);
        } else {
          data[item["position"] as int] =
              getValue(item['ValueType'], item['ValueID']);
        }
      } catch (e) {
        rethrow;
      }
    }
    return ShroomData('list', data.values.toList());
  }

  ShroomData _getSubList(int superListItemID) {
    //print("getSubList: $superListItemID");
    String sql = 'SELECT * FROM list_item WHERE super_list_item_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([superListItemID]);
    Map<int, ShroomData> data = {};
    for (var item in result) {
      if (item['ValueType'] == 'list') {
        data[item["position"]] = (_getSubList(item['id']));
      } else {
        data[item["position"]] = (getValue(item['ValueType'], item['ValueID']));
      }
    }
    return ShroomData('list', data.values.toList());
  }

  saveList(int leafID, List<ShroomData> list) {
    for (int i = 0; i < list.length; i++) {
      ShroomData item = list[i];
      if (item.type == 'list') {
        String sql =
            'INSERT INTO list_item (leaf_id, ValueType, position) VALUES (?, ?, ?)';
        execute(sql, [leafID, item.type, i]);
        int susperListItemID = lastInsertRowId;
        _saveSubList(susperListItemID, item.value);
      } else {
        int valueID = saveValue(item.tableName, item);
        String sql =
            'INSERT INTO list_item (leaf_id, ValueID, ValueType, position) VALUES (?, ?, ?, ?)';
        prepare(sql).execute([leafID, valueID, item.type, i]);
      }
    }
  }

  _saveSubList(int superListItemID, List<ShroomData> list) {
    for (int i = 0; i < list.length; i++) {
      ShroomData item = list[i];
      if (item.type == 'list') {
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueType, position) VALUES (?, ?, ?)';
        execute(sql, [superListItemID, item.type, i]);
        int newSuperListItemID = lastInsertRowId;
        _saveSubList(newSuperListItemID, item.value);
      } else {
        int valueID = saveValue(item.tableName, item);
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueID, ValueType, position) VALUES (?, ?, ?, ?)';
        final stmt = prepare(sql);
        stmt.execute([superListItemID, valueID, item.type, i]);
      }
    }
  }

  deleteList(int leafID) {
    String sql = 'SELECT * FROM list_item WHERE leaf_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([leafID]);
    for (int i = 0; i < result.length; i++) {
      Map item = result[i];
      if (item['ValueType'] == 'list') {
        _deleteSubList(item['id']);
      } else {
        deleteValue(item['ValueType'], item['ValueID']);
      }
    }
  }

  _deleteSubList(int superListItemID) {
    String sql = 'SELECT * FROM list_item WHERE super_list_item_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([superListItemID]);
    for (int i = 0; i < result.length; i++) {
      Map item = result[i];
      if (item['ValueType'] == 'list') {
        _deleteSubList(item['id']);
      } else {
        deleteValue(item['ValueType'], item['ValueID']);
      }
    }
  }
}
