import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/features/places/place_categories.dart';

void main() {
  test('covers every agreed category with a stable key and both languages', () {
    expect(
      PlaceCategory.values.map((category) => category.key).toList(),
      ['tambayan', 'coffee', 'park', 'eatery', 'other'],
    );

    final keys = PlaceCategory.values.map((category) => category.key).toSet();
    expect(keys.length, PlaceCategory.values.length);

    for (final category in PlaceCategory.values) {
      expect(category.labelEn.trim(), isNotEmpty);
      expect(category.labelTl.trim(), isNotEmpty);
      expect(category.icon, isNotNull);
      expect(category.tint, isNotNull);
    }
  });

  test('resolves supported keys and rejects unrecognised ones', () {
    expect(PlaceCategory.fromKey('coffee'), PlaceCategory.coffee);
    expect(PlaceCategory.fromKey('other'), PlaceCategory.other);
    expect(PlaceCategory.fromKey('Karinderya'), isNull);
  });

  test('copy labels every agreed category in both languages', () {
    const english = AppCopy(AppLanguage.english);
    const tagalog = AppCopy(AppLanguage.tagalog);

    expect(english.category('eatery'), 'Karinderya / affordable eatery');
    expect(tagalog.category('eatery'), 'Karinderya / abot-kayang kainan');
    expect(english.category('other'), 'Other place');
    expect(tagalog.category('other'), 'Iba pang lugar');

    // An unrecognised stored key stays visible instead of turning into a blank
    // or silently borrowing another category's label.
    expect(english.category('karinderya'), 'karinderya');
  });
}
