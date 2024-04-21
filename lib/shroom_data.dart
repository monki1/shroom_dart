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
    ], // Assuming mushroom values are stored as int
    'spell': [
      'SpellValue',
      String,
    ], // Assuming spell values are stored as String
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
}
