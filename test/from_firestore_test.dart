import 'package:firestore_api_converter/firestore_api_converter.dart';
import 'package:test/test.dart';

void main() {
  group('fromFirestore', () {
    group('null', () {
      // Not valid in the API, but it's faster to not check the type.
      test('string -> null', () {
        const input = {'nullValue': 'anything'};
        const expected = null;

        expect(_decodeField(input), expected);
      });
    });

    group('boolean', () {
      test('true -> true', () {
        const input = {'booleanValue': true};
        const expected = true;

        expect(_decodeField(input), expected);
      });

      test('false -> false', () {
        const input = {'booleanValue': false};
        const expected = false;

        expect(_decodeField(input), expected);
      });

      test('null -> TypeError', () {
        const input = {'booleanValue': null};

        expect(() => _decodeField(input), throwsA(isA<TypeError>()));
      });
    });

    group('integer', () {
      test('String -> int', () {
        const input = {'integerValue': '123'};
        const expected = 123;

        expect(_decodeField(input), expected);
      });

      test('int -> int', () {
        const input = {'integerValue': 123};
        const expected = 123;

        expect(_decodeField(input), expected);
      });

      test('null -> Exception', () {
        const input = {'integerValue': null};

        expect(() => _decodeField(input), throwsException);
      });
    });

    group('double', () {
      test('double -> double', () {
        const input = {'doubleValue': .5};
        const expected = .5;

        expect(_decodeField(input), expected);
      });

      test('String -> TypeError', () {
        const input = {'doubleValue': '.5'};

        expect(() => _decodeField(input), throwsA(isA<TypeError>()));
      });

      test('null -> TypeError', () {
        const input = {'doubleValue': null};

        expect(() => _decodeField(input), throwsA(isA<TypeError>()));
      });
    });

    group('timestamp', () {
      test('ISO 8601 hyphens, no millis, Z', () {
        const input = {'timestampValue': '2021-10-07T19:01:02'};
        final expected = DateTime(2021, 10, 7, 19, 1, 2);

        expect(_decodeField(input), expected);
      });

      test('ISO 8601 hyphens, millis, Z', () {
        const input = {'timestampValue': '2021-10-07T19:01:02.002'};
        final expected = DateTime(2021, 10, 7, 19, 1, 2, 2);

        expect(_decodeField(input), expected);
      });

      test('ISO 8601 hyphens, no millis, Z', () {
        const input = {'timestampValue': '2021-10-07T19:01:02Z'};
        final expected = DateTime.utc(2021, 10, 7, 19, 1, 2);

        expect(_decodeField(input), expected);
      });

      test('ISO 8601 hyphens, millis, Z', () {
        const input = {'timestampValue': '2021-10-07T19:01:02.002Z'};
        final expected = DateTime.utc(2021, 10, 7, 19, 1, 2, 2);

        expect(_decodeField(input), expected);
      });

      test('null -> TypeError', () {
        const input = {'timestampValue': null};

        expect(() => _decodeField(input), throwsA(isA<TypeError>()));
      });
    });

    group('string', () {
      test('string', () {
        const stringValue = {'stringValue': 'abc'};
        const expected = 'abc';

        expect(_decodeField(stringValue), expected);
      });

      test('null -> TypeError', () {
        const stringValue = {'stringValue': null};

        expect(() => _decodeField(stringValue), throwsA(isA<TypeError>()));
      });
    });

    // TODO(alexeyinkin): bytes, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/1
    // TODO(alexeyinkin): references, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/2
    // TODO(alexeyinkin): geopoints, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/3

    group('array', () {
      test('Empty -> List', () {
        const input = {'arrayValue': <String, dynamic>{}};
        const expected = [];

        expect(_decodeField(input), expected);
      });

      test('values -> List', () {
        const input = {
          'arrayValue': {
            'values': [
              {'booleanValue': true},
              {'stringValue': 'abc'},
              {'integerValue': '123'},
            ],
          },
        };
        const expected = [true, 'abc', 123];

        expect(_decodeField(input), expected);
      });

      test('values + something else -> List', () {
        const input = {
          'arrayValue': {
            'non_standard_key': 'anything',
            'values': [
              {'booleanValue': false},
              {'stringValue': '123'},
              {'integerValue': '123'},
            ],
          },
        };
        const expected = [false, '123', 123];

        expect(_decodeField(input), expected);
      });

      test('no values, something else -> Empty', () {
        const input = {
          'arrayValue': {
            'non_standard_key': [
              {'stringValue': 'abc'},
            ],
          },
        };
        const expected = [];

        expect(_decodeField(input), expected);
      });
    });

    group('map', () {
      test('{} -> Empty', () {
        const input = {'mapValue': {}};
        const expected = {};

        expect(_decodeField(input), expected);
      });

      test('empty fields -> Empty', () {
        const input = {
          'mapValue': {'fields': {}},
        };
        const expected = {};

        expect(_decodeField(input), expected);
      });

      test('fields -> Map', () {
        const input = {
          'mapValue': {
            'fields': {
              'b': {'booleanValue': true},
              's': {'stringValue': 'abc'},
            },
          },
        };
        const expected = {'b': true, 's': 'abc'};

        expect(_decodeField(input), expected);
      });

      test('fields + something else -> Map', () {
        const input = {
          'mapValue': {
            'non_standard_key': 'anything',
            'fields': {
              'b': {'booleanValue': false},
            },
          },
        };
        const expected = {'b': false};

        expect(_decodeField(input), expected);
      });

      test('no fields, something else -> Empty', () {
        const input = {
          'mapValue': {
            'non_standard_key': {'stringValue': 'abc'},
          },
        };
        const expected = {};

        expect(_decodeField(input), expected);
      });
    });

    group('Invalid', () {
      test('{} -> TypeError', () {
        const input = {};

        expect(() => _decodeField(input), throwsA(isA<TypeError>()));
      });

      test('<String, dynamic>{} -> Exception', () {
        const input = <String, dynamic>{};

        expect(() => _decodeField(input), throwsException);
      });
    });
  });
}

dynamic _decodeField(dynamic input) {
  return FirestoreApiConverter.fromFirestore({
    'fields': {'field': input},
  })['field'];
}
