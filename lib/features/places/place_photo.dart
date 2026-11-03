import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'place.dart';

/// Which photo the interface should try first.
enum PlacePhotoSource { network, asset, none }

/// Prefers the shared photo so the team can replace it from the dashboard,
/// then the bundled copy that keeps photos visible without a connection.
PlacePhotoSource placePhotoSource(Place place) {
  final photo = place.coverPhoto;
  if (photo?.photoUrl != null) return PlacePhotoSource.network;
  if (photo?.photoAsset != null) return PlacePhotoSource.asset;
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
    final fallback = placeholder ?? _NoPhoto(width: width, height: height);

    final child = _PhotoImage(photo: place.coverPhoto, fallback: fallback);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

/// A swipeable gallery for place details. Cards continue to use [PlacePhoto]
/// so they always show the designated cover image.
class PlacePhotoGallery extends StatefulWidget {
  const PlacePhotoGallery({
    required this.place,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.placeholder,
    required this.photoPosition,
    super.key,
  });

  final Place place;
  final double width;
  final double height;
  final double borderRadius;
  final Widget placeholder;
  final String Function(int current, int total) photoPosition;

  @override
  State<PlacePhotoGallery> createState() => _PlacePhotoGalleryState();
}

class _PlacePhotoGalleryState extends State<PlacePhotoGallery> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.place.photos;
    if (photos.length < 2) {
      return PlacePhoto(
        place: widget.place,
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
        placeholder: widget.placeholder,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              key: Key('place-photo-gallery-${widget.place.id}'),
              itemCount: photos.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _PhotoImage(
                photo: photos[index],
                fallback: widget.placeholder,
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Semantics(
                liveRegion: true,
                label: widget.photoPosition(_currentPage + 1, photos.length),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    child: Text(
                      '${_currentPage + 1} / ${photos.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoImage extends StatelessWidget {
  const _PhotoImage({required this.photo, required this.fallback});

  final PlaceGalleryPhoto? photo;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (photo?.photoUrl != null) {
      return Image.network(
        photo!.photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, image, progress) =>
            progress == null ? image : fallback,
        errorBuilder: (context, error, stackTrace) =>
            _assetOrFallback(photo!.photoAsset, fallback),
      );
    }
    return _assetOrFallback(photo?.photoAsset, fallback);
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
