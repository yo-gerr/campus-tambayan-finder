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
    );
  }
}
