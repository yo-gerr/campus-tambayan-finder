import 'place_filters.dart';

class Place implements PlaceLike {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.descriptionEn,
    required this.descriptionTl,
    required this.priceMin,
    required this.priceMax,
    required this.hours,
    required this.amenities,
    required this.setting,
    required this.activities,
    required this.mapX,
    required this.mapY,
    this.photoUrl,
    this.photoAsset,
    this.photos = const [],
  });

  final String id;
  final String name;
  @override
  final String category;
  final String area;
  final String descriptionEn;
  final String descriptionTl;
  @override
  final int priceMin;
  final int priceMax;
  final String hours;
  @override
  final List<String> amenities;
  @override
  final String setting;
  @override
  final List<String> activities;
  final double mapX;
  final double mapY;

  /// Public URL of the place photo, when the team has uploaded one.
  ///
  /// The app tries this first so a photo can change without rebuilding. It is
  /// optional: rows and builds without photos keep working.
  final String? photoUrl;

  /// Bundled photo used when [photoUrl] is absent or cannot be loaded.
  ///
  /// This is what keeps photos visible offline. Optional until the team
  /// supplies approved images.
  final String? photoAsset;

  /// Ordered gallery entries loaded from the shared `place_photos` table.
  ///
  /// Existing bundled rows can omit this safely. [coverPhoto] then preserves
  /// the original single-photo fields as the card image.
  final List<PlaceGalleryPhoto> photos;

  PlaceGalleryPhoto? get coverPhoto {
    for (final photo in photos) {
      if (photo.isCover) return photo;
    }
    if (photos.isNotEmpty) return photos.first;
    if (photoUrl == null && photoAsset == null) return null;
    return PlaceGalleryPhoto(
      photoUrl: photoUrl,
      photoAsset: photoAsset,
      sortOrder: 0,
      isCover: true,
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      area: json['area'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionTl: json['descriptionTl'] as String,
      priceMin: json['priceMin'] as int,
      priceMax: json['priceMax'] as int,
      hours: json['hours'] as String,
      amenities: List<String>.from(json['amenities'] as List<dynamic>),
      setting: json['setting'] as String,
      activities: List<String>.from(json['activities'] as List<dynamic>),
      mapX: (json['mapX'] as num).toDouble(),
      mapY: (json['mapY'] as num).toDouble(),
      photoUrl: _optionalText(json['photoUrl']),
      photoAsset: _optionalText(json['photoAsset']),
      photos: _photos(json['place_photos'] ?? json['photos']),
    );
  }
}

class PlaceGalleryPhoto {
  const PlaceGalleryPhoto({
    required this.photoUrl,
    required this.photoAsset,
    required this.sortOrder,
    required this.isCover,
    this.captionEn,
    this.captionTl,
  });

  final String? photoUrl;
  final String? photoAsset;
  final int sortOrder;
  final bool isCover;
  final String? captionEn;
  final String? captionTl;

  factory PlaceGalleryPhoto.fromJson(Map<String, dynamic> json) {
    return PlaceGalleryPhoto(
      photoUrl: _optionalText(json['photoUrl']),
      photoAsset: _optionalText(json['photoAsset']),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isCover: json['isCover'] == true,
      captionEn: _optionalText(json['captionEn']),
      captionTl: _optionalText(json['captionTl']),
    );
  }
}

List<PlaceGalleryPhoto> _photos(Object? value) {
  if (value is! List) return const [];
  final photos =
      value
          .whereType<Map<String, dynamic>>()
          .map(PlaceGalleryPhoto.fromJson)
          .where((photo) => photo.photoUrl != null || photo.photoAsset != null)
          .toList()
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
  return List.unmodifiable(photos);
}

/// Treats a missing, null, blank, or non-string value as "no photo" so a
/// partially filled row never reaches the image widgets.
String? _optionalText(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
