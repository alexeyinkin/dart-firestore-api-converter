# Usage

## Encode an Map

If you have an object, convert it to a map using
any of [the standard methods](https://docs.flutter.dev/data-and-backend/serialization/json).
Then encode that map to send it over Firestore REST API:

```dart
final map = {
  'null': null,
  'boolean': true,
  'integer': 123,
  'double': .5,
  'timestamp': DateTime.utc(2023, 9, 13, 17, 43, 11, 0, 2002),
  'string': 'abc',
  'array': [true, 'abc', 123],
  'map': {'boolean': true, 'string': 'abc', 'integer': 123},
};
final encoded = FirestoreApiConverter.toFirestore(map);
// {
//   "fields": {
//     "null": { "nullValue": null },
//     "boolean": { "booleanValue": true },
//     "integer": { "integerValue": "123" },
//     "double": { "doubleValue": 0.5 },
//     "timestamp": { "timestampValue": "2023-09-13T17:43:11.002Z" },
//     "string": { "stringValue": "abc" },
//     "array": {
//       "arrayValue": {
//         "values": [
//           { "booleanValue": true },
//           { "stringValue": "abc" },
//           { "integerValue": "123" }
//         ]
//       }
//     },
//     "map": {
//       "mapValue": {
//         "fields": {
//           "boolean": { "booleanValue": true },
//           "string": { "stringValue": "abc" },
//           "integer": { "integerValue": "123" }
//         }
//       }
//     }
//   }
// }
```

## Decode a Document
Decode a document received via Firestore REST API:

```dart
final decoded = FirestoreApiConverter.fromFirestore(encoded);
```

# Type Support

## Full Support

- null
- boolean
- integer
- double
- timestamp
- string
- array
- map

## Not Yet Supported

- bytes, [See the issue](https://github.com/alexeyinkin/dart-firestore-api-converter/issues/1)
- reference, [See the issue](https://github.com/alexeyinkin/dart-firestore-api-converter/issues/2)
- geoPoint, [See the issue](https://github.com/alexeyinkin/dart-firestore-api-converter/issues/3)

I do not have use cases to test those properly.
If you have one, submit a PR. Before working on it, read a discussion corresponding issue
linked above and suggest your idea of implementation.
