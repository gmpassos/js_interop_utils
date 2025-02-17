@TestOn('browser')
library;

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Object', () {
    test('isJSAny', () {
      expect(null.isJSAny, isFalse, reason: "null");
      expect({}.isJSAny, isFalse, reason: "{}");

      // Ambiguous types (some platforms):

      expect(1.toJS.isJSAny, isTrue, reason: "1.toJS");
      expect(1.2.toJS.isJSAny, isTrue, reason: "1.2.toJS");
      expect("a".toJS.isJSAny, isTrue, reason: "a.toJS");
      expect(true.toJS.isJSAny, isTrue, reason: "true.toJS");

      expect(1.isJSAny, 1.isJSAny == true ? isTrue : isFalse, reason: "1");
      expect(1.2.isJSAny, 1.2.isJSAny == true ? isTrue : isFalse,
          reason: "1.2");
      expect("a".isJSAny, "a".isJSAny == true ? isTrue : isFalse, reason: "a");
      expect(true.isJSAny, true.isJSAny == true ? isTrue : isFalse,
          reason: "true");

      // `[].isJSAny`: dart2js: null ; dart2wasm: false
      expect([].isJSAny, [].isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
          reason: "[]");

      expect(JSArray().isJSAny,
          JSArray().isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
          reason: "JSArray()");

      expect([].toJSDeep.isJSAny,
          [].toJSDeep.isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
          reason: "[].toJSDeep");

      // JSAny types:

      expect(JSObject().isJSAny, isTrue, reason: "JSObject()");
      expect({}.toJSDeep.isJSAny, isTrue, reason: "{}.toJSDeep");
    });

    test('asJSAny', () {
      expect(null.asJSAny, isNull, reason: "null");
      expect({}.asJSAny, isNull, reason: "{}");

      // Ambiguous types (some platforms):

      expect(1.toJS.asJSAny, isNotNull, reason: "1.toJS");
      expect(1.2.toJS.asJSAny, isNotNull, reason: "1.2.toJS");
      expect("a".toJS.asJSAny, isNotNull, reason: "a.toJS");
      expect(true.toJS.asJSAny, isNotNull, reason: "true.toJS");

      expect(1.asJSAny, 1.isJSAny == true ? isNotNull : isNull, reason: "1");
      expect(1.2.asJSAny, 1.2.isJSAny == true ? isNotNull : isNull,
          reason: "1.2");
      expect("a".asJSAny, "a".isJSAny == true ? isNotNull : isNull,
          reason: "a");
      expect(true.asJSAny, true.isJSAny == true ? isNotNull : isNull,
          reason: "true");

      // `[].asJSAny`: dart2js: null ; dart2wasm: false
      expect([].asJSAny, [].isJSAny != false ? isNotNull : isNull,
          reason: "[]");

      // JSAny types:

      expect(JSObject().asJSAny, isNotNull, reason: "JSObject()");
      expect({}.toJSDeep.asJSAny, isNotNull, reason: "{}.toJSDeep");
    });

    test('isJSObject', () {
      expect(null.isJSObject, isFalse, reason: "null");
      expect({}.isJSObject, isFalse, reason: "{}");

      expect(1.toJS.isJSObject, isFalse, reason: "1.toJS");
      expect(1.2.toJS.isJSObject, isFalse, reason: "1.2.toJS");
      expect("a".toJS.isJSObject, isFalse, reason: "a.toJS");
      expect(true.toJS.isJSObject, isFalse, reason: "true.toJS");

      expect(1.isJSObject, anyOf(isNull, isFalse), reason: "1");
      expect(1.2.isJSObject, anyOf(isNull, isFalse), reason: "1.2");
      expect("a".isJSObject, anyOf(isNull, isFalse), reason: "a");
      expect(true.isJSObject, anyOf(isNull, isFalse), reason: "true");

      // Ambiguous types:

      expect([].toJSDeep.isJSObject, anyOf(isNull, isTrue),
          reason: "[].toJSDeep");
      expect([].isJSObject, anyOf(isNull, isFalse), reason: "[]");
      expect(JSArray().isJSObject, anyOf(isNull, isTrue), reason: "JSArray()");

      // JSObject types:

      expect(JSObject().isJSObject, anyOf(isNull, isTrue),
          reason: "JSObject()");
      expect({}.toJSDeep.isJSObject, anyOf(isNull, isTrue),
          reason: "{}.toJSDeep");
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
