import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// The place categories the product supports, whether or not listings exist
/// for them yet.
///
/// This list is the single source of truth for category keys, bilingual
/// labels, and the no-photo icon/tint. Filter chips, search, cards, and detail
/// subtitles all read from it, so adding a category is one edit and a category
/// stays selectable before any listing uses it.
///
/// Keys must match the `category` values stored in `public.places`; see
/// `docs/SUPABASE_SETUP.md`. An unrecognised stored key is still shown verbatim
/// rather than hidden or relabelled, so an import mistake stays visible.
enum PlaceCategory {
  tambayan(
    key: 'tambayan',
    labelEn: 'Tambayan',
    labelTl: 'Tambayan',
    icon: Icons.menu_book_outlined,
    tint: AppColors.sage,
  ),
  coffee(
    key: 'coffee',
    labelEn: 'Coffee shop',
    labelTl: 'Kapihan',
    icon: Icons.local_cafe_outlined,
    tint: AppColors.coffeeTint,
  ),
  park(
    key: 'park',
    labelEn: 'Park / open space',
    labelTl: 'Parke / bukas na lugar',
    icon: Icons.park_outlined,
    tint: AppColors.parkTint,
  ),
  eatery(
    key: 'eatery',
    labelEn: 'Karinderya / affordable eatery',
    labelTl: 'Karinderya / abot-kayang kainan',
    icon: Icons.restaurant_outlined,
    tint: AppColors.eateryTint,
  ),
  other(
    key: 'other',
    labelEn: 'Other place',
    labelTl: 'Iba pang lugar',
    icon: Icons.place_outlined,
    tint: AppColors.otherTint,
  );

  const PlaceCategory({
    required this.key,
    required this.labelEn,
    required this.labelTl,
    required this.icon,
    required this.tint,
  });

  /// Stable value stored in `places.category` and used in filter keys.
  final String key;
  final String labelEn;
  final String labelTl;
  final IconData icon;
  final Color tint;

  String label(bool isTagalog) => isTagalog ? labelTl : labelEn;

  /// Looks up a stored key. Returns null when the value is not one of the
  /// categories the product supports.
  static PlaceCategory? fromKey(String key) {
    for (final category in values) {
      if (category.key == key) return category;
    }
    return null;
  }
}
