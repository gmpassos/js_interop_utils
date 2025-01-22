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

    // Ambiguous types:

    if (self is String) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSString) {
        return null;
      } else {
        return false;
      }
    }

    if (self is num) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSNumber) {
        return null;
      } else {
        return false;
      }
    }

    if (self is bool) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSBoolean) {
        return null;
      } else {
        return false;
      }
    }

    if (self is Function) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSFunction) {
        return null;
      } else {
        return false;
      }
    }

    if (self is List) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSArray) {
        return null;
      } else {
        return false;
      }
    }

    if (self is Map) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSArray || self is JSObject) {
        return null;
      } else {
        return false;
      }
    }

    // ignore: invalid_runtime_check_with_js_interop_types
    return self is JSAny;
  }

  /// Casts an [Object] to a [JSAny], in a graceful manner.
  /// See [isJSAny].
  JSAny? get asJSAny {
    final self = this;
    if (self == null) return null;

    var isJSAny = self.isJSAny;
    if (isJSAny != null) {
      if (isJSAny) {
        return self as JSAny;
      } else {
        return null;
      }
    } else {
      try {
        return self as JSAny;
      } catch (_) {
        return null;
      }
    }
  }

  /// Returns `true` if this instance is a [JSObject].
  /// Returns `null` if it's an ambiguous Dart/JS type.
  bool? get isJSObject {
    final self = this;
    if (self == null) return false;

    if (self is String) {
      return false;
    }
    // ignore: invalid_runtime_check_with_js_interop_types
    else if (self is JSString) {
      if (self.isA<JSString>()) return false;
    }

    if (self is num) {
      return false;
    }
    // ignore: invalid_runtime_check_with_js_interop_types
    else if (self is JSNumber) {
      if (self.isA<JSNumber>()) return false;
    }

    if (self is bool) {
      return false;
    }
    // ignore: invalid_runtime_check_with_js_interop_types
    else if (self is JSBoolean) {
      if (self.isA<JSBoolean>()) return false;
    }

    if (self is List) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSArray) {
        // ignore: invalid_runtime_check_with_js_interop_types
        if ((self as JSAny).isA<JSArray>()) {
          return null;
        }
      }
      // ignore: invalid_runtime_check_with_js_interop_types
      else if (self is JSObject) {
        // ignore: invalid_runtime_check_with_js_interop_types
        if ((self as JSAny).isA<JSObject>()) {
          return true;
        }
      } else {
        return false;
      }
    }

    if (self is Map) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSArray) {
        // ignore: invalid_runtime_check_with_js_interop_types
        if ((self as JSAny).isA<JSArray>()) {
          return true;
        }
      }
      // ignore: invalid_runtime_check_with_js_interop_types
      else if (self is JSObject) {
        // ignore: invalid_runtime_check_with_js_interop_types
        if ((self as JSAny).isA<JSObject>()) {
          return true;
        }
      } else {
        return false;
      }
    }

    if (self is Function) {
      // ignore: invalid_runtime_check_with_js_interop_types
      if (self is JSFunction) {
        return true;
      } else {
        return false;
      }
    }
    // ignore: invalid_runtime_check_with_js_interop_types
    else if (self is JSFunction) {
      return true;
    }

    // ignore: invalid_runtime_check_with_js_interop_types
    if (self is JSArray) {
      return true;
    }

    // ignore: invalid_runtime_check_with_js_interop_types
    return self is JSObject;
  }

  /// Casts an [Object] to a [JSObject], in a graceful manner.
  /// See [isJSObject].
  JSObject? get asJSObject {
    final self = this;
    if (self == null) return null;

    var isJSObject = self.isJSObject;
    if (isJSObject != null) {
      if (isJSObject) {
        try {
          return self as JSObject;
        } catch (_) {
          return null;
        }
      } else {
        return null;
      }
    } else {
      try {
        return self as JSObject;
      } catch (_) {
        return null;
      }
    }
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
  JSArray<JSAny?> get toJSDeep => map((e) => e.toJSDeep).toList().toJS;

  Iterable<JSAny> whereJSAny() => map((e) => e.asJSAny).nonNulls;
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
