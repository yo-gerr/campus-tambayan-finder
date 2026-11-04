import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.loadingLabel = 'Loading photo',
    this.placeholder,
    super.key,
  });

  final Place place;
  final double width;
  final double height;
  final double borderRadius;
  final String loadingLabel;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ?? _NoPhoto(width: width, height: height);

    final child = _PhotoImage(
      photo: place.coverPhoto,
      fallback: fallback,
      loadingLabel: loadingLabel,
    );

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
    this.loadingLabel = 'Loading photo',
    required this.photoPosition,
    required this.viewPhotoLabel,
    required this.closeLabel,
    this.photoCaption,
    super.key,
  });

  final Place place;
  final double width;
  final double height;
  final double borderRadius;
  final Widget placeholder;
  final String loadingLabel;
  final String Function(int current, int total) photoPosition;
  final String viewPhotoLabel;
  final String closeLabel;
  final String? Function(PlaceGalleryPhoto photo)? photoCaption;

  @override
  State<PlacePhotoGallery> createState() => _PlacePhotoGalleryState();
}

class _PlacePhotoGalleryState extends State<PlacePhotoGallery> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.place.photos.isNotEmpty
        ? widget.place.photos
        : [?widget.place.coverPhoto];
    if (photos.length < 2) {
      if (photos.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _galleryPhoto(context, photos.single, 0),
                _caption(photos.single, hasPositionIndicator: false),
              ],
            ),
          ),
        );
      }

      return PlacePhoto(
        place: widget.place,
        width: widget.width,
        height: widget.height,
        borderRadius: widget.borderRadius,
        loadingLabel: widget.loadingLabel,
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
              itemBuilder: (context, index) =>
                  _galleryPhoto(context, photos[index], index),
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
            _caption(
              photos[_currentPage.clamp(0, photos.length - 1)],
              hasPositionIndicator: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _galleryPhoto(
    BuildContext context,
    PlaceGalleryPhoto photo,
    int index,
  ) {
    return Semantics(
      button: true,
      label: widget.viewPhotoLabel,
      child: GestureDetector(
        key: Key('photo-gallery-open-${widget.place.id}-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _showPhotoViewer(
          context,
          placeName: widget.place.name,
          photo: photo,
          fallback: widget.placeholder,
          loadingLabel: widget.loadingLabel,
          closeLabel: widget.closeLabel,
        ),
        child: _PhotoImage(
          photo: photo,
          fallback: widget.placeholder,
          loadingLabel: widget.loadingLabel,
        ),
      ),
    );
  }

  Widget _caption(
    PlaceGalleryPhoto photo, {
    required bool hasPositionIndicator,
  }) {
    final caption = widget.photoCaption?.call(photo);
    if (caption == null || caption.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 10,
      right: hasPositionIndicator ? 62 : 10,
      bottom: 10,
      // Labels must not steal the tap that opens the full-screen viewer.
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              caption,
              key: const Key('place-photo-caption'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoImage extends StatelessWidget {
  const _PhotoImage({
    required this.photo,
    required this.fallback,
    required this.loadingLabel,
    this.fit = BoxFit.cover,
  });

  final PlaceGalleryPhoto? photo;
  final Widget fallback;
  final String loadingLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (photo?.photoUrl != null) {
      return Image.network(
        photo!.photoUrl!,
        fit: fit,
        frameBuilder: (context, image, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return image;
          return PlacePhotoLoadingSkeleton(label: loadingLabel);
        },
        errorBuilder: (context, error, stackTrace) =>
            _assetOrFallback(photo!.photoAsset, fallback),
      );
    }
    final asset = photo?.photoAsset;
    if (asset == null) return fallback;
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

Future<void> _showPhotoViewer(
  BuildContext context, {
  required String placeName,
  required PlaceGalleryPhoto photo,
  required Widget fallback,
  required String loadingLabel,
  required String closeLabel,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => _PhotoViewerScreen(
        placeName: placeName,
        photo: photo,
        fallback: fallback,
        loadingLabel: loadingLabel,
        closeLabel: closeLabel,
      ),
    ),
  );
}

class _PhotoViewerScreen extends StatelessWidget {
  const _PhotoViewerScreen({
    required this.placeName,
    required this.photo,
    required this.fallback,
    required this.loadingLabel,
    required this.closeLabel,
  });

  final String placeName;
  final PlaceGalleryPhoto photo;
  final Widget fallback;
  final String loadingLabel;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        key: const Key('photo-viewer-app-bar'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  Colors.black.withValues(alpha: 0.48),
                  Colors.transparent,
                ],
                stops: const [0, 0.58, 1],
              ),
            ),
          ),
        ),
        title: Text(placeName),
        leading: IconButton(
          tooltip: closeLabel,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: _PhotoImage(
                photo: photo,
                fallback: fallback,
                loadingLabel: loadingLabel,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlacePhotoLoadingSkeleton extends StatelessWidget {
  const PlacePhotoLoadingSkeleton({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shapeColor = colors.surfaceContainerLow;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: const Alignment(0, -0.2),
                    child: Container(
                      width: constraints.maxWidth * 0.18,
                      height: constraints.maxWidth * 0.18,
                      decoration: BoxDecoration(
                        color: shapeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.42),
                    child: Container(
                      width: constraints.maxWidth * 0.58,
                      height: constraints.maxHeight * 0.2,
                      decoration: BoxDecoration(
                        color: shapeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
