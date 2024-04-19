import 'package:test/test.dart';
import '../../lib/src/shroom_base.dart';
import '../../lib/src/models/mushroom.dart';
import '../../lib/src/models/macroshroom.dart';
import '../../lib/src/sql/db.dart';


void main() {
  group('ShroomBase Tests', () {
    late ShroomBase shroomBase1;

    setUp(() {
      ShroomBase.init("test_database" + DateTime.now().toString() + ".db");

    });

    test('createShroom', () {
        shroomBase1 = ShroomBase.createShroom();
        expect(shroomBase1.mushroom is Mushroom, true);
        expect(! (shroomBase1.mushroom is MacroShroom), true);

    });

    test('create shroom macro', () async {
      shroomBase1 = await ShroomBase.createShroomMacro("test");
      expect(shroomBase1.mushroom is MacroShroom, true);



    });

    test('get shroom by id', () async {
      shroomBase1 = await ShroomBase.createShroomMacro("test");
      final shroomBase2 = await ShroomBase.getShroomById(shroomBase1.mushroom.id!);
      expect(shroomBase1.mushroom.id!, shroomBase2.mushroom.id!);
      expect((shroomBase1.mushroom is MacroShroom), true);

    });


    tearDown(() {
      ShroomBase.removeDatabase();

 
    });

    });
}