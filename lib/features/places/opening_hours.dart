/// Structured opening hours for a listing.
///
/// The shared table stores these as `hoursByDay`: a JSON object keyed by
/// three-letter weekday. Three states are distinct on purpose:
///
/// - a day key is **absent** -> we do not know that day's hours;
/// - a day key maps to **null** -> the place is closed that day;
/// - a day key maps to `{"open": "HH:MM", "close": "HH:MM"}` -> that window.
///
/// Keeping "unknown" separate from "closed" matters: the map and cards must be
/// able to stay silent instead of telling a student a place is shut when the
/// team simply has not supplied the day yet.
library;

/// Philippines has no daylight saving time, so a fixed offset is exact.
const manilaUtcOffset = Duration(hours: 8);

/// Wall-clock time in Manila for any given instant.
///
/// The device timezone is deliberately ignored: an "open now" badge has to
/// describe the shop, not the viewer's travel plans.
DateTime manilaTimeOf(DateTime instant) => instant.toUtc().add(manilaUtcOffset);

/// One day's opening window, held as minutes from midnight so comparisons stay
/// integer-exact.
class DayHours {
  const DayHours({required this.openMinutes, required this.closeMinutes});

  final int openMinutes;
  final int closeMinutes;

  /// A window that ends at or before it starts crosses midnight, e.g.
  /// 20:00-02:00. Without this, late-night tambayans would read as closed.
  bool get crossesMidnight => closeMinutes <= openMinutes;

  /// Opening time is inclusive, closing time exclusive, so the badge flips at
  /// the stated closing minute instead of a minute later.
  bool containsMinute(int minute) {
    if (crossesMidnight) {
      return minute >= openMinutes || minute < closeMinutes;
    }
    return minute >= openMinutes && minute < closeMinutes;
  }

  /// Returns null for anything that is not a usable window.
  static DayHours? tryParse(Object? value) {
    if (value is! Map) return null;
    final open = _minutes(value['open']);
    final close = _minutes(value['close']);
    if (open == null || close == null) return null;
    // Equal bounds are ambiguous: noon-to-noon could mean 24 hours or a typo.
    // Treat the day as unknown rather than silently claiming it never closes.
    // Recorded as a client follow-up in the project brief.
    if (open == close) return null;
    return DayHours(openMinutes: open, closeMinutes: close);
  }
}

class OpeningHours {
  const OpeningHours(this._byWeekday);

  /// Values are null for a day the team marked as closed.
  final Map<int, DayHours?> _byWeekday;

  /// Weekday keys in display order, matching [DateTime.monday] onwards.
  static const weekdayKeys = <String, int>{
    'mon': DateTime.monday,
    'tue': DateTime.tuesday,
    'wed': DateTime.wednesday,
    'thu': DateTime.thursday,
    'fri': DateTime.friday,
    'sat': DateTime.saturday,
    'sun': DateTime.sunday,
  };

  bool get hasData => _byWeekday.isNotEmpty;

  /// Null when the column is absent, not an object, or holds no usable day.
  static OpeningHours? tryParse(Object? value) {
    if (value is! Map) return null;
    final byWeekday = <int, DayHours?>{};
    for (final entry in weekdayKeys.entries) {
      if (!value.containsKey(entry.key)) continue; // unknown, not closed
      final raw = value[entry.key];
      if (raw == null) {
        byWeekday[entry.value] = null; // explicitly closed
        continue;
      }
      final hours = DayHours.tryParse(raw);
      // A malformed entry is dropped, which reads as unknown for that day.
      // Better a silent day than a confidently wrong badge.
      if (hours != null) byWeekday[entry.value] = hours;
    }
    return byWeekday.isEmpty ? null : OpeningHours(byWeekday);
  }

  bool isKnownOn(int weekday) => _byWeekday.containsKey(weekday);

  bool isClosedOn(int weekday) =>
      _byWeekday.containsKey(weekday) && _byWeekday[weekday] == null;

  DayHours? hoursFor(int weekday) => _byWeekday[weekday];

  Map<String, Object?> toJson() {
    final result = <String, Object?>{};
    for (final entry in weekdayKeys.entries) {
      if (!_byWeekday.containsKey(entry.value)) continue;
      final hours = _byWeekday[entry.value];
      result[entry.key] = hours == null
          ? null
          : {
              'open': _time(hours.openMinutes),
              'close': _time(hours.closeMinutes),
            };
    }
    return result;
  }

  /// Whether the place is open at [instant], evaluated in Manila time.
  ///
  /// Null means the day's hours are unknown, so callers must show nothing
  /// rather than guessing "closed".
  bool? isOpenAt(DateTime instant) {
    final manila = manilaTimeOf(instant);
    final minute = manila.hour * 60 + manila.minute;
    final weekday = manila.weekday;

    // A window that started yesterday can still be running past midnight.
    final previousWeekday = weekday == DateTime.monday
        ? DateTime.sunday
        : weekday - 1;
    final previous = _byWeekday[previousWeekday];
    if (previous != null &&
        previous.crossesMidnight &&
        minute < previous.closeMinutes) {
      return true;
    }

    if (!_byWeekday.containsKey(weekday)) return null;
    final today = _byWeekday[weekday];
    if (today == null) return false;
    return today.containsMinute(minute);
  }
}

/// Parses "HH:MM" or "H:MM" into minutes from midnight.
///
/// Deliberately strict: hours past 23 or minutes past 59 are rejected so a
/// dashboard typo cannot silently become a 25:00 opening time.
int? _minutes(Object? value) {
  if (value is! String) return null;
  final parts = value.trim().split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return hour * 60 + minute;
}

String _time(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}
