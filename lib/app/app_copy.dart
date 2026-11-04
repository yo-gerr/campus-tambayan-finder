import '../features/places/place_categories.dart';

enum AppLanguage { english, tagalog }

class AppCopy {
  const AppCopy(this.language);

  final AppLanguage language;

  bool get isTagalog => language == AppLanguage.tagalog;

  String get(String key) {
    final translations = _translations[key];
    if (translations == null) return key;
    return translations[isTagalog ? 1 : 0];
  }

  /// Bilingual label for a stored category key.
  ///
  /// Labels live in [PlaceCategory] so the chip list, search, and cards cannot
  /// drift apart. Unknown keys are returned unchanged rather than blanked.
  String category(String key) =>
      PlaceCategory.fromKey(key)?.label(isTagalog) ?? key;

  String activity(String key) {
    final labels = _activities[key];
    if (labels == null) return key;
    return labels[isTagalog ? 1 : 0];
  }

  String photoPosition(int current, int total) =>
      isTagalog ? 'Larawan $current ng $total' : 'Photo $current of $total';

  /// Estimated spend for a listing, or the "not listed" copy when the team has
  /// no reliable range. An exact price collapses to a single value instead of
  /// reading as "₱50–₱50".
  String priceRange(int? min, int? max) {
    if (min == null || max == null) return get('price_not_listed');
    return min == max ? '₱$min' : '₱$min–₱$max';
  }

  /// Twelve-hour clock label for a minute offset from midnight.
  String timeOfDay(int minutes) {
    final hour24 = (minutes ~/ 60) % 24;
    final rest = minutes % 60;
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final suffix = hour24 < 12 ? 'AM' : 'PM';
    return '$hour:${rest.toString().padLeft(2, '0')} $suffix';
  }

  /// Weekday name for a [DateTime.weekday] value (1 = Monday).
  String weekday(int weekday) => switch (weekday) {
    DateTime.monday => get('monday'),
    DateTime.tuesday => get('tuesday'),
    DateTime.wednesday => get('wednesday'),
    DateTime.thursday => get('thursday'),
    DateTime.friday => get('friday'),
    DateTime.saturday => get('saturday'),
    _ => get('sunday'),
  };

  /// The language a tap will switch to, kept compact for the app bar.
  String get languageToggleTarget => isTagalog ? 'Eng' : 'Tag';

  String get languageToggleTooltip =>
      isTagalog ? 'Lumipat sa English' : 'Switch to Filipino';

  static const _translations = <String, List<String>>{
    'explore': ['Explore', 'Mag-explore'],
    'map': ['Map', 'Mapa'],
    'welcome': [
      'Find a place to pause, study, or meet up.',
      'Humanap ng lugar para magpahinga, mag-aral, o makipagkita.',
    ],
    'campus_plv': ['PLV Annex', 'PLV Annex'],
    'campus_cpag': ['CPAG', 'CPAG'],
    'places_near': ['Places near', 'Mga lugar malapit sa'],
    'show_map': ['View map', 'Tingnan ang mapa'],
    'show_list': ['View list', 'Tingnan ang listahan'],
    'search_hint': [
      'Find a place or category',
      'Maghanap ng lugar o kategorya',
    ],
    'filters': ['Filters', 'Mga filter'],
    'starting_near': ['Starting near', 'Simula malapit sa'],
    'demo_banner': [
      'DEMO CONTENT · NOT VERIFIED',
      'DEMO CONTENT · HINDI BERIPIKADO',
    ],
    'offline_notice': [
      'Showing the bundled sample copy · live updates unavailable',
      'Ipinapakita ang naka-bundle na halimbawa · walang live updates',
    ],
    'offline_saved_notice': [
      'Showing the last saved listings · updates unavailable',
      'Ipinapakita ang huling na-save na listahan · walang update',
    ],
    'no_photo': ['No photo yet', 'Wala pang larawan'],
    'loading_photo': ['Loading photo', 'Naglo-load ang larawan'],
    'view_photo': [
      'View photo full screen',
      'Tingnan ang larawan sa buong screen',
    ],
    'demo_badge': ['DEMO', 'HALIMBAWA'],
    'sample_data': [
      'Sample information for prototype review only.',
      'Halimbawang impormasyon para lamang sa prototype.',
    ],
    'hours': ['Hours', 'Oras'],
    'availability': ['Availability', 'Kung bukas'],
    'open_now': ['Open now', 'Bukas ngayon'],
    'closed_now': ['Closed now', 'Sarado ngayon'],
    'closed': ['Closed', 'Sarado'],
    'hours_not_listed': ['Hours not listed', 'Hindi nakalista ang oras'],
    'monday': ['Monday', 'Lunes'],
    'tuesday': ['Tuesday', 'Martes'],
    'wednesday': ['Wednesday', 'Miyerkules'],
    'thursday': ['Thursday', 'Huwebes'],
    'friday': ['Friday', 'Biyernes'],
    'saturday': ['Saturday', 'Sabado'],
    'sunday': ['Sunday', 'Linggo'],
    'price': ['Estimated\nspend', 'Tinatayang gastos'],
    'price_not_listed': ['Price not listed', 'Hindi nakalista ang presyo'],
    'amenities': ['Amenities', 'Mga amenity'],
    'setting': ['Setting', 'Lugar'],
    'address': ['Address', 'Adres'],
    'good_for': ['Good for', 'Angkop para sa'],
    'location': ['Location', 'Lokasyon'],
    'location_unverified': [
      'Not yet verified; directions are unavailable.',
      'Hindi pa beripikado; hindi available ang direksyon.',
    ],
    'not_listed': ['Not listed', 'Hindi nakalista'],
    'directions': ['Directions', 'Direksyon'],
    'directions_location_unverified': [
      'Directions are unavailable because this listing’s location has not been verified yet.',
      'Hindi pa available ang direksyon dahil hindi pa beripikado ang lokasyon ng listahang ito.',
    ],
    'directions_coordinates_missing': [
      'Directions are unavailable because this listing has no valid coordinates yet.',
      'Hindi pa available ang direksyon dahil wala pang wastong coordinate ang listahang ito.',
    ],
    'directions_could_not_open': [
      'Could not open Google Maps. Check that a maps app or browser is available, then try again.',
      'Hindi mabuksan ang Google Maps. Tiyaking may maps app o browser, pagkatapos ay subukan muli.',
    ],
    'map_online_note': ['Map needs internet', 'Kailangan ng internet ang mapa'],
    'map_unverified_places': [
      'Places without a valid coordinate pair are not shown on the map.',
      'Hindi ipinapakita sa mapa ang mga lugar na walang wastong pares ng coordinate.',
    ],
    'list_view': ['Places', 'Mga lugar'],
    'empty_title': [
      'No places match those filters',
      'Walang lugar na tugma sa mga filter',
    ],
    'empty_category_title': [
      'No {category} listings yet',
      'Wala pang listahan para sa {category}',
    ],
    'empty_body': [
      'Try changing or clearing your filters.',
      'Baguhin o alisin ang mga filter.',
    ],
    'clear_filters': ['Clear filters', 'Alisin ang mga filter'],
    'apply': ['Show places', 'Ipakita ang mga lugar'],
    'reset': ['Reset', 'I-reset'],
    'category': ['Category', 'Kategorya'],
    'budget': ['Maximum budget', 'Pinakamataas na budget'],
    'any_price': ['Any budget', 'Anumang budget'],
    'setting_filter': ['Indoor or outdoor', 'Loob o labas'],
    'activity_filter': ['What do you want to do?', 'Ano ang gusto mong gawin?'],
    'all': ['All', 'Lahat'],
    'indoor': ['Indoor', 'Indoor'],
    'outdoor': ['Outdoor', 'Outdoor'],
    'wifi': ['Free Wi-Fi', 'Libreng Wi-Fi'],
    'aircon': ['Air conditioning', 'Aircon'],
    'outlets': ['Power outlets', 'Saksakan'],
    'capacity': ['Roomy', 'Maluwag'],
    'back': ['Back', 'Bumalik'],
    'help': ['How to use', 'Paano gamitin'],
    'guide_title': [
      'Find your next tambayan',
      'Hanapin ang susunod mong tambayan',
    ],
    'guide_body': [
      'Browse sample places, try filters, and open a place for details. '
          'This prototype works with sample data only.',
      'Tingnan ang mga halimbawang lugar, subukan ang mga filter, at buksan ang detalye. '
          'Halimbawang datos lamang ang gamit ng prototype na ito.',
    ],
    'guide_map': [
      'The map marks PLV Annex and CPAG. Place pins appear only for valid coordinates; the app does not access your device location.',
      'Minamarkahan sa mapa ang PLV Annex at CPAG. Ipinapakita lamang ang pin ng lugar kung may wastong coordinate; hindi ina-access ng app ang lokasyon ng iyong device.',
    ],
    'got_it': ['Start exploring', 'Simulan'],
    'close': ['Close', 'Isara'],
    'choose_origin': ['Choose starting point', 'Piliin ang pinagmulan'],
    'place_count': ['places to explore', 'lugar na matutuklasan'],
    'open_now_unknown': ['Hours are sample data', 'Halimbawa lamang ang oras'],
  };

  static const _activities = <String, List<String>>{
    'study': ['Study', 'Mag-aral'],
    'eat': ['Eat', 'Kumain'],
    'relax': ['Relax', 'Magpahinga'],
    'socialize': ['Socialize', 'Makisalamuha'],
  };
}
