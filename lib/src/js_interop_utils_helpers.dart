import 'dart:js_interop';

import 'js_interop_utils_extensions.dart';

@JS('Object')
extension type JSObjectUtil._(JSObject _jsObject) implements JSAny {
  @JS('Object.keys')
  external static JSArray jsKeys(JSObject object);

  static Iterable<String> keys(JSObject object) =>
      jsKeys(object).whereType<String>();
}

@JS('Array')
extension type JSArrayUtil<T extends JSAny?>._(JSArray _jsArray)
    implements JSObject {
  JSArrayUtil(this._jsArray);

  external int push(
    JSAny? any, [
    JSAny? any2,
    JSAny? any3,
    JSAny? any4,
    JSAny? any5,
    JSAny? any6,
    JSAny? any7,
    JSAny? any8,
    JSAny? any9,
  ]);
}

R? tryCall<R>(R Function() call) {
  try {
    return call();
  } catch (_) {
    return null;
  }
}
