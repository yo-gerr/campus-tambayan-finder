import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import 'open_status_badge.dart';
import 'place.dart';
import 'place_photo.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    required this.place,
    required this.copy,
    required this.onTap,
    this.now,
    super.key,
  });

  final Place place;
  final AppCopy copy;
  final VoidCallback onTap;

  /// Injectable clock so callers can keep every card in a list consistent.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final status = place.openingHours?.isOpenAt(now ?? DateTime.now());
    return Container(
      key: Key('place-card-${place.id}'),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceUnder,
            offset: Offset(0, kCardUnderOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                PlacePhoto(
                  place: place,
                  width: 68,
                  height: 76,
                  borderRadius: 16,
                  loadingLabel: copy.get('loading_photo'),
                  placeholder: PlacePhotoPlaceholder(
                    category: place.category,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (place.openingHours != null) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (status != null)
                              OpenStatusBadge(open: status, copy: copy),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${copy.category(place.category)} · ${place.area}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _TinyLabel(
                            icon: Icons.payments_outlined,
                            text: copy.priceRange(
                              place.priceMin,
                              place.priceMax,
                            ),
                          ),
                          ...place.amenities
                              .take(2)
                              .map(
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
      ),
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
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
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
