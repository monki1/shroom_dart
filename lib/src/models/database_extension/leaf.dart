import 'package:shroom/src/models/database_extension/tree.dart';
import 'package:shroom/src/models/shroom_data.dart';
import 'package:shroom/src/models/database_extension/value.dart';
import 'package:sqlite3/sqlite3.dart';

extension LeafDatabase on Database {
  int addLeaf(int mushroomID, int treeID, ShroomData value) {
    // for (int i = 0; i < values.length; i++) {
    // final value = values[i];
    if (value.type == 'list') {
      print("add leaf: add top level list");
      final insertSql =
          'INSERT INTO Leaves (MushroomID, ValueType, TreeID) VALUES (?, ?, ?)';
      final insertStmt = prepare(insertSql);
      insertStmt.execute([mushroomID, value.type, treeID]);
      insertStmt.dispose();
      int thisLeafID = lastInsertRowId;
      saveList(lastInsertRowId, value.value as List<ShroomData>);
      print("super list item id: $lastInsertRowId");
      return thisLeafID;
    } else {
      return _addLeafValue(mushroomID, treeID, value);
    }
    // }
  }

  int _addLeafValue(int mushroomID, int treeID, ShroomData value) {
    int dataID = saveValue(value.type, value);
    final insertSql =
        'INSERT INTO Leaves (MushroomID, ValueType, ValueID, TreeID) VALUES (?, ?, ?, ?)';
    final insertStmt = prepare(insertSql);
    insertStmt.execute([mushroomID, value.type, dataID, treeID]);
    insertStmt.dispose();
    return lastInsertRowId;
  }

  // _addLeafList(int leafID, List<ShroomData> list) {
  //   for (int i = 0; i < list.length; i++) {
  //     print("add top level list item: $i");
  //     final item = list[i];
  //     if (item.type == 'list') {
  //       print("add leaf: add 2nd level sub list");
  //       saveList(leafID, item.value as List<ShroomData>);
  //     } else {
  //       int dataID = saveValue(item.type, item);
  //       final insertSql =
  //           'INSERT INTO list_item (leaf_id, position, ValueType, ValueID) VALUES (?, ?, ?, ?)';
  //       final insertStmt = prepare(insertSql);
  //       insertStmt.execute([leafID, i, item.type, dataID]);
  //       insertStmt.dispose();
  //     }
  //   }
  // }

  void deleteLeaf(int mushroomID, int treeID) {
    //find the valueID and ValueType
    final sql =
        'SELECT ValueID, ValueType FROM Leaves WHERE MushroomID = ? AND TreeID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([mushroomID, treeID]);
    if (result.isNotEmpty) {
      final String type = result.first['ValueType'] as String;
      if (type == 'list') {
        deleteList(result.first['LeafID'] as int);
      } else {
        deleteValue(type, result.first['ValueID'] as int);
      }
      final deleteSql =
          'DELETE FROM Leaves WHERE MushroomID = ? AND TreeID = ?';
      final deleteStmt = prepare(deleteSql);
      deleteStmt.execute([mushroomID, treeID]);
      return;
    }
    throw Exception('Leaf not found');
  }

  void deleteLeaves(int mushroomID) {
    final sql = 'SELECT * FROM Leaves WHERE MushroomID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([mushroomID]);
    for (int i = 0; i < result.length; i++) {
      final leaf = result[i];
      final type = leaf['ValueType'] as String;
      if (type == 'list') {
        deleteList(leaf['LeafID'] as int);
      } else {
        deleteValue(type, leaf['ValueID'] as int);
      }
    }
    final deleteSql = 'DELETE FROM Leaves WHERE MushroomID = ?';
    final deleteStmt = prepare(deleteSql);
    deleteStmt.execute([mushroomID]);
  }

  Map<String, ShroomData> getLeaves(int mushroomID) {
    final sql = 'SELECT * FROM Leaves WHERE MushroomID = ?';
    final stmt = prepare(sql);
    final result = stmt.select([mushroomID]);
    Map<String, ShroomData> leaves = {};
    print("top level leaves: $result");
    
    for (int i = 0; i < result.length; i++) {
      final leaf = result[i];
      final type = leaf['ValueType'] as String;
      if (type == 'list') {
        leaves.addAll({getTreeNameFromID(leaf['TreeID']):  getList(leaf['LeafID'] as int)});

      } else {
        leaves.addAll({getTreeNameFromID(leaf['TreeID']) :getValue(type, leaf['ValueID'] as int)});
      }
    }
    return leaves;
  }

  
}
