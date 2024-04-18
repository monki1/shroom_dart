import 'package:test/test.dart';
import '../../../lib/src/sql/db.dart';
import 'dart:io';

const String schemaFilePath = 'lib/src/sql/schema.sql';
final String databaseFilePath = 'lib/src/test_database' + DateTime.now().toString() + '.db';

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
    test('Database Initialization', () {
      // Test the initialization of the database
      dbManager.initDatabase();
      final dbFile = File(dbManager.databaseFilePath);
      expect(dbFile.existsSync(), true);
    });

    test('Get Database', () {
      // Test getting the database
      final db = dbManager.getDatabase();
      expect(db, isNotNull);
      db.dispose();
    });

    test('Remove Database', () {
      // Test removing the database
      dbManager.initDatabase();
      dbManager.removeDatabase();
      final dbFile = File(dbManager.databaseFilePath);
      expect(dbFile.existsSync(), false);
    });

    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
