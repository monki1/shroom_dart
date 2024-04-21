import '../shroom_data.dart';

final Map<String, List<dynamic>> typeDetails = ShroomData.typeDetails;

class ValueTypeHandler {
  static final List<String> _validTypes = typeDetails.keys.toList();

  static bool isValidType(String type) => _validTypes.contains(type);

  static Map<String, dynamic> prepareData(String valueType, dynamic value) {
    // Initialize a map to hold the null values for each possible value type.
    Map<String, dynamic> dataMap = Map.fromIterable(typeDetails.values,
        key: (item) => item[0], value: (item) => null);

    // Check if the provided valueType is valid and set the appropriate field.
    if (isValidType(valueType)) {
      String valueKey = typeDetails[valueType]![0];
      dataMap[valueKey] = value;
    }

    return dataMap;
  }

  static String prepareUpdateSql(
      Map<String, dynamic> data, String tableName, int id) {
    final columns =
        data.keys.where((key) => data[key] != null).join(' = ?, ') + ' = ?';
    return 'UPDATE $tableName SET $columns WHERE LeafID = ?';
  }

  static List<dynamic> prepareSqlValues(Map<String, dynamic> data) {
    List<dynamic> values = data.values.where((value) => value != null).toList();
    values.add(data['LeafID']); // Append the LeafID for the WHERE clause.
    return values;
  }

  static dynamic parseValue(Map<String, dynamic> result, String valueType) {
    if (!isValidType(valueType)) {
      throw ArgumentError('Unsupported value type');
    }
    return result[typeDetails[valueType]![0] as String];
  }

  static String getValueColumns() {
    return typeDetails.values.map((detail) => detail[0] as String).join(', ');
  }
}
