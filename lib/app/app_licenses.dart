import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the bundled font licenses to Flutter's license registry.
///
/// Package licenses are collected automatically from the generated `NOTICES`
/// file, but font files declared in `pubspec.yaml` are not. The OFL requires
/// the copyright notice and license text to accompany the font, so register
/// both texts for the in-app license page.
void registerBundledLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Fredoka',
    ], await rootBundle.loadString('assets/fonts/OFL-fredoka.txt'));
    yield LicenseEntryWithLineBreaks(const [
      'Nunito',
    ], await rootBundle.loadString('assets/fonts/OFL-nunito.txt'));
  });
}
