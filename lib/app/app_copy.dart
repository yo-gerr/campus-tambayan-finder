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

  String category(String key) {
    final labels = _categories[key];
    if (labels == null) return key;
    return labels[isTagalog ? 1 : 0];
  }

  String activity(String key) {
    final labels = _activities[key];
    if (labels == null) return key;
    return labels[isTagalog ? 1 : 0];
  }

  String photoPosition(int current, int total) =>
      isTagalog ? 'Larawan $current ng $total' : 'Photo $current of $total';

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
      'Showing the bundled copy · live updates unavailable',
      'Naka-bundle na kopya · walang live updates',
    ],
    'no_photo': ['No photo yet', 'Wala pang larawan'],
    'loading_photo': ['Loading photo', 'Naglo-load ang larawan'],
    'view_photo': [
      'View photo full screen',
      'Tingnan ang larawan sa buong screen',
    ],
    'demo_badge': ['DEMO LISTING', 'HALIMBAWANG LISTAHAN'],
    'sample_data': [
      'Sample information for prototype review only.',
      'Halimbawang impormasyon para lamang sa prototype.',
    ],
    'hours': ['Hours', 'Oras'],
    'price': ['Estimated spend', 'Tinatayang gastos'],
    'amenities': ['Amenities', 'Mga amenity'],
    'setting': ['Setting', 'Lugar'],
    'good_for': ['Good for', 'Angkop para sa'],
    'directions': ['Directions', 'Direksyon'],
    'directions_demo': [
      'Directions are not connected in this prototype.',
      'Hindi pa gumagana ang direksyon sa prototype na ito.',
    ],
    'map_online_note': [
      'Map tiles need internet. Places with coordinates appear on the map.',
      'Kailangan ng internet sa mapa. Lalabas dito ang mga lugar na may coordinate.',
    ],
    'map_unverified_places': [
      'Places without a valid coordinate pair are not shown on the map.',
      'Hindi ipinapakita sa mapa ang mga lugar na walang wastong pares ng coordinate.',
    ],
    'map_waiting_for_coordinates': [
      'Map pins will appear after place coordinates are added.',
      'Lalabas ang mga pin kapag naidagdag na ang coordinate ng mga lugar.',
    ],
    'map_coordinates_note': [
      'You can still browse all places below. Sample coordinates are never plotted.',
      'Maaari pa ring tingnan ang mga lugar sa ibaba. Hindi ginagamit ang sample coordinate.',
    ],
    'list_view': ['Places', 'Mga lugar'],
    'empty_title': [
      'No places match those filters',
      'Walang lugar na tugma sa mga filter',
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
      'Map pins use verified place coordinates. The app does not access your device location.',
      'Beripikadong coordinate ng lugar ang gamit ng mga pin. Hindi ina-access ng app ang lokasyon ng iyong device.',
    ],
    'got_it': ['Start exploring', 'Simulan'],
    'close': ['Close', 'Isara'],
    'choose_origin': ['Choose starting point', 'Piliin ang pinagmulan'],
    'place_count': ['places to explore', 'lugar na matutuklasan'],
    'open_now_unknown': ['Hours are sample data', 'Halimbawa lamang ang oras'],
  };

  static const _categories = <String, List<String>>{
    'tambayan': ['Tambayan', 'Tambayan'],
    'coffee': ['Coffee shop', 'Kapihan'],
    'park': ['Park / open space', 'Parke / bukas na lugar'],
    'eatery': ['Affordable eatery', 'Abot-kayang kainan'],
  };

  static const _activities = <String, List<String>>{
    'study': ['Study', 'Mag-aral'],
    'eat': ['Eat', 'Kumain'],
    'relax': ['Relax', 'Magpahinga'],
    'socialize': ['Socialize', 'Makisalamuha'],
  };
}
