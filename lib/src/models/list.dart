import 'package:shroom/src/models/shroom_data.dart';
import 'package:sqlite3/sqlite3.dart';

class LeafList {
  static Database? _db;
  static setDB(Database database) {
    _db = database;
  }

  late final List<ShroomData> listItems;

  LeafList(List<ShroomData> list) {
    listItems = list;
  }

  LeafList._fromLeafId(int id) {
    //get all leaves with tree id
    //get all leaves with tree id
    final sql = 'SELECT * FROM ListItems WHERE LeafID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([id]);
    final Map<int, ShroomData> data = {};
    // List<ShroomData> list = [];
    //print(result);
    for (var row in result) {
      final type = row['ValueType'];

      //print(type);

      if(type == 'list'){
        data[row['OrderIndex']] = ShroomData(
          row['ValueType'], _fromListItemId(row['ListItemID']).value);
        continue;
      }
      data[row['OrderIndex']] = ShroomData(
          row['ValueType'], row[ShroomData.getColumnString(row['ValueType'])]);
    }
    //sort the map into a list by order index
    listItems = data.values.toList();
    //confirm that the list is sorted//TODO: remove this
  }

  static ShroomData _fromListItemId(int listItemId) {
    //get all leaves with tree id
    //get all leaves with tree id
    final sql = 'SELECT * FROM ListItems WHERE SuperListItemID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([listItemId]);
    final Map<int, ShroomData> data = {};
    // List<ShroomData> list = [];
    //print(result);
    for (var row in result) {
      //print(row['ValueType']);
      if(row['ValueType'] == 'list'){
        //get the id of row
        int thisId = row['ListItemID'];
        print(thisId);
        Map<int, ShroomData> data = {};
        final fetItemsSql = 'SELECT * FROM ListItems WHERE SuperListItemID = ?';
        final stmt = _db!.prepare(fetItemsSql);
        final result = stmt.select([thisId]);
        for ( int i = 0; i < result.length; i++) {
          final row = result[i];
          if(row['ValueType'] == 'list'){
            data[row['OrderIndex']] = _fromListItemId(row['ListItemID']);
            continue;
          }
        }

        data[row['OrderIndex']] = ShroomData(
          row['ValueType'],row[ShroomData.getColumnString(row['ValueType'])]);
          continue;
      }
      data[row['OrderIndex']] = ShroomData(
          row['ValueType'], row[ShroomData.getColumnString(row['ValueType'])]);
    }
    print(data);
    return ShroomData('list', data.values.toList());
    //sort the map into a list by order index
  }



  static List<ShroomData> get(int leafId) {
    final newLeafList = LeafList._fromLeafId(leafId);
    return newLeafList.listItems;
  }

  static _saveInList(List list, int listItemID) {
    LeafList newLeafList = LeafList(list.isEmpty ? []:list as List<ShroomData>);
    final listItems = newLeafList.listItems;
    for (int i = 0; i < listItems.length; i++) {
      final value = listItems[i].value;
      final type = listItems[i].type;

      if(type == 'list'){

      

            String sql =
          'INSERT INTO ListItems (ValueType, SuperListItemID, OrderIndex) VALUES(?, ?, ?)';
          var stmt = _db!.prepare(sql);
      stmt.execute([type, listItemID, i]);
      stmt.dispose();
      String getLastId = 'SELECT last_insert_rowid()';
      int lastId = _db!.select(getLastId)[0]['last_insert_rowid()'];

      // print("last id: $lastId");
        LeafList._saveInList(value, lastId);
        continue;
      }



      final key = ShroomData.getColumnString(listItems[i].type);
      String sql =
          // 'UPDATE ListItems SET $key = $value WHERE SuperListItemID = $listItemID AND OrderIndex = $i';
          "INSERT INTO ListItems (ValueType, SuperListItemID, OrderIndex, $key) VALUES(?, ?, ?, ?)";

      var stmt = _db!.prepare(sql);
      stmt.execute([type, listItemID, i, value]);
      stmt.dispose();
    }
  }


  static save(List list, int leafId) {
    LeafList newLeafList = LeafList(list.isEmpty ? []:list as List<ShroomData>);
    final listItems = newLeafList.listItems;
    for (int i = 0; i < listItems.length; i++) {
      final value = listItems[i].value;
      final type = listItems[i].type;

      if(type == 'list'){
        String sql =
          // 'UPDATE ListItems SET ValueType = \'$type\' WHERE LeafID = $leafId AND OrderIndex = $i';
          'INSERT INTO ListItems (ValueType, LeafID, OrderIndex) VALUES(?, ?, ?)';
      var stmt = _db!.prepare(sql);
      stmt.execute([type, leafId, i]);
      stmt.dispose();
      String getLastId = 'SELECT last_insert_rowid()';
      int lastId = _db!.select(getLastId)[0]['last_insert_rowid()'];        
        LeafList._saveInList(value, lastId);
        continue;
      }



      final key = ShroomData.getColumnString(listItems[i].type);
      String sql =
          'INSERT INTO ListItems (ValueType, LeafID, OrderIndex, $key) VALUES(?, ?, ?, ?)';
      var stmt = _db!.prepare(sql);
      stmt.execute([type, leafId, i, value]);
      stmt.dispose();
    }
  }

  static delete(int leafId) {
    String sql = 'DELETE FROM ListItems WHERE LeafID = $leafId';
    var stmt = _db!.prepare(sql);
    stmt.execute();
    stmt.dispose();
  }
}
