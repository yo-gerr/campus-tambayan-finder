import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../map/campus_map_anchors.dart';
import '../map/route_estimate.dart';
import 'place.dart';

/// Shows distance-based walk and ride estimates from a campus anchor.
///
/// The card starts from the campus closest to the place, lets the reader switch
/// origins, and keeps full sentences in the semantics tree while the visible
/// tiles stay compact.
class TravelEstimateCard extends StatefulWidget {
  const TravelEstimateCard({
    required this.place,
    required this.copy,
    super.key,
  });

  final Place place;
  final AppCopy copy;

  @override
  State<TravelEstimateCard> createState() => _TravelEstimateCardState();
}

class _TravelEstimateCardState extends State<TravelEstimateCard> {
  late CampusMapAnchor _selectedCampus;

  @override
  void initState() {
    super.initState();
    _selectedCampus = RouteEstimate.nearestAnchor(widget.place);
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

    // Full sentences are kept for screen readers.
    final walkSentence = copy
        .get('eta_walk')
        .replaceAll('{minutes}', '${estimate.walkMinutes}')
        .replaceAll('{distance}', estimate.formattedDistance);
    final rideSentence = copy
        .get('eta_ride')
        .replaceAll('{minutes}', '${estimate.rideMinutes}')
        .replaceAll('{distance}', estimate.formattedDistance);

    final walkTile = _EtaTile(
      icon: Icons.directions_walk_rounded,
      label: copy.get('eta_walk_label'),
      minutes: estimate.walkMinutes,
      semanticLabel: walkSentence,
    );
    final rideTile = _EtaTile(
      icon: Icons.directions_bus_outlined,
      label: copy.get('eta_ride_label'),
      minutes: estimate.rideMinutes,
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
            onSelected: (campus) => setState(() => _selectedCampus = campus),
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
