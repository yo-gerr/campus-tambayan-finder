import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import 'place.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    required this.place,
    required this.copy,
    required this.onTap,
    super.key,
  });

  final Place place;
  final AppCopy copy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('place-card-${place.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _PlaceIllustration(category: place.category),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.get('demo_badge'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.terracotta,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${copy.category(place.category)} · ${place.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedInk,
                          ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _TinyLabel(
                          icon: Icons.payments_outlined,
                          text: '₱${place.priceMin}–₱${place.priceMax}',
                        ),
                        ...place.amenities.take(2).map(
                              (amenity) => _TinyLabel(
                                icon: _amenityIcon(amenity),
                                text: copy.get(amenity),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.mutedInk),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceIllustration extends StatelessWidget {
  const _PlaceIllustration({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      'coffee' => (Icons.local_cafe_outlined, const Color(0xFFF2E5D6)),
      'park' => (Icons.park_outlined, const Color(0xFFE1EDDF)),
      'eatery' => (Icons.restaurant_outlined, const Color(0xFFF4E4DB)),
      _ => (Icons.menu_book_outlined, AppColors.sage),
    };

    return Container(
      width: 68,
      height: 74,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, size: 31, color: AppColors.primary),
    );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.mutedInk),
        const SizedBox(width: 3),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

IconData _amenityIcon(String amenity) => switch (amenity) {
      'wifi' => Icons.wifi,
      'aircon' => Icons.ac_unit,
      'outlets' => Icons.power,
      _ => Icons.check_circle_outline,
    };
