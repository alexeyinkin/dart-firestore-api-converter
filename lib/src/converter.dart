/// Converts data to and from Firestore REST API.
abstract final class FirestoreApiConverter {
  /// Decodes a document coming from Firestore into plain Dart map.
  static Map<String, dynamic> fromFirestore(Map<String, dynamic> doc) =>
      _decodeMap(doc);

  /// Encodes a plain Dart map to Firestore format suitable for sending
  /// to server.
  static Map<String, dynamic> toFirestore(Map<String, dynamic> map) =>
      _encodeMap(map)['mapValue'];
}

dynamic _decodeDynamic(Map<String, dynamic> map) {
  for (final entry in map.entries) {
    switch (entry.key) {
      case 'nullValue':
        return null;

      case 'booleanValue':
        return _decodeBool(entry.value);

      case 'integerValue':
        return _decodeInt(entry.value);

      case 'doubleValue':
        return _decodeDouble(entry.value);

      case 'timestampValue':
        return _decodeDateTime(entry.value);

      case 'stringValue':
        return _decodeString(entry.value);

      case 'arrayValue':
        return _decodeList(entry.value);

      case 'mapValue':
        return _decodeMap(entry.value);
    }
  }

  throw Exception('Cannot decode field from Firestore API: $map');
}

bool _decodeBool(dynamic value) => value as bool;

int _decodeInt(dynamic value) => switch (value) {
      int() => value,
      _ => int.parse(value.toString()),
    };

double _decodeDouble(dynamic value) => value as double;

DateTime _decodeDateTime(dynamic value) => DateTime.parse(value);

String _decodeString(dynamic value) => value as String;

List<dynamic> _decodeList(Map<String, dynamic> map) {
  final values = map['values'];

  if (values == null) {
    return [];
  }

  if (values is! List) {
    throw Exception(
      'Expected "values" key to be List, '
      'found ${values.runtimeType} ($values)',
    );
  }

  return values
      .map((v) => _decodeDynamic(v as Map<String, dynamic>))
      .toList(growable: false);
}

Map<String, dynamic> _decodeMap(Map map) {
// if (mapValue is! Map<String, dynamic>) {
//   throw Exception(
//     'Expected "mapValue" key to be Map<String, dynamic>, '
//     'found ${mapValue.runtimeType} ($mapValue)',
//   );
// }

  final fields = map['fields'];

  if (fields == null) {
    return {};
  }

  if (fields is! Map) {
    throw Exception(
      'Expected "fields" key to be Map, '
      'found ${fields.runtimeType} ($fields)',
    );
  }

  return fields.map((k, v) => MapEntry(k, _decodeDynamic(v)));
}

Map<String, dynamic> _encodeDynamic(Object? value) {
  return switch (value) {
    null => {'nullValue': null},
    bool() => _encodeBool(value),
    int() => _encodeInt(value),
    double() => _encodeDouble(value),
    DateTime() => _encodeDateTime(value),
    String() => _encodeString(value),
    List() => _encodeList(value),
    Map<String, dynamic>() => _encodeMap(value),
    _ => throw Exception(
        '${value.runtimeType} is not supported for Firestore encoding. '
        'Tried to encode: $value',
      ),
  };
}

Map<String, dynamic> _encodeBool(bool value) => {'booleanValue': value};

Map<String, dynamic> _encodeInt(int value) => {'integerValue': '$value'};

Map<String, dynamic> _encodeDouble(double value) => {'doubleValue': value};

Map<String, dynamic> _encodeDateTime(DateTime dt) {
  return {
    'timestampValue': dt.copyWith(microsecond: 0).toIso8601String(),
  };
}

Map<String, dynamic> _encodeString(String value) => {'stringValue': value};

Map<String, dynamic> _encodeList(List value) {
  if (value.isEmpty) {
    return const {'arrayValue': {}};
  }

  final values = value.map(_encodeDynamic).toList(growable: false);
  return {
    'arrayValue': {'values': values},
  };
}

Map<String, dynamic> _encodeMap(Map<String, dynamic> value) {
  if (value.isEmpty) {
    return const {'mapValue': {}};
  }

  final fields = value.map(
    (k, v) => MapEntry(k, _encodeDynamic(v)),
  );

  return {
    'mapValue': {'fields': fields},
  };
}
