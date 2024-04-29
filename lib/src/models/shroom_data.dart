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
  int? id;

  ShroomData(this.type, this.value) {
    // Check type is in typeDetails
    if (!isValidType(type)) {
      throw ArgumentError('Invalid value type');
    }
  }

  String get tableName {
    return typeDetails[type]![0] as String;
  }

  @override
  String toString() {
    return 'Type: $type, Value: ${value is List ? [
        for (var item in value) item.toString()
      ] : value}';
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
