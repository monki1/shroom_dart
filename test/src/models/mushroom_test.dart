import 'package:test/test.dart';
import 'package:shroom/src/models/mushroom.dart';
import 'package:shroom/src/sql/db.dart';

void main() {
  group('Mushroom Tests', () {
    late DatabaseManager dbManager;
    // late Mushroom mushroom;

    setUp(() {
      dbManager = DatabaseManager(
        schemaFilePath: 'lib/src/sql/schema.sql',
        databaseFilePath: 'test_database${DateTime.now().toString()}.db',
      );
      dbManager.initDatabase();
      Mushroom.setDB(dbManager.getDatabase());
      // mushroom = Mushroom();
    });

    test('Add/Remove Leaf to Mushroom', () async {});

    //test init mushroom from id
    test('Mushroom Initialization from ID', () {});

    test('Mushroom Deletion', () async {});

    tearDown(() {
      // Teardown code after each test
      dbManager.removeDatabase();
    });
  });
}
