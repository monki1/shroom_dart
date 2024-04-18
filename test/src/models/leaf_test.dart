import 'package:test/test.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'lib/src/test_database' + DateTime.now().toString() + '.db';

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

    test('Leaf Initialization', () {
      // Test the initialization of the Leaf object
      final tree = Tree('Maple');
      final leaf = Leaf(tree: tree, valueType: 'string', value: 'Green');
      expect(leaf.tree.name, 'Maple');
      expect(leaf.valueType, 'string');
      expect(leaf.value, 'Green');
    });

    test('Leaf Save', () {
      // Test saving a Leaf object to the database
      final tree = Tree('Birch');
    //   tree.save();
      final leaf = Leaf(tree: tree, valueType: 'int', value: 42);
      leaf.save();

      final db = dbManager.getDatabase();
      final sql = 'SELECT TreeID, ValueType, IntValue FROM Leaves WHERE LeafID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([leaf.id]);
      expect(result.isNotEmpty, true);
      expect(result.first['TreeID'], tree.id);
      expect(result.first['ValueType'], 'int');
      expect(result.first['IntValue'], 42);
      stmt.dispose();
      db.dispose();
    });

    test('Leaf Delete Without Mushroom', () {
      // Test that a Leaf object without an associated mushroom can be deleted
      final tree = Tree('Willow');
      tree.save();
      final leaf = Leaf(tree: tree, valueType: 'string', value: 'Yellow');
      leaf.save();

      // Attempt to delete the leaf
      leaf.delete();

      // Check if the leaf has been deleted
      final db = dbManager.getDatabase();
      final checkSql = 'SELECT ValueType, StringValue FROM Leaves WHERE LeafID = ?';
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
