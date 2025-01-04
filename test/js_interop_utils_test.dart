@TestOn('browser')
library;

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Object', () {
    test('isJSAny', () {
      expect(null.isJSAny, isFalse, reason: "null");
      expect({}.isJSAny, isFalse, reason: "{}");

      // Ambiguous types (all platforms):

      expect(JSArray().isJSAny, isNull, reason: "JSArray()");
      expect([].toJSDeep.isJSAny, isNull, reason: "[].toJSDeep");
      expect(1.toJS.isJSAny, isNull, reason: "1.toJS");
      expect(1.2.toJS.isJSAny, isNull, reason: "1.2.toJS");
      expect("a".toJS.isJSAny, isNull, reason: "a.toJS");
      expect(true.toJS.isJSAny, isNull, reason: "true.toJS");

      // Ambiguous types (some platforms):

      expect(1.isJSAny, anyOf(isNull, isFalse), reason: "1");
      expect(1.2.isJSAny, anyOf(isNull, isFalse), reason: "1.2");
      expect("a".isJSAny, anyOf(isNull, isFalse), reason: "a");
      expect(true.isJSAny, anyOf(isNull, isFalse), reason: "true");
      expect([].isJSAny, anyOf(isNull, isFalse), reason: "[]");

      expect(JSObject().isJSAny, anyOf(isNull, isTrue), reason: "JSObject()");
      expect({}.toJSDeep.isJSAny, anyOf(isNull, isTrue), reason: "{}.toJSDeep");
    });

    test('objectDartify', () {
      expect(true.objectDartify(), equals(true));
      expect(true.toJS.objectDartify(), equals(true));

      expect(1.objectDartify(), equals(1));
      expect(1.toJS.objectDartify(), equals(1));

      expect(1.2.objectDartify(), equals(1.2));
      expect(1.2.toJS.objectDartify(), equals(1.2));

      expect("a".objectDartify(), equals("a"));
      expect("a".toJS.objectDartify(), equals("a"));

      expect([].objectDartify(), equals([]));
      expect([].toJSDeep.objectDartify(), equals([]));

      expect([1, 2].objectDartify(), equals([1, 2]));
      expect([1, 2].toJSDeep.objectDartify(), equals([1, 2]));

      expect({}.objectDartify(), equals({}));
      expect({}.toJSDeep.objectDartify(), equals({}));

      expect({"a": 1, "b": 2}.objectDartify(), equals({"a": 1, "b": 2}));
      expect(
          {"a": 1, "b": 2}.toJSDeep.objectDartify(), equals({"a": 1, "b": 2}));
    });
  });

  group('JSObjectUtil', () {
    test('keys', () {
      expect(JSObjectUtil.keys(JSObject()), equals([]));

      var o2 = {'a': '1', 'b': 2}.toJSDeep;
      expect(JSObjectUtil.keys(o2), equals(['a', 'b']));
    });
  });

  group('JSArrayUtil', () {
    test('push, toList', () {
      expect(
        JSArrayUtil(JSArray()).toList(),
        equals([]),
      );

      expect(
        (JSArrayUtil(JSArray())
              ..push(
                1.toJS,
                2.toJS,
              ))
            .toList(),
        equals([1, 2]),
      );
    });
  });

  group('JSArray', () {
    test('Iterable<int>.toJS', () {
      expect(
        [
          1,
          2,
        ].toJS.dartify(),
        equals(
          (JSArray()..pushVarArgs(1, 2)).dartify(),
        ),
      );
    });

    test('Iterable<double>.toJS', () {
      expect(
        [
          1.1,
          2.2,
        ].toJS.dartify(),
        equals(
          (JSArray()..pushVarArgs(1.1, 2.2)).dartify(),
        ),
      );
    });

    test('Iterable<num>.toJS', () {
      expect(
        [
          1,
          2.2,
        ].toJS.dartify(),
        equals(
          (JSArray()..pushVarArgs(1, 2.2)).dartify(),
        ),
      );
    });

    test('Iterable<String>.toJS', () {
      expect(
        [
          'a',
          'b',
        ].toJS.dartify(),
        equals(
          (JSArray()..pushVarArgs('a', 'b')).dartify(),
        ),
      );
    });

    test('Iterable<Iterable<String>>.toJSDeep', () {
      expect(
        [
          ['a', 1],
          ['b', 2],
        ].toJSDeep.dartify(),
        equals(
          (JSArray()..pushVarArgs(['a', 1], ['b', 2])).dartify(),
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
