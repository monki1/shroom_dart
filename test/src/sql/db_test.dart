import 'package:test/test.dart';
import 'package:shroom/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'test_database${DateTime.now().toString()}.db';

void main() {
  group('DatabaseManager Tests', () {
    late DatabaseManager dbManager;

    setUp(() {
      // Setup code before each test
      dbManager = DatabaseManager(
        schemaFilePath: schemaFilePath,
        databaseFilePath: databaseFilePath,
      );
    });
// THIS IS INCLUDED IN GET DATABASE TEST
    // test('Database Initialization', () {
    //   // Test the initialization of the database
    //   dbManager.initDatabase();
    //   final dbFile = File(dbManager.databaseFilePath);
    //   expect(dbFile.existsSync(), true);
    // });

    test('Get Database', () {
      // Test getting the database
      final db = dbManager.getDatabase();
      expect(db, isNotNull);
      db.dispose();
      dbManager.removeDatabase();
    });

    test('Remove Database', () async {
      // Test removing the database
      dbManager.getDatabase();
      dbManager.removeDatabase();
      final dbFile = File(dbManager.databaseFilePath);
      expect(await dbFile.exists(), false);
    });

    //test prune database

    tearDown(() {
      // Teardown code after each test
      // dbManager.removeDatabase();
    });
  });
}
