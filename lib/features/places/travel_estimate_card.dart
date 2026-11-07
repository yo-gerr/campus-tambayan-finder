import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../map/campus_map_anchors.dart';
import '../map/osrm_route_service.dart';
import '../map/route_estimate.dart';
import 'place.dart';

/// Shows distance-based walk and ride estimates from a campus anchor.
///
/// The card starts from the campus closest to the place, lets the reader switch
/// origins, and fetches OSRM/Cached route details on demand when opened.
class TravelEstimateCard extends StatefulWidget {
  const TravelEstimateCard({
    required this.place,
    required this.copy,
    this.routeService,
    super.key,
  });

  final Place place;
  final AppCopy copy;
  final OsrmRouteService? routeService;

  @override
  State<TravelEstimateCard> createState() => _TravelEstimateCardState();
}

class _TravelEstimateCardState extends State<TravelEstimateCard> {
  late CampusMapAnchor _selectedCampus;
  OsrmRouteResult? _osrmResult;

  @override
  void initState() {
    super.initState();
    _selectedCampus = RouteEstimate.nearestAnchor(widget.place);
    _fetchOsrmRoute();
  }

  @override
  void didUpdateWidget(TravelEstimateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) {
      _selectedCampus = RouteEstimate.nearestAnchor(widget.place);
      _osrmResult = null;
      _fetchOsrmRoute();
    }
  }

  void _onCampusSelected(CampusMapAnchor campus) {
    if (_selectedCampus == campus) return;
    setState(() {
      _selectedCampus = campus;
      _osrmResult = null;
    });
    _fetchOsrmRoute();
  }

  void _fetchOsrmRoute() {
    final routeService = widget.routeService;
    final coordinates = widget.place.coordinates;
    if (routeService == null || coordinates == null) return;

    final origin = _selectedCampus.location;
    final destination = LatLng(coordinates.latitude, coordinates.longitude);

    routeService
        .fetchRoute(
          origin: origin,
          destination: destination,
          destPlaceId: widget.place.id,
        )
        .then((result) {
      if (mounted && result != null) {
        setState(() => _osrmResult = result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final estimate = RouteEstimate.calculate(
      campusAnchor: _selectedCampus,
      place: widget.place,
    );
    if (estimate == null) return const SizedBox.shrink();

    final copy = widget.copy;
    final textTheme = Theme.of(context).textTheme;
    final largeText = AppLayout.of(context).usesLargeText;

    // If OSRM/Cache returned distance and duration, use them; otherwise fallback to Haversine estimate.
    final osrm = _osrmResult;
    final double distanceMeters = osrm?.distanceMeters ?? estimate.distanceMeters;
    final int walkMinutes = osrm != null
        ? math.max(1, (osrm.durationSeconds / 60).round())
        : estimate.walkMinutes;
    final int rideMinutes = osrm != null
        ? math.max(1, (osrm.durationSeconds / 240).round() + 1)
        : estimate.rideMinutes;

    final formattedDist = distanceMeters < 1000
        ? '${distanceMeters.round()} m'
        : '${(distanceMeters / 1000).toStringAsFixed(1)} km';

    // Full sentences are kept for screen readers.
    final walkSentence = copy
        .get('eta_walk')
        .replaceAll('{minutes}', '$walkMinutes')
        .replaceAll('{distance}', formattedDist);
    final rideSentence = copy
        .get('eta_ride')
        .replaceAll('{minutes}', '$rideMinutes')
        .replaceAll('{distance}', formattedDist);

    final walkTile = _EtaTile(
      icon: Icons.directions_walk_rounded,
      label: copy.get('eta_walk_label'),
      minutes: walkMinutes,
      semanticLabel: walkSentence,
    );
    final rideTile = _EtaTile(
      icon: Icons.directions_bus_outlined,
      label: copy.get('eta_ride_label'),
      minutes: rideMinutes,
      semanticLabel: rideSentence,
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceUnder,
            offset: Offset(0, kCardUnderOffset),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_walk_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  copy.get('travel_time'),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.inkStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            copy.get('eta_from'),
            style: textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
          ),
          const SizedBox(height: 6),
          _CampusSelector(
            selected: _selectedCampus,
            onSelected: _onCampusSelected,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = largeText || constraints.maxWidth < 260;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [walkTile, const SizedBox(height: 10), rideTile],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: walkTile),
                    const SizedBox(width: 10),
                    Expanded(child: rideTile),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.straighten_outlined,
                size: 16,
                color: AppColors.mutedInk,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  copy
                      .get('eta_distance')
                      .replaceAll('{distance}', estimate.formattedDistance),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            copy.get('eta_disclaimer'),
            style: textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
          ),
        ],
      ),
    );
  }
}

/// Full-width pill selector: equal-width options, each at least 44 px tall.
class _CampusSelector extends StatelessWidget {
  const _CampusSelector({required this.selected, required this.onSelected});

  final CampusMapAnchor selected;
  final ValueChanged<CampusMapAnchor> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final anchor in campusMapAnchors)
            Expanded(
              child: _CampusOption(
                label: anchor.label,
                selected: anchor == selected,
                onTap: () => onSelected(anchor),
              ),
            ),
        ],
      ),
    );
  }
}

class _CampusOption extends StatelessWidget {
  const _CampusOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.inkStrong,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One mode of travel: a small label and a big minutes number.
class _EtaTile extends StatelessWidget {
  const _EtaTile({
    required this.icon,
    required this.label,
    required this.minutes,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final int minutes;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bubble,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.inkStrong),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.inkStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${minutes.round()}',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkStrong,
                      ),
                    ),
                    TextSpan(
                      text: ' min',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkStrong,
                      ),
                    ),
                  ],
                ),
                key: ValueKey('${label}_${minutes.round()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
