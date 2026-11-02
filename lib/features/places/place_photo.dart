import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'place.dart';

/// Which photo the interface should try first.
enum PlacePhotoSource { network, asset, none }

/// Prefers the shared photo so the team can replace it from the dashboard,
/// then the bundled copy that keeps photos visible without a connection.
PlacePhotoSource placePhotoSource(Place place) {
  if (place.photoUrl != null) return PlacePhotoSource.network;
  if (place.photoAsset != null) return PlacePhotoSource.asset;
  return PlacePhotoSource.none;
}

/// Renders a place photo, falling back to the bundled copy and then to
/// [placeholder].
///
/// A missing photo is an expected state until the team supplies approved
/// images, so it is presented as a neutral placeholder rather than an error.
class PlacePhoto extends StatelessWidget {
  const PlacePhoto({
    required this.place,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.placeholder,
    super.key,
  });

  final Place place;
  final double width;
  final double height;
  final double borderRadius;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final fallback =
        placeholder ?? _NoPhoto(width: width, height: height);

    final Widget child = switch (placePhotoSource(place)) {
      PlacePhotoSource.network => Image.network(
        place.photoUrl!,
        fit: BoxFit.cover,
        // Show the offline-safe image while the shared photo downloads, so a
        // slow connection never leaves an empty block on screen.
        loadingBuilder: (context, image, progress) =>
            progress == null ? image : fallback,
        errorBuilder: (context, error, stackTrace) =>
            _assetOrFallback(place.photoAsset, fallback),
      ),
      PlacePhotoSource.asset => _assetOrFallback(place.photoAsset, fallback),
      PlacePhotoSource.none => fallback,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

Widget _assetOrFallback(String? asset, Widget fallback) {
  if (asset == null) return fallback;
  return Image.asset(
    asset,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('place-photo-fallback'),
      width: width,
      height: height,
      color: AppColors.sage,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.mutedInk),
    );
  }
}
