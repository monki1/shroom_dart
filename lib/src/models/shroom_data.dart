class ShroomData {
  static Map<String, List<dynamic>> typeDetails = {
    'int': [
      //type String
      'IntValue', //sql column name
      int, //dart type
    ],
    'float': [
      'FloatValue',
      double,
    ],
    'string': [
      'StringValue',
      String,
    ],
    'binary': [
      'BinaryValue',
      List<int>,
    ],
    'mushroom': [
      'MushroomValue',
      int,
    ],
    'bool': [
      'BoolValue', //sql type: BIT
      int, //0 or 1
    ],
    'list': [
      'N/A',
      List,
    ],
  };

  String type;
  dynamic value;

  ShroomData(this.type, this.value) {
    // Check type is in typeDetails
    if (!isValidType(type)) {
      throw ArgumentError('Invalid value type');
    }
  }

  static String getColumnString(String type) {
    return typeDetails[type]![0] as String;
  }

  static String get allColumnsString {
    //if not N/A, join the column names with a comma
    return typeDetails.values
        .where((element) => element[0] != 'N/A')
        .map((e) => e[0] as String)
        .join(', ');
  }

  String get column {
    return typeDetails[type]![0] as String;
  }

  static bool isValidType(String type) {
    return typeDetails.containsKey(type);
  }
}
