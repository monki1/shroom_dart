import 'package:shroom/src/models/shroom_data.dart';
import 'package:sqlite3/sqlite3.dart';

extension Value on Database {
  ShroomData getValue(String type, int id) {
    String sql =
        'SELECT * FROM ${ShroomData.getTableName(type)} WHERE ValueID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([id]);
    if (result.isNotEmpty) {
      dynamic value = result.first['value'];
      return ShroomData(type, value);
    }
    throw Exception('Value not found');
  }

  ShroomData getList(int leafID) {
    String sql = 'SELECT * FROM list_item WHERE leaf_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([leafID]);
    Map<int, ShroomData> data = {};
    for (int i = 0; i < result.length; i++) {
      Map item = result[i];
      if (item['ValueType'] == 'list') {
        data[item["position"]] = (_getSubList(item['leaf_id']));
      } else {
        data[item["position"]] = getValue(item['ValueType'], item['ValueID']);
      }
    }
    return ShroomData('list', data.values.toList());
  }

  ShroomData _getSubList(int superListItemID) {
    String sql = 'SELECT * FROM list_item WHERE super_list_item_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([superListItemID]);
    Map<int, ShroomData> data = {};
    for (int i = 0; i < result.length; i++) {
      Map item = result[i];
      if (item['ValueType'] == 'list') {
        data[item["position"]] = (_getSubList(item['super_list_item_id']));
      } else {
        data[item["position"]] = (getValue(item['ValueType'], item['ValueID']));
      }
    }
    return ShroomData('list', data.values.toList());
  }

  int saveValue(String tableName, ShroomData value) {
    String sql = 'INSERT INTO $tableName (value) VALUES (?)';
    final stmt = prepare(sql);
    stmt.execute([value.value]);
    return lastInsertRowId;
  }

  saveList(int leafID, List<ShroomData> list) {
    //insert list items into list_item
    for (int i = 0; i < list.length; i++) {
      ShroomData item = list[i];
      if (item.type == 'list') {
        String sql =
            'INSERT INTO list_item (leaf_id, ValueType, position) VALUES (?, ?)';
        final stmt = prepare(sql);
        stmt.execute([leafID, item.type, i]);
        stmt.dispose();
        int superListItemID = lastInsertRowId;
        _saveSubList(superListItemID, item.value);
      } else {
        int valueID = saveValue(item.tableName, item.value);
        String sql =
            'INSERT INTO list_item (leaf_id, ValueID, ValueType, position) VALUES (?, ?, ?)';
        final stmt = prepare(sql);
        stmt.execute([leafID, valueID, item.type, i]);
      }
    }
  }

  _saveSubList(int superListItemID, List<ShroomData> list) {
    //insert list items into list_item
    for (int i = 0; i < list.length; i++) {
      ShroomData item = list[i];
      if (item.type == 'list') {
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueType, position) VALUES (?, ?, ?)';
        final stmt = prepare(sql);
        stmt.execute([superListItemID, item.type, i]);
        stmt.dispose();
        int newSuperListItemID = lastInsertRowId;
        _saveSubList(newSuperListItemID, item.value);
      } else {
        int valueID = saveValue('list_item', item.value);
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueID, ValueType, position) VALUES (?, ?, ?)';
        final stmt = prepare(sql);
        stmt.execute([superListItemID, valueID, item.type, i]);
      }
    }
  }

  deleteValue(String type, int id) {
    String sql =
        'DELETE FROM ${ShroomData.getTableName(type)} WHERE ValueID = ?';
    final stmt = prepare(sql);
    stmt.execute([id]);
    stmt.dispose();
  }

  deleteList(int leafID) {
    //find all the list items associated with this leaf_id
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
    //find all the list items associated with this super_list_item_id
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
