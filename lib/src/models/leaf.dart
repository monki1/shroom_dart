import 'package:sqlite3/sqlite3.dart';
import 'tree.dart';

const List<String> valueTypes = ['int', 'float', 'string', 'mushroom', 'spell', 'binary'];

class Leaf {
  Tree tree;
  String valueType;
  dynamic value;
  int? id;
  static String tableName = 'Leaves';
  static Database? _db;

  Leaf({required this.tree, required this.valueType, this.value}) {
    if (!valueTypes.contains(valueType)) {
      throw ArgumentError('Invalid value type');
    }
    _save();

  }

  static Leaf getLeafById(int leafId) {
    if (_db == null) {
      throw Exception('Database not set.');
    }

    final sql = 'SELECT TreeID, ValueType, IntValue, FloatValue, StringValue, MushroomValue, SpellValue, BinaryValue FROM $tableName WHERE LeafID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([leafId]);
    if (result.isNotEmpty) {
      final tree = Tree.getTreeById(result.first['TreeID'] as int);
      final valueType = result.first['ValueType'] as String;
      final value = result.first[valueType + 'Value'];
      return Leaf(tree: tree!, valueType: valueType, value: value);
    } else {
      throw Exception('Leaf not found');
    }
  }

  static void setDB(Database db) {
    _db = db;
  }

  void _checkAndCreateId() {
    if (_db == null) {
      throw Exception('Database not set.');
    }

    if (id == null) {
      final sql = 'SELECT LeafID FROM $tableName WHERE TreeID = ? AND ValueType = ?';
      final stmt = _db!.prepare(sql);
      final result = stmt.select([tree.id, valueType]);
      if (result.isNotEmpty) {
        id = result.first['LeafID'] as int?;
      } else {
        stmt.dispose();
        final insertSql = 'INSERT INTO $tableName (TreeID, ValueType) VALUES (?, ?)';
        final insertStmt = _db!.prepare(insertSql);
        insertStmt.execute([tree.id, valueType]);
        id = _db!.lastInsertRowId;
        insertStmt.dispose();
      }
    }
  }

  void _save()  {
    _checkAndCreateId();
    if (_db == null) {
      throw Exception('Database not set.');
    }
    if (id == null) {
      throw Exception('Leaf ID not set.');
    }

    final updateSql = '''
    UPDATE $tableName 
    SET IntValue = ?, 
        FloatValue = ?, 
        StringValue = ?, 
        MushroomValue = ?, 
        SpellValue = ?, 
        BinaryValue = ? 
    WHERE LeafID = ?''';
    final updateStmt = _db!.prepare(updateSql);

    updateStmt.execute([
      valueType == 'int' ? value : null,
      valueType == 'float' ? value : null,
      valueType == 'string' ? value : null,
      valueType == 'mushroom' ? value : null,
      valueType == 'spell' ? value : null,
      valueType == 'binary' ? value : null,
      id
    ]);

    updateStmt.dispose();
    return;
  }

  void delete()  {
            final deleteSql = 'DELETE FROM $tableName WHERE LeafID = ?';
            final deleteStmt = _db!.prepare(deleteSql);
            deleteStmt.execute([id]);
            deleteStmt.dispose();
            Tree treeObj = Tree.getTreeById(this.tree.id!)!;
            treeObj.delete();

            print('Leaf deleted '+id.toString());
    return;
  }
}
