import 'package:js_interop_utils/js_interop_utils.dart';

void main() {
  var jsArrayOfStrings = ['a', 'b'].toJS; // JSArray<JSString>
  print('JSArray<JSString>: $jsArrayOfStrings');

  var jsArrayOfNumbers = [1, 2].toJS; // JSArray<JSNumber>
  print('JSArray<JSNumber>: $jsArrayOfNumbers');

  var jsArrayOfPairs = [
    ['a', 1],
    ['b', 2]
  ].toJSDeep; // JSArray<JSArray<JSAny?>>
  print('JSArray<JSArray<JSAny?>>: $jsArrayOfPairs');

  var jsObject = {
    'a': 1,
    'b': 2,
  }.toJSDeep;
  print('JSObject: $jsObject');

  var jsObject2 = {
    'a': [1, 10],
    'b': [2, 20],
  }.toJSDeep;

  print('JSObject (deep): $jsObject2');
}
