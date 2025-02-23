@TestOn('browser')
library;

import 'package:js_interop_utils/js_interop_utils.dart';
import 'package:test/test.dart';

void main() {
  group('JSDate', () {
    test('basic', () {
      var now = DateTime.now();
      var date = JSDate();

      var dateTime = date.getTime();
      expect(dateTime, greaterThanOrEqualTo(now.millisecondsSinceEpoch));
      expect((dateTime - now.millisecondsSinceEpoch), inInclusiveRange(0, 500));
    });

    test('JSDate.fromMillisecondsSinceEpoch()', () {
      var now = DateTime.now();
      var date = JSDate.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch);

      expect(date.getTime(), equals(now.millisecondsSinceEpoch));

      expect(date.toDateTime(), equals(now));
      expect(date.toDateTime(isUtc: true), equals(now.toUtc()));
    });

    test('JSDate.now()', () {
      var now = DateTime.now();
      var dateTime = JSDate.now();

      expect(dateTime, greaterThanOrEqualTo(now.millisecondsSinceEpoch));
      expect((dateTime - now.millisecondsSinceEpoch), inInclusiveRange(0, 500));
    });

    test('JSDate.UTC()', () {
      var now = DateTime.now().toUtc();
      var dateTimeUTC = JSDate.UTC(now.year, now.month - 1, now.day, now.hour,
          now.minute, now.second, now.millisecond);

      expect(dateTimeUTC, equals(now.millisecondsSinceEpoch));
    });
  });
}
