import 'package:test/test.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath =
    'lib/src/test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Leaf Tests', () {
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
      // Mushroom.setDB(dbManager.getDatabase());
    });

    test('get leaf by id', () {
      final tree = Tree('Maple');
      final leaf = Leaf(tree: tree, valueType: 'string', value: 'Green');
      final leaf2 = Leaf.getLeafById(leaf.id!);
      expect(leaf2.id, leaf.id);
      expect(leaf2.tree.name, leaf.tree.name);
      expect(leaf2.valueType, leaf.valueType);
      expect(leaf2.value, leaf.value);
    });

    test('Leaf Initialization - String', () {
      // Test the initialization of the Leaf object
      final tree = Tree('Maple');
      final leaf = Leaf(tree: tree, valueType: 'string', value: 'Green');
      expect(leaf.tree.name, 'Maple');
      expect(leaf.valueType, 'string');
      expect(leaf.value, 'Green');
    });

    test('Leaf Initialization - Int', () {
      // Test the initialization of the Leaf object
      final tree = Tree('Maple');
      final leaf = Leaf(tree: tree, valueType: 'int', value: 42);
      expect(leaf.tree.name, 'Maple');
      expect(leaf.valueType, 'int');
      expect(leaf.value, 42);
    });

    test('Leaf Initialization - Float', () {
      // Test the initialization of the Leaf object
      final tree = Tree('Maple');
      final leaf = Leaf(tree: tree, valueType: 'float', value: 42.555);
      expect(leaf.tree.name, 'Maple');
      expect(leaf.valueType, 'float');
      expect(leaf.value, 42.555);
    });

    test('Leaf Initialization - Binary', () {
      // Setup a tree for the leaf
      final tree = Tree('Cedar');

      // Create a binary data array
      List<int> binaryData = [0, 255, 127, 128];

      // Initialize the leaf with binary data
      final leaf = Leaf(tree: tree, valueType: 'binary', value: binaryData);

      // Save the leaf to the database

      // Fetch the leaf from the database to verify it was saved correctly
      final db = dbManager.getDatabase();
      final sql =
          'SELECT TreeID, ValueType, BinaryValue FROM Leaves WHERE LeafID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([leaf.id]);

      // Check that the database entry matches the input
      expect(result.isNotEmpty, true);
      expect(result.first['TreeID'], tree.id);
      expect(result.first['ValueType'], 'binary');
      expect(result.first['BinaryValue'], binaryData);
    });

    test('Leaf Initialization - Spell', () {
      // Setup a tree for the leaf
      final tree = Tree('Birch');

      // Initialize the leaf with a spell type
      final spellDescription = 'Invisibility';
      final leaf =
          Leaf(tree: tree, valueType: 'spell', value: spellDescription);

      // Fetch the leaf from the database to verify it was saved correctly
      final db = dbManager.getDatabase();
      final sql =
          'SELECT TreeID, ValueType, SpellValue FROM Leaves WHERE LeafID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([leaf.id]);

      // Check that the database entry matches the input
      expect(result.isNotEmpty, true);
      expect(result.first['TreeID'], tree.id);
      expect(result.first['ValueType'], 'spell');
      expect(result.first['SpellValue'], spellDescription);

      // Clean up
      stmt.dispose();
      db.dispose();
    });

    test('Leaf Initialization - Mushroom', () {
      // Setup a tree for the leaf
      final tree = Tree('Elm');

      // Example Mushroom ID
      final exampleMushroomId = 1;

      // Initialize the leaf with a mushroom type
      final leaf =
          Leaf(tree: tree, valueType: 'mushroom', value: exampleMushroomId);

      // Fetch the leaf from the database to verify it was saved correctly
      final db = dbManager.getDatabase();
      final sql =
          'SELECT TreeID, ValueType, MushroomValue FROM Leaves WHERE LeafID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([leaf.id]);

      // Check that the database entry matches the input
      expect(result.isNotEmpty, true);
      expect(result.first['TreeID'], tree.id);
      expect(result.first['ValueType'], 'mushroom');
      expect(result.first['MushroomValue'], exampleMushroomId);

      // Clean up
      stmt.dispose();
      db.dispose();
    });

    //TESTED IN INITIALIZATION
    // test('Leaf Save', () {
    //   // Test saving a Leaf object to the database
    //   final tree = Tree('Birch');
    // //   tree.save();
    //   final leaf = Leaf(tree: tree, valueType: 'int', value: 42);
    //

    //   final db = dbManager.getDatabase();
    //   final sql = 'SELECT TreeID, ValueType, IntValue FROM Leaves WHERE LeafID = ?';
    //   final stmt = db.prepare(sql);
    //   final result = stmt.select([leaf.id]);
    //   expect(result.isNotEmpty, true);
    //   expect(result.first['TreeID'], tree.id);
    //   expect(result.first['ValueType'], 'int');
    //   expect(result.first['IntValue'], 42);
    //   stmt.dispose();
    //   db.dispose();
    // });

    test('Leaf Delete', () {
      // Test that a Leaf object without an associated mushroom can be deleted
      final tree = Tree('Willow');
      final leaf = Leaf(tree: tree, valueType: 'string', value: 'Yellow');

      // Attempt to delete the leaf
      leaf.delete();

      // Check if the leaf has been deleted
      final db = dbManager.getDatabase();
      final checkSql =
          'SELECT ValueType, StringValue FROM Leaves WHERE LeafID = ?';
      final checkStmt = db.prepare(checkSql);
      final checkResult = checkStmt.select([leaf.id]);
      expect(checkResult.isEmpty, true);
      checkStmt.dispose();
    });

    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
