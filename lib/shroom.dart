import '/src/shroom_base.dart';
import '/shroom_data.dart';
import '/src/models/leaf.dart';

class Shroom {
  late ShroomBase shroomBase;

  static init(String path) {
    ShroomBase.init(path);
  }

  static removeDatabase() {
    ShroomBase.dbManager.removeDatabase();
  }

  Shroom();

  static Future<Shroom> create({String? name = null}) async {
    // try {
    Shroom sb1 = Shroom();
    if (name != null) {
      sb1.shroomBase = await ShroomBase.createShroomMacro(name);
    } else {
      sb1.shroomBase = ShroomBase.createShroom();
    }
    return sb1;
    // } catch (e) {
    //   return null;
    // }
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

  Map<String, ShroomData> get data {
    List<Leaf> leaves = shroomBase.mushroom.leaves;
    Map<String, ShroomData> data = {};
    for (Leaf leaf in leaves) {
      data[leaf.tree.name] = ShroomData(leaf.valueType, leaf.value);
    }
    return data;
  }

  Future<void> delete() async {
    await shroomBase.mushroom.delete();
  }

  Future<void> set(String name, ShroomData shroomData) async {
    await shroomBase.upsert(name, shroomData.type, shroomData.value);
  }

  Future<void> remove(String name) async {
    await shroomBase.mushroom.removeLeaf(name);
  }

  int get id {
    return shroomBase.id;
  }

  String? get name {
    return shroomBase.name;
  }

  set name(String? name) {
    shroomBase.name = name;
  }
}
