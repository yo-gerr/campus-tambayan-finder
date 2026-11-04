import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/opening_hours.dart';

/// 2026-11-02 is a Monday. Manila is UTC+8, so Manila 08:00 is UTC 00:00.
DateTime _utc(int day, int hour, [int minute = 0]) =>
    DateTime.utc(2026, 11, day, hour, minute);

OpeningHours _parse(Map<String, Object?> raw) =>
    // Null is a test failure, surfaced by the assertions in each case.
    OpeningHours.tryParse(raw)!;

void main() {
  group('parsing', () {
    test('distinguishes unknown days from closed days', () {
      final hours = _parse({
        'mon': {'open': '08:00', 'close': '20:00'},
        'sun': null,
      });

      expect(hours.isKnownOn(DateTime.monday), isTrue);
      expect(hours.isClosedOn(DateTime.monday), isFalse);
      expect(hours.isClosedOn(DateTime.sunday), isTrue);
      // No key at all means we do not know, which must not read as closed.
      expect(hours.isKnownOn(DateTime.tuesday), isFalse);
      expect(hours.isClosedOn(DateTime.tuesday), isFalse);
    });

    test('rejects unusable shapes instead of guessing', () {
      expect(OpeningHours.tryParse(null), isNull);
      expect(OpeningHours.tryParse('daily'), isNull);
      expect(OpeningHours.tryParse(<String, Object?>{}), isNull);
      expect(
        OpeningHours.tryParse({
          'mon': {'open': '08:00'},
        }),
        isNull,
      );
      expect(
        OpeningHours.tryParse({
          'mon': {'open': '8am', 'close': '5pm'},
        }),
        isNull,
      );
      expect(
        OpeningHours.tryParse({
          'mon': {'open': '08:00', 'close': '24:00'},
        }),
        isNull,
      );
    });

    test('treats identical bounds as unknown rather than open all day', () {
      // Ambiguous: noon-to-noon could be 24 hours or a typo. Recorded as a
      // client follow-up, so the app stays silent instead of claiming 24h.
      final hours = OpeningHours.tryParse({
        'mon': {'open': '00:00', 'close': '00:00'},
        'tue': {'open': '09:00', 'close': '17:00'},
      });

      expect(hours, isNotNull);
      expect(hours!.isKnownOn(DateTime.monday), isFalse);
      expect(hours.isKnownOn(DateTime.tuesday), isTrue);
    });
  });

  group('open state', () {
    final hours = _parse({
      'mon': {'open': '08:00', 'close': '20:00'},
    });

    test('opening time is inclusive and closing time is exclusive', () {
      // Manila Monday 08:00.
      expect(hours.isOpenAt(_utc(2, 0)), isTrue);
      // Manila Monday 19:59.
      expect(hours.isOpenAt(_utc(2, 11, 59)), isTrue);
      // Manila Monday 20:00 exactly.
      expect(hours.isOpenAt(_utc(2, 12)), isFalse);
      // Manila Monday 07:59.
      expect(hours.isOpenAt(_utc(2, 0).subtract(const Duration(minutes: 1))),
          isFalse);
    });

    test('returns null on a day with no data', () {
      // Manila Tuesday 10:00.
      expect(hours.isOpenAt(_utc(3, 2)), isNull);
    });

    test('returns false on a day marked closed', () {
      final closed = _parse({'tue': null});
      expect(closed.isOpenAt(_utc(3, 2)), isFalse);
    });

    test('evaluates Manila time, not the device timezone', () {
      // UTC Monday 17:00 is Manila Tuesday 01:00, where no data exists.
      expect(hours.isOpenAt(_utc(2, 17)), isNull);
      // UTC Sunday 23:00 is Manila Monday 07:00, before opening.
      expect(hours.isOpenAt(DateTime.utc(2026, 11, 1, 23)), isFalse);
    });
  });

  group('overnight windows', () {
    // Friday 20:00 through Saturday 02:00, with Saturday opening later.
    final hours = _parse({
      'fri': {'open': '20:00', 'close': '02:00'},
      'sat': {'open': '10:00', 'close': '18:00'},
    });

    test('stays open past midnight into the next day', () {
      // Manila Saturday 01:00 is UTC Friday 17:00.
      expect(hours.isOpenAt(_utc(6, 17)), isTrue);
      // Manila Saturday 02:00 exactly is closed.
      expect(hours.isOpenAt(_utc(6, 18)), isFalse);
    });

    test('opens in the evening on the listed day', () {
      // Manila Friday 21:00 is UTC Friday 13:00.
      expect(hours.isOpenAt(_utc(6, 13)), isTrue);
    });
  });
}
