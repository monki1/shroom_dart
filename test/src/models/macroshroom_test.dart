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
void main() {   }