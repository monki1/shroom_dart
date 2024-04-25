import 'package:shroom/src/models/list.dart';
import 'package:sqlite3/sqlite3.dart';
import 'tree.dart';
import 'leaf_helper.dart';
// import 'shroom_data.dart';

class Leaf {
  final Tree tree;
  final String valueType;
  dynamic value;
  int? id;
  static const String tableName = 'Leaves';
  static Database? _db;

  Leaf({required this.tree, required this.valueType, this.value, this.id}) {
    if (!ValueTypeHandler.isValidType(valueType)) {
      throw ArgumentError('Invalid value type');
    }
    if (id == null) {
      _save();
    }
  }

  static Leaf getLeafById(int leafId) {
    final sql = 'SELECT TreeID, ValueType, ' +
        ValueTypeHandler.getValueColumns() +
        ' FROM $tableName WHERE LeafID = ?';
    final result = DatabaseHelper.select(_db!, sql, [leafId]);
    if (result.isEmpty) {
      throw Exception('Leaf with ID $leafId not found');
    }
    final ftree = Tree.getTreeById(result.first['TreeID'] as int);
    final fvalueType = result.first['ValueType'] as String;
    // ignore: prefer_typing_uninitialized_variables
    late final fvalue;

    if (fvalueType == 'list') {
      fvalue = LeafList.get(leafId);
    } else {
      fvalue = ValueTypeHandler.parseValue(result.first, fvalueType);
    }
    return Leaf(tree: ftree!, valueType: fvalueType, value: fvalue, id: leafId);
  }

  static void setDB(Database db) {
    _db = db;
  }

  void _save() {
    if (_db == null) {
      throw Exception('Database not set.');
    }
    _checkAndCreateId();
    if (id == null) {
      throw Exception('Leaf ID not set.');
    }

    //if the value type is a list, save the list
    if (valueType == 'list') {
      LeafList.save(value, id!);
      //add valueType as list
      String updateSql = 'UPDATE $tableName SET ValueType = ? WHERE LeafID = ?';
      DatabaseHelper.executeInsertOrUpdate(_db!, updateSql, [valueType, id]);
    } else {
      Map<String, dynamic> sqlData =
          ValueTypeHandler.prepareData(valueType, value);
      sqlData['LeafID'] = id; // Ensure LeafID is included for the WHERE clause.
      String updateSql =
          ValueTypeHandler.prepareUpdateSql(sqlData, tableName, id!);
      List<dynamic> values = ValueTypeHandler.prepareSqlValues(sqlData);
      DatabaseHelper.executeInsertOrUpdate(_db!, updateSql, values);
    }
  }

  void _checkAndCreateId() {
    if (id != null) return;

    // final sql =
    //     'SELECT LeafID FROM $tableName WHERE TreeID = ? AND ValueType = ?';
    // final result = DatabaseHelper.select(_db!, sql, [tree.id, valueType]);
    // if (result.isNotEmpty) {
    //   //compare the the return value is the same
    //   id = result.first['LeafID'] as int;
    // } else {
    final insertSql =
        'INSERT INTO $tableName (TreeID, ValueType) VALUES (?, ?)';
    DatabaseHelper.executeInsertOrUpdate(_db!, insertSql, [tree.id, valueType]);
    id = _db!.lastInsertRowId;
    // }
  }

  void delete() {
    if (valueType == 'list') {
      LeafList.delete(id!);
    }

    final deleteSql = 'DELETE FROM $tableName WHERE LeafID = ?';

    //add delete list
    DatabaseHelper.executeInsertOrUpdate(_db!, deleteSql, [id]);
    Tree treeObj = Tree.getTreeById(tree.id!)!;
    treeObj.delete();
  }
}
