import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import 'google_maps_directions.dart';
import 'place.dart';
import 'place_photo.dart';

typedef DirectionsUrlLauncher = Future<bool> Function(Uri url);

Future<void> showPlaceDetails({
  required BuildContext context,
  required Place place,
  required AppCopy copy,
  DirectionsUrlLauncher? launchDirections,
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
    ),
  );
}

class _PlaceDetailSheet extends StatelessWidget {
  const _PlaceDetailSheet({
    required this.place,
    required this.copy,
    required this.launchDirections,
  });

  final Place place;
  final AppCopy copy;
  final DirectionsUrlLauncher launchDirections;

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
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: ListView(
        key: const Key('place-detail-list'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8D8D0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  copy.get('demo_badge'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
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
            placeholder: _DetailPhotoPlaceholder(
              category: place.category,
              copy: copy,
            ),
            photoPosition: copy.photoPosition,
            viewPhotoLabel: copy.get('view_photo'),
            closeLabel: copy.get('close'),
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
                    '${copy.get('sample_data')} $description',
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
            value: '₱${place.priceMin}–₱${place.priceMax}',
          ),
          _DetailRow(
            icon: Icons.schedule_outlined,
            title: copy.get('hours'),
            value: place.hours,
          ),
          _DetailRow(
            icon: Icons.place_outlined,
            title: copy.get('setting'),
            value: copy.get(place.setting),
          ),
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
                ? [Chip(label: Text(copy.get('sample_data')))]
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

class _DetailPhotoPlaceholder extends StatelessWidget {
  const _DetailPhotoPlaceholder({required this.category, required this.copy});

  final String category;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      'coffee' => Icons.local_cafe_outlined,
      'park' => Icons.park_outlined,
      'eatery' => Icons.restaurant_outlined,
      _ => Icons.menu_book_outlined,
    };

    return ColoredBox(
      color: AppColors.sage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            copy.get('no_photo'),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.mutedInk),
          ),
        ],
      ),
    );
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
