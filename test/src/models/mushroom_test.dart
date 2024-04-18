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
  leafStmt.dispose();

  db.dispose();
});

test('Mushroom Update - Change Leaves and Save', () async {
  final tree1 = Tree('Apple');
  final tree2 = Tree('Banana');
  final leaf1 = Leaf(tree: tree1, valueType: 'string', value: 'Red');
  final leaf2 = Leaf(tree: tree2, valueType: 'string', value: 'Yellow');

  // Initialize the mushroom with initial leaves
  var mushroom = Mushroom([leaf1, leaf2]);

  // Changing leaves
  final leaf3 = Leaf(tree: tree1, valueType: 'string', value: 'Green');
  mushroom.leaves = [leaf3];  // Update mushroom with a new set of leaves

  // Save updates to the database
  await mushroom.save();  // Ensure save is awaited if it's asynchronous

  // Verify the updated leaves are in the database
  final db = dbManager.getDatabase();
  final sqlCheckUpdated = 'SELECT LeafID FROM Mycelium WHERE MushroomID = ?';
  final stmtCheckUpdated = db.prepare(sqlCheckUpdated);
  final resultCheckUpdated = await stmtCheckUpdated.select([mushroom.id]);  // Assuming select is asynchronous

  expect(resultCheckUpdated.any((row) => row['LeafID'] == leaf3.id), true);
  stmtCheckUpdated.dispose();

  //wait for 1 sec
  await Future.delayed(Duration(seconds: 1));

  // Check if the disconnected leaves have been deleted
  final sqlCheckDisconnected = 'SELECT LeafID FROM Leaves WHERE LeafID = ? OR LeafID = ?';
  final stmtCheckDisconnected = db.prepare(sqlCheckDisconnected);
  final resultCheckDisconnected = await stmtCheckDisconnected.select([leaf1.id, leaf2.id]);  // Assuming select is asynchronous

  expect(resultCheckDisconnected.isEmpty, true);
  stmtCheckDisconnected.dispose();

  db.dispose();
});




    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
