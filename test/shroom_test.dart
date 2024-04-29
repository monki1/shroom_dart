import 'package:shroom/shroom.dart';

import 'package:test/test.dart';

final testDatabaseFilePath =
    'test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Shroom Tests', () {
    setUp(() {
      Shroom.initDB(path: testDatabaseFilePath);
    });

    test('Shroom Create', () async {
      Shroom shroom = Shroom(name: 'test');
      expect(shroom.name, 'test');
      expect(shroom.id, isNotNull);
      expect(shroom.data, {});
    });

    test('Shroom Create without name', () async {
      Shroom shroom = Shroom();
      expect(shroom.name, isNull);
      expect(shroom.id, isNotNull);
      expect(shroom.data, {});
    });

    test('Shroom Get by ID', () async {
      Shroom shroom = Shroom(name: 'test');
      Shroom shroom2 = Shroom(id: shroom.id);
      expect(shroom2.name, 'test');
      expect(shroom2.id, shroom.id);
      expect(shroom2.data, {});
    });

    test('Shroom Get by Name', () async {
      Shroom shroom = Shroom(name: 'test');
      Shroom shroom2 = Shroom(name: 'test');
      expect(shroom2.name, 'test');
      expect(shroom2.id, shroom.id);
      expect(shroom2.data, {});
    });

    test('Shroom set Occupied name throws exeption', () async {
      Shroom(name: 'test');
      expect(() => Shroom().name = 'test', throwsException);
    });

    test('Shroom Set Data', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.upsert('test', ShroomData('string', 'test'));
      expect(shroom.data['test']!.value, 'test');
    });

    test('Shroom Set List', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.upsert(
          'test',
          ShroomData(
              'list', [ShroomData('string', 'string'), ShroomData('int', 1)]));
      Shroom shroom2 = Shroom(name: 'test');
      expect(shroom2.data['test']!.value[0].value, 'string');
      expect(shroom2.data['test']!.value[1].value, 1);
    });

    test('Shroom Set Bool', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.upsert('test', ShroomData('bool', false));
      expect(Shroom(name: 'test').data['test']!.value, 0);
    });

    test('Shroom Set 3D List', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.upsert(
          'test',
          ShroomData('list', [
            ShroomData('int', 1),
            ShroomData('int', 2),
            ShroomData('list', [
              ShroomData('list', [
              ShroomData('string', 'string'),
              ]),
            ]),
            // ])
          ]));

      // await Future.delayed(Duration(seconds: 1), () {});
      Shroom shroom2 = Shroom(name: 'test');
      print(shroom2.data['test']!);

      expect(shroom2.data['test'].toString()==shroom.data['test'].toString(), true);
    });

    test('Shroom Remove Data', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.upsert('test', ShroomData('string', 'test'));
      shroom.remove('test');
      expect(Shroom(name: 'test').data, {});
    });

    test('Shroom Delete', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.delete();
      expect(() => Shroom(id: shroom.id), throwsException);
    });

    test('Shroom set name', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.name = 'test2';
      expect(Shroom(name: 'test2').id, shroom.id);
    });

    test('Shroom set name to null', () async {
      Shroom shroom = Shroom(name: 'test');
      shroom.name = null;
      expect(Shroom(id: shroom.id).name, isNull);
    });

    tearDown(() {
      Shroom.deleteDB(path: testDatabaseFilePath);
    });
  });
}
// Compare this snippet from lib/src/models/macroshroom.dart:
