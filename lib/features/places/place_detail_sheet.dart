import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import '../../app/app_widgets.dart';
import 'demo_badge.dart';
import 'google_maps_directions.dart';
import 'open_status_badge.dart';
import 'opening_hours.dart';
import 'place.dart';
import 'place_photo.dart';

typedef DirectionsUrlLauncher = Future<bool> Function(Uri url);

Future<void> showPlaceDetails({
  required BuildContext context,
  required Place place,
  required AppCopy copy,
  DirectionsUrlLauncher? launchDirections,
  DateTime? now,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    builder: (context) => _PlaceDetailSheet(
      place: place,
      copy: copy,
      launchDirections: launchDirections ?? _launchExternalUrl,
      now: now,
    ),
  );
}

class _PlaceDetailSheet extends StatelessWidget {
  const _PlaceDetailSheet({
    required this.place,
    required this.copy,
    required this.launchDirections,
    this.now,
  });

  final Place place;
  final AppCopy copy;
  final DirectionsUrlLauncher launchDirections;
  final DateTime? now;

  Future<void> _openDirections(BuildContext context) async {
    if (!place.locationVerified) {
      await _showDirectionsUnavailable(
        context,
        copy.get('directions_location_unverified'),
      );
      return;
    }

    final uri = googleMapsDirectionsUri(place);
    if (uri == null) {
      await _showDirectionsUnavailable(
        context,
        copy.get('directions_coordinates_missing'),
      );
      return;
    }

    var launched = false;
    try {
      launched = await launchDirections(uri);
    } on PlatformException {
      launched = false;
    } on MissingPluginException {
      launched = false;
    }
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.get('directions_could_not_open'))),
      );
    }
  }

  Future<void> _showDirectionsUnavailable(
    BuildContext context,
    String message,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.route_outlined),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.get('got_it')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = copy.isTagalog
        ? place.descriptionTl
        : place.descriptionEn;
    final address = place.address;
    final openingHours = place.openingHours;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: ListView(
        key: const Key('place-detail-list'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Center(child: SheetHandle()),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: place.isDemo
                    ? DemoBadge(label: copy.get('demo_badge'))
                    : const SizedBox.shrink(),
              ),
              IconButton(
                tooltip: copy.get('close'),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            place.name,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            '${copy.category(place.category)} · ${place.area}',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.mutedInk),
          ),
          const SizedBox(height: 14),
          PlacePhotoGallery(
            place: place,
            width: double.infinity,
            height: 210,
            borderRadius: 18,
            loadingLabel: copy.get('loading_photo'),
            placeholder: PlacePhotoPlaceholder(
              category: place.category,
              label: copy.get('no_photo'),
              iconSize: 40,
            ),
            photoPosition: copy.photoPosition,
            viewPhotoLabel: copy.get('view_photo'),
            closeLabel: copy.get('close'),
            photoCaption: (photo) => copy.isTagalog
                ? photo.captionTl ?? photo.captionEn
                : photo.captionEn ?? photo.captionTl,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place.isDemo
                        ? '${copy.get('sample_data')} $description'
                        : description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.payments_outlined,
            title: copy.get('price'),
            value: copy.priceRange(place.priceMin, place.priceMax),
          ),
          if (openingHours != null)
            _WeeklyHours(
              hours: openingHours,
              copy: copy,
              now: now ?? DateTime.now(),
              note: place.hours,
            )
          else
            _DetailRow(
              icon: Icons.schedule_outlined,
              title: copy.get('hours'),
              value: place.hours ?? copy.get('hours_not_listed'),
            ),
          _DetailRow(
            icon: Icons.place_outlined,
            title: copy.get('setting'),
            value: copy.get(place.setting),
          ),
          if (address != null)
            _DetailRow(
              icon: Icons.location_on_outlined,
              title: copy.get('address'),
              value: address,
            ),
          if (!place.locationVerified)
            _DetailRow(
              icon: Icons.location_off_outlined,
              title: copy.get('location'),
              value: copy.get('location_unverified'),
            ),
          if (place.activities.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              copy.get('good_for'),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: place.activities
                  .map((activity) => Chip(label: Text(copy.activity(activity))))
                  .toList(),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            copy.get('amenities'),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: place.amenities.isEmpty
                ? [
                    Chip(
                      label: Text(
                        place.isDemo
                            ? copy.get('sample_data')
                            : copy.get('not_listed'),
                      ),
                    ),
                  ]
                : place.amenities
                      .map((amenity) => Chip(label: Text(copy.get(amenity))))
                      .toList(),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('place-directions'),
            onPressed: () => _openDirections(context),
            icon: const Icon(Icons.directions_outlined),
            label: Text(copy.get('directions')),
          ),
        ],
      ),
    );
  }
}

Future<bool> _launchExternalUrl(Uri url) {
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

/// Weekly schedule block.
///
/// Only days with data are listed: an unknown day is omitted rather than shown
/// as "Closed", so a half-filled schedule never reads as a closed shop.
class _WeeklyHours extends StatelessWidget {
  const _WeeklyHours({
    required this.hours,
    required this.copy,
    required this.now,
    this.note,
  });

  final OpeningHours hours;
  final AppCopy copy;
  final DateTime now;

  /// Free-text summary or exception note kept from the original field.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final status = hours.isOpenAt(now);
    final days = [
      for (final weekday in OpeningHours.weekdayKeys.values)
        if (hours.isKnownOn(weekday)) weekday,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                copy.get('hours'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
              ),
              if (status != null) ...[
                const SizedBox(width: 10),
                OpenStatusBadge(open: status, copy: copy),
              ],
            ],
          ),
          for (final weekday in days)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      copy.weekday(weekday),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedInk,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _dayLabel(hours, weekday),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 6),
              child: Text(
                note!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
              ),
            ),
        ],
      ),
    );
  }

  String _dayLabel(OpeningHours hours, int weekday) {
    final day = hours.hoursFor(weekday);
    if (day == null) return copy.get('closed');
    return '${copy.timeOfDay(day.openMinutes)}–'
        '${copy.timeOfDay(day.closeMinutes)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.mutedInk),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
