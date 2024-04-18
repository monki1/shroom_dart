import 'package:sqlite3/sqlite3.dart';
import 'leaf.dart';
import 'tree.dart';


class Mushroom {
  List<Leaf> _leaves=[];
  int? id;
  static String tableName = 'Mushrooms';
  static Database? _db;

  Mushroom() {
    _checkAndCreateId();
  }

  static void setDB(Database db) {
    _db = db;
  }

  static Mushroom getMushroomById(int mushroomId) {
    if (_db == null) {
      throw Exception('Database not set.');
    }

    final sql = 'SELECT MushroomID FROM $tableName WHERE MushroomID = ?';
    final stmt = _db!.prepare(sql);
    final result = stmt.select([mushroomId]);
    if (result.isNotEmpty) {
      final mushroom = Mushroom();
      mushroom.id = result.first['MushroomID'] as int;
      stmt.dispose();

      // Get the leaves
      final myceliumSql = 'SELECT LeafID FROM Mycelium WHERE MushroomID = ?';
      final myceliumStmt = _db!.prepare(myceliumSql);
      final myceliumResult = myceliumStmt.select([mushroomId]);
      for (var row in myceliumResult) {
        final leaf = Leaf.getLeafById(row['LeafID'] as int);
        mushroom._leaves.add(leaf);
      }
      myceliumStmt.dispose();

      return mushroom;
    } else {
      throw Exception('Mushroom not found');
    }
  }

  

  Future<void> _addMycelium(Leaf leaf) async {
    // add mycelium to the database
    final insertSql = 'INSERT INTO Mycelium (MushroomID, LeafID) VALUES (?, ?)';
    final insertStmt = _db!.prepare(insertSql);
    // await insertStmt.execute([id, leaf.id]);
    insertStmt.execute([id, leaf.id]);
    // print('Mycelium added');
  }
  Future<void> _removeMycelium(Leaf leaf) async {
    // remove mycelium from the database
    final deleteSql = 'DELETE FROM Mycelium WHERE MushroomID = ? AND LeafID = ?';
    final deleteStmt = _db!.prepare(deleteSql);
    deleteStmt.execute([id, leaf.id]);
  }

  //IMPLEMENT : function addLeaf(Leaf): check if leaf from the same tree exists. if yes then remove the previous leaf first, add mycelium to the database,
  Future<void> addLeaf(Leaf leaf) async {
    // Check if the leaf is from the same tree
    if (leaf.tree.id != id) {
      throw Exception('Leaf is not from the same tree');
    }

    // Check if the leaf is already added
    if (_leaves.contains(leaf)) {
      return;
    }

    //check if leaf from the same tree exists. if yes then remove the previous leaf first
    for (var i = 0; i < _leaves.length; i++) {
      if (_leaves[i].tree.id == leaf.tree.id) {
        await _removeMycelium(_leaves[i]);
        _leaves.removeAt(i);
        break;
      }
    }

    // Add the leaf
    _leaves.add(leaf);
    await _addMycelium(leaf);
  }


  //IMPLEMENT : function removeLeaf(TreeName String): 
  Future<void> removeLeaf(String treeName) async {
  // Attempt to find a leaf associated with the given tree name
  //if no leaf of that tree name is found, throw an exception
  Leaf? targetLeaf = _leaves.firstWhere(
    (leaf) => leaf.tree.name == treeName,
  );

  if (targetLeaf != null) {
    await _removeMycelium(targetLeaf);
    _leaves.remove(targetLeaf);
  } else {
    throw Exception('Leaf with tree name "$treeName" not found');
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




Future<void> delete() async {
  for (var leaf in _leaves) {
    await _removeMycelium(leaf);  // Assuming this could be changed to async
    leaf.delete();
  }
  final deleteSql = 'DELETE FROM $tableName WHERE MushroomID = ?';
  final deleteStmt = _db!.prepare(deleteSql);
  deleteStmt.execute([id]);
  deleteStmt.dispose();
}

}
