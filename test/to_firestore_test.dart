import 'package:firestore_api_converter/firestore_api_converter.dart';
import 'package:test/test.dart';

void main() {
  group('JSON to Firestore', () {
    test('null', () {
      const input = null;
      const expected = {'nullValue': null};

      expect(_encodeField(input), expected);
    });

    test('boolean', () {
      const input = true;
      const expected = {'booleanValue': true};

      expect(_encodeField(input), expected);
    });

    test('integer', () {
      const input = 123;
      const expected = {'integerValue': '123'};

      expect(_encodeField(input), expected);
    });

    test('double', () {
      const input = .5;
      const expected = {'doubleValue': .5};

      expect(_encodeField(input), expected);
    });

    group('timestamp', () {
      test('Micro, UTC -> Floored to millis', () {
        final input = DateTime.utc(2023, 9, 13, 17, 43, 11, 0, 2002);
        const expected = {'timestampValue': '2023-09-13T17:43:11.002Z'};

        expect(_encodeField(input), expected);
      });

      test('No micro, UTC', () {
        final input = DateTime.utc(2023, 9, 13, 17, 43, 11);
        const expected = {'timestampValue': '2023-09-13T17:43:11.000Z'};

        expect(_encodeField(input), expected);
      });

      test('Micro, Non-UTC -> Floored to millis', () {
        final input = DateTime(2023, 9, 13, 17, 43, 11, 0, 2002);
        const expected = {'timestampValue': '2023-09-13T17:43:11.002'};

        expect(_encodeField(input), expected);
      });

      test('No micro, Non-UTC', () {
        final input = DateTime(2023, 9, 13, 17, 43, 11);
        const expected = {'timestampValue': '2023-09-13T17:43:11.000'};

        expect(_encodeField(input), expected);
      });
    });

    test('string', () {
      const input = 'abc';
      const expected = {'stringValue': 'abc'};

      expect(_encodeField(input), expected);
    });

    // TODO(alexeyinkin): bytes, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/1
    // TODO(alexeyinkin): references, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/2
    // TODO(alexeyinkin): geopoints, https://github.com/alexeyinkin/dart-firestore-api-converter/issues/3

    group('array', () {
      test('empty', () {
        const input = [];
        const expected = {'arrayValue': {}};

        expect(_encodeField(input), expected);
      });

      test('non-empty', () {
        const input = [true, 'abc', 123];
        const expected = {
          'arrayValue': {
            'values': [
              {'booleanValue': true},
              {'stringValue': 'abc'},
              {'integerValue': '123'},
            ],
          },
        };

        expect(_encodeField(input), expected);
      });
    });

    group('map', () {
      test('empty', () {
        const input = <String, dynamic>{};
        const expected = {'mapValue': {}};

        expect(_encodeField(input), expected);
      });

      test('non-empty, string keys', () {
        const input = {'a': true, 'b': 'abc', 'c': 123};
        const expected = {
          'mapValue': {
            'fields': {
              'a': {'booleanValue': true},
              'b': {'stringValue': 'abc'},
              'c': {'integerValue': '123'},
            },
          },
        };

        expect(_encodeField(input), expected);
      });

      test('non-empty, int keys -> Exception', () {
        const input = {1: true};

        expect(() => _encodeField(input), throwsException);
      });
    });

    test('other', () {
      final input = Object();

      expect(() => _encodeField(input), throwsException);
    });
  });
}

dynamic _encodeField(dynamic input) {
  final obj = {'field': input};
  final encodedObj = FirestoreApiConverter.toFirestore(obj);
  return (encodedObj['fields'] as Map)['field'];
}
