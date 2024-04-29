/GraphDB/Graph Database/

# Shroom Library Documentation

## Get Started
```yaml
dependencies:
  shroom_dart:
    git:
      url: https://github.com/monki1/shroom_dart/
      ref: main
```

## Constructors

- **`Shroom.create({String? name})`**:
  - Instantiates a new `Shroom` with an optional name. If provided, the instance is initialized with that name.
- **`Shroom.get({String name, String id})`**:
  - Retrieves a `Shroom` instance by its ID or name. At least one parameter must be provided and not null. This constructor will throw an exception if no matching `Shroom` is found.

## Static Methods

- **`initDB({String? path})`**:
  - Initializes the database at a specified path, or uses a default location if no path is provided. Essential for setting up the storage environment for `Shroom` instances.
- **`deleteDB({String? path})`**:
  - Deletes the database located at a specified path or the default location. Typically used for resetting or cleaning up the database environment in testing scenarios.

## Instance Methods

- **`upsert(String key, ShroomData data)`**:
  - Inserts or updates a piece of data identified by the key within this `Shroom` instance. Allows for dynamic data management.
- **`delete()`**:
  - Deletes this `Shroom` instance from the database, removing all its stored data.
- **`remove(String key)`**:
  - Removes the data associated with the specified key from this `Shroom` instance, useful for deleting specific entries without affecting the entire dataset.

## Usage Example

Below is an example demonstrating the creation of a `Shroom`, updating data, removing a specific data entry, and general cleanup:

```dart
import 'package:shroom/shroom.dart';

void main() {
  // Initialize the database
  Shroom.initDB();

  // Create a new Shroom instance
  var shroom = Shroom.create(name: 'example');
  shroom.upsert('description', ShroomData('string', 'A simple example of using Shroom'));
  shroom.upsert('type', ShroomData('string', 'educational'));

  // Retrieve the Shroom by name (assuming `name` is a unique identifier)
  var retrievedShroom = Shroom.get(name: 'example');
  print('Retrieved Shroom: ${retrievedShroom.data}');

  // Remove the 'type' data entry
  retrievedShroom.remove('type');
  print('Updated Shroom data after removal: ${retrievedShroom.data}');

  // Cleanup the instance
  retrievedShroom.delete();

  // Optionally, delete the database when done
  Shroom.deleteDB();
}
```
## Supported Data Types
check [ShroomData Dart File](lib/src/shroom_data.dart)
 and [Schema SQL File](lib/src/sql/schema.sql)