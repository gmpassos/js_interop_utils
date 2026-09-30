## 1.1.0

- sdk: ^3.13.0

- `ObjectExtension`:
  - `isJSAny`, `asJSAny`, `isJSObject`, `asJSObject`, `objectDartify`:
    - Reimplemented with `Object?.isA<T>()` (Dart 3.12+), removing the `is JSxxx` checks and
      `invalid_runtime_check_with_js_interop_types` ignores.
    - Fix: a non-JS Dart object (e.g. an instance of a Dart class) is no longer reported as a `JSAny` with `dart2js`.
    - `null` (ambiguous) is still returned for JS values that are also a Dart `List`/`Map`/`Function` (`dart2js`).
  - Added `isJSFunction` and `isJSExportedDartFunction`.
  - `toJSDeep`: Fix: `TypedData` (e.g. a `Uint8List` inside a `Map`) is converted to a JS typed array,
    not to a JS `Array`.

- Fix: `Int8List`, `Uint8ClampedList`, `Int16List`, `Uint16List`, `Int32List`, `Uint32List`, `Float32List` and
  `Float64List` `.toJS` returned a JS `Array`: the package `Iterable<int>`/`Iterable<double>` `toJS` extensions
  shadowed the `dart:js_interop` ones. Added `Int8ListExtension`, `Uint8ClampedListExtension`,
  `Int16ListExtension`, `Uint16ListExtension`, `Int32ListExtension`, `Uint32ListExtension`,
  `Float32ListExtension` and `Float64ListExtension` (as `Uint8ListExtension` already did for `Uint8List`).

- `IterableExtension`:
  - Added `toJSIterableDeep`: lazy `JSIterable` counterpart of `toJSDeep` (uses `Iterable.toJSIterable`, Dart 3.12+).

- Added `JSIterableExtension` with `toIterable` and `toList`.
  - Works around `JSIterable.toDartIterable` failing for a JS string (`Reflect.get called on non-object`).

- `JSObjectExtension`:
  - Added `prototype` (`JSObject.getPrototypeOf`, Dart 3.13+) and `isPlainObject`.
  - `as<T>()`:
    - Fix: with `dart2wasm` all interop types are erased to one runtime type, so dispatching on `T` returned
      `null` for valid casts (e.g. `JSObject().as<JSObject>()`). It now only casts when `T` can't be inspected.
    - Fix: `as<JSObject>()` returned `null` with `dart2js`.
    - Added `JSFunction` check; removed duplicated `JSInt8Array` branch and unreachable `JSPromise` branch.

- `JSArrayExtension`:
  - `push`: uses `JSArray.add`.
  - Fix: `toListOfDouble` now returns `List<double>` (was a `List<int>` of only the integer elements).
  - Fix: `toListOfInt` returned an empty list with `dart2wasm` (JS numbers are dartified as `double`).
    It now returns the integer-valued numbers on all platforms.

- `JSArrayOfJSNumberExtension`:
  - Fix: `toListNum` threw for non-integer numbers (e.g. `2.5`) with `dart2js`.

- Tests:
  - Added integration tests (`test/js_integration_test.dart`) exchanging values with real JS code
    (JSON, iteration protocols, `Set`/`Map`/generators, callbacks, `BigInt`, `Date`, typed arrays, prototypes).
  - Added unit tests for the whole public API (`test/js_interop_utils_api_test.dart`).

- `JSObjectUtil`: added `prototype` (`Object.prototype`).

- lints: ^6.1.0
- test: ^1.32.0
- dependency_validator: ^5.1.0

## 1.0.11

- `lib/src/js_interop_utils_extensions.dart`:
  - Added nullable iterable extensions for JS interop conversions:
    - `IterableStringNullableExtension` with `toJS` returning `JSArray<JSString?>`.
    - `IterableNumNullableExtension` with `toJS` returning `JSArray<JSNumber?>`.
    - `IterableIntNullableExtension` with `toJS` returning `JSArray<JSNumber?>`.
    - `IterableDoubleNullableExtension` with `toJS` returning `JSArray<JSNumber?>`.
    - `IterableBoolNullableExtension` with `toJS` returning `JSArray<JSBoolean?>`.

## 1.0.10

- `IterableExtension`, `IterableOfIterableExtension`, `IterableStringExtension`, `IterableNumExtension`,
  `IterableIntExtension`, `IterableDoubleExtension`, `IterableBoolExtension`:
  - `toJSDeep`: removed intermediate `.toList()` call before `.toJS`.

## 1.0.9

- `ObjectExtension`:
  - `toJSDeep`:
    - Optimize for `Function`: call `self.jsify()`.

- test: ^1.26.3

## 1.0.8

- Added `Uint8ListExtension` with `toJS` method for `JSUint8Array` conversion.
- Updated `isJSAny` check to support `JSTypedArray`.
 
- test: ^1.26.2

## 1.0.7

- `JSArrayExtension`:
  - `toIterable`, `toList`: avoid return of `<dynamic>` and avoid issues with `dynamic` values.

- dependency_validator: ^4.1.3

## 1.0.6

- New `JSDate`:
  - `DateTimeToJSDateExtension`: `toJSDate`.

## 1.0.5

- Improve `isJSAny` implementation for `bool`, `num` and `String`.
- Improve `isJSAny` and `asJSAny` tests.

- test: ^1.25.15

## 1.0.4

- Improve `isJSAny` and `isJSObject`.

## 1.0.3

- New `StringExtension`:
  - Added `toDartFix`.

## 1.0.2

- `JSObjectUtil`: fix `jsKeys` mapping name.

- `ObjectExtension`: added `asJSAny`.

## 1.0.1

- Added extension `Object.isJSAny` and `Object.objectDartify()`;

- CI: test with `dart2js` and `dart2wasm` (on Chrome).

## 1.0.0

- Initial version.
