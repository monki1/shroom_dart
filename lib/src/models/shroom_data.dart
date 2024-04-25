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
    'list': [
      'N/A',
      List,
    ],
  };

  String type;
  dynamic value;

  ShroomData(this.type, this.value) {
    // Check type is in typeDetails
    if (!typeDetails.containsKey(type)) {
      throw ArgumentError('Invalid value type');
    }
    // Check value is of the correct type
  }

  static String getColumn(String type) {
    return typeDetails[type]![0] as String;
  }

  String get column {
    return typeDetails[type]![0] as String;
  }
}
