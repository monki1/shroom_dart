import 'dart:convert';

import 'package:shroom/shroom.dart';

import 'package:test/test.dart';

final testDatabaseFilePath =
    'test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Shroom Tests', () {
    setUp(() {
      Shroom.initDB(path: testDatabaseFilePath);
    });

    test('Shroom Create', () async {});

    test('Shroom Create without name', () async {});

    test('Shroom Get by ID', () async {});

    test('Shroom Get by Name', () async {});

    test('Shroom create Occupied name throws exeption', () async {});

    test('Shroom Set Data', () async {});

    test('Shroom Set List', () async {});

    test('Shroom Set Bool', () async {});

    test('Shroom Set 3D List', () async {});

    test('Shroom Remove Data', () async {});

    test('Shroom Delete', () async {});

    test('Shroom set name', () async {});

    test('Shroom set name to null', () async {});

    tearDown(() {
      Shroom.deleteDB(path: testDatabaseFilePath);
    });
  });
}
// Compare this snippet from lib/src/models/macroshroom.dart:
