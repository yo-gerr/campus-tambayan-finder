import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import 'place.dart';
import 'place_card.dart';
import 'place_filters.dart';

class PlacesExploreScreen extends StatefulWidget {
  const PlacesExploreScreen({
    required this.places,
    required this.copy,
    required this.filters,
    required this.campus,
    required this.usingOfflineCopy,
    required this.onCampusChanged,
    required this.onFiltersPressed,
    required this.onClearFilters,
    required this.onPlaceSelected,
    required this.onMapPressed,
    super.key,
  });

  final List<Place> places;
  final AppCopy copy;
  final PlaceFilters filters;
  final String campus;
  final bool usingOfflineCopy;
  final ValueChanged<String> onCampusChanged;
  final VoidCallback onFiltersPressed;
  final VoidCallback onClearFilters;
  final ValueChanged<Place> onPlaceSelected;
  final VoidCallback onMapPressed;

  @override
  State<PlacesExploreScreen> createState() => _PlacesExploreScreenState();
}

class _PlacesExploreScreenState extends State<PlacesExploreScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final results = widget.places.where((place) {
      if (!widget.filters.matches(place)) return false;
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.area.toLowerCase().contains(query) ||
          copy.category(place.category).toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          copy.get('welcome'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
        ),
        const SizedBox(height: 17),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDE4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.science_outlined,
                  size: 19, color: AppColors.terracotta),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  copy.get('demo_banner'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (widget.usingOfflineCopy) ...[
          const SizedBox(height: 10),
          _OfflineNotice(copy: copy),
        ],
        const SizedBox(height: 15),
        TextField(
          key: const Key('place-search'),
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: copy.get('search_hint'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              key: const Key('open-filters'),
              tooltip: copy.get('filters'),
              onPressed: widget.onFiltersPressed,
              icon: Badge(
                isLabelVisible: widget.filters.activeCount > 0,
                label: Text('${widget.filters.activeCount}'),
                child: const Icon(Icons.tune),
              ),
            ),
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: Text(
                copy.get('starting_near'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.mutedInk,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            _CampusSelector(
              campus: widget.campus,
              copy: copy,
              onChanged: widget.onCampusChanged,
            ),
          ],
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: Text(
                '${results.length} ${copy.get('place_count')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: widget.onMapPressed,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(copy.get('show_map')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          _EmptyResults(
            copy: copy,
            onClear: () {
              setState(() => _query = '');
              widget.onClearFilters();
            },
          )
        else
          ...results.map(
            (place) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PlaceCard(
                place: place,
                copy: copy,
                onTap: () => widget.onPlaceSelected(place),
              ),
            ),
          ),
      ],
    );
  }
}

class _CampusSelector extends StatelessWidget {
  const _CampusSelector({
    required this.campus,
    required this.copy,
    required this.onChanged,
  });

  final String campus;
  final AppCopy copy;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      key: const Key('campus-selector'),
      segments: [
        ButtonSegment(
          value: 'plv',
          label: Text(copy.get('campus_plv')),
        ),
        ButtonSegment(
          value: 'cpag',
          label: Text(copy.get('campus_cpag')),
        ),
      ],
      selected: {campus},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.copy, required this.onClear});

  final AppCopy copy;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 42, color: AppColors.mutedInk),
          const SizedBox(height: 12),
          Text(
            copy.get('empty_title'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            copy.get('empty_body'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedInk,
                ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onClear,
            child: Text(copy.get('clear_filters')),
          ),
        ],
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('offline-notice'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              copy.get('offline_notice'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
