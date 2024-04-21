import '/src/shroom_base.dart';

class Shroom {
  late ShroomBase shroomBase;

  static init(String path) {
    ShroomBase.init(path);
  }

  Shroom();

  static Future<Shroom?> create({String? name = null}) async {
    try {
      Shroom sb1 = Shroom();
      if (name != null) {
        sb1.shroomBase = await ShroomBase.createShroomMacro(name);
      } else {
        sb1.shroomBase = ShroomBase.createShroom();
      }
      return sb1;
    } catch (e) {
      return null;
    }
  }

  static Future<Shroom?> fromID(int id) async {
    Shroom sb1 = Shroom();
    try {
      sb1.shroomBase = await ShroomBase.getShroomById(id);
      return sb1;
    } catch (e) {
      return null;
    }
  }

  static Future<Shroom?> fromName(String name) async {
    Shroom sb1 = Shroom();
    try {
      sb1.shroomBase = (await ShroomBase.getShroomByName(name))!;
      return sb1;
    } catch (e) {
      return null;
    }
  }

  Future<void> delete() async {
    await shroomBase.mushroom.delete();
  }

  Future<void> set(String name, String valueType, dynamic value) async {
    await shroomBase.upsert(name, valueType, value);
  }

  Future<void> remove(String name) async {
    await shroomBase.mushroom.removeLeaf(name);
  }
}
