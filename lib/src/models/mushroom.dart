import 'package:shroom/shroom.dart';
import 'package:shroom/src/models/database_extension/leaf.dart';
import 'package:shroom/src/models/database_extension/name.dart';
import 'package:shroom/src/models/database_extension/tree.dart';
import 'package:shroom/src/models/database_extension/mushroom.dart';
import 'package:sqlite3/sqlite3.dart';

class Mushroom {
  final Map<String, ShroomData> _data = {};
  Map<String, ShroomData> get data => _data;
  String? _name;
  String? get name => _name;
  set name(String? name) {
    if (name != null) {
      _name = name;
      _db.setName(name, id);
    } else {
      _name = null;
      _db.deleteName(id);
    }
  }

  late int id;
  static String tableName = 'Mushrooms';
  static late Database _db;
  static void setDB(Database db) {
    _db = db;
  }

  Mushroom({int? id, String? name}) {
    if (name != null) {
      _name = name;
      try {
        this.id = _db.getMushroomIDfromName(name);
      } catch (e) {
        this.id = _db.createEmptyMushroom();
        this.name = name;
        return;
      }
    } else if (id != null) {
      if (_db.checkMushroomExists(id) == false) {
        throw Exception('Mushroom with id $id not found');
      }
      this.id = id;
      //try to get the name from the database
      try {
        _name = _db.getNameFromMushroomID(id);
      } catch (e) {
        _name = null;
      }
    } else {
      this.id = _db.createEmptyMushroom();
      return;
    }
    _data.addAll(_db.getLeaves(this.id));
    return;
  }

  //IMPLEMENT : function addLeaf(Leaf): check if leaf from the same tree exists. if yes then remove the previous leaf first, add mycelium to the database,
  upsert(String treeName, ShroomData data) {
    //if tree name exists in the data, remove the leaf first
    if (_data.containsKey(treeName)) {
      remove(treeName);
    }
    _db.addLeaf(id, _db.getTreeIDfromName(treeName), data);
    _data.addAll({treeName: data});
  }

  //IMPLEMENT : function removeLeaf(TreeName String):
  remove(String treeName) {
    // Attempt to find a leaf associated with the given tree name
    //if no leaf of that tree name is found, throw an exception
    if (!_data.containsKey(treeName)) {
      throw Exception('Leaf with tree name $treeName not found');
    }
    //remove the leaf from the database
    _db.deleteLeaf(id, _db.getTreeIDfromName(treeName));
    _db.deleteTreeByName(treeName);
    _data.remove(treeName);
  }

  delete() {
    if (_name != null) {
      _db.deleteName(id);
    }
    _db.deleteLeaves(id);
    _db.deleteMushroom(id);
  }
}
