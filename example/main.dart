import 'dart:convert';

import 'package:dump/dump.dart';
import 'package:firestore_api_converter/firestore_api_converter.dart';

void main() {
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
  final decoded = FirestoreApiConverter.fromFirestore(encoded);

  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(encoded));
  // {
  //   "fields": {
  //     "null": {
  //       "nullValue": null
  //     },
  //     "boolean": {
  //       "booleanValue": true
  //     },
  //     "integer": {
  //       "integerValue": "123"
  //     },
  //     "double": {
  //       "doubleValue": 0.5
  //     },
  //     "timestamp": {
  //       "timestampValue": "2023-09-13T17:43:11.002Z"
  //     },
  //     "string": {
  //       "stringValue": "abc"
  //     },
  //     "array": {
  //       "arrayValue": {
  //         "values": [
  //           {
  //             "booleanValue": true
  //           },
  //           {
  //             "stringValue": "abc"
  //           },
  //           {
  //             "integerValue": "123"
  //           }
  //         ]
  //       }
  //     },
  //     "map": {
  //       "mapValue": {
  //         "fields": {
  //           "boolean": {
  //             "booleanValue": true
  //           },
  //           "string": {
  //             "stringValue": "abc"
  //           },
  //           "integer": {
  //             "integerValue": "123"
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

  // We cannot dump this structure with jsonEncode because it contains DateTime
  // which is not serializable. So using the `dump` package.
  print(dumpString(decoded));
  // {
  //   "null": null,
  //   "boolean": true,
  //   "integer": 123,
  //   "double": 0.5,
  //   "timestamp": {
  //     "": "DateTime",
  //     "isUtc": true,
  //     "toString()": "2023-09-13 17:43:11.002Z"
  //   },
  //   "string": "abc",
  //   "array": [
  //     true,
  //     "abc",
  //     123
  //   ],
  //   "map": {
  //     "boolean": true,
  //     "string": "abc",
  //     "integer": 123
  //   }
  // }
}
