@TestOn('browser')
library;

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

void main() {
  group('JSArray', () {
    test('Iterable<int>.toJS', () {
      expect(
        [
          1,
          2,
        ].toJS,
        equals(
          JSArray()..pushVarArgs(1, 2),
        ),
      );
    });

    test('Iterable<double>.toJS', () {
      expect(
        [
          1.1,
          2.2,
        ].toJS,
        equals(
          JSArray()..pushVarArgs(1.1, 2.2),
        ),
      );
    });

    test('Iterable<num>.toJS', () {
      expect(
        [
          1,
          2.2,
        ].toJS,
        equals(
          JSArray()..pushVarArgs(1, 2.2),
        ),
      );
    });

    test('Iterable<String>.toJS', () {
      expect(
        [
          'a',
          'b',
        ].toJS,
        equals(
          JSArray()..pushVarArgs('a', 'b'),
        ),
      );
    });

    test('Iterable<Iterable<String>>.toJSDeep', () {
      expect(
        [
          ['a', 1],
          ['b', 2],
        ].toJSDeep,
        equals(
          JSArray()..pushVarArgs(['a', 1], ['b', 2]),
        ),
      );
    });
  });

  group('JSObject', () {
    test('Iterable<String>.toJS', () {
      expect(
        {
          'a': 1,
          'b': 2,
        }.toJSDeep.dartify(),
        equals(
          (JSObject()
                ..put('a', 1)
                ..put('b', 2))
              .dartify(),
        ),
      );
    });
  });
}
