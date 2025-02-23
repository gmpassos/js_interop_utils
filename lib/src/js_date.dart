import 'dart:js_interop';

@JS('Date')
extension type JSDate._(JSObject _) implements JSObject {
  external JSDate();

  external JSDate.fromMillisecondsSinceEpoch(int milliseconds);

  external static int now();

  // ignore: non_constant_identifier_names
  external static int UTC(int year,
      [int monthIndex,
      int day,
      int hours,
      int minutes,
      int seconds,
      int milliseconds]);

  external int getTime();

  DateTime toDateTime({bool isUtc = false}) =>
      DateTime.fromMillisecondsSinceEpoch(getTime(), isUtc: isUtc);
}

extension DateTimeToJSDateExtension on DateTime {
  JSDate toJSDate() =>
      JSDate.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
}
