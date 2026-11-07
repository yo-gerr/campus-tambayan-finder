import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Canonical links used by the map and credits screen.
///
/// Keeping the URLs here stops attribution text and its destination from
/// drifting apart in different screens.
abstract final class AppLinks {
  static final openStreetMapCopyright = Uri.parse(
    'https://www.openstreetmap.org/copyright',
  );
  static final openStreetMapFixTheMap = Uri.parse(
    'https://www.openstreetmap.org/fixthemap',
  );
  static final openFreeMap = Uri.parse('https://openfreemap.org/');
  static final openMapTiles = Uri.parse('https://www.openmaptiles.org/');
}

/// Opens [url] outside the app and reports a localized failure when no handler
/// is available.
Future<void> openExternalLink(
  BuildContext context,
  Uri url, {
  String? failureMessage,
}) async {
  var opened = false;
  try {
    opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint('Could not open $url: $error');
  }

  if (!opened && context.mounted) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(failureMessage ?? 'Could not open the link.')),
    );
  }
}
