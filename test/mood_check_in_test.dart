import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/features/mood/mood_check_in.dart';
import 'package:campus_tambayan_finder/features/mood/mood_check_in_repository.dart';
import 'package:campus_tambayan_finder/features/mood/mood_info_screen.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';

class _FakeMoodRepository implements MoodCheckInRepository {
  final List<MoodCheckIn> submissions = [];

  @override
  Future<void> submitCheckIn(MoodCheckIn checkIn) async {
    submissions.add(checkIn);
  }

  @override
  Future<Map<String, int>> getAggregateMoods(String placeId) async {
    final counts = <String, int>{};
    for (final s in submissions.where((item) => item.placeId == placeId)) {
      counts[s.mood] = (counts[s.mood] ?? 0) + 1;
    }
    return counts;
  }
}

void main() {
  const samplePlace = Place(
    id: 'sample-study-corner',
    name: 'Sample Study Corner',
    category: 'tambayan',
    area: 'Demo location near PLV Annex',
    descriptionEn: 'A fictional quiet-place example.',
    descriptionTl: 'Kathang-halimbawang tahimik na lugar.',
    priceMin: 0,
    priceMax: 120,
    setting: 'indoor',
    amenities: [],
    activities: [],
  );

  test('MoodCheckIn serializes to and from JSON', () {
    const checkIn = MoodCheckIn(
      placeId: 'sample-study-corner',
      mood: 'happy',
      nickname: 'Alex',
    );
    final json = checkIn.toJson();
    expect(json['place_id'], 'sample-study-corner');
    expect(json['mood'], 'happy');
    expect(json['nickname'], 'Alex');

    final restored = MoodCheckIn.fromJson(json);
    expect(restored.placeId, 'sample-study-corner');
    expect(restored.mood, 'happy');
    expect(restored.nickname, 'Alex');
  });

  testWidgets('walks through mood check-in steps and submits', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeMoodRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodInfoScreen(
            copy: const AppCopy(AppLanguage.english),
            onHome: () {},
            onMenu: () {},
            places: const [samplePlace],
            repository: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Intro step
    expect(
      find.text(const AppCopy(AppLanguage.english).get('mood_preview_title')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('mood-start-checkin')),
      100,
    );
    await tester.tap(find.byKey(const Key('mood-start-checkin')));
    await tester.pumpAndSettle();

    // Consent step
    expect(find.text('Before you continue'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mood-consent')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mood-continue-button')));
    await tester.pumpAndSettle();

    // Mood selection step
    expect(find.text('Where were you?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mood-happy')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mood-continue-button')));
    await tester.pumpAndSettle();

    // Review & submit step
    expect(find.text('Review your response'), findsOneWidget);
    expect(find.text('Happy'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mood-continue-button')));
    await tester.pumpAndSettle();

    // Complete step
    expect(find.text('Check-in submitted!'), findsOneWidget);
    expect(repo.submissions.length, 1);
    expect(repo.submissions.first.placeId, 'sample-study-corner');
    expect(repo.submissions.first.mood, 'happy');
  });
}
