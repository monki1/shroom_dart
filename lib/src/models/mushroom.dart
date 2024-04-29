import 'package:shroom/shroom.dart';
import 'package:shroom/src/models/database_extension/database_extension.dart';
import 'package:sqlite3/sqlite3.dart';

class Mushroom {
  static late Database _db;
  static void setDB(Database db) {
    _db = db;
  }

  late int id;
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

  Mushroom.get({int? id, String? name}) {
    if (name != null) {
      _name = name;
      try {
        this.id = _db.getMushroomIDfromName(name);
      } catch (e) {
        throw Exception('Mushroom with name $name not found');
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
      throw Exception('Mushroom not found');
    }
    _data.addAll(_db.getLeaves(this.id));
    return;
  }

  Mushroom.create(String? name) {
    if (name != null) {
      _name = name;
      try {
        _db.getMushroomIDfromName(name);
        throw Exception('Mushroom with name $name already exists');
      } catch (e) {
        id = _db.createEmptyMushroom();
        this.name = name;
      }
    } else {
      id = _db.createEmptyMushroom();
    }
    _data.addAll(_db.getLeaves(id));
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
