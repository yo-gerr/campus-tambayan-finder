import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import '../home/app_chrome.dart';
import '../home/speech_bubble.dart';

/// Informational destination for the mood bubble.
///
/// The mood check-in itself is still an open privacy decision, so this screen
/// explains the plan without asking for a mood, a nickname, or anything else
/// that would need a consent and retention decision first.
class MoodInfoScreen extends StatelessWidget {
  const MoodInfoScreen({
    required this.copy,
    required this.onHome,
    super.key,
  });

  final AppCopy copy;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return BandScaffold(
      header: SectionHeader(
        title: copy.get('mood_title'),
        copy: copy,
        onHome: onHome,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.all(Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surfaceUnder,
                  offset: Offset(0, kCardUnderOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                const MoodFaces(width: 168),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.demoContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    copy.get('mood_soon'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onDemoContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(copy.get('mood_body'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.bubble,
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.inkStrong,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    copy.get('mood_privacy'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            key: const Key('mood-back-home'),
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded),
            label: Text(copy.get('mood_cta')),
          ),
        ],
      ),
    );
  }
}
