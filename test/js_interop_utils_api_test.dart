@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

/// Unit tests covering the public API of the package, member by member.

class _Foo {}

void main() {
  group('ObjectExtension.toJSDeep', () {
    test('primitives', () {
      expect(null.toJSDeep, isNull);
      expect('a'.toJSDeep.dartify(), equals('a'));
      expect(1.toJSDeep.dartify(), equals(1));
      expect(1.5.toJSDeep.dartify(), equals(1.5));
      expect(true.toJSDeep.dartify(), equals(true));
    });

    test('collections', () {
      expect(<Object?>[].toJSDeep.dartify(), equals([]));
      expect(<Object?, Object?>{}.toJSDeep.dartify(), equals({}));
      expect({1, 2, 3}.toJSDeep.dartify(), equals([1, 2, 3]));
      expect(
        Iterable.generate(3, (i) => i * 10).toJSDeep.dartify(),
        equals([0, 10, 20]),
      );
    });

    test('deep nesting', () {
      final data = {
        'a': [
          {
            'b': [
              1,
              {'c': null},
            ],
          },
          {1, 2},
        ],
      };
      expect(
        (data as Object).toJSDeep.dartify(),
        equals({
          'a': [
            {
              'b': [
                1,
                {'c': null},
              ],
            },
            [1, 2],
          ],
        }),
      );
    });

    test('JS values pass through unchanged', () {
      final o = JSObject();
      expect((o as Object).toJSDeep.strictEquals(o).toDart, isTrue);

      // With `dart2js` a JS array is also a Dart `List`, indistinguishable
      // from one that needs deep conversion, so it's converted into a copy:
      final a = [1, 'a'].toJSDeep;
      expect((a as Object).toJSDeep.dartify(), equals([1, 'a']));
    });
  });

  group('ObjectExtension casts', () {
    test('asJSAny / asJSObject keep identity', () {
      final o = JSObject();
      expect(o.asJSAny.strictEquals(o).toDart, isTrue);
      expect(o.asJSObject.strictEquals(o).toDart, isTrue);
    });

    test('asJSObject of JS primitives is null', () {
      expect('a'.toJS.asJSObject, isNull);
      expect(1.toJS.asJSObject, isNull);
      expect(true.toJS.asJSObject, isNull);
      expect(null.asJSObject, isNull);
    });

    test('non-JS Dart values', () {
      expect(_Foo().isJSFunction, isFalse);
      expect(_Foo().isJSExportedDartFunction, isFalse);
      expect(<String, int>{}.asJSObject, isNull);
      expect(<String, int>{}.asJSAny, isNull);
    });
  });

  group('JSAny asString', () {
    test('JSAnyExtension', () {
      JSAny s = 'abc'.toJS;
      JSAny b = true.toJS;
      expect(s.asString, equals('abc'));
      expect(b.asString, equals('true'));
      expect(JSObject().asString, equals('{}'));
    });

    test('JSAnyNullableExtension', () {
      JSAny? n;
      JSAny? s = 'x'.toJS;
      expect(n.asString, isNull);
      expect(s.asString, equals('x'));
    });
  });

  group('StringExtension.toDartFix', () {
    test('Dart strings are returned as is', () {
      const s = 'abc';
      expect(identical(s.toDartFix, s), isTrue);
      expect(''.toDartFix, isEmpty);
    });

    test('JS strings become Dart strings', () {
      final s = 'a${1}b'.toJS.toDart.toDartFix;
      expect(s, equals('a1b'));
      expect(s.runtimeType, equals(String));
    });
  });

  group('MapExtension.toJSDeep', () {
    test('keys', () {
      final o = {1: 'a', 'b': 2, null: 'n', true: 't'}.toJSDeep;
      expect(o.get('1'), equals('a'));
      expect(o.get('b'), equals(2));
      expect(o.get(''), equals('n'), reason: 'null key -> ""');
      expect(o.get('true'), equals('t'));
    });

    test('values', () {
      final o = {
        'n': null,
        'l': [1, 'x'],
        'm': {'k': 'v'},
        's': {1},
      }.toJSDeep;
      expect(
        o.toMap(),
        equals({
          'n': null,
          'l': [1, 'x'],
          'm': {'k': 'v'},
          's': [1],
        }),
      );
      expect(o.isPlainObject, isTrue);
    });
  });

  group('Iterable toJS', () {
    test('IterableJSAnyToJSArray', () {
      final a = [1.toJS, null, 'a'.toJS].toJS;
      expect(a.length, equals(3));
      expect(a.dartify(), equals([1, null, 'a']));

      final JSArray<JSString> strings = {'x'.toJS, 'y'.toJS}.toJS;
      expect(strings.toList(), equals(['x', 'y']));
    });

    test('String', () {
      expect(['a', 'b'].toJS.toList(), equals(['a', 'b']));
      expect(['a', null].toJS.dartify(), equals(['a', null]));
    });

    test('num / int / double', () {
      expect(<num>[1, 2.5].toJS.toListNum(), equals([1, 2.5]));
      expect(<num?>[1, null].toJS.dartify(), equals([1, null]));
      expect([1, 2].toJS.toListInt(), equals([1, 2]));
      expect(<int?>[1, null].toJS.dartify(), equals([1, null]));
      expect([1.5, 2.0].toJS.toListDouble(), equals([1.5, 2.0]));
      expect(<double?>[1.5, null].toJS.dartify(), equals([1.5, null]));
    });

    test('bool', () {
      expect([true, false].toJS.toList(), equals([true, false]));
      expect(<bool?>[true, null].toJS.dartify(), equals([true, null]));
    });

    test('Uint8List', () {
      final js = Uint8List.fromList([0, 127, 255]).toJS;
      expect(js.isA<JSUint8Array>(), isTrue);
      expect(js.toDart, equals([0, 127, 255]));
      expect(Uint8List(0).toJS.toDart, isEmpty);
    });

    test('IterableOfIterableExtension.toJSDeep', () {
      final JSArray<JSArray<JSAny?>> a = [
        [1],
        <int>[],
        [2, 3],
      ].toJSDeep;
      expect(a.length, equals(3));
      expect(
        a.dartify(),
        equals([
          [1],
          [],
          [2, 3],
        ]),
      );
    });

    test('whereJSAny', () {
      final values = <Object?>[1.toJS, _Foo(), null, JSObject(), 'a'.toJS];
      expect(values.whereJSAny().length, equals(3));
      expect(<Object?>[].whereJSAny(), isEmpty);
    });

    test('toJSIterableDeep of empty and nested iterables', () {
      expect(<Object?>[].toJSIterableDeep.toList(), isEmpty);
      expect(
        [
          [1, 2],
          {'a': <int>{}},
        ].toJSIterableDeep.toList(),
        equals([
          [1, 2],
          {'a': []},
        ]),
      );
    });
  });

  group('JSObjectExtension', () {
    test('keys / get / entries / toMap', () {
      final o = JSObject();
      expect(o.keys, isEmpty);
      expect(o.toMap(), isEmpty);

      o
        ..put('b', 1)
        ..put('a', [true]);
      expect(o.keys, equals(['b', 'a']));
      expect(o.get('a'), equals([true]));
      expect(o.get('none'), isNull);
      expect(o.entries.map((e) => e.key), equals(['b', 'a']));
      expect(
        o.entries.map((e) => e.value),
        equals([
          1,
          [true],
        ]),
      );
      expect(
        o.toMap(),
        equals({
          'b': 1,
          'a': [true],
        }),
      );
    });

    test('put overwrites and converts deeply', () {
      final o = JSObject()
        ..put('k', 1)
        ..put('k', {
          'x': [1, 2],
        });
      expect(o.keys, equals(['k']));
      expect(
        o.get('k'),
        equals({
          'x': [1, 2],
        }),
      );
    });

    test('JS orders integer-like keys first', () {
      final o = JSObject()
        ..put('z', 0)
        ..put(2, 0)
        ..put('1', 0);
      expect(o.keys, equals(['1', '2', 'z']));
    });

    test('null properties', () {
      final o = JSObject()..put('n', null);
      expect(o.keys, equals(['n']));
      expect(o.get('n'), isNull);
      expect(o.toMap(), equals({'n': null}));
    });

    test('as<T>() for every checked JS type', () {
      // With `dart2wasm` the type argument can't be inspected at runtime, so
      // a mismatching `as<T>()` only casts (not null):
      final mismatch = JSObject == JSArray ? isNotNull : isNull;
      final plain = JSObject();

      JSObject o(JSAny v) => v as JSObject;

      final buffer = Uint8List(4).buffer;

      expect(o(buffer.toJS).as<JSArrayBuffer>(), isNotNull);
      expect(plain.as<JSArrayBuffer>(), mismatch);

      expect(o(Int8List(1).toJS).as<JSTypedArray>(), isNotNull);
      expect(plain.as<JSTypedArray>(), mismatch);

      expect(o(Int8List(1).toJS).as<JSInt8Array>(), isNotNull);
      expect(o(Uint8List(1).toJS).as<JSUint8Array>(), isNotNull);
      expect(o(Uint8ClampedList(1).toJS).as<JSUint8ClampedArray>(), isNotNull);
      expect(o(Int16List(1).toJS).as<JSInt16Array>(), isNotNull);
      expect(o(Uint16List(1).toJS).as<JSUint16Array>(), isNotNull);
      expect(o(Int32List(1).toJS).as<JSInt32Array>(), isNotNull);
      expect(o(Uint32List(1).toJS).as<JSUint32Array>(), isNotNull);
      expect(o(Float32List(1).toJS).as<JSFloat32Array>(), isNotNull);
      expect(o(Float64List(1).toJS).as<JSFloat64Array>(), isNotNull);

      final int8 = o(Int8List(1).toJS);
      expect(int8.as<JSUint8ClampedArray>(), mismatch);
      expect(int8.as<JSInt16Array>(), mismatch);
      expect(int8.as<JSUint16Array>(), mismatch);
      expect(int8.as<JSInt32Array>(), mismatch);
      expect(int8.as<JSUint32Array>(), mismatch);
      expect(int8.as<JSFloat32Array>(), mismatch);
      expect(int8.as<JSFloat64Array>(), mismatch);

      expect(o(ByteData(2).toJS).as<JSDataView>(), isNotNull);
      expect(int8.as<JSDataView>(), mismatch);

      expect(o(Future.value(1.toJS).toJS).as<JSPromise>(), isNotNull);
    });

    test('as<T>() keeps identity', () {
      final d = JSDate();
      expect(d.as<JSObject>().strictEquals(d).toDart, isTrue);
      final a = [1].toJSDeep as JSObject;
      expect(a.as<JSArray>().strictEquals(a).toDart, isTrue);
    });
  });

  group('JSArrayExtension', () {
    test('push', () {
      final a = JSArray();
      expect(a.push(null), equals(1));
      expect(a.push([1, 2]), equals(2));
      expect(
        a.toList(),
        equals([
          null,
          [1, 2],
        ]),
      );
    });

    for (var n = 1; n <= 9; n++) {
      test('pushVarArgs with $n argument(s)', () {
        final args = List.generate(n, (i) => i + 1);
        final a = JSArray();
        final len = Function.apply(a.pushVarArgs, args) as int;
        expect(len, equals(n));
        expect(a.toList(), equals(args));
      });
    }

    test('pushVarArgs converts deeply', () {
      final a = JSArray()..pushVarArgs({'a': 1}, [2], 'x');
      expect(
        a.toList(),
        equals([
          {'a': 1},
          [2],
          'x',
        ]),
      );
    });

    test('pushVarArgs: trailing null arguments are not pushed', () {
      final a = JSArray()..pushVarArgs(1, null, 3, null);
      expect(a.toList(), equals([1, null, 3]));
    });

    test('toIterable / toList / whereType', () {
      final a = [1, 'a', true, null].toJSDeep;
      expect(a.toIterable().length, equals(4));
      expect(a.toList(), equals([1, 'a', true, null]));
      expect(a.whereType<String>(), equals(['a']));
      expect(a.whereType<bool>(), equals([true]));
    });

    test('toListOfString / toListOfInt / toListOfDouble', () {
      final a = [1, 2.5, 'a', 3, 'b', null].toJSDeep;
      expect(a.toListOfString(), equals(['a', 'b']));
      expect(a.toListOfInt(), equals([1, 3]));
      expect(a.toListOfDouble(), equals([1.0, 2.5, 3.0]));
      expect(JSArray().toListOfInt(), isEmpty);
    });
  });

  group('JSIterableExtension', () {
    test('JSArray is a JSIterable', () {
      final JSIterable it = [
        1,
        {'a': 2},
      ].toJSDeep;
      expect(
        it.toList(),
        equals([
          1,
          {'a': 2},
        ]),
      );
    });

    test('JSString is a JSIterable', () {
      final JSIterable it = 'héllo'.toJS;
      expect(it.toList(), equals(['h', 'é', 'l', 'l', 'o']));
      final JSIterable empty = ''.toJS;
      expect(empty.toList(), isEmpty);
    });
  });

  group('JSArrayOf* extensions', () {
    test('JSArray<JSString>', () {
      expect(<JSString>[].toJS.toList(), isEmpty);
      expect(['a', 'b'].toJS.toList(), isA<List<String>>());
    });

    test('JSArray<JSBoolean>', () {
      expect([false].toJS.toList(), isA<List<bool>>());
    });

    test('JSArray<JSNumber>', () {
      final a = [1, 2.5, -3].toJS;
      expect(a.toListDouble(), equals([1.0, 2.5, -3.0]));
      expect(a.toListNum(), equals([1, 2.5, -3]));
      expect(a.toListNum().whereType<int>(), equals([1, -3]));
      expect([4, 5].toJS.toListInt(), equals([4, 5]));
    });
  });

  group('JSObjectUtil', () {
    test('keys', () {
      expect(JSObjectUtil.keys({'x': 1, 'y': 2}.toJSDeep), equals(['x', 'y']));
    });

    test('prototype is Object.prototype', () {
      expect(
        JSObject().prototype!.strictEquals(JSObjectUtil.prototype).toDart,
        isTrue,
      );
      expect(JSObjectUtil.prototype.prototype, isNull);
    });
  });

  group('JSArrayUtil', () {
    test('push up to 9 values', () {
      final a = JSArrayUtil(JSArray());
      expect(
        a.push(
          1.toJS,
          2.toJS,
          3.toJS,
          4.toJS,
          5.toJS,
          6.toJS,
          7.toJS,
          8.toJS,
          9.toJS,
        ),
        equals(9),
      );
      expect(a.toList(), equals([1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });
  });

  group('tryCall', () {
    test('returns the result', () {
      expect(tryCall(() => 1), equals(1));
      expect(tryCall<int?>(() => null), isNull);
    });

    test('returns null on error', () {
      expect(tryCall<int>(() => throw StateError('x')), isNull);
      expect(tryCall(() => int.parse('x')), isNull);
    });
  });

  group('JSDate / DateTime', () {
    test('toJSDate round-trip', () {
      final dt = DateTime.utc(1999, 12, 31, 23, 59, 59, 999);
      final d = dt.toJSDate();
      expect(d.getTime(), equals(dt.millisecondsSinceEpoch));
      expect(d.toDateTime(isUtc: true), equals(dt));
      expect(d.toDateTime().isUtc, isFalse);
      expect(d.toDateTime(), equals(dt.toLocal()));
    });

    test('epoch and pre-epoch', () {
      expect(JSDate.fromMillisecondsSinceEpoch(0).getTime(), equals(0));
      final before = DateTime.utc(1900, 1, 1);
      expect(before.toJSDate().toDateTime(isUtc: true), equals(before));
    });

    test('JSDate.UTC with year only', () {
      expect(
        JSDate.UTC(2000),
        equals(DateTime.utc(2000).millisecondsSinceEpoch),
      );
    });

    test('JSDate is a JSObject, not a plain object', () {
      final d = JSDate();
      expect(d.isJSObject, isTrue);
      expect(d.isPlainObject, isFalse);
      expect(d.keys, isEmpty);
    });
  });
}
