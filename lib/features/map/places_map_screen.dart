import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import '../places/place.dart';
import '../places/place_card.dart';

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
    final mapHeight = (MediaQuery.sizeOf(context).height * 0.38).clamp(
      220.0,
      360.0,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ListView(
        children: [
          Text(
            copy.get('map'),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            copy.get('map_online_note'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedInk),
          ),
          if (placesWithoutCoordinates > 0) ...[
            const SizedBox(height: 4),
            Text(
              copy.get('map_unverified_places'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.mutedInk),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: mapHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: mappablePlaces.isEmpty
                  ? _CoordinatesPending(copy: copy)
                  : _PlacesMap(
                      places: mappablePlaces,
                      onPlaceSelected: onPlaceSelected,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            copy.get('list_view'),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final place = places[index];
                return SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 70).clamp(
                    0.0,
                    double.infinity,
                  ),
                  child: PlaceCard(
                    place: place,
                    copy: copy,
                    onTap: () => onPlaceSelected(place),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesPending extends StatelessWidget {
  const _CoordinatesPending({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_searching_outlined,
                size: 42,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                copy.get('map_waiting_for_coordinates'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                copy.get('map_coordinates_note'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.mutedInk),
              ),
            ],
          ),
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
    final coordinates = widget.places
        .map((place) => place.coordinates!)
        .toList();
    final center = PlaceCoordinates(
      latitude:
          coordinates
              .map((coordinate) => coordinate.latitude)
              .reduce((first, second) => first + second) /
          coordinates.length,
      longitude:
          coordinates
              .map((coordinate) => coordinate.longitude)
              .reduce((first, second) => first + second) /
          coordinates.length,
    );

    return MapLibreMap(
      key: ValueKey(
        widget.places
            .map((place) {
              final coordinates = place.coordinates!;
              return '${place.id}:${coordinates.latitude},${coordinates.longitude}';
            })
            .join('|'),
      ),
      styleString: _styleUrl,
      initialCameraPosition: CameraPosition(
        target: LatLng(center.latitude, center.longitude),
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
    final symbols = await controller.addSymbols(
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
    for (final (index, symbol) in symbols.indexed) {
      _placeIndexesBySymbolId[symbol.id] = index;
    }

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
