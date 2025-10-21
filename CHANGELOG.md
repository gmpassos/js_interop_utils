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
