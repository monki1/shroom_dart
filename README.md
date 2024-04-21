# Shroom Class README

## Introduction

The Shroom class is a part of a larger project that involves managing data using a tree-like structure. It provides a way to create, retrieve, modify, and delete data objects, known as "shrooms," in a hierarchical manner.

## Usage

Here's an example of how to use the Shroom class:

```dart
import 'package:shroom/shroom.dart';

void main() async {
  // Initialize the Shroom database
  Shroom.init('path/to/database.db');

  // Create a new Shroom object with a name
  Shroom shroom = await Shroom.create(name: 'test');

  // Set some data on the Shroom
  ShroomData data = ShroomData('string', 'value');
  // var dataInt = ShroomData('int', 42);
  // var dataFloat = ShroomData('float', 3.14);
  // var dataBinary = ShroomData('binary', [0, 1, 2, 3]); 
  await shroom.set('key', data);

  // Retrieve the data from the Shroom
  ShroomData retrievedData = shroom.data['key'];

  // Retrieve a Shroom by ID
  Shroom shroomById = await Shroom.fromID(1);
  if (shroomById != null) {
    print('Shroom by ID: ${shroomById.name}');
  }

  // Retrieve a Shroom by name
  Shroom shroomByName = await Shroom.fromName('test');
  if (shroomByName != null) {
    print('Shroom by name: ${shroomByName.name}');
  }

  // Remove the data from the Shroom
  await shroom.remove('key');

  // Modify the name of the Shroom
  shroom.name = 'new name';
  shroom.name = null;

  // Delete the Shroom
  await shroom.delete();
}
```

## Shroom Class Methods

Here's the updated summary with the return types at the beginning, similar to a function declaration:


- class methods:
    - `.init(path: String)`: Initializes the Shroom database at the specified path. This method does not return any value.
    - `.create({name: String})`: Creates a new Shroom object with an optional name. It returns a `Future<Shroom>` object, which represents the newly created Shroom.
    - `.fromID(id: int)`: Retrieves a Shroom object by its ID. It returns a `Future<Shroom?>` object, which may be null if no Shroom with the given ID is found.
    - `.fromName(name: String)`: Retrieves a Shroom object by its name. It returns a `Future<Shroom?>` object, which may be null if no Shroom with the given name is found.
    - `.set(name: String, data: ShroomData)`: Sets data on the Shroom object with a given name. The `ShroomData` class represents a piece of data with a specific type and value. This method does not return any value.
- instance methods:
    - `.remove(name: String)`: Removes data with the given name from the Shroom object. This method does not return any value.
    - `.delete()`: Deletes the Shroom object from the database. This method returns a `Future<void>` object.
    - `.id`: Gets the ID of the Shroom object. The return type is `int`.
    - `.name`: Gets the name of the Shroom object. The return type is `String?`, indicating that the name may be null.
    - `.name = value`: Sets the name of the Shroom object. The value can be of type `String?` since the name is optional.

## ShroomData Class

The `ShroomData` class is used to store data in a Shroom object. It has two properties: `type` and `value`. The `type` specifies the data type, such as "int", "float", "string", etc. The `value` holds the actual data value.

## Supported Data Types
check [ShroomData Dart File](lib/shroom_data.dart)
 and [Schema SQL File](lib/src/sql/schema.sql)

```dart
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
    ]
    //.......
  }
}

```

## Testing

The Shroom class has been thoroughly tested to ensure its functionality. The test files (`shroom_test.dart` and others) contain various test cases that verify the creation, retrieval, modification, and deletion of Shroom objects.

## Conclusion

The Shroom class provides a convenient way to manage data in a hierarchical manner. It offers methods to create, retrieve, modify, and delete data objects, making it a powerful tool for organizing and manipulating data.