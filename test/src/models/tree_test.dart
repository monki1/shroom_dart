import 'package:test/test.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'lib/src/test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Tree Tests', () {
    late DatabaseManager dbManager;

    setUp(() {
      // Setup code before each test, if needed.
      dbManager = DatabaseManager(
        schemaFilePath: schemaFilePath,
        databaseFilePath: databaseFilePath,
      );
      dbManager.initDatabase();
      Tree.setDB(dbManager.getDatabase());
    });

    test('Tree Initialization', () {
      // Test the initialization of the Tree object.
      final tree = Tree('Oak');
      expect(tree.name, 'Oak');
    });

    test('Tree Save', () {
      // Test saving a Tree object to the database.
      final tree = Tree('Pine');


      final db = dbManager.getDatabase();
      final sql = 'SELECT Name FROM Trees WHERE TreeID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([tree.id]);
      expect(result.isNotEmpty, true);
      expect(result.first['Name'], 'Pine');
      stmt.dispose();
      db.dispose();
    });

    test('Tree Delete', ()  {
      // Test deleting a Tree object from the database.
      final tree = Tree('Maple');
      

      tree.delete();

      final db = dbManager.getDatabase();
      final sql = 'SELECT Name FROM Trees WHERE TreeID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([tree.id]);
      expect(result.isEmpty, true);
      stmt.dispose();
      db.dispose();
    });

    test('Tree Should NOT Delete With Leaves', ()  {
      // Test that a Tree object with leaves cannot be deleted.
      final tree = Tree('Birch');
      

      // Add a leaf to the tree
      final leafSql = 'INSERT INTO Leaves (TreeID, ValueType, StringValue) VALUES (?, ?, ?)';
      final leafStmt = dbManager.getDatabase().prepare(leafSql);
      leafStmt.execute([tree.id, 'string', 'LeafValue']);
      leafStmt.dispose();

      // Attempt to delete the tree
      tree.delete();

      // Check if the tree still exists
      final db = dbManager.getDatabase();
      final checkSql = 'SELECT Name FROM Trees WHERE TreeID = ?';
      final checkStmt = db.prepare(checkSql);
      final checkResult = checkStmt.select([tree.id]);
      expect(checkResult.isNotEmpty, true);
      checkStmt.dispose();

      // Clean up
      final deleteLeafSql = 'DELETE FROM Leaves WHERE TreeID = ?';
      final deleteLeafStmt = db.prepare(deleteLeafSql);
      deleteLeafStmt.execute([tree.id]);
      deleteLeafStmt.dispose();
    });

    test('Get Tree By ID', () {
      // Test retrieving a Tree object by ID.
      final tree = Tree('Willow');
      

      final retrievedTree = Tree.getTreeById(tree.id!);
      expect(retrievedTree, isNotNull);
      expect(retrievedTree!.name, 'Willow');
    });

    tearDown(() {
      // Teardown code after each test, if needed.
      dbManager.removeDatabase();
    });
  });
}
