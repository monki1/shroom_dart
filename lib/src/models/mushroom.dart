import 'package:sqlite3/sqlite3.dart';
import 'leaf.dart';
import 'tree.dart';

class Mushroom {
  List<Leaf> leaves;
  int? id;
  static String tableName = 'Mushrooms';
  static Database? _db;

  Mushroom(this.leaves) {
    _checkLeavesFromDifferentTrees();
    save();
  }

  static void setDB(Database db) {
    _db = db;
  }

  void _checkLeavesFromDifferentTrees() {
    final treeNames = leaves.map((leaf) => leaf.tree.name).toSet();
    if (treeNames.length != leaves.length) {
      throw ArgumentError('One mushroom can only have one leaf from each tree.');
    }
  }

  void _checkAndCreateId() {
    if (_db == null) {
      throw Exception('Database not set.');
    }

    if (id == null) {
      final insertSql = 'INSERT INTO $tableName DEFAULT VALUES';
      final insertStmt = _db!.prepare(insertSql);
      insertStmt.execute();
      id = _db!.lastInsertRowId;
      insertStmt.dispose();
    }
  }

  Set<int> _getExistingLeafIds() {
    final existingLeavesQuery = 'SELECT LeafID FROM Mycelium WHERE MushroomID = ?';
    final existingLeavesStmt = _db!.prepare(existingLeavesQuery);
    final existingLeavesResult = existingLeavesStmt.select([id]);
    final existingLeafIds = existingLeavesResult.map((row) => row['LeafID'] as int).toSet();
    existingLeavesStmt.dispose();
    return existingLeafIds;
  }

  void _insertIntoMycelium(int leafId)  {
    final myceliumInsertSql = 'INSERT INTO Mycelium (MushroomID, LeafID) VALUES (?, ?)';
    final myceliumInsertStmt = _db!.prepare(myceliumInsertSql);
    myceliumInsertStmt.execute([id, leafId]);
    myceliumInsertStmt.dispose();
  }

  void _deleteFromMycelium(int leafId)  {
    final myceliumDeleteSql = 'DELETE FROM Mycelium WHERE MushroomID = ? AND LeafID = ?';
    final myceliumDeleteStmt = _db!.prepare(myceliumDeleteSql);
    myceliumDeleteStmt.execute([id, leafId]);
    myceliumDeleteStmt.dispose();
  }

  Future<void> save() async {
    _checkAndCreateId();
    if (_db == null) {
      throw Exception('Database not set.');
    }
    if (id == null) {
      throw Exception('Mushroom ID not set.');
    }

    final existingLeafIds = _getExistingLeafIds();

    for (var leaf in leaves) {
      if (!existingLeafIds.contains(leaf.id)) {
        _insertIntoMycelium(leaf.id!);
      }
      existingLeafIds.remove(leaf.id);
    }

    for (var leafId in existingLeafIds) {
      _deleteFromMycelium(leafId);
      final leaf = Leaf.getLeafById(leafId);
       leaf.delete();
    }
  }

  void delete() {
    if (_db == null) {
      throw Exception('Database not set.');
    }
    if (id == null) {
      throw Exception('Mushroom ID not set.');
    }

    // Retrieve all leaves associated with this mushroom
    final myceliumQuery = 'SELECT LeafID FROM Mycelium WHERE MushroomID = ?';
    final myceliumStmt = _db!.prepare(myceliumQuery);
    final myceliumResult = myceliumStmt.select([id]);
    myceliumStmt.dispose();

    // Delete each leaf
    for (var row in myceliumResult) {
      final leafId = row['LeafID'] as int;
      final leaf = Leaf.getLeafById(leafId);
      leaf.delete();
    }

    // Delete all mycelium entries associated with this mushroom
    final myceliumDeleteSql = 'DELETE FROM Mycelium WHERE MushroomID = ?';
    final myceliumDeleteStmt = _db!.prepare(myceliumDeleteSql);
    myceliumDeleteStmt.execute([id]);
    myceliumDeleteStmt.dispose();

    // Delete the mushroom from the Mushrooms table
    final mushroomDeleteSql = 'DELETE FROM Mushrooms WHERE MushroomID = ?';
    final mushroomDeleteStmt = _db!.prepare(mushroomDeleteSql);
    mushroomDeleteStmt.execute([id]);
    mushroomDeleteStmt.dispose();
  }
}
