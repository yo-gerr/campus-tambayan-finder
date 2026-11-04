import 'package:flutter/material.dart';

import '../features/map/places_map_screen.dart';
import '../features/onboarding/intro_dialog.dart';
import '../features/places/place.dart';
import '../features/places/place_detail_sheet.dart';
import '../features/places/place_filter_sheet.dart';
import '../features/places/place_filters.dart';
import '../features/places/places_explore_screen.dart';
import '../features/places/places_repository.dart';
import '../features/places/sample_places_repository.dart';
import 'app_copy.dart';
import 'app_theme.dart';

class TambayanApp extends StatelessWidget {
  const TambayanApp({
    this.showIntroOnStart = true,
    this.placesRepository,
    super.key,
  });

  final bool showIntroOnStart;
  final PlacesRepository? placesRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tambayan',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _TambayanHome(
        showIntroOnStart: showIntroOnStart,
        placesRepository: placesRepository ?? SamplePlacesRepository(),
      ),
    );
  }
}

class _TambayanHome extends StatefulWidget {
  const _TambayanHome({
    required this.showIntroOnStart,
    required this.placesRepository,
  });

  final bool showIntroOnStart;
  final PlacesRepository placesRepository;

  @override
  State<_TambayanHome> createState() => _TambayanHomeState();
}

class _TambayanHomeState extends State<_TambayanHome> {
  late Stream<PlacesSnapshot> _placesStream;
  AppLanguage _language = AppLanguage.english;
  PlaceFilters _filters = const PlaceFilters();
  String _campus = 'plv';
  int _tabIndex = 0;
  bool _mapOpened = false;

  AppCopy get _copy => AppCopy(_language);

  @override
  void initState() {
    super.initState();
    _placesStream = widget.placesRepository.watchPlaces();
    if (widget.showIntroOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showGuide();
      });
    }
  }

  Future<void> _showGuide() async {
    await showIntroDialog(context, _copy);
  }

  Future<void> _openFilters() async {
    final result = await showPlaceFilterSheet(
      context: context,
      copy: _copy,
      initialFilters: _filters,
    );
    if (result != null && mounted) {
      setState(() => _filters = result);
    }
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == AppLanguage.english
          ? AppLanguage.tagalog
          : AppLanguage.english;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_outlined,
                size: 20,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'tambayan',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: _copy.languageToggleTooltip,
            child: Semantics(
              button: true,
              label: _copy.languageToggleTooltip,
              child: TextButton(
                key: const Key('language-toggle'),
                onPressed: _toggleLanguage,
                child: Text(_copy.languageToggleTarget),
              ),
            ),
          ),
          IconButton(
            key: const Key('open-guide'),
            tooltip: _copy.get('help'),
            onPressed: _showGuide,
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<PlacesSnapshot>(
        stream: _placesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(
              onRetry: () => setState(
                () => _placesStream = widget.placesRepository.watchPlaces(),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final places = snapshot.data!.places;
          final visiblePlaces = places.where(_filters.matches).toList();
          return IndexedStack(
            index: _tabIndex,
            children: [
              PlacesExploreScreen(
                places: places,
                copy: _copy,
                filters: _filters,
                campus: _campus,
                usingOfflineCopy: snapshot.data!.isOfflineFallback,
                onCampusChanged: (campus) => setState(() => _campus = campus),
                onFiltersPressed: _openFilters,
                onClearFilters: () =>
                    setState(() => _filters = const PlaceFilters()),
                onPlaceSelected: _openPlace,
                onMapPressed: () => setState(() {
                  _mapOpened = true;
                  _tabIndex = 1;
                }),
              ),
              if (_mapOpened)
                PlacesMapScreen(
                  places: visiblePlaces,
                  copy: _copy,
                  onPlaceSelected: _openPlace,
                )
              else
                const SizedBox.shrink(),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() {
          if (index == 1) _mapOpened = true;
          _tabIndex = index;
        }),
        destinations: [
          NavigationDestination(
            key: const Key('nav-explore'),
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: _copy.get('explore'),
          ),
          NavigationDestination(
            key: const Key('nav-map'),
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: _copy.get('map'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPlace(Place place) {
    return showPlaceDetails(context: context, place: place, copy: _copy);
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text('Could not load places.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
