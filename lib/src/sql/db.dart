import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

class DatabaseManager {
  final String schemaFilePath;
  final String databaseFilePath;

  DatabaseManager(
      {required this.schemaFilePath, required this.databaseFilePath}) {}

  Database getDatabase() {
    final dbFile = File(databaseFilePath);
    if (!dbFile.existsSync()) {
      initDatabase();
    }
    return sqlite3.open(databaseFilePath);
  }

  void initDatabase() {
    final schema = _readSqlSchema(schemaFilePath);
    if (schema.isNotEmpty) {
      final dbFile = File(databaseFilePath);
      if (!dbFile.existsSync()) {
        _initializeDatabase(schema, databaseFilePath);
      } else {
        print('Database already exists. No action taken.');
      }
    }
  }

  void _initializeDatabase(String schema, String databaseFilePath) {
    try {
      final db = sqlite3.open(databaseFilePath);
      db.execute(schema);
      // print('Database initialized successfully. Database file: $databaseFilePath');
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
    final file = File(databaseFilePath);
    if (file.existsSync()) {
      file.delete();
      // print('Database removed successfully. Database file: $databaseFilePath');
    } else {
      print('Database does not exist. No action taken.');
    }
  }
}
