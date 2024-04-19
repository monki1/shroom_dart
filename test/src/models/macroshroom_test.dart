import 'package:test/test.dart';
import '../../../lib/src/models/macroshroom.dart';
import '../../../lib/src/models/mushroom.dart';
import '../../../lib/src/models/leaf.dart';
import '../../../lib/src/models/tree.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath =
    'lib/src/test_database' + DateTime.now().toString() + '.db';

void main() {
  group('MacroShroom Tests', () {
    late DatabaseManager dbManager;
    late Tree testTree;
    late Mushroom mushroom;
    late MacroShroom macroshroom;
    late Leaf leaf;

    setUp(() async {
      dbManager = DatabaseManager(
        schemaFilePath: schemaFilePath,
        databaseFilePath: databaseFilePath,
      );
      dbManager.initDatabase();
      Tree.setDB(dbManager.getDatabase());
      Leaf.setDB(dbManager.getDatabase());
      Mushroom.setDB(dbManager.getDatabase());
      MacroShroom.setDB(dbManager.getDatabase());
      testTree = Tree('Oak');
      mushroom = Mushroom();
      leaf = Leaf(tree: testTree, valueType: 'string', value: 'Yellow');
      await mushroom.addLeaf(leaf);
      macroshroom = await MacroShroom.fromMushroom("test", mushroom);
    });

    //     //check if name is in macroshroomNames table with correct mushroomID
    test('MacroShroom Initialization', () async {
      Future.delayed(Duration(seconds: 1));
      final db = dbManager.getDatabase();

      // Print all the rows in the MacroShroomNames table
      final sql2 = 'SELECT * FROM MacroShroomNames';
      final stmt2 = db.prepare(sql2);
      final result2 = stmt2.select([]);
      print("result2" + result2.toString());

      expect(macroshroom.name, 'test');
      expect(macroshroom.id, mushroom.id);

      expect(macroshroom.leaves.isNotEmpty, true);
      expect(macroshroom.leaves.first.tree.name, 'Oak');

      final sql = 'SELECT * FROM MacroShroomNames WHERE MushroomID = ?';

      final stmt = db.prepare(sql);
      final result = stmt.select([mushroom.id]);
      expect(result.isNotEmpty, true);
      expect(result.first['Name'], 'test');
      expect(result.first['MushroomID'], mushroom.id);

      stmt.dispose();
      db.dispose();
    });

    //test setName
    test('Set Name', () async {
      await macroshroom.setName("test4");
      final db = dbManager.getDatabase();
      final sql = 'SELECT * FROM MacroShroomNames WHERE MushroomID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([mushroom.id]);
      expect(result.isNotEmpty, true);
      expect(result.first['Name'], 'test4');
      expect(result.first['MushroomID'], mushroom.id);
      stmt.dispose();
      db.dispose();
    });
    //     //delete => delete from macroshroomNames
    test('Delete', () {
      macroshroom.delete();
      final db = dbManager.getDatabase();
      final sql = 'SELECT * FROM MacroShroomNames WHERE MushroomID = ?';
      final stmt = db.prepare(sql);
      final result = stmt.select([mushroom.id]);
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
