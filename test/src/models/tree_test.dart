import 'package:test/test.dart';
import 'package:shroom/src/models/tree.dart';
import 'package:shroom/src/sql/db.dart';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'test_database${DateTime.now().toString()}.db';

void main() {
  group('Tree Tests', () {
    late DatabaseManager dbManager;
    late Tree testTree;

    setUp(() {
      // Setup code before each test, if needed.
      dbManager = DatabaseManager(
        schemaFilePath: schemaFilePath,
        databaseFilePath: databaseFilePath,
      );
      dbManager.initDatabase();
      Tree.setDB(dbManager.getDatabase());
      testTree = Tree(name: 'fart');
    });

    test('Tree Initialization from Name', () {
      // Test the initialization of the Tree object.
      final tree = Tree(name: 'Oak');
      expect(tree.name, 'Oak');
      expect(tree.id, isNotNull);
    });

    test('Tree Initialization from ID', () {
      // Test saving a Tree object to the database.
      final tree = Tree(id: testTree.id);

      final db = dbManager.getDatabase();
      final sql = 'SELECT Name FROM Trees WHERE TreeID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([tree.id]);
      expect(result.isNotEmpty, true);
      expect(result.first['Name'], testTree.name);
      stmt.dispose();
      db.dispose();
    });

    test('Tree Delete', () {
      // Test deleting a Tree object from the database.
      final tree = Tree(name: 'Maple');

      tree.delete();

      final db = dbManager.getDatabase();
      final sql = 'SELECT Name FROM Trees WHERE TreeID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([tree.id]);
      expect(result.isEmpty, true);
      stmt.dispose();
      db.dispose();
    });

    // test('Tree Should NOT Delete With Leaves', () {
    //   // Test that a Tree object with leaves cannot be deleted.
    //   final tree = Tree('Birch');

    //   // Add a leaf to the tree
    //   final leafSql =
    //       'INSERT INTO Leaves (TreeID, ValueType, StringValue) VALUES (?, ?, ?)';
    //   final leafStmt = dbManager.getDatabase().prepare(leafSql);
    //   leafStmt.execute([tree.id, 'string', 'LeafValue']);
    //   leafStmt.dispose();

    //   // Attempt to delete the tree
    //   tree.delete();

    //   // Check if the tree still exists
    //   final db = dbManager.getDatabase();
    //   final checkSql = 'SELECT Name FROM Trees WHERE TreeID = ?';
    //   final checkStmt = db.prepare(checkSql);
    //   final checkResult = checkStmt.select([tree.id]);
    //   expect(checkResult.isNotEmpty, true);
    //   checkStmt.dispose();

    //   // Clean up
    //   final deleteLeafSql = 'DELETE FROM Leaves WHERE TreeID = ?';
    //   final deleteLeafStmt = db.prepare(deleteLeafSql);
    //   deleteLeafStmt.execute([tree.id]);
    //   deleteLeafStmt.dispose();
    // });

    tearDown(() {
      // Teardown code after each test, if needed.
      dbManager.removeDatabase();
    });
  });
}
