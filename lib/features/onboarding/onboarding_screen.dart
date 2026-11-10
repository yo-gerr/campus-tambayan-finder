import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.copy, super.key});

  final AppCopy copy;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  final _scrollController = ScrollController();

  AppCopy get copy => widget.copy;

  void _jumpToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(copy.get('guide_title')),
        leading: IconButton(
          key: const Key('onboarding-close'),
          tooltip: copy.get('close'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            layout.contentInset,
            8,
            layout.contentInset,
            28,
          ),
          children: [
            Text(
              copy.get('guide_intro'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            _GuideContents(copy: copy, onSelected: _jumpToSection),
            const SizedBox(height: 20),
            _GuideSection(
              key: _sectionKeys[0],
              icon: Icons.search_rounded,
              title: copy.get('guide_find_title'),
              body: copy.get('guide_find_body'),
              color: AppColors.bubble,
            ),
            _GuideSection(
              key: _sectionKeys[1],
              icon: Icons.tune_rounded,
              title: copy.get('guide_filter_title'),
              body: copy.get('guide_filter_body'),
              color: AppColors.sky,
            ),
            _GuideSection(
              key: _sectionKeys[2],
              icon: Icons.storefront_rounded,
              title: copy.get('guide_details_title'),
              body: copy.get('guide_details_body'),
              color: AppColors.demoContainer,
            ),
            _GuideSection(
              key: _sectionKeys[3],
              icon: Icons.map_outlined,
              title: copy.get('guide_map_title'),
              body: copy.get('guide_map_body'),
              color: AppColors.bubble,
            ),
            _GuideSection(
              key: _sectionKeys[4],
              icon: Icons.mood_rounded,
              title: copy.get('guide_mood_title'),
              body: copy.get('guide_mood_body'),
              color: AppColors.sky,
            ),
            _GuideSection(
              key: _sectionKeys[5],
              icon: Icons.menu_rounded,
              title: copy.get('guide_info_title'),
              body: copy.get('guide_info_body'),
              color: AppColors.demoContainer,
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('onboarding-start'),
              onPressed: () => Navigator.pop(context),
              child: Text(copy.get('guide_start')),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideContents extends StatelessWidget {
  const _GuideContents({required this.copy, required this.onSelected});

  final AppCopy copy;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = [
      copy.get('guide_find_title'),
      copy.get('guide_filter_title'),
      copy.get('guide_details_title'),
      copy.get('guide_map_title'),
      copy.get('guide_mood_title'),
      copy.get('guide_info_title'),
    ];

    return Card(
      key: const Key('onboarding-contents'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.get('guide_contents'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (var index = 0; index < entries.length; index++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.bubble,
                  child: Text('${index + 1}'),
                ),
                title: Text(entries[index]),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => onSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.inkStrong),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
