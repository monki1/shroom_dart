import 'package:shroom/src/models/shroom_data.dart';
import 'package:sqlite3/sqlite3.dart';

extension Value on Database {

    ShroomData _getSubList(int superListItemID) {
      print("getSubList: $superListItemID");
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
    print(result);
    print("got sub list: ${data}");
    return ShroomData('list', data.values.toList());
  }

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

  ShroomData getList(int leafID) {
    String sql = 'SELECT * FROM list_item WHERE leaf_id = ?';
    final stmt = prepare(sql);
    final result = stmt.select([leafID]);
    print("retrieved top level list: ${result.length}");
    Map<int, ShroomData> data = {};
    for (var item in result) {
      print("retrieved top level list item: ${item['position']} $item");
      try{

        if (item['ValueType'] == 'list') {
          data[item["position"] as int] = _getSubList(item['id']);
        } else {
          data[item["position"] as int] = getValue(item['ValueType'], item['ValueID']);
        }
      }catch(e){
          print(e);
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
    print("saveList: list length: ${list.length}");
    //insert list items into list_item
    for (int i = 0; i < list.length; i++) {
      ShroomData item = list[i];
      print("saveList: $i ${item.type}");
      if (item.type == 'list') {
        print("add leaf: add 2+ level sub list");
        String sql =
            'INSERT INTO list_item (leaf_id, ValueType, position) VALUES (?, ?, ?)';
        execute(sql,[leafID, item.type, i]);
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
    print("save sub list superListItemID: $superListItemID");
    //insert list items into list_item
    for (int i = 0; i < list.length; i++) {
      print("saveSubList: $i");
      ShroomData item = list[i];
      if (item.type == 'list') {
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueType, position) VALUES (?, ?, ?)';
        execute(sql, [superListItemID, item.type, i]);
        int newSuperListItemID =  lastInsertRowId;
        _saveSubList(newSuperListItemID, item.value);
      } else {
        //print save sub list item value: position
        print("saveSubList: $i ${item.type}");
        int valueID = saveValue(item.tableName, item);
        String sql =
            'INSERT INTO list_item (super_list_item_id, ValueID, ValueType, position) VALUES (?, ?, ?, ?)';
        final stmt = prepare(sql);
        stmt.execute([superListItemID, valueID, item.type, i]);
      }
    }
  }

  deleteValue(String type, int id) {
    String sql =
        'DELETE FROM ${ShroomData.getTableName(type)} WHERE id = ?';
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
