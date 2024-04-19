import 'package:test/test.dart';
import '../../../lib/src/models/mushroom.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

void main() {
  group('Mushroom Tests', () {
    late DatabaseManager dbManager;
    late Tree testTree;
    late Mushroom mushroom;

    setUp(() {
      dbManager = DatabaseManager(
        schemaFilePath: 'lib/src/sql/schema.sql',
        databaseFilePath: 'lib/src/test_database' + DateTime.now().toString() + '.db',
      );
      dbManager.initDatabase();
      Tree.setDB(dbManager.getDatabase());
      Leaf.setDB(dbManager.getDatabase());
      Mushroom.setDB(dbManager.getDatabase());
      testTree = Tree('Oak');
      mushroom = Mushroom();
    });

    test('Add/Remove Leaf to Mushroom', () async {
      final leaf = Leaf(tree: testTree, valueType: 'string', value: 'Green');
      await expectLater(mushroom.addLeaf(leaf), completes);
      //check if leaf and mycelium are added in db
      final db = dbManager.getDatabase();
      final leafSql = 'SELECT * FROM Leaves WHERE LeafID = ?';
      final leafStmt = db.prepare(leafSql);
      final leafResult = leafStmt.select([leaf.id]);
      expect(leafResult.isNotEmpty, true);
      final myceliumSql = 'SELECT * FROM Mycelium WHERE LeafID = ?';
      final myceliumStmt = db.prepare(myceliumSql);
      final myceliumResult = myceliumStmt.select([leaf.id]);
      //expect mycelium leafID and mushroomID to be the same as the leaf and mushroom

      expect(myceliumResult.isNotEmpty, true);
      expect(myceliumResult.first['MushroomID'], mushroom.id);
      //remove leaf from mushroom
      await expectLater(mushroom.removeLeaf(leaf.tree.name), completes);
      //check if leaf and mycelium are removed from db
      final leafResult2 = leafStmt.select([leaf.id]);
      print (leafResult2);
      expect(leafResult2.isEmpty, true);
      final myceliumResult2 = myceliumStmt.select([leaf.id]);
      expect(myceliumResult2.isEmpty, true);
      leafStmt.dispose();
    });

    //test init mushroom from id
    test('Mushroom Initialization from ID', () {
      final leaf = Leaf(tree: testTree, valueType: 'string', value: 'Green');
      mushroom.addLeaf(leaf);
      final mushroom2 = Mushroom(id: mushroom.id);
      expect(mushroom2.id, mushroom.id);
      //check if leaves are loaded
      expect(mushroom2.leaves.isNotEmpty, true);
      expect(mushroom2.leaves.first.tree.name, testTree.name);
      expect(mushroom2.leaves.first.valueType, 'string');
      expect(mushroom2.leaves.first.value, 'Green');
    });



    test('Mushroom Deletion', () async {
      final leaf = Leaf(tree: testTree, valueType: 'string', value: 'Green');
      expectLater(mushroom.delete(), completes);
      final db = dbManager.getDatabase();
      final mushroomSql = 'SELECT * FROM Mushrooms WHERE MushroomID = ?';
      final mushroomStmt = db.prepare(mushroomSql);
      final mushroomResult = mushroomStmt.select([mushroom.id]);
      expect(mushroomResult.isEmpty, true);
      final myceliumSql = 'SELECT * FROM Mycelium WHERE MushroomID = ?';
      final myceliumStmt = db.prepare(myceliumSql);
      final myceliumResult = myceliumStmt.select([mushroom.id]);
      expect(myceliumResult.isEmpty, true);
//verify leaf result deletion
      final leafSql = 'SELECT * FROM Leaves WHERE LeafID = ?';
      final leafStmt = db.prepare(leafSql);
      final leafResult = leafStmt.select([leaf.id]);
      expect(leafResult.isEmpty, true);





      mushroomStmt.dispose();
    });

    tearDown(() {
      dbManager.removeDatabase();
    });
  });
}
