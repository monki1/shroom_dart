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
    for (var row in result) {
      data[row['OrderIndex']] = ShroomData(
          row['ValueType'], row[ShroomData.getColumn(row['ValueType'])]);
    }
    //sort the map into a list by order index
    listItems = data.values.toList();
    //confirm that the list is sorted//TODO: remove this
    for (int i = 0; i < listItems.length - 1; i++) {
      if (listItems[i] != data[i]) {
        throw Exception('List not sorted');
      }
    }
  }

  static List<ShroomData> get(int leafId) {
    final newLeafList = LeafList._fromLeafId(leafId);
    return newLeafList.listItems;
  }

  static save(List<ShroomData> list, int leafId) {
    LeafList newLeafList = LeafList(list);
    final listItems = newLeafList.listItems;
    for (int i = 0; i < listItems.length; i++) {
      final value = listItems[i].value;
      final key = ShroomData.getColumn(listItems[i].type);
      String sql =
          'UPDATE ListItems SET $key = $value WHERE LeafID = $leafId AND OrderIndex = $i';
      var stmt = _db!.prepare(sql);
      stmt.execute();
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
