import 'package:shroom/shroom.dart';
import 'package:shroom/src/models/macroshroom.dart';

import 'package:test/test.dart';
import 'package:shroom/shroom_data.dart';

final testDatabaseFilePath =
    'test_database' + DateTime.now().toString() + '.db';

void main() {
  group('Shroom Tests', () {
    setUp(() {
      Shroom.init(testDatabaseFilePath);
    });

    test('Shroom Create', () async {
      // Test creating a Shroom object with a name.
      final shroom = await Shroom.create(name: 'test');
      expect(shroom, isNotNull);
      expect(shroom.shroomBase.mushroom is MacroShroom, true);
      expect(shroom.name, 'test');
    });

    test('Shroom Create without name', () async {
      // Test creating a Shroom object without a name.
      final shroom = await Shroom.create();
      expect(shroom, isNotNull);
      expect(shroom.shroomBase.mushroom is MacroShroom, false);
      expect(shroom.name, null);
    });

    test('Shroom Get by ID', () async {
      // Test getting a Shroom object by its ID.
      final createdShroom = await Shroom.create(name: 'test');
      final shroom = await Shroom.fromID(createdShroom.id);
      expect(shroom, isNotNull);
      expect(shroom!.name, 'test');
    });

    test('Shroom Get by Name', () async {
      // Test getting a Shroom object by its name.
      await Shroom.create(name: 'test');
      final shroom = await Shroom.fromName('test');
      expect(shroom, isNotNull);
      expect(shroom!.shroomBase.mushroom is MacroShroom, true);
      expect(shroom.name, 'test');
    });

    test('Shroom Set Data', () async {
      // Test setting data on a Shroom object.
      final shroom = await Shroom.create(name: 'test');
      final exampleShroomData = ShroomData('string', 'value');
      await shroom.set('key', exampleShroomData);
      final retrievedData = shroom.data['key'];

      expect(retrievedData?.type, exampleShroomData.type);
      expect(retrievedData?.value, exampleShroomData.value);
    });

    test('Shroom Remove Data', () async {
      // Test removing data from a Shroom object.
      final shroom = await Shroom.create(name: 'test');
      final data = {'key': ShroomData('string', 'value')};
      await shroom.set('key', data['key']!);
      await shroom.remove('key');
      final retrievedData = shroom.data;
      expect(retrievedData, isNot(data));
      expect(retrievedData['key'], isNull);
    });

    test('Shroom Delete', () async {
      // Test deleting a Shroom object.
      final shroom = await Shroom.create(name: 'test');
      await shroom.delete();
      final deletedShroom = await Shroom.fromName('test');
      expect(deletedShroom, isNull);
    });

    test('Shroom set name', () async {
      // Test setting the name of a Shroom object.
      final shroom = await Shroom.create();
      final id = shroom.id;
      shroom.name = 'test2';
      final updatedShroom = await Shroom.fromID(id);
      expect(updatedShroom?.name, 'test2');
    });

    test('Shroom set name to null', () async {
      // Test setting the name of a Shroom object to null.
      final shroom = await Shroom.create(name: 'test');
      final id = shroom.id;
      shroom.name = null;
      final updatedShroom = await Shroom.fromID(id);
      expect(updatedShroom?.name, null);
      expect(updatedShroom?.shroomBase.mushroom is MacroShroom, false);
    });

    tearDown(() {
      Shroom.removeDatabase();
    });
  });
}
// Compare this snippet from lib/src/models/macroshroom.dart:
