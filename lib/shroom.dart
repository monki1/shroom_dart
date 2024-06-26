import 'package:shroom/src/models/mushroom.dart';
import 'package:shroom/src/sql/db.dart';

export 'src/models/shroom_data.dart';

// ignore: constant_identifier_names
const String SCHEMA_PATH = 'lib/src/sql/schema.sql';
// ignore: constant_identifier_names
const String DEFAULT_DB_PATH = 'shroom.db';

class Shroom extends Mushroom {
  static late String _path;

  static initDB({String? path}) {
    _path = path ?? DEFAULT_DB_PATH;
    DatabaseManager dbManager = DatabaseManager(
      schemaFilePath: SCHEMA_PATH,
      databaseFilePath: _path,
    );
    dbManager.initDatabase();
    Mushroom.setDB(dbManager.getDatabase());
  }

  static deleteDB({String? path}) {
    DatabaseManager dbManager = DatabaseManager(
      schemaFilePath: SCHEMA_PATH,
      databaseFilePath: path ?? _path,
    );
    dbManager.removeDatabase();
  }

  Shroom({super.name, super.id});

  Shroom.get({super.id, super.name});

  // ignore: use_super_parameters
  Shroom.create({name}) : super.create(name);
}
