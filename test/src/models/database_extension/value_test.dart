import 'package:shroom/src/models/database_extension/leaf.dart';
import 'package:shroom/src/models/database_extension/mushroom.dart';
import 'package:shroom/src/models/database_extension/tree.dart';
import 'package:test/test.dart';
import 'package:shroom/src/sql/db.dart';
import 'package:shroom/src/models/database_extension/value.dart';
import 'package:shroom/src/models/shroom_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shroom/src/models/database_extension/list.dart';

void main() {
  group('Value Extension Tests', () {
    late DatabaseManager dbManager;
    late Database db;
    late int shroomID;
    late int treeID;

    setUp(() {
      // Set up the real database for testing
      dbManager = DatabaseManager(
          schemaFilePath: 'lib/src/sql/schema.sql',
          databaseFilePath: 'test_value_extension.db');
      dbManager.initDatabase();
      db = dbManager.getDatabase();
      shroomID = db.createEmptyMushroom();
      treeID = db.getTreeIDfromName('testTree');
    });

    test('Test Save and Retrieve Value', () {
      var testData = ShroomData('string', 'testValue');
      int valueID = db.saveValue(testData.tableName, testData);
      ShroomData retrievedData = db.getValue('string', valueID);

      expect(retrievedData.value, equals('testValue'));
    });

    test('Test Save and Retrieve List', () async {
      var listData = ShroomData(
          'list', [ShroomData('string', 'testString'), ShroomData('int', 123)]);
      int leafID = db.addLeaf(shroomID, treeID, listData);
      ShroomData retrievedList = db.getList(leafID);
      print(retrievedList);
      Future.delayed(Duration(seconds: 1));

      expect(retrievedList.value[0].value, 'testString');
      expect(retrievedList.value[1].value, 123);
    });

    test('Test Save and Retrieve Nested List', () {
      var nestedListData = ShroomData('list', [
        ShroomData('string', 'outerString'),
        ShroomData('list',
            [ShroomData('string', 'innerString'), ShroomData('int', 456)])
      ]);

      int leafid = db.addLeaf(shroomID, treeID,
          nestedListData); // Again, `2` is a placeholder LeafID
      ShroomData retrievedNestedList = db.getList(leafid);

      expect(retrievedNestedList.value[0].value, 'outerString');
      expect(retrievedNestedList.value[1].value[0].value, 'innerString');
      expect(retrievedNestedList.value[1].value[1].value, 456);
    });

    test('Test Delete Value', () {
      var testData = ShroomData('int', 42);
      int valueID = db.saveValue(testData.tableName, testData);
      db.deleteValue('int', valueID);

      expect(() => db.getValue('int', valueID), throwsException);
    });

    tearDown(() {
      db.dispose();
      dbManager.removeDatabase();
    });
  });
}
