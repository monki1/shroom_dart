class ShroomData {
  static Map<String, List<dynamic>> typeDetails = {
    'int': ['IntValue', int],
    'float': ['FloatValue', double],
    'string': ['StringValue', String],
    'mushroom': [
      'MushroomValue',
      int
    ], // Assuming mushroom values are stored as int
    'spell': [
      'SpellValue',
      String
    ], // Assuming spell values are stored as String
    'binary': [
      'BinaryValue',
      List<int>
    ] // Assuming binary values are stored as List<int>
  };

  String type;
  dynamic value;

  ShroomData(this.type, this.value);
}
