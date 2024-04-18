import 'package:test/test.dart';
import '../../../lib/src/models/macroshroom.dart';
import '../../../lib/src/models/mushroom.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'lib/src/test_database' + DateTime.now().toString() + '.db';
// void main(){}
void main() {
  group('MacroShroom Tests', () {
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
      MacroShroom.setDB(dbManager.getDatabase());
    });

    test('MacroShroom Initialization', () {
      final tree = Tree('Oak');
      final leaf1 = Leaf(tree: tree, valueType: 'string', value: 'Red');
      final macroShroom = MacroShroom('Big Red', [leaf1]);

      expect(macroShroom.name, 'Big Red');
      expect(macroShroom.leaves.length, 1);
      expect(macroShroom.leaves.first.value, 'Red');
    });


    test('MacroShroom Delete', () {
      final tree = Tree('Pine');
      final leaf1 = Leaf(tree: tree, valueType: 'float', value: 10.5);
      final macroShroom = MacroShroom('Floating Pine', [leaf1]);


      macroShroom.delete();

      final db = dbManager.getDatabase();
      final sql = 'SELECT Name FROM MacroShroomNames WHERE MushroomID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([macroShroom.id]);

      expect(result.isEmpty, true);
      stmt.dispose();
      db.dispose();
    });

    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
