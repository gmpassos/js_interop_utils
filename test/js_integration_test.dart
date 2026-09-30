@TestOn('browser')
library;

import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

/// Integration tests: values produced by this package are consumed by real
/// JavaScript code, and values produced by JavaScript are consumed by this
/// package.

@JS('Function')
extension type _JSFunctionCtor._(JSFunction _) implements JSFunction {
  external _JSFunctionCtor(String body);
}

/// Creates a JS function from [body]; arguments are read from `arguments`.
JSFunction _js(String body) => _JSFunctionCtor(body);

/// Evaluates a JS [expression], returning its value.
JSAny? _eval(String expression) =>
    _js('return ($expression);').callAsFunction();

final _stringify = _js('return JSON.stringify(arguments[0]);');

String _jsonOf(JSAny? value) =>
    (_stringify.callAsFunction(null, value) as JSString).toDart;

String _typeOf(JSAny? value) => (_js(
  'return typeof arguments[0];',
).callAsFunction(null, value) as JSString).toDart;

bool _jsBool(String body, JSAny? arg) =>
    (_js(body).callAsFunction(null, arg) as JSBoolean).toDart;

void main() {
  group('Dart -> JS', () {
    test('toJSDeep: JSON.stringify of a deep structure', () {
      final o = {
        'a': 1,
        'b': [
          1,
          2.5,
          {'c': true},
        ],
        'd': null,
        'e': 'x',
        'f': <Object?>[],
        'g': <String, Object?>{},
      }.toJSDeep;

      expect(
        _jsonOf(o),
        equals('{"a":1,"b":[1,2.5,{"c":true}],"d":null,"e":"x","f":[],"g":{}}'),
      );
    });

    test('toJSDeep: JS types seen by JS', () {
      expect(
        _jsBool('return Array.isArray(arguments[0]);', [1].toJSDeep),
        isTrue,
      );
      expect(
        _jsBool('return Array.isArray(arguments[0]);', {'a': 1}.toJSDeep),
        isFalse,
      );
      expect(_typeOf('a'.toJSDeep), equals('string'));
      expect(_typeOf(1.toJSDeep), equals('number'));
      expect(_typeOf(true.toJSDeep), equals('boolean'));
      expect(_typeOf(null.toJSDeep), equals('object'));
      expect(_typeOf({'a': 1}.toJSDeep), equals('object'));
    });

    test('Iterable toJS variants seen by JS', () {
      expect(_jsonOf(['a', 'b'].toJS), equals('["a","b"]'));
      expect(_jsonOf(['a', null].toJS), equals('["a",null]'));
      expect(_jsonOf([1, 2].toJS), equals('[1,2]'));
      expect(_jsonOf([1, null].toJS), equals('[1,null]'));
      expect(_jsonOf([1.5, 2.5].toJS), equals('[1.5,2.5]'));
      expect(_jsonOf([1.5, null].toJS), equals('[1.5,null]'));
      expect(_jsonOf(<num>[1, 2.5].toJS), equals('[1,2.5]'));
      expect(_jsonOf(<num?>[1, null].toJS), equals('[1,null]'));
      expect(_jsonOf([true, false].toJS), equals('[true,false]'));
      expect(_jsonOf([true, null].toJS), equals('[true,null]'));
      expect(
        _jsonOf(
          [
            ['a', 1],
            ['b', 2],
          ].toJSDeep,
        ),
        equals('[["a",1],["b",2]]'),
      );
    });

    test('Uint8List.toJS is a JS Uint8Array', () {
      final a = Uint8List.fromList([1, 2, 255]).toJS;
      expect(_jsBool('return arguments[0] instanceof Uint8Array;', a), isTrue);
      expect(
        _jsonOf(
          _js('return Array.from(arguments[0]);').callAsFunction(null, a),
        ),
        equals('[1,2,255]'),
      );
    });

    test('every typed list .toJS is the matching JS typed array', () {
      final values = <String, JSAny>{
        'Int8Array': Int8List.fromList([1, -1]).toJS,
        'Uint8Array': Uint8List.fromList([1, 255]).toJS,
        'Uint8ClampedArray': Uint8ClampedList.fromList([1, 255]).toJS,
        'Int16Array': Int16List.fromList([1, -1]).toJS,
        'Uint16Array': Uint16List.fromList([1, 65535]).toJS,
        'Int32Array': Int32List.fromList([1, -1]).toJS,
        'Uint32Array': Uint32List.fromList([1, 4294967295]).toJS,
        'Float32Array': Float32List.fromList([1, 0.5]).toJS,
        'Float64Array': Float64List.fromList([1, 0.1]).toJS,
      };

      for (final e in values.entries) {
        expect(
          (_js(
            'return Object.prototype.toString.call(arguments[0]);',
          ).callAsFunction(null, e.value) as JSString).toDart,
          equals('[object ${e.key}]'),
          reason: e.key,
        );
        expect(e.value.isA<JSTypedArray>(), isTrue, reason: e.key);
      }

      expect(
        _jsonOf(
          _js('return Array.from(arguments[0]);')
              .callAsFunction(null, values['Int8Array']),
        ),
        equals('[1,-1]'),
      );
      expect(
        _jsonOf(
          _js('return Array.from(arguments[0]);')
              .callAsFunction(null, values['Float64Array']),
        ),
        equals('[1,0.1]'),
      );
    });

    test('typed lists nested in toJSDeep are JS typed arrays', () {
      final o = {
        'bytes': Uint8List.fromList([1, 2]),
        'floats': [
          Float32List.fromList([0.5]),
        ],
      }.toJSDeep;

      expect(
        _jsBool('return arguments[0].bytes instanceof Uint8Array;', o),
        isTrue,
      );
      expect(
        _jsBool('return arguments[0].floats[0] instanceof Float32Array;', o),
        isTrue,
      );
      expect((o.get('bytes') as List).cast<int>(), equals([1, 2]));
    });

    test('DateTime.toJSDate is a JS Date', () {
      final dt = DateTime.utc(2024, 2, 29, 12, 30, 15, 250);
      final d = dt.toJSDate();
      expect(_jsBool('return arguments[0] instanceof Date;', d), isTrue);
      expect(
        (_js(
          'return arguments[0].toISOString();',
        ).callAsFunction(null, d) as JSString).toDart,
        equals('2024-02-29T12:30:15.250Z'),
      );
    });

    test('JSObject.put / JSArray.push seen by JS', () {
      final o = JSObject()
        ..put('a', [1, 2])
        ..put(1, 'one')
        ..put('n', null);
      expect(_jsonOf(o), equals('{"1":"one","a":[1,2],"n":null}'));

      final arr = JSArray()
        ..push(1)
        ..push({'x': 'y'})
        ..pushVarArgs('a', 'b', 'c');
      expect(
        (_js(
          'return arguments[0].length;',
        ).callAsFunction(null, arr) as JSNumber).toDartInt,
        equals(5),
      );
      expect(_jsonOf(arr), equals('[1,{"x":"y"},"a","b","c"]'));
    });

    test(
      'exported Dart callback in a toJSDeep structure is callable by JS',
      () {
        final o = {
          'double': ((JSNumber n) => (n.toDartInt * 2).toJS).toJS,
          'value': 21,
        }.toJSDeep;

        final r = _js(
          'var o = arguments[0]; return o.double(o.value);',
        ).callAsFunction(null, o) as JSNumber;
        expect(r.toDartInt, equals(42));

        final fn = o.getProperty<JSAny?>('double'.toJS);
        expect(fn.isJSFunction, isTrue);
        expect(fn.isJSExportedDartFunction, isTrue);
      },
    );

    test('toJSIterableDeep consumed by JS iteration protocols', () {
      final it = [
        1,
        'a',
        {'b': true},
      ].toJSIterableDeep;

      expect(
        _jsonOf(
          _js('return Array.from(arguments[0]);').callAsFunction(null, it),
        ),
        equals('[1,"a",{"b":true}]'),
      );
      expect(
        _jsonOf(_js('return [...arguments[0]];').callAsFunction(null, it)),
        equals('[1,"a",{"b":true}]'),
      );
      expect(
        (_js(
          'var n = 0; for (const x of arguments[0]) n++; return n;',
        ).callAsFunction(null, it) as JSNumber).toDartInt,
        equals(3),
      );
      // Re-iterable: each iteration gets a new iterator.
      expect(
        (_js(
          'return new Set(arguments[0]).size;',
        ).callAsFunction(null, it) as JSNumber).toDartInt,
        equals(3),
      );
    });

    test('toJSIterableDeep is lazy when JS stops early', () {
      var count = 0;
      Iterable<int> gen() sync* {
        for (var i = 0; i < 1000; i++) {
          count++;
          yield i;
        }
      }

      final first = _js(
        'for (const x of arguments[0]) { if (x >= 2) return x; } return -1;',
      ).callAsFunction(null, gen().toJSIterableDeep) as JSNumber;

      expect(first.toDartInt, equals(2));
      expect(count, equals(3));
    });
  });

  group('JS -> Dart', () {
    test('JSON.parse result: toMap / get / keys / entries', () {
      final o = _eval(
        'JSON.parse(\'{"a":1,"b":[1,"x",null],"c":{"d":true}}\')',
      ) as JSObject;

      expect(o.keys, equals(['a', 'b', 'c']));
      expect(o.get('a'), equals(1));
      expect(o.get('b'), equals([1, 'x', null]));
      expect(o.get('c'), equals({'d': true}));
      expect(o.get('missing'), isNull);
      expect(o.entries.map((e) => e.key), equals(['a', 'b', 'c']));
      expect(
        o.toMap(),
        equals({
          'a': 1,
          'b': [1, 'x', null],
          'c': {'d': true},
        }),
      );
      expect(o.isPlainObject, isTrue);
    });

    test('JSON.parse arrays: typed list conversions', () {
      final mixed = _eval('[1, 2.5, "a", true, null]') as JSArray;
      expect(mixed.toList(), equals([1, 2.5, 'a', true, null]));
      expect(mixed.toListOfString(), equals(['a']));
      expect(mixed.toListOfInt(), equals([1]));
      expect(
        (_eval('[1, 2.0, 2.5, 3]') as JSArray).toListOfInt(),
        equals([1, 2, 3]),
      );
      expect(mixed.toListOfDouble(), equals([1.0, 2.5]));
      expect(mixed.whereType<bool>(), equals([true]));

      expect(
        (_eval('["a", "b"]') as JSArray<JSString>).toList(),
        equals(['a', 'b']),
      );
      expect(
        (_eval('[true, false]') as JSArray<JSBoolean>).toList(),
        equals([true, false]),
      );

      final nums = _eval('[1, 2.5, 3]') as JSArray<JSNumber>;
      expect(nums.toListDouble(), equals([1.0, 2.5, 3.0]));
      expect(nums.toListNum(), equals([1, 2.5, 3]));
      expect(nums.toListNum()[0], isA<int>());
      expect(nums.toListNum()[1], equals(2.5));
      expect(
        (_eval('[NaN, Infinity]') as JSArray<JSNumber>).toListNum(),
        everyElement(isA<double>()),
      );
      expect(
        (_eval('[1, 2, 3]') as JSArray<JSNumber>).toListInt(),
        equals([1, 2, 3]),
      );
    });

    // Regression: whole numbers beyond 2^53 were converted with `toInt()`,
    // which caps them on the VM/dart2wasm (`1e20` -> 9223372036854775807).
    test('large whole numbers are not capped', () {
      final big = _eval('[1e20, -1e20, 9007199254740991, 5]') as JSArray;

      expect(
        (big as JSArray<JSNumber>).toListNum(),
        equals([1e20, -1e20, 9007199254740991, 5]),
      );
      expect(big.toListNum()[2], isA<int>());
      expect(big.toListOfInt(), equals([9007199254740991, 5]));
    });

    test('JS BigInt array', () {
      final a = _eval('[1n, 2n, 12345678901234567890n]') as JSArray<JSBigInt>;
      expect(
        a.toList(),
        equals([BigInt.one, BigInt.two, BigInt.parse('12345678901234567890')]),
      );
    });

    test('JS Date to DateTime', () {
      final d = _eval('new Date(Date.UTC(2020, 0, 2, 3, 4, 5, 6))') as JSDate;
      expect(
        d.toDateTime(isUtc: true),
        equals(DateTime.utc(2020, 1, 2, 3, 4, 5, 6)),
      );
      expect(d.isPlainObject, isFalse);
      expect(d.as<JSObject>(), isNotNull);
    });

    test('JS Set / Map / String / generator as JSIterable', () {
      expect(
        (_eval('new Set([1, 2, 2, 3])') as JSIterable).toList(),
        equals([1, 2, 3]),
      );
      expect(
        (_eval('new Map([["a", 1], ["b", 2]])') as JSIterable).toList(),
        equals([
          ['a', 1],
          ['b', 2],
        ]),
      );
      expect((_eval('"abc"') as JSIterable).toList(), equals(['a', 'b', 'c']));
      // Same code point split as JS `[..."a😀"]`:
      expect(
        (_eval('"a\u{1F600}"') as JSIterable).toList(),
        equals(['a', '\u{1F600}']),
      );
      expect(
        _jsonOf(_eval('[..."a\u{1F600}"]')),
        equals(_jsonOf(['a', '\u{1F600}'].toJS)),
      );
      expect(
        (_eval(
          '(function* () { yield 1; yield "x"; yield {y: 2}; })()',
        ) as JSIterable).toList(),
        equals([
          1,
          'x',
          {'y': 2},
        ]),
      );
    });

    test('JS iterable round-trip through Dart', () {
      final jsSet = _eval('new Set(["a", "b"])') as JSIterable;
      final back = jsSet.toIterable().toJSIterableDeep;
      expect(
        _jsonOf(
          _js('return Array.from(arguments[0]);').callAsFunction(null, back),
        ),
        equals('["a","b"]'),
      );
    });

    test('prototypes of JS-created objects', () {
      final instance = _eval(
        'new (class Foo { constructor() { this.a = 1; } })()',
      ) as JSObject;
      expect(instance.isPlainObject, isFalse);
      expect(instance.prototype, isNotNull);
      expect(instance.toMap(), equals({'a': 1}));

      final noProto = _eval(
        'Object.assign(Object.create(null), {a: 1, b: "x"})',
      ) as JSObject;
      expect(noProto.prototype, isNull);
      expect(noProto.isPlainObject, isTrue);
      expect(noProto.isJSObject, isTrue);
      expect(noProto.keys, equals(['a', 'b']));
      expect(noProto.toMap(), equals({'a': 1, 'b': 'x'}));

      final literal = _eval('({a: 1})') as JSObject;
      expect(literal.isPlainObject, isTrue);
      expect(
        literal.prototype!.strictEquals(JSObjectUtil.prototype).toDart,
        isTrue,
      );
    });

    test('type checks on JS-created values', () {
      final fn = _eval('function f(a) { return a; }');
      expect(fn.isJSFunction, isTrue);
      expect(fn.isJSExportedDartFunction, isFalse);
      expect(fn.isJSAny, isNot(isFalse));
      expect(fn.isJSObject, isTrue);

      final arrow = _eval('(a) => a');
      expect(arrow.isJSFunction, isTrue);

      // An exported Dart function stays recognizable after passing through JS.
      final exported = ((JSAny? a) => a).toJS;
      final same = _js('return arguments[0];').callAsFunction(null, exported);
      expect(same.isJSExportedDartFunction, isTrue);

      final arr = _eval('[1, 2]');
      expect(arr.isJSAny, isNot(isFalse));
      expect(arr.isJSObject, isNot(isFalse));
      expect(arr.isJSFunction, isFalse);
      expect((arr as JSObject).as<JSArray>(), isNotNull);

      final u8 = _eval('new Uint8Array([7, 8])') as JSObject;
      expect(u8.as<JSUint8Array>(), isNotNull);
      expect(u8.as<JSUint8Array>()!.toDart, equals([7, 8]));

      expect(_eval('"s"').isJSObject, isFalse);
      expect(_eval('1').isJSObject, isFalse);
      expect(_eval('undefined').isJSAny, isFalse);
      expect(_eval('null').asJSObject, isNull);
    });

    test('asString on JS values', () {
      expect(_eval('"abc"').asString, equals('abc'));
      expect(_eval('12').asString, anyOf('12', '12.0'));
      expect(_eval('true').asString, equals('true'));
      expect(_eval('null').asString, isNull);
      expect(_eval('[1, "a"]')!.asString, anyOf('[1, a]', '[1.0, a]'));
    });

    test('objectDartify on JS-created values', () {
      expect(_eval('({a: [1, {b: "c"}]})').objectDartify(), {
        'a': [
          1,
          {'b': 'c'},
        ],
      });
      expect(_eval('null').objectDartify(), isNull);
      expect(_eval('"x"').objectDartify(), equals('x'));
    });

    test('JS strings are safe Dart strings after toDartFix', () {
      final s = (_eval('"a" + "b" + "c"') as JSString).toDart.toDartFix;
      expect(s, equals('abc'));
      expect(s.runtimeType, equals(String));
      expect('$s!', equals('abc!'));
      expect(''.toDartFix, isEmpty);
    });

    test('whereJSAny over mixed JS/Dart values', () {
      final values = [_eval('1'), _eval('({})'), _Foo(), null, _eval('"s"')];
      expect(values.whereJSAny().length, equals(3));
    });
  });

  group('round-trips', () {
    test('Dart map -> JS -> JSON -> JS -> Dart map', () {
      final data = {
        'id': 7,
        'name': 'n',
        'tags': ['a', 'b'],
        'nested': {
          'ok': true,
          'list': [
            1,
            [2, 3],
          ],
        },
      };

      final json = _jsonOf(data.toJSDeep);
      final parsed = _js(
        'return JSON.parse(arguments[0]);',
      ).callAsFunction(null, json.toJS) as JSObject;
      expect(parsed.toMap(), equals(data));
    });

    test('JS mutates a toJSDeep object; Dart reads it back', () {
      final o = {'count': 1, 'items': <Object?>[]}.toJSDeep;
      _js(
        'var o = arguments[0]; o.count++; o.items.push("x", 2); o.extra = {k: null};',
      ).callAsFunction(null, o);

      expect(
        o.toMap(),
        equals({
          'count': 2,
          'items': ['x', 2],
          'extra': {'k': null},
        }),
      );
    });

    test('globalThis property set via JSObject.put', () {
      globalContext.put('__jsInteropUtilsTest', {'v': 1});
      try {
        expect(_jsonOf(_eval('globalThis.__jsInteropUtilsTest')), '{"v":1}');
      } finally {
        globalContext.delete('__jsInteropUtilsTest'.toJS);
      }
    });
  });
}

class _Foo {}
