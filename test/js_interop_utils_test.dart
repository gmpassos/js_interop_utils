@TestOn('browser')
library;

import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

@JS('Object.create')
external JSObject _objectCreate(JSAny? proto);

class _Foo {}

/// `true` when JS interop types are erased to one runtime type (`dart2wasm`).
final _interopTypesErased = JSObject == JSArray;

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
      expect(
        1.2.isJSAny,
        1.2.isJSAny == true ? isTrue : isFalse,
        reason: "1.2",
      );
      expect("a".isJSAny, "a".isJSAny == true ? isTrue : isFalse, reason: "a");
      expect(
        true.isJSAny,
        true.isJSAny == true ? isTrue : isFalse,
        reason: "true",
      );

      // `[].isJSAny`: dart2js: null ; dart2wasm: false
      expect(
        [].isJSAny,
        [].isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
        reason: "[]",
      );

      expect(
        JSArray().isJSAny,
        JSArray().isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
        reason: "JSArray()",
      );

      expect(
        [].toJSDeep.isJSAny,
        [].toJSDeep.isJSAny != false ? anyOf(isTrue, isNull) : isFalse,
        reason: "[].toJSDeep",
      );

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
      expect(
        1.2.asJSAny,
        1.2.isJSAny == true ? isNotNull : isNull,
        reason: "1.2",
      );
      expect(
        "a".asJSAny,
        "a".isJSAny == true ? isNotNull : isNull,
        reason: "a",
      );
      expect(
        true.asJSAny,
        true.isJSAny == true ? isNotNull : isNull,
        reason: "true",
      );

      // `[].asJSAny`: dart2js: null ; dart2wasm: false
      expect(
        [].asJSAny,
        [].isJSAny != false ? isNotNull : isNull,
        reason: "[]",
      );

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

      expect(
        [].toJSDeep.isJSObject,
        anyOf(isNull, isTrue),
        reason: "[].toJSDeep",
      );
      expect([].isJSObject, anyOf(isNull, isFalse), reason: "[]");
      expect(JSArray().isJSObject, anyOf(isNull, isTrue), reason: "JSArray()");

      // JSObject types:

      expect(
        JSObject().isJSObject,
        anyOf(isNull, isTrue),
        reason: "JSObject()",
      );
      expect(
        {}.toJSDeep.isJSObject,
        anyOf(isNull, isTrue),
        reason: "{}.toJSDeep",
      );
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
        {"a": 1, "b": 2}.toJSDeep.objectDartify(),
        equals({"a": 1, "b": 2}),
      );
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
      expect(JSArrayUtil(JSArray()).toList(), equals([]));

      expect(
        (JSArrayUtil(JSArray())..push(1.toJS, 2.toJS)).toList(),
        equals([1, 2]),
      );
    });
  });

  group('JSArray', () {
    test('Uint8List.toJS', () {
      var uint8list = Uint8List.fromList([1, 2]);
      expect(uint8list.isJSAny, anyOf(isNull, isFalse));

      var jsUint8Array = uint8list.toJS;

      expect(jsUint8Array.isA<JSUint8Array>(), isTrue);
      expect(jsUint8Array.isJSAny, anyOf(isNull, isTrue));

      expect(
        jsUint8Array.dartify(),
        equals(
          Uint8ListToJSUint8Array(Uint8List.fromList([1, 2])).toJS.dartify(),
        ),
      );
    });

    test('Iterable<int>.toJS', () {
      expect(
        [1, 2].toJS.dartify(),
        equals((JSArray()..pushVarArgs(1, 2)).dartify()),
      );
    });

    test('Iterable<double>.toJS', () {
      expect(
        [1.1, 2.2].toJS.dartify(),
        equals((JSArray()..pushVarArgs(1.1, 2.2)).dartify()),
      );
    });

    test('Iterable<num>.toJS', () {
      expect(
        [1, 2.2].toJS.dartify(),
        equals((JSArray()..pushVarArgs(1, 2.2)).dartify()),
      );
    });

    test('Iterable<String>.toJS', () {
      expect(
        ['a', 'b'].toJS.dartify(),
        equals((JSArray()..pushVarArgs('a', 'b')).dartify()),
      );
    });

    test('Iterable<Iterable<String>>.toJSDeep', () {
      expect(
        [
          ['a', 1],
          ['b', 2],
        ].toJSDeep.dartify(),
        equals((JSArray()..pushVarArgs(['a', 1], ['b', 2])).dartify()),
      );
    });
  });

  group('JSObject', () {
    test('Iterable<String>.toJS', () {
      expect(
        {'a': 1, 'b': 2}.toJSDeep.dartify(),
        equals(
          (JSObject()
                ..put('a', 1)
                ..put('b', 2))
              .dartify(),
        ),
      );
    });

    test('prototype', () {
      expect(JSObject().prototype, isNotNull);
      expect(JSDate().prototype, isNotNull);
      expect(_objectCreate(null).prototype, isNull);
    });

    test('isPlainObject', () {
      expect(JSObject().isPlainObject, isTrue);
      expect({'a': 1}.toJSDeep.isPlainObject, isTrue);
      expect(_objectCreate(null).isPlainObject, isTrue);

      expect(JSDate().isPlainObject, isFalse);
      expect((JSArray() as JSObject).isPlainObject, isFalse);
      expect(_objectCreate(JSObject()).isPlainObject, isFalse);
    });

    test('as<T>()', () {
      expect(JSObject().as<JSObject>(), isNotNull);
      expect((JSArray() as JSObject).as<JSArray>(), isNotNull);
      expect(Uint8List(2).toJS.as<JSUint8Array>(), isNotNull);
      expect((() {}).toJS.as<JSFunction>(), isNotNull);

      // With `dart2wasm` the type argument can't be inspected at runtime:
      final notA = _interopTypesErased ? isNotNull : isNull;
      expect(JSObject().as<JSArray>(), notA);
      expect(JSObject().as<JSFunction>(), notA);
      expect(Uint8List(2).toJS.as<JSInt8Array>(), notA);
    });
  });

  group('isA based checks', () {
    test('non-JS Dart object', () {
      final foo = _Foo();
      expect(foo.isJSAny, isFalse);
      expect(foo.asJSAny, isNull);
      expect(foo.isJSObject, isFalse);
      expect(foo.asJSObject, isNull);
      expect(foo.objectDartify(), same(foo));
    });

    test('JS objects', () {
      expect(JSDate().isJSAny, isTrue);
      expect(JSDate().isJSObject, isTrue);

      final noProto = _objectCreate(null);
      expect(noProto.isJSAny, isTrue);
      expect(noProto.isJSObject, isTrue);
      expect(noProto.asJSObject, isNotNull);
    });

    test('isJSFunction / isJSExportedDartFunction', () {
      final exported = (() {}).toJS;
      final parseInt = globalContext['parseInt'];

      expect(exported.isJSFunction, isTrue);
      expect(exported.isJSExportedDartFunction, isTrue);

      expect(parseInt.isJSFunction, isTrue);
      expect(parseInt.isJSExportedDartFunction, isFalse);

      expect((() {}).isJSFunction, isFalse);
      expect(JSObject().isJSFunction, isFalse);
      expect(null.isJSFunction, isFalse);
    });
  });

  group('JSIterable', () {
    test('Iterable.toJSIterableDeep', () {
      expect(
        [
          1,
          'a',
          [true],
          {'b': 2},
        ].toJSIterableDeep.toList(),
        equals([
          1,
          'a',
          [true],
          {'b': 2},
        ]),
      );
    });

    test('Iterable.toJSIterableDeep is lazy', () {
      var count = 0;
      final iterable = [1, 2, 3].map((e) {
        count++;
        return e;
      }).toJSIterableDeep;

      expect(count, equals(0));
      expect(iterable.toList(), equals([1, 2, 3]));
      expect(count, equals(3));
    });

    test('JSArray as JSIterable', () {
      final JSIterable iterable = ['a', 'b'].toJSDeep;
      expect(iterable.toIterable(), equals(['a', 'b']));
    });
  });

  group('JSArrayExtension', () {
    test('push', () {
      final a = JSArray();
      expect(a.push(1), equals(1));
      expect(a.push('b'), equals(2));
      expect(a.toList(), equals([1, 'b']));
    });

    test('toListOfDouble', () {
      final l = [1, 2.5, 'x'].toJSDeep.toListOfDouble();
      expect(l, isA<List<double>>());
      expect(l, equals([1.0, 2.5]));
    });
  });
}
