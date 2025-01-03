# js_interop_utils

[![pub package](https://img.shields.io/pub/v/js_interop_utils.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/js_interop_utils)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/js_interop_utils)](https://app.codecov.io/gh/gmpassos/js_interop_utils)
[![Dart CI](https://github.com/gmpassos/js_interop_utils/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/gmpassos/js_interop_utils/actions/workflows/dart.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/js_interop_utils?logo=git&logoColor=white)](https://github.com/gmpassos/js_interop_utils/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/js_interop_utils/latest?logo=git&logoColor=white)](https://github.com/gmpassos/js_interop_utils/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/js_interop_utils?logo=git&logoColor=white)](https://github.com/gmpassos/js_interop_utils/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/js_interop_utils?logo=github&logoColor=white)](https://github.com/gmpassos/js_interop_utils/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/js_interop_utils?logo=github&logoColor=white)](https://github.com/gmpassos/js_interop_utils)
[![License](https://img.shields.io/github/license/gmpassos/js_interop_utils?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/js_interop_utils/blob/master/LICENSE)

This library leverages `dart:js_interop` to provide utilities for seamless interaction between Dart and JavaScript
objects, enabling deep and flexible transformations.
It includes extensions for `Object`, `Map`, `Iterable`, `JSObject`, `JSArray`, and more.

## Features

- **Object Extensions**: Convert Dart objects to JavaScript objects using `.toJSDeep`.
- **Map Extensions**: Convert Dart `Map` objects to JavaScript objects, supporting deep transformations.
- **Iterable Extensions**: Handle Dart lists and collections, converting them to JavaScript arrays, including typed
  arrays.
- **JSObject Utilities**: Access JavaScript object keys, properties, and convert them back to Dart maps.
- **JSArray Utilities**: Work with JavaScript arrays, including pushing elements and converting them to Dart lists.

## Usage

### Converting Dart Objects to JavaScript

```dart
// import 'dart:js_interop'; // Already exported by `js_interop_utils`
import 'package:js_interop_utils/js_interop_utils.dart';

void main() {
  var map = {'key': 'value', 'number': 42};
  var jsObject = map.toJSDeep; // Convert to `JSObject`
}
```

### Working with JavaScript Objects

```dart
import 'package:js_interop_utils/js_interop_utils.dart';

void main() {
  var jsObject = JSObject();
  jsObject.put('a', 1);
  jsObject.put('b', 2);

  print(jsObject.get('a')); // Access property `a`
}
```

### Handling Collections

```dart
import 'package:js_interop_utils/js_interop_utils.dart';

void main() {
  var list = [1, 2, 3];
  var jsArray = list.toJSDeep; // Convert to `JSArray`
}
```

### Accessing JavaScript Array Utilities

```dart
import 'package:js_interop_utils/js_interop_utils.dart';

void main() {
  var jsArray = JSArray();
  jsArray.push('a');
  jsArray.pushVarArgs('b', 3);

  var list = jsArray.toList(); // Convert to Dart `List`
  print(list); // ['a','b',3]
}
```

## Extensions Overview

### Object Extensions

- `toJSDeep`: Converts any Dart object to a deeply nested JavaScript object.

### Map Extensions

- `toJSDeep`: Converts a Dart `Map` to a deeply nested JavaScript object.

### Iterable Extensions

- `toJS`: same as `toJS` for `List`.
- `toJSDeep`: Converts a Dart `Iterable` to a deeply nested JavaScript array.

### JSObject Extensions

- `keys`: Returns all keys of a JavaScript object.
- `get`: Access a property by key.
- `toMap`: Converts a JavaScript object to a Dart map.

### JSArray Extensions

- `push`: Appends an element to a JavaScript array.
- `toList`: Converts a JavaScript array to a Dart list.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/js_interop_utils/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## Sponsor

Don't be shy, show some love, and become our [GitHub Sponsor][github_sponsors].
Your support means the world to us, and it keeps the code caffeinated! ☕✨

Thanks a million! 🚀😄

[github_sponsors]: https://github.com/sponsors/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt
