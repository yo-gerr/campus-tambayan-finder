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
    'home': ['Home', 'Home'],
    'home_find': ['Find a tambayan', 'Humanap ng tambayan'],
    'home_mood': ['Mood check-in', 'Mood check-in'],
    'home_more': ['More', 'Higit pa'],
    'menu': ['Menu', 'Menu'],
    'close_menu': ['Close menu', 'Isara ang menu'],
    'instructions': ['Instructions', 'Mga tagubilin'],
    'vision_mission': ['Vision & Mission', 'Bisyon at Misyon'],
    'privacy': ['Privacy', 'Privacy'],
    'terms': ['Terms & Conditions', 'Mga Tuntunin at Kundisyon'],
    'pending_review': ['Pending review', 'Naghihintay ng pagsusuri'],
    'vision_pending': [
      'The client has not supplied approved vision and mission copy yet. This page is a placeholder.',
      'Wala pang aprubadong bisyon at misyon mula sa client. Placeholder pa lang ang pahinang ito.',
    ],
    'privacy_pending': [
      'A reviewed privacy notice is not available yet. This page is a placeholder, not a privacy policy.',
      'Wala pang nasuring privacy notice. Placeholder pa lang ang pahinang ito, hindi ito privacy policy.',
    ],
    'terms_pending': [
      'Reviewed terms and conditions are not available yet. This page is a placeholder, not a legal agreement.',
      'Wala pang nasuring tuntunin at kundisyon. Placeholder pa lang ang pahinang ito, hindi ito legal na kasunduan.',
    ],
    'app_version': [
      'Kamus Tambay · Version 1.0.0 (demo)',
      'Kamus Tambay · Bersyon 1.0.0 (demo)',
    ],
    'language': ['Language', 'Wika'],
    'language_english': ['English', 'English'],
    'language_filipino': ['Filipino', 'Filipino'],
    'mood_title': ['Mood check-in', 'Mood check-in'],
    'mood_soon': ['Coming soon', 'Paparating na'],
    'mood_body': [
      'Share how you feel after visiting a place. This interactive preview shows the planned flow; nothing is collected or submitted yet.',
      'Ibahagi ang iyong pakiramdam pagkatapos bumisita sa isang lugar. Ipinapakita ng interactive preview na ito ang planong daloy; walang kinokolekta o ipinapasa.',
    ],
    'mood_privacy': [
      'Nothing is saved here: no mood, no nickname, and no profile.',
      'Walang nai-save dito: walang mood, walang palayaw, at walang profile.',
    ],
    'mood_cta': ['Back to home', 'Bumalik sa home'],
    'mood_preview_title': [
      'A private check-in preview',
      'Pribadong preview ng check-in',
    ],
    'mood_start': ['See the check-in flow', 'Tingnan ang daloy ng check-in'],
    'mood_consent_title': ['Before you continue', 'Bago magpatuloy'],
    'mood_consent_body': [
      'A future version may use voluntary responses for anonymous aggregate analysis. This prototype does not collect or save anything.',
      'Maaaring gamitin ng future version ang boluntaryong sagot para sa anonymous aggregate analysis. Walang kinokolekta o sine-save ang prototype na ito.',
    ],
    'mood_consent_data': [
      'The planned check-in may connect a mood to the place you choose. It will not use GPS, accounts, or a persistent profile. Retention, access, and deletion rules still need client approval.',
      'Maaaring iugnay ng planong check-in ang mood sa lugar na pipiliin mo. Hindi ito gagamit ng GPS, account, o persistent profile. Kailangan pa ng approval para sa retention, access, at deletion rules.',
    ],
    'mood_consent_agree': [
      'I understand this is a preview and not a real submission.',
      'Naiintindihan kong preview ito at hindi totoong submission.',
    ],
    'mood_select_title': ['How do you feel?', 'Ano ang iyong nararamdaman?'],
    'mood_select_body': [
      'Choose one response. Your selection stays on this screen only.',
      'Pumili ng isang sagot. Mananatili lamang ang pinili sa screen na ito.',
    ],
    'mood_happy': ['Happy', 'Masaya'],
    'mood_relaxed': ['Relaxed', 'Relaxado'],
    'mood_stressed': ['Stressed', 'Stress'],
    'mood_sad': ['Sad', 'Malungkot'],
    'mood_nickname': [
      'Optional nickname (preview only)',
      'Opsyonal na palayaw (preview lang)',
    ],
    'mood_nickname_help': [
      'A nickname may still identify you. You can leave this blank.',
      'Maaaring makilala ka pa rin gamit ang palayaw. Maaari itong iwanang blangko.',
    ],
    'mood_continue': ['Continue', 'Magpatuloy'],
    'mood_review_title': ['Review your response', 'Suriin ang iyong sagot'],
    'mood_review_mood': ['Mood', 'Mood'],
    'mood_review_nickname': ['Nickname', 'Palayaw'],
    'mood_not_provided': ['Not provided', 'Walang inilagay'],
    'mood_demo_notice': [
      'Preview only: this response will not be sent, saved, or used for analysis.',
      'Preview lang: hindi ipapadala, ise-save, o gagamitin sa analysis ang sagot na ito.',
    ],
    'mood_preview_submit': [
      'Preview confirmation',
      'I-preview ang confirmation',
    ],
    'mood_complete_title': ['Nothing was submitted', 'Walang ipinasa'],
    'mood_complete_body': [
      'This prototype recorded nothing. Real collection will require approved consent, retention, access, and deletion rules.',
      'Walang naitala ang prototype na ito. Kailangan muna ng approved consent, retention, access, at deletion rules bago ang totoong collection.',
    ],
    'mood_restart': ['Try the preview again', 'Ulitin ang preview'],
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
    'opens': ['Opens', 'Bubukas'],
    'closes': ['Closes', 'Magsasara'],
    'see_full_week': ['See full week', 'Tingnan ang buong linggo'],
    'hide_full_week': ['Hide', 'Itago'],
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
    'address_copied': ['Address copied', 'Nakopya ang address'],
    'good_for': ['Good for', 'Angkop para sa'],
    'location': ['Location', 'Lokasyon'],
    'location_unverified': [
      'Not yet verified; directions are unavailable.',
      'Hindi pa beripikado; hindi available ang direksyon.',
    ],
    'not_listed': ['Not listed', 'Hindi nakalista'],
    'directions': ['Directions', 'Direksyon'],
    'opens_google_maps': ['Opens in Google Maps', 'Magbubukas sa Google Maps'],
    'travel_time': ['Travel estimate', 'Tinatayang biyahe'],
    'eta_from': ['From', 'Mula sa'],
    'eta_walk_label': ['Walk', 'Lakad'],
    'eta_ride_label': ['Ride', 'Sakay'],
    'eta_distance': ['About {distance} away', 'Mga {distance} ang layo'],
    'eta_walk': [
      '{minutes} min walk ({distance})',
      '{minutes} min lakad ({distance})',
    ],
    'eta_ride': [
      '{minutes} min ride ({distance})',
      '{minutes} min sakay ({distance})',
    ],
    'eta_disclaimer': [
      'Estimated time based on distance; traffic not included.',
      'Tinatayang oras batay sa distansya; hindi kasama ang trapiko.',
    ],
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
    'skip': ['Skip', 'Laktawan'],
    'next': ['Next', 'Susunod'],
    'get_started': ['Get started', 'Magsimula'],
    'visual_find_title': [
      'Find your next tambayan',
      'Hanapin ang susunod mong tambayan',
    ],
    'visual_find_body': [
      'See student-friendly places near PLV Annex and CPAG on the map, or browse them as a list.',
      'Tingnan ang mga lugar malapit sa PLV Annex at CPAG sa mapa o bilang listahan.',
    ],
    'visual_filter_title': ['Pick what fits you', 'Piliin ang bagay sa iyo'],
    'visual_filter_body': [
      'Filter by budget, Wi-Fi, outlets, aircon, and open status before you go.',
      'Mag-filter ayon sa budget, Wi-Fi, saksakan, aircon, at bukas na lugar bago pumunta.',
    ],
    'visual_go_title': ['Check it, then go', 'Tingnan, saka pumunta'],
    'visual_go_body': [
      'Open a place for hours, prices, and photos, then get directions in Google Maps. Mood check-in is only a preview for now.',
      'Buksan ang lugar para sa oras, presyo, at larawan, saka kumuha ng directions sa Google Maps. Preview pa lamang ang mood check-in.',
    ],
    'guide_intro': [
      'Learn the main features before you start exploring. Tap a topic below to jump straight to it.',
      'Alamin ang mga pangunahing feature bago magsimula. Pumili ng paksa sa ibaba para direktang pumunta roon.',
    ],
    'guide_contents': ['Guide contents', 'Mga bahagi ng gabay'],
    'guide_find_title': ['Find a tambayan', 'Maghanap ng tambayan'],
    'guide_find_body': [
      'Open Find a tambayan from Home to browse places near PLV Annex and CPAG. Scroll through the cards to compare places.',
      'Buksan ang Maghanap ng tambayan mula sa Home para makita ang mga lugar malapit sa PLV Annex at CPAG. I-scroll ang mga card para maghambing.',
    ],
    'guide_filter_title': ['Use filters', 'Gumamit ng mga filter'],
    'guide_filter_body': [
      'Use category, activity, budget, setting, and amenity filters to narrow the list. Clear filters when you want to see every place again.',
      'Gamitin ang category, aktibidad, budget, setting, at amenity filters para lumiit ang listahan. Burahin ang mga filter para makita ulit lahat ng lugar.',
    ],
    'guide_details_title': [
      'Open place details',
      'Buksan ang detalye ng lugar',
    ],
    'guide_details_body': [
      'Tap a place card to see its description, photos, amenities, prices, and opening hours. Check the date or source of supplied information when shown.',
      'I-tap ang card ng lugar para makita ang paglalarawan, larawan, amenities, presyo, at oras. Tingnan ang petsa o pinagmulan ng impormasyon kung ipinapakita.',
    ],
    'guide_map_title': [
      'View the map and directions',
      'Tingnan ang mapa at directions',
    ],
    'guide_map_body': [
      'View the map to compare verified place pins with PLV Annex and CPAG. Directions open in Google Maps only when a listing has a verified location.',
      'Tingnan ang mapa para ihambing ang mga verified na pin sa PLV Annex at CPAG. Bubukas ang directions sa Google Maps kapag verified ang lokasyon ng lugar.',
    ],
    'guide_info_title': [
      'Understand the information',
      'Unawain ang impormasyon',
    ],
    'guide_info_body': [
      'Listings, hours, prices, photos, and locations may need updates. Some features require internet access, and this demo does not access your device location.',
      'Maaaring kailangang i-update ang listings, oras, presyo, larawan, at lokasyon. Nangangailangan ng internet ang ilang feature, at hindi ina-access ng demo ang lokasyon ng iyong device.',
    ],
    'guide_start': ['Start exploring', 'Simulan ang pag-explore'],
    'close': ['Close', 'Isara'],
    'got_it': ['Got it', 'Naintindihan'],
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
