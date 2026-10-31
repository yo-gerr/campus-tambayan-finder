import 'package:flutter/material.dart';

import '../features/map/illustrative_map_screen.dart';
import '../features/onboarding/intro_dialog.dart';
import '../features/places/place.dart';
import '../features/places/place_detail_sheet.dart';
import '../features/places/place_filter_sheet.dart';
import '../features/places/place_filters.dart';
import '../features/places/places_explore_screen.dart';
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
  late Future<List<Place>> _placesFuture;
  AppLanguage _language = AppLanguage.english;
  PlaceFilters _filters = const PlaceFilters();
  String _campus = 'plv';
  int _tabIndex = 0;

  AppCopy get _copy => AppCopy(_language);

  @override
  void initState() {
    super.initState();
    _placesFuture = widget.placesRepository.loadPlaces();
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
                color: Colors.white,
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
          IconButton(
            key: const Key('language-toggle'),
            tooltip: _language == AppLanguage.english
                ? 'Switch to Filipino'
                : 'Switch to English',
            onPressed: _toggleLanguage,
            icon: const Icon(Icons.translate),
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
      body: FutureBuilder<List<Place>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              onRetry: () => setState(
                () => _placesFuture = widget.placesRepository.loadPlaces(),
              ),
            );
          }
          final places = snapshot.data!;
          final visiblePlaces = places.where(_filters.matches).toList();
          return IndexedStack(
            index: _tabIndex,
            children: [
              PlacesExploreScreen(
                places: places,
                copy: _copy,
                filters: _filters,
                campus: _campus,
                onCampusChanged: (campus) => setState(() => _campus = campus),
                onFiltersPressed: _openFilters,
                onClearFilters: () =>
                    setState(() => _filters = const PlaceFilters()),
                onPlaceSelected: _openPlace,
                onMapPressed: () => setState(() => _tabIndex = 1),
              ),
              IllustrativeMapScreen(
                places: visiblePlaces,
                copy: _copy,
                campus: _campus,
                onCampusChanged: (campus) => setState(() => _campus = campus),
                onPlaceSelected: _openPlace,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
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
            const Text('Could not load the sample places.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
