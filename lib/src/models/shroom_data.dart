class ShroomData {
  static Map<String, List<dynamic>> typeDetails = {
    'int': [
      //type String
      'int', //sql table name
      int, //dart type
    ],
    'float': [
      'float',
      double,
    ],
    'string': [
      'string',
      String,
    ],
    'binary': [
      'binary',
      List<int>,
    ],
    'mushroom': [
      'mushroom',
      int,
    ],
    'bool': [
      'bool', //sql type: BIT
      bool, //or int: (0 or 1 ) or (true or false)
    ],
    'list': [
      'list_item',
      List,
    ],
  };

  static bool isValidType(String type) {
    return typeDetails.containsKey(type);
  }

  static String getTableName(String type) {
    return typeDetails[type]![0] as String;
  }

  String type;
  dynamic value;

  ShroomData(this.type, this.value) {
    // Check type is in typeDetails
    if (!isValidType(type)) {
      throw ArgumentError('Invalid value type');
    }
  }

  String get tableName {
    return typeDetails[type]![0] as String;
  }

  String _toString({String indent = ""}) {
    var valueRepresentation = value;

    // Handle list types differently to encode each item.
    if (type == 'list' && value is List) {
      String newIndent = indent + "  ";

      valueRepresentation = value.map((item) {
        return "\n" + item._toString(indent: newIndent);
      }).toList();
    }

    // Create a map of the data to be encoded to JSON.
    Map<String, dynamic> dataMap = {
      "type": type,
      'Value': valueRepresentation,
    };

    return indent + dataMap.toString();
  }

  @override
  String toString() {
    return _toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is ShroomData) {
      if (other.type == type) {
        if (type == 'list') {
          if (other.value.length == value.length) {
            for (int i = 0; i < value.length; i++) {
              if (value[i] != other.value[i]) {
                return false;
              }
            }
            return true;
          }
        } else {
          return other.value == value;
        }
      }
    }
    return false;
  }
}
