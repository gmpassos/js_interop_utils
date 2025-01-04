import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'js_interop_utils_helpers.dart';

extension ObjectExtension on Object? {
  /// Returns `true` if this instance is a [JSAny].
  /// Returns `null` if it's an ambiguous Dart/JS type.
  bool? get isJSAny {
    final self = this;
    if (self == null) return false;

    // TODO: check a better way to identify a `JSAny` instance:

    // Ambiguous platform identification:
    // ignore: invalid_runtime_check_with_js_interop_types, unnecessary_type_check
    if (self is JSArray && self is JSObject) {
      return null;
    }

    // Ambiguous types:

    // ignore: invalid_runtime_check_with_js_interop_types, unnecessary_type_check
    if (self is String && self is JSString) {
      return null;
    }
    // ignore: invalid_runtime_check_with_js_interop_types, unnecessary_type_check
    else if (self is num && self is JSNumber) {
      return null;
    }
    // ignore: invalid_runtime_check_with_js_interop_types, unnecessary_type_check
    else if (self is bool && self is JSBoolean) {
      return null;
    }
    // ignore: invalid_runtime_check_with_js_interop_types, unnecessary_type_check
    else if (self is List && self is JSArray) {
      return null;
    }

    // Exclusive Dart types:
    if (self is Map) {
      return false;
    }

    // ignore: invalid_runtime_check_with_js_interop_types
    return self is JSAny;
  }

  /// Converts an [Object], which could be a [JSAny], to a Dart type in a graceful manner.
  /// See [isJSAny].
  Object? objectDartify() {
    final self = this;
    if (self == null) return null;

    var isJSAny = self.isJSAny;

    if (isJSAny != null) {
      if (isJSAny) {
        return (self as JSAny).dartify();
      } else {
        return self;
      }
    } else {
      try {
        var o = self as JSAny;
        return o.dartify();
      } catch (_) {
        return self;
      }
    }
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
    } else if (self is Map) {
      return self.toJSDeep;
    } else if (self is Iterable) {
      return self.toJSDeep;
    } else {
      return self.jsify();
    }
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
  JSArray<JSAny?> get toJSDeep => map((e) => e.toJSDeep).toList().toJS;
}

extension IterableOfIterableExtension<E, T extends Iterable<E>> on Iterable<T> {
  JSArray<JSArray<JSAny?>> get toJSDeep => map((e) => e.toJSDeep).toList().toJS;
}

extension IterableStringExtension<T> on Iterable<String> {
  JSArray<JSString> get toJS => map((e) => e.toJS).toList().toJS;
}

extension IterableNumExtension<T> on Iterable<num> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toList().toJS;
}

extension IterableIntExtension<T> on Iterable<int> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toList().toJS;
}

extension IterableDoubleExtension<T> on Iterable<double> {
  JSArray<JSNumber> get toJS => map((e) => e.toJS).toList().toJS;
}

extension IterableBoolExtension<T> on Iterable<bool> {
  JSArray<JSBoolean> get toJS => map((e) => e.toJS).toList().toJS;
}

extension JSObjectExtension on JSObject {
  T? as<T extends JSObject>() {
    if (isUndefinedOrNull) return null;

    if (T == JSArray) {
      return isA<JSArray>() ? this as T : null;
    } else if (T == JSArrayBuffer) {
      return isA<JSArrayBuffer>() ? this as T : null;
    } else if (T == JSTypedArray) {
      return isA<JSTypedArray>() ? this as T : null;
    } else if (T == JSInt8Array) {
      return isA<JSInt8Array>() ? this as T : null;
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
    } else if (T == JSPromise) {
      return isA<JSPromise>() ? this as T : null;
    } else if (T == JSDataView) {
      return isA<JSDataView>() ? this as T : null;
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
}

extension JSArrayExtension on JSArray {
  int push(Object? any) => JSArrayUtil(this).push(any?.toJSDeep);

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
      return a.push(
        any?.toJSDeep,
        any2?.toJSDeep,
        any3.toJSDeep,
      );
    } else if (any2 != null) {
      return a.push(
        any?.toJSDeep,
        any2.toJSDeep,
      );
    } else {
      return a.push(
        any?.toJSDeep,
      );
    }
  }

  Iterable<dynamic> toIterable() => toDart.map((e) => e.dartify());

  List<dynamic> toList() => toIterable().toList();

  Iterable<T> whereType<T>() => toIterable().whereType<T>();

  List<String> toListOfString() =>
      toDart.map((e) => e.dartify()).whereType<String>().toList();

  List<int> toListOfInt() =>
      toDart.map((e) => e.dartify()).whereType<int>().toList();

  List<int> toListOfDouble() =>
      toDart.map((e) => e.dartify()).whereType<int>().toList();
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

  List<num> toListNum() => toDart.map((e) {
        var d = e.toDartDouble;
        var n = e.toDartInt;
        return d == n ? n : d;
      }).toList();
}

extension JSArrayOfJSBigIntExtension on JSArray<JSBigInt> {
  List<BigInt> toList() => toDart.map((e) {
        var o = e.dartify();
        if (o is BigInt) return o;
        return BigInt.parse(o.toString());
      }).toList();
}
