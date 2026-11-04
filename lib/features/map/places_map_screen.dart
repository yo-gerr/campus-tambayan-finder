import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import '../places/place.dart';
import 'campus_map_anchors.dart';

class PlacesMapScreen extends StatelessWidget {
  const PlacesMapScreen({
    required this.places,
    required this.copy,
    required this.onPlaceSelected,
    super.key,
  });

  final List<Place> places;
  final AppCopy copy;
  final ValueChanged<Place> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    final mappablePlaces = places
        .where((place) => place.coordinates != null)
        .toList();
    final placesWithoutCoordinates = places.length - mappablePlaces.length;
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _PlacesMap(places: mappablePlaces, onPlaceSelected: onPlaceSelected),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: _MapStatusOverlay(
                copy: copy,
                placesWithoutCoordinates: placesWithoutCoordinates,
                theme: theme,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapStatusOverlay extends StatelessWidget {
  const _MapStatusOverlay({
    required this.copy,
    required this.placesWithoutCoordinates,
    required this.theme,
  });

  final AppCopy copy;
  final int placesWithoutCoordinates;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 7),
                Text(
                  copy.get('map_online_note'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (placesWithoutCoordinates > 0) ...[
              const SizedBox(height: 4),
              Text(
                copy.get('map_unverified_places'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlacesMap extends StatefulWidget {
  const _PlacesMap({required this.places, required this.onPlaceSelected});

  final List<Place> places;
  final ValueChanged<Place> onPlaceSelected;

  @override
  State<_PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<_PlacesMap> {
  static const _styleUrl = 'https://tiles.openfreemap.org/styles/positron';

  MapLibreMapController? _controller;
  final Map<String, int> _placeIndexesByCircleId = {};
  final Map<String, int> _placeIndexesBySymbolId = {};

  @override
  void dispose() {
    final controller = _controller;
    controller
      ?..onCircleTapped.remove(_onCircleTapped)
      ..onSymbolTapped.remove(_onSymbolTapped);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      key: ValueKey(
        [
          ...campusMapAnchors.map(
            (anchor) =>
                '${anchor.id}:${anchor.location.latitude},${anchor.location.longitude}',
          ),
          ...widget.places.map((place) {
            final coordinates = place.coordinates!;
            return '${place.id}:${coordinates.latitude},${coordinates.longitude}';
          }),
        ].join('|'),
      ),
      styleString: _styleUrl,
      initialCameraPosition: CameraPosition(
        target: initialCampusMapCenter,
        zoom: 15,
      ),
      attributionEnabled: true,
      logoEnabled: false,
      annotationOrder: const [AnnotationType.symbol, AnnotationType.circle],
      annotationConsumeTapEvents: const [
        AnnotationType.symbol,
        AnnotationType.circle,
      ],
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    controller.onCircleTapped.add(_onCircleTapped);
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null) return;

    _placeIndexesByCircleId.clear();
    _placeIndexesBySymbolId.clear();
    final placeSymbols = await controller.addSymbols(
      widget.places.map((place) {
        final coordinates = place.coordinates!;
        return SymbolOptions(
          geometry: LatLng(coordinates.latitude, coordinates.longitude),
          textField: place.name,
          textSize: 12,
          textAnchor: 'top',
          textOffset: const Offset(0, 0.9),
          textColor: _mapLibreColor(Theme.of(context).colorScheme.primary),
          textHaloColor: _mapLibreColor(Theme.of(context).colorScheme.surface),
          textHaloWidth: 2,
        );
      }).toList(),
    );
    if (!mounted) return;
    for (final (index, symbol) in placeSymbols.indexed) {
      _placeIndexesBySymbolId[symbol.id] = index;
    }

    await controller.addSymbols(
      campusMapAnchors
          .map(
            (anchor) => SymbolOptions(
              geometry: anchor.location,
              textField: anchor.label,
              textSize: 13,
              textAnchor: 'top',
              textOffset: const Offset(0, 0.9),
              textColor: _mapLibreColor(AppColors.terracotta),
              textHaloColor: _mapLibreColor(
                Theme.of(context).colorScheme.surface,
              ),
              textHaloWidth: 2,
            ),
          )
          .toList(),
    );
    if (!mounted) return;

    final circles = await controller.addCircles(
      widget.places.map((place) {
        final coordinates = place.coordinates!;
        return CircleOptions(
          geometry: LatLng(coordinates.latitude, coordinates.longitude),
          circleRadius: 9,
          circleColor: _mapLibreColor(Theme.of(context).colorScheme.primary),
          circleStrokeColor: _mapLibreColor(
            Theme.of(context).colorScheme.surface,
          ),
          circleStrokeWidth: 3,
        );
      }).toList(),
    );
    if (!mounted) return;
    for (final (index, circle) in circles.indexed) {
      _placeIndexesByCircleId[circle.id] = index;
    }

    await controller.addCircles(
      campusMapAnchors
          .map(
            (anchor) => CircleOptions(
              geometry: anchor.location,
              circleRadius: 12,
              circleColor: _mapLibreColor(AppColors.terracotta),
              circleStrokeColor: _mapLibreColor(
                Theme.of(context).colorScheme.surface,
              ),
              circleStrokeWidth: 3,
            ),
          )
          .toList(),
    );
  }

  void _onCircleTapped(Circle circle) {
    _selectPlace(_placeIndexesByCircleId[circle.id]);
  }

  void _onSymbolTapped(Symbol symbol) {
    _selectPlace(_placeIndexesBySymbolId[symbol.id]);
  }

  void _selectPlace(int? index) {
    if (index != null && index < widget.places.length) {
      widget.onPlaceSelected(widget.places[index]);
    }
  }
}

String _mapLibreColor(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0')}';
}
