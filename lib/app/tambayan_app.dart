import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/app_drawer.dart';
import '../features/home/home_screen.dart';
import '../features/info/credits_screen.dart';
import '../features/info/info_placeholder_screen.dart';
import '../features/map/places_map_screen.dart';
import '../features/mood/mood_check_in_repository.dart';
import '../features/mood/mood_info_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/visual_onboarding_screen.dart';
import '../features/places/place.dart';
import '../features/places/place_detail_sheet.dart';
import '../features/places/place_filter_sheet.dart';
import '../features/places/place_filters.dart';
import '../features/places/places_explore_screen.dart';
import '../features/places/places_repository.dart';
import '../features/places/sample_places_repository.dart';
import 'app_copy.dart';
import 'app_section.dart';
import 'app_theme.dart';

/// Where the hub currently points.
///
/// The app no longer has a bottom bar: home is the hub and each spoke is a
/// section of this one shell, so the Back control and the visible Home control
/// both return to the same place. Vision, Privacy, and Terms are placeholders
/// until the client supplies approved copy; Credits is factual attribution.
class TambayanApp extends StatelessWidget {
  const TambayanApp({
    this.showIntroOnStart,
    this.placesRepository,
    this.moodCheckInRepository,
    super.key,
  });

  final bool? showIntroOnStart;
  final PlacesRepository? placesRepository;
  final MoodCheckInRepository? moodCheckInRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamus Tambay',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _TambayanHome(
        showIntroOnStart: showIntroOnStart,
        placesRepository: placesRepository ?? SamplePlacesRepository(),
        moodCheckInRepository:
            moodCheckInRepository ?? SupabaseMoodCheckInRepository(null),
      ),
    );
  }
}

class _TambayanHome extends StatefulWidget {
  const _TambayanHome({
    required this.showIntroOnStart,
    required this.placesRepository,
    required this.moodCheckInRepository,
  });

  final bool? showIntroOnStart;
  final PlacesRepository placesRepository;
  final MoodCheckInRepository moodCheckInRepository;

  @override
  State<_TambayanHome> createState() => _TambayanHomeState();
}

class _TambayanHomeState extends State<_TambayanHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Stream<PlacesSnapshot> _placesStream;
  AppLanguage _language = AppLanguage.english;
  PlaceFilters _filters = const PlaceFilters();
  String _campus = 'plv';
  AppSection _section = AppSection.home;
  bool _mapOpened = false;

  AppCopy get _copy => AppCopy(_language);

  @override
  void initState() {
    super.initState();
    _placesStream = widget.placesRepository.watchPlaces();
    if (widget.showIntroOnStart == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showVisualOnboarding(force: true);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showVisualOnboarding();
      });
    }
  }

  Future<void> _showVisualOnboarding({bool force = false}) async {
    final preferencesFuture = SharedPreferences.getInstance();
    if (!force) {
      final preferences = await preferencesFuture;
      if (preferences.getBool('onboarding.completed.v1') == true) {
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisualOnboardingScreen(
          copy: _copy,
          onCompleted: () async {
            final preferences = await preferencesFuture;
            await preferences.setBool('onboarding.completed.v1', true);
          },
        ),
      ),
    );
  }

  Future<void> _showGuide() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OnboardingScreen(copy: _copy)),
    );
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

  void _setLanguage(AppLanguage language) {
    if (language != _language) {
      setState(() => _language = language);
    }
  }

  void _goHome() {
    setState(() => _section = AppSection.home);
  }

  void _openSection(AppSection section) {
    setState(() {
      if (section == AppSection.map) _mapOpened = true;
      _section = section;
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeMenu() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _goHomeFromMenu() {
    _closeMenu();
    _goHome();
  }

  void _openSectionFromMenu(AppSection section) {
    _closeMenu();
    _openSection(section);
  }

  Future<void> _showGuideFromMenu() async {
    _closeMenu();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (mounted) await _showGuide();
  }

  Future<void> _refreshPlaces() async {
    await widget.placesRepository.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _section == AppSection.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _section != AppSection.home) {
          _goHome();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawerScrimColor: AppColors.scrim,
        drawer: AppDrawer(
          copy: _copy,
          section: _section,
          onClose: _closeMenu,
          onHome: _goHomeFromMenu,
          onSectionSelected: _openSectionFromMenu,
          onShowInstructions: _showGuideFromMenu,
          onLanguageChanged: _setLanguage,
        ),
        body: StreamBuilder<PlacesSnapshot>(
          stream: _placesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _LoadError(
                copy: _copy,
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
              index: _section.index,
              children: [
                HomeScreen(
                  copy: _copy,
                  onFindTambayan: () => _openSection(AppSection.explore),
                  onMood: () => _openSection(AppSection.mood),
                  onMenu: _openMenu,
                ),
                PlacesExploreScreen(
                  places: places,
                  copy: _copy,
                  filters: _filters,
                  campus: _campus,
                  usingOfflineCopy: snapshot.data!.isOfflineFallback,
                  usingSavedCopy: snapshot.data!.isSavedOfflineCopy,
                  onMenu: _openMenu,
                  onCampusChanged: (campus) => setState(() => _campus = campus),
                  onFiltersPressed: _openFilters,
                  onClearFilters: () =>
                      setState(() => _filters = const PlaceFilters()),
                  onPlaceSelected: _openPlace,
                  onMapPressed: () => _openSection(AppSection.map),
                  onRefresh: _refreshPlaces,
                ),
                if (_mapOpened)
                  PlacesMapScreen(
                    places: visiblePlaces,
                    copy: _copy,
                    onMenu: _openMenu,
                    onPlaceSelected: _openPlace,
                  )
                else
                  const SizedBox.shrink(),
                MoodInfoScreen(
                  copy: _copy,
                  onHome: _goHome,
                  onMenu: _openMenu,
                  places: places,
                  repository: widget.moodCheckInRepository,
                ),
                InfoPlaceholderScreen(
                  title: _copy.get('vision_mission'),
                  message: _copy.get('vision_pending'),
                  icon: Icons.flag_outlined,
                  copy: _copy,
                  onMenu: _openMenu,
                ),
                InfoPlaceholderScreen(
                  title: _copy.get('privacy'),
                  message: _copy.get('privacy_pending'),
                  icon: Icons.lock_outline,
                  copy: _copy,
                  onMenu: _openMenu,
                ),
                InfoPlaceholderScreen(
                  title: _copy.get('terms'),
                  message: _copy.get('terms_pending'),
                  icon: Icons.description_outlined,
                  copy: _copy,
                  onMenu: _openMenu,
                ),
                CreditsScreen(copy: _copy, onMenu: _openMenu),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPlace(Place place) {
    return showPlaceDetails(context: context, place: place, copy: _copy);
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.copy, required this.onRetry});

  final AppCopy copy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('Could not load places.'),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(copy.get('apply'))),
          ],
        ),
      ),
    );
  }
}
