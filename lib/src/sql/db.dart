import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

class DatabaseManager {
  final String schemaFilePath;
  final String databaseFilePath;
  late String dbPath;

  DatabaseManager({required this.schemaFilePath, required this.databaseFilePath}) {
    dbPath = databaseFilePath;
  }

  Database getDatabase() {
    final dbFile = File(dbPath);
    if (!dbFile.existsSync()) {
      initDatabase();
    }
    return sqlite3.open(dbPath);
  }

  void initDatabase() {
    final schema = _readSqlSchema(schemaFilePath);
    if (schema.isNotEmpty) {
      final dbFile = File(dbPath);
      if (!dbFile.existsSync()) {
        _initializeDatabase(schema, dbPath);
      } else {
        print('Database already exists. No action taken.');
      }
    }
  }

  void _initializeDatabase(String schema, String dbPath) {
    try {
      final db = sqlite3.open(dbPath);
      db.execute(schema);
      print('Database initialized successfully. Database file: $dbPath');
      db.dispose();
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  String _readSqlSchema(String filePath) {
    try {
      return File(filePath).readAsStringSync();
    } catch (e) {
      print('Error reading schema file: $e');
      return '';
    }
  }

  void removeDatabase() {
    final file = File(dbPath);
    if (file.existsSync()) {
      file.delete();
      print('Database removed successfully. Database file: $dbPath');
    } else {
      print('Database does not exist. No action taken.');
    }
  }

  /// Asynchronously deletes mushrooms that are not referenced in MacroShroomNames and not associated with any leaf in Mycelium.
  void prune() {
    final db = getDatabase();
    try {
      const sql = '''
        DELETE FROM Mushrooms
        WHERE MushroomID NOT IN (SELECT MushroomID FROM MacroShroomNames)
        AND MushroomID NOT IN (SELECT MushroomID FROM Mycelium);
      ''';
      db.execute(sql); // Using executeAsync if supported, or handle the async operation differently
      print('Pruning complete: Unreferenced mushrooms have been deleted.');
    } catch (e) {
      print('Error during pruning: $e');
    } finally {
      db.dispose();
    }
  }
}
