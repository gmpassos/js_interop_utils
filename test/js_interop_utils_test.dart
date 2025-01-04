@TestOn('browser')
library;

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Object', () {
    test('isJSAny', () {
      expect(null.isJSAny, isFalse);

      expect({}.isJSAny, isFalse);
      expect(JSObject().isJSAny, isTrue);
      expect({}.toJSDeep.isJSAny, isTrue);

      // Ambiguous types:
      expect(1.isJSAny, isNull);
      expect(1.2.isJSAny, isNull);
      expect("a".isJSAny, isNull);
      expect(true.isJSAny, isNull);
      expect([].isJSAny, isNull);

      expect(JSArray().isJSAny, isNull);
      expect([].toJSDeep.isJSAny, isNull);
      expect(1.toJS.isJSAny, isNull);
      expect(1.2.toJS.isJSAny, isNull);
      expect("a".toJS.isJSAny, isNull);
      expect(true.toJS.isJSAny, isNull);
    });
  });

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
