import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'js_interop_utils_helpers.dart';

extension ObjectExtension on Object? {
  /// Returns `true` if this instance is a [JSAny].
  /// Returns `null` if it's an ambiguous Dart/JS type: a JS value that is also
  /// a Dart [List], [Map] or [Function] (for example, when compiled with
  /// `dart2js`, a Dart [List] is a JS `Array`).
  bool? get isJSAny {
    final self = this;
    if (!self.isA<JSAny>()) return false;

    if (self is List || self is Map || self is Function) return null;

    return true;
  }

  /// Casts an [Object] to a [JSAny], in a graceful manner.
  /// Returns `null` if this instance is not a JS value.
  /// See [isJSAny].
  JSAny? get asJSAny {
    final self = this;
    return self.isA<JSAny>() ? self as JSAny : null;
  }

  /// Returns `true` if this instance is a [JSObject].
  /// Returns `null` if it's an ambiguous Dart/JS type: a JS `Array` that is
  /// also a Dart [List] (when compiled with `dart2js`).
  bool? get isJSObject {
    final self = this;
    if (!self.isA<JSObject>()) return false;

    if (self is List && self.isA<JSArray>()) return null;

    return true;
  }

  /// Casts an [Object] to a [JSObject], in a graceful manner.
  /// Returns `null` if this instance is not a JS object.
  /// See [isJSObject].
  JSObject? get asJSObject {
    final self = this;
    return self.isA<JSObject>() ? self as JSObject : null;
  }

  /// Returns `true` if this instance is a JS `Function`,
  /// including a Dart function exported with `Function.toJS`.
  bool get isJSFunction => isA<JSFunction>();

  /// Returns `true` if this instance is a Dart function exported to JS
  /// with `Function.toJS` or `Function.toJSCaptureThis`.
  bool get isJSExportedDartFunction => isA<JSExportedDartFunction>();

  /// Converts an [Object], which could be a [JSAny], to a Dart type in a graceful manner.
  /// See [isJSAny].
  Object? objectDartify() {
    final self = this;
    return self.isA<JSAny>() ? (self as JSAny).dartify() : self;
  }

  JSAny? get toJSDeep {
    final self = this;
    if (self == null) {
      return null;
    } else if (self is String) {
      return self.toJS;
    } else if (self is num) {
      return self.toJS;
    } else if (self is bool) {
      return self.toJS;
    } else if (self is Function) {
      return self.jsify();
    } else if (self is TypedData) {
      // To a JS typed array (not an `Array`, as an `Iterable` would be):
      return self.jsify();
    } else if (self is Map) {
      return self.toJSDeep;
    } else if (self is Iterable) {
      return self.toJSDeep;
    } else {
      return self.jsify();
    }
  }
}

extension JSAnyNullableExtension on JSAny? {
  String? get asString => this?.dartify()?.toString();
}

extension JSAnyExtension on JSAny {
  String get asString => dartify()?.toString() ?? '';
}

extension StringExtension on String {
  static final _emptyString = '';

  /// When compiled to `Wasm` a `JSStringImpl` can leak to the `Wasm` VM
  /// and it will crash, trying to cast to a `Wasm` String (`OneByteString`).
  String get toDartFix {
    final self = this;

    if (self.isEmpty) {
      return '';
    }

    if (self.runtimeType != String) {
      // Force a Dart String.
      var b = '$_emptyString$self';
      return b;
    }

    return this;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  JSObject get toJSDeep {
    var obj = JSObject();

    for (var e in entries) {
      var key = e.key ?? '';
      var value = e.value;
      obj.setProperty(key.toJSDeep!, value.toJSDeep);
    }

    return obj;
  }
}

extension IterableJSAnyToJSArray<T extends JSAny?> on Iterable<T> {
  JSArray<T> get toJS => ListToJSArray(toList()).toJS;
}

extension IterableExtension<T> on Iterable<T> {
  JSArray<JSAny?> get toJSDeep => map((e) => e.toJSDeep).toJS;

  /// A lazy [JSIterable] over this [Iterable], converting each element
  /// with [ObjectExtension.toJSDeep] as it's iterated.
  /// See [IterableToJSIterable.toJSIterable].
  JSIterable<JSAny?> get toJSIterableDeep =>
      map((e) => e.toJSDeep).toJSIterable;

  Iterable<JSAny> whereJSAny() => map((e) => e.asJSAny).nonNulls;
}

extension IterableOfIterableExtension<E, T extends Iterable<E>> on Iterable<T> {
  JSArray<JSArray<JSAny?>> get toJSDeep => map((e) => e.toJSDeep).toJS;
}

extension IterableStringExtension<T> on Iterable<String> {
  JSArray<JSString> get toJS => map((e) => e.toJS).toJS;
}

extension IterableStringNullableExtension<T> on Iterable<String?> {
  JSArray<JSString?> get toJS => map((e) => e?.toJS).toJS;
}

// Typed lists are also `Iterable<int>`/`Iterable<double>`, and a package
// extension takes precedence over a `dart:js_interop` one. Without these, the
// `Iterable<int>`/`Iterable<double>` `toJS` below would shadow the SDK's and
// convert a typed list into a JS `Array` instead of a JS typed array.

extension Uint8ListExtension on Uint8List {
  JSUint8Array get toJS => Uint8ListToJSUint8Array(this).toJS;
}

extension Int8ListExtension on Int8List {
  JSInt8Array get toJS => Int8ListToJSInt8Array(this).toJS;
}

extension Uint8ClampedListExtension on Uint8ClampedList {
  JSUint8ClampedArray get toJS =>
      Uint8ClampedListToJSUint8ClampedArray(this).toJS;
}

extension Int16ListExtension on Int16List {
  JSInt16Array get toJS => Int16ListToJSInt16Array(this).toJS;
}

extension Uint16ListExtension on Uint16List {
  JSUint16Array get toJS => Uint16ListToJSUint16Array(this).toJS;
}

extension Int32ListExtension on Int32List {
  JSInt32Array get toJS => Int32ListToJSInt32Array(this).toJS;
}

extension Uint32ListExtension on Uint32List {
  JSUint32Array get toJS => Uint32ListToJSUint32Array(this).toJS;
}

extension Float32ListExtension on Float32List {
  JSFloat32Array get toJS => Float32ListToJSFloat32Array(this).toJS;
}

extension Float64ListExtension on Float64List {
  JSFloat64Array get toJS => Float64ListToJSFloat64Array(this).toJS;
}

extension IterableNumExtension<T> on Iterable<num> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toJS;
}

extension IterableNumNullableExtension<T> on Iterable<num?> {
  JSArray<JSNumber?> get toJS => map((e) => e?.toJS).toJS;
}

extension IterableIntExtension<T> on Iterable<int> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toJS;
}

extension IterableIntNullableExtension<T> on Iterable<int?> {
  JSArray<JSNumber?> get toJS => map((e) => e?.toJS).toJS;
}

extension IterableDoubleExtension<T> on Iterable<double> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toJS;
}

extension IterableDoubleNullableExtension<T> on Iterable<double?> {
  JSArray<JSNumber?> get toJS => map((e) => e?.toJS).toJS;
}

extension IterableBoolExtension<T> on Iterable<bool> {
  JSArray<JSBoolean> get toJS => map((e) => e.toJS).toJS;
}

extension IterableBoolNullableExtension<T> on Iterable<bool?> {
  JSArray<JSBoolean?> get toJS => map((e) => e?.toJS).toJS;
}

extension JSObjectExtension on JSObject {
  /// Whether JS interop types are erased to the same runtime type, which is
  /// the case with `dart2wasm` (e.g. `JSObject == JSArray`). When erased, [T]
  /// can't be inspected at runtime by [as].
  static final bool _interopTypesErased = JSObject == JSArray;

  /// Casts this [JSObject] to [T], returning `null` if it isn't a [T].
  ///
  /// The JS type of [T] is only checked when it can be told apart at runtime.
  /// With `dart2wasm` no interop type can, and with `dart2js` types erased to
  /// the same runtime type as [JSObject] (e.g. [JSPromise]) can't, so in
  /// those cases this only casts. Prefer `isA<T>()` with a concrete type
  /// argument when the check matters.
  T? as<T extends JSObject>() {
    if (isUndefinedOrNull) return null;

    if (_interopTypesErased || T == JSObject) {
      return this as T;
    } else if (T == JSArray) {
      return isA<JSArray>() ? this as T : null;
    } else if (T == JSArrayBuffer) {
      return isA<JSArrayBuffer>() ? this as T : null;
    } else if (T == JSTypedArray) {
      return isA<JSTypedArray>() ? this as T : null;
    } else if (T == JSInt8Array) {
      return isA<JSInt8Array>() ? this as T : null;
    } else if (T == JSUint8Array) {
      return isA<JSUint8Array>() ? this as T : null;
    } else if (T == JSUint8ClampedArray) {
      return isA<JSUint8ClampedArray>() ? this as T : null;
    } else if (T == JSInt16Array) {
      return isA<JSInt16Array>() ? this as T : null;
    } else if (T == JSUint16Array) {
      return isA<JSUint16Array>() ? this as T : null;
    } else if (T == JSInt32Array) {
      return isA<JSInt32Array>() ? this as T : null;
    } else if (T == JSUint32Array) {
      return isA<JSUint32Array>() ? this as T : null;
    } else if (T == JSFloat32Array) {
      return isA<JSFloat32Array>() ? this as T : null;
    } else if (T == JSFloat64Array) {
      return isA<JSFloat64Array>() ? this as T : null;
    } else if (T == JSDataView) {
      return isA<JSDataView>() ? this as T : null;
    } else if (T == JSFunction) {
      return isA<JSFunction>() ? this as T : null;
    } else {
      try {
        return this as T;
      } catch (_) {
        return null;
      }
    }
  }

  Iterable<String> get keys => JSObjectUtil.keys(this);

  Object? get(String key) => getProperty(key.toJS)?.dartify();

  Iterable<MapEntry<String, dynamic>> get entries =>
      keys.map((k) => MapEntry(k, get(k)));

  Map<String, dynamic> toMap() => Map.fromEntries(entries);

  void put(Object key, Object? value) =>
      setProperty(key.toJSDeep!, value.toJSDeep);

  /// The JS prototype of this object, or `null` if it has none
  /// (e.g. an object created with `Object.create(null)`).
  /// See [JSObject.getPrototypeOf].
  JSObject? get prototype => JSObject.getPrototypeOf(this);

  /// Returns `true` if this is a plain JS object (a dictionary-like object
  /// such as `{}`), whose prototype is `Object.prototype` or `null`.
  bool get isPlainObject {
    final proto = prototype;
    return proto == null || proto.strictEquals(JSObjectUtil.prototype).toDart;
  }
}

extension JSArrayExtension on JSArray {
  int push(Object? any) {
    add(any?.toJSDeep);
    return length;
  }

  int pushVarArgs(
    Object? any, [
    Object? any2,
    Object? any3,
    Object? any4,
    Object? any5,
    Object? any6,
    Object? any7,
    Object? any8,
    Object? any9,
  ]) {
    var a = JSArrayUtil(this);

    if (any9 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4?.toJSDeep,
        any5?.toJSDeep,
        any6?.toJSDeep,
        any7?.toJSDeep,
        any8?.toJSDeep,
        any9.toJSDeep,
      );
    } else if (any8 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4?.toJSDeep,
        any5?.toJSDeep,
        any6?.toJSDeep,
        any7?.toJSDeep,
        any8.toJSDeep,
      );
    } else if (any7 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4?.toJSDeep,
        any5?.toJSDeep,
        any6?.toJSDeep,
        any7.toJSDeep,
      );
    } else if (any6 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4?.toJSDeep,
        any5?.toJSDeep,
        any6.toJSDeep,
      );
    } else if (any5 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4?.toJSDeep,
        any5.toJSDeep,
      );
    } else if (any4 != null) {
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3?.toJSDeep,
        any4.toJSDeep,
      );
    } else if (any3 != null) {
      return a.push(any?.toJSDeep, any2?.toJSDeep, any3.toJSDeep);
    } else if (any2 != null) {
      return a.push(any?.toJSDeep, any2.toJSDeep);
    } else {
      return a.push(any?.toJSDeep);
    }
  }

  Iterable<Object?> toIterable() => toDart.map((e) => e.dartify());

  List<Object?> toList() => toIterable().toList();

  Iterable<T> whereType<T>() => toIterable().whereType<T>();

  List<String> toListOfString() =>
      toDart.map((e) => e.dartify()).whereType<String>().toList();

  /// The integer-valued numbers of this array.
  /// (With `dart2wasm`, `dartify` returns JS numbers as [double]s.)
  List<int> toListOfInt() => toDart
      .map((e) => e.dartify())
      .whereType<num>()
      .where(_isIntegral)
      .map((n) => n.toInt())
      .toList();

  List<double> toListOfDouble() => toDart
      .map((e) => e.dartify())
      .whereType<num>()
      .map((n) => n.toDouble())
      .toList();
}

extension JSIterableExtension on JSIterable {
  /// Iterates this [JSIterable], converting each element with `dartify`.
  /// See [JSIterableToIterable.toDartIterable].
  Iterable<Object?> toIterable() {
    // `toDartIterable` fails for a primitive JS string (`Reflect.get` called
    // on non-object), so iterate its code points like JS does:
    if (isA<JSString>()) {
      return (this as JSString).toDart.runes.map(String.fromCharCode);
    }
    return toDartIterable.map((e) => e.dartify());
  }

  List<Object?> toList() => toIterable().toList();
}

extension JSArrayOfJSStringExtension on JSArray<JSString> {
  List<String> toList() => toDart.map((e) => e.toDart).toList();
}

extension JSArrayOfJSBooleanExtension on JSArray<JSBoolean> {
  List<bool> toList() => toDart.map((e) => e.toDart).toList();
}

extension JSArrayOfJSNumberExtension on JSArray<JSNumber> {
  List<int> toListInt() => toDart.map((e) => e.toDartInt).toList();

  List<double> toListDouble() => toDart.map((e) => e.toDartDouble).toList();

  /// Integer-valued numbers are returned as [int], others as [double].
  List<num> toListNum() => toDart.map((e) {
    var d = e.toDartDouble;
    return _isIntegral(d) ? d.toInt() : d;
  }).toList();
}

bool _isIntegral(num n) => n.isFinite && n == n.truncateToDouble();

extension JSArrayOfJSBigIntExtension on JSArray<JSBigInt> {
  List<BigInt> toList() => toDart.map((e) {
    var o = e.dartify();
    if (o is BigInt) return o;
    return BigInt.parse(o.toString());
  }).toList();
}
