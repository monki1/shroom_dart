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

    test('Add Leaf to Mushroom', () async {
      final leaf = Leaf(tree: testTree, valueType: 'string', value: 'Green');
      await expectLater(mushroom.addLeaf(leaf), completes);
      //check if leaf and mycelium are added in db
      final db = dbManager.getDatabase();
      final leafSql = 'SELECT * FROM Leaves WHERE LeafID = ?';
      final leafStmt = db.prepare(leafSql);
      final leafResult = leafStmt.select([leaf.id]);
      expect(leafResult.isNotEmpty, true);
      leafStmt.dispose();
      final myceliumSql = 'SELECT * FROM Mycelium WHERE LeafID = ?';
      final myceliumStmt = db.prepare(myceliumSql);
      final myceliumResult = myceliumStmt.select([leaf.id]);
      //expect mycelium leafID and mushroomID to be the same as the leaf and mushroom

      expect(myceliumResult.isNotEmpty, true);
      expect(myceliumResult.first['MushroomID'], mushroom.id);
    });

    test('Remove Leaf from Mushroom', () async {
      final leaf = Leaf(tree: testTree, valueType: 'string', value: 'Green');
      await mushroom.addLeaf(leaf);
      expectLater(mushroom.removeLeaf(testTree.name), completes);
    });

    test('Exception on Adding Leaf from Different Tree', () {
      final otherTree = Tree('Maple');
      final leaf = Leaf(tree: otherTree, valueType: 'string', value: 'Red');
      expectLater(mushroom.addLeaf(leaf), throwsException);
    });

    test('Mushroom Deletion', () async {
      expectLater(mushroom.delete(), completes);
    });

    tearDown(() {
      dbManager.removeDatabase();
    });
  });
}
