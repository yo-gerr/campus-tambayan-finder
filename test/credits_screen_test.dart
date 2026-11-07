import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/app/app_licenses.dart';
import 'package:campus_tambayan_finder/features/info/credits_screen.dart';

void main() {
  testWidgets('lists credits and opens the license page', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreditsScreen(
            copy: const AppCopy(AppLanguage.english),
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('OpenStreetMap contributors'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('no LICENSE file'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('no LICENSE file'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('credits-licenses')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('credits-licenses')));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('uses Filipino section labels', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreditsScreen(
            copy: const AppCopy(AppLanguage.tagalog),
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mga kredito'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.textContaining('Datos ng mapa'), findsOneWidget);
  });

  testWidgets('registers the bundled font licenses', (tester) async {
    registerBundledLicenses();

    final licenses = await LicenseRegistry.licenses.toList();
    final packages = licenses.expand((license) => license.packages).toSet();

    expect(packages, containsAll(<String>['Fredoka', 'Nunito']));
  });
}
