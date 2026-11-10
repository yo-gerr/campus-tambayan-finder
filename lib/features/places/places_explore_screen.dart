import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../home/app_chrome.dart';
import '../map/campus_map_anchors.dart';
import 'place.dart';
import 'place_card.dart';
import 'place_categories.dart';
import 'place_filters.dart';

class PlacesExploreScreen extends StatefulWidget {
  const PlacesExploreScreen({
    required this.places,
    required this.copy,
    required this.filters,
    required this.campus,
    required this.usingOfflineCopy,
    required this.usingSavedCopy,
    required this.onMenu,
    required this.onCampusChanged,
    required this.onFiltersPressed,
    required this.onClearFilters,
    required this.onPlaceSelected,
    required this.onMapPressed,
    this.onRefresh,
    super.key,
  });

  final List<Place> places;
  final AppCopy copy;
  final PlaceFilters filters;
  final String campus;
  final bool usingOfflineCopy;
  final bool usingSavedCopy;
  final VoidCallback onMenu;
  final ValueChanged<String> onCampusChanged;
  final VoidCallback onFiltersPressed;
  final VoidCallback onClearFilters;
  final ValueChanged<Place> onPlaceSelected;
  final VoidCallback onMapPressed;
  final Future<void> Function()? onRefresh;

  @override
  State<PlacesExploreScreen> createState() => _PlacesExploreScreenState();
}

class _PlacesExploreScreenState extends State<PlacesExploreScreen>
    with WidgetsBindingObserver {
  String _query = '';

  /// One clock reading shared by every card and by the filter, so a list never
  /// shows two different "now" values in one frame.
  DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // "Open now" goes stale while the app sits open, so refresh it quietly.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _now = DateTime.now());
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    final copy = widget.copy;
    final results = widget.places.where((place) {
      if (!widget.filters.matches(place, now: _now)) return false;
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.area.toLowerCase().contains(query) ||
          copy.category(place.category).toLowerCase().contains(query);
    }).toList();

    // Sort results by distance from the selected campus anchor.
    final activeAnchor = anchorForCampus(widget.campus);
    results.sort((a, b) {
      final coordsA = a.coordinates;
      final coordsB = b.coordinates;
      if (coordsA == null && coordsB == null) return 0;
      if (coordsA == null) return 1;
      if (coordsB == null) return -1;
      final distA = distanceMetersBetween(
        activeAnchor.location,
        LatLng(coordsA.latitude, coordsA.longitude),
      );
      final distB = distanceMetersBetween(
        activeAnchor.location,
        LatLng(coordsB.latitude, coordsB.longitude),
      );
      return distA.compareTo(distB);
    });

    // A category is selectable before any listing uses it. Distinguish "we have
    // nothing in this category yet" from "your filters excluded everything", so
    // the empty state does not blame the filters for missing data.
    final selectedCategory = widget.filters.category;
    String? missingCategory;
    if (selectedCategory != null &&
        !widget.places.any((place) => place.category == selectedCategory)) {
      missingCategory =
          PlaceCategory.fromKey(selectedCategory)?.label(copy.isTagalog) ??
          selectedCategory;
    }

    return BandScaffold(
      header: SectionHeader(
        title: copy.get('explore'),
        copy: copy,
        onMenu: widget.onMenu,
      ),
      child: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        color: AppColors.primary,
        backgroundColor: AppColors.raised,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            layout.contentInset,
            8,
            layout.contentInset,
            32,
          ),
          children: [
          Text(
            copy.get('welcome'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          if (widget.usingOfflineCopy) ...[
            _OfflineNotice(copy: copy, usingSavedCopy: widget.usingSavedCopy),
          ],
          const SizedBox(height: 16),
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
          const SizedBox(height: 18),
          if (layout.usesLargeText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.get('starting_near'),
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: AppColors.mutedInk),
                ),
                const SizedBox(height: AppSpacing.unit),
                _CampusSelector(
                  campus: widget.campus,
                  copy: copy,
                  onChanged: widget.onCampusChanged,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    copy.get('starting_near'),
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: AppColors.mutedInk),
                  ),
                ),
                _CampusSelector(
                  campus: widget.campus,
                  copy: copy,
                  onChanged: widget.onCampusChanged,
                ),
              ],
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${results.length} ${copy.get('place_count')}',
                  style: Theme.of(context).textTheme.titleMedium,
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
              missingCategory: missingCategory,
              onClear: () {
                setState(() => _query = '');
                widget.onClearFilters();
              },
            )
          else
            ...results.map(
              (place) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PlaceCard(
                  place: place,
                  copy: copy,
                  now: _now,
                  onTap: () => widget.onPlaceSelected(place),
                ),
              ),
            ),
        ],
      ),
    ),
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
        ButtonSegment(value: 'plv', label: Text(copy.get('campus_plv'))),
        ButtonSegment(value: 'cpag', label: Text(copy.get('campus_cpag'))),
      ],
      selected: {campus},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.copy,
    required this.onClear,
    this.missingCategory,
  });

  final AppCopy copy;
  final VoidCallback onClear;

  /// Bilingual label of the selected category when the dataset has no listing
  /// in it at all. Null when results are empty for other reasons.
  final String? missingCategory;

  @override
  Widget build(BuildContext context) {
    final category = missingCategory;
    final title = category == null
        ? copy.get('empty_title')
        : copy.get('empty_category_title').replaceAll('{category}', category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
      child: Column(
        children: [
          Icon(
            category == null ? Icons.search_off : Icons.place_outlined,
            size: 42,
            color: AppColors.mutedInk,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            copy.get('empty_body'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.mutedInk),
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
  const _OfflineNotice({required this.copy, required this.usingSavedCopy});

  final AppCopy copy;
  final bool usingSavedCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('offline-notice'),
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 19,
            color: AppColors.inkStrong,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              copy.get(
                usingSavedCopy ? 'offline_saved_notice' : 'offline_notice',
              ),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AppColors.inkStrong, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
