import 'package:test/test.dart';
import '../../../lib/src/models/mushroom.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'lib/src/test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Mushroom Tests', () {
    late DatabaseManager dbManager;

    setUp(() {
      // Setup code before each test
      dbManager = DatabaseManager(
        schemaFilePath: schemaFilePath,
        databaseFilePath: databaseFilePath,
      );
      dbManager.initDatabase();
      Tree.setDB(dbManager.getDatabase());
      Leaf.setDB(dbManager.getDatabase());
      Mushroom.setDB(dbManager.getDatabase());
    });

    test('Mushroom Initialization', () {
      // Test the initialization of the Mushroom object
      final tree1 = Tree('Oak');
      final tree2 = Tree('Pine');

      final leaf1 = Leaf(tree: tree1, valueType: 'int', value: 10);
      final leaf2 = Leaf(tree: tree2, valueType: 'string', value: 'Green');

      final mushroom = Mushroom([leaf1, leaf2]);

      expect(mushroom.leaves.length, 2);
      expect(mushroom.leaves[0].value, 10);
      expect(mushroom.leaves[1].value, 'Green');
    });

    test('Mushroom Delete', () async {
  // Test deleting a Mushroom object from the database
  final tree1 = Tree('Willow');
  final tree2 = Tree('Redwood');
  final leaf1 = Leaf(tree: tree1, valueType: 'int', value: 15);
  final leaf2 = Leaf(tree: tree2, valueType: 'string', value: 'Yellow');
  final mushroom = Mushroom([leaf1, leaf2]);
   
  for(var i in mushroom.leaves){
    print(i.tree.id);
  }

  // Delete the mushroom
   mushroom.delete();

  // Check if the mushroom has been deleted
  final db = dbManager.getDatabase();
  final mushroomSql = 'SELECT MushroomID FROM Mushrooms WHERE MushroomID = ?';
  final mushroomStmt = db.prepare(mushroomSql);
  final mushroomResult = mushroomStmt.select([mushroom.id]);
  expect(mushroomResult.isEmpty, true);
  mushroomStmt.dispose();

  // Check if the leaves have been deleted
  final leafSql = 'SELECT LeafID FROM Leaves WHERE LeafID = ? OR LeafID = ?';
  final leafStmt = db.prepare(leafSql);
  final leafResult = leafStmt.select([leaf1.id, leaf2.id]);
  print(leafResult);
  expect(leafResult.isEmpty, true);
//   leafStmt.dispose();

//   db.dispose();
});


    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
