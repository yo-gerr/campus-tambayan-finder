import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';

class VisualOnboardingScreen extends StatefulWidget {
  const VisualOnboardingScreen({
    required this.copy,
    required this.onCompleted,
    super.key,
  });

  final AppCopy copy;
  final VoidCallback onCompleted;

  @override
  State<VisualOnboardingScreen> createState() => _VisualOnboardingScreenState();
}

class _VisualOnboardingScreenState extends State<VisualOnboardingScreen> {
  int _page = 0;

  void _complete() {
    widget.onCompleted();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _VisualPage(
        icon: Icons.location_on_rounded,
        title: widget.copy.get('visual_find_title'),
        body: widget.copy.get('visual_find_body'),
        illustration: const _MapIllustration(),
      ),
      _VisualPage(
        icon: Icons.tune_rounded,
        title: widget.copy.get('visual_filter_title'),
        body: widget.copy.get('visual_filter_body'),
        illustration: const _FilterIllustration(),
      ),
      _VisualPage(
        icon: Icons.directions_rounded,
        title: widget.copy.get('visual_go_title'),
        body: widget.copy.get('visual_go_body'),
        illustration: const _DetailsIllustration(),
      ),
    ];

    final isLast = _page == pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('visual-onboarding-skip'),
                onPressed: _complete,
                child: Text(widget.copy.get('skip')),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Padding(
                  key: ValueKey(_page),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: pages[_page],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < pages.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? AppColors.brand
                          : AppColors.surfaceUnder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      key: const Key('visual-onboarding-back'),
                      onPressed: () => setState(() => _page--),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: Key(
                        isLast
                            ? 'visual-onboarding-start'
                            : 'visual-onboarding-next',
                      ),
                      onPressed: isLast
                          ? _complete
                          : () => setState(() => _page++),
                      child: Text(
                        widget.copy.get(isLast ? 'get_started' : 'next'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualPage extends StatelessWidget {
  const _VisualPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.illustration,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 292,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(color: AppColors.surfaceUnder, offset: Offset(0, 8)),
            ],
          ),
          child: illustration,
        ),
        const SizedBox(height: 42),
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _MapIllustration extends StatelessWidget {
  const _MapIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final offset in const [
          Offset(32, 58),
          Offset(104, 190),
          Offset(254, 150),
        ])
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: const Icon(
              Icons.location_on_rounded,
              size: 34,
              color: AppColors.brand,
            ),
          ),
        const Positioned(
          left: 80,
          top: 112,
          child: _CampusPin(label: 'PLV Annex'),
        ),
        const Positioned(left: 205, top: 174, child: _CampusPin(label: 'CPAG')),
      ],
    );
  }
}

class _CampusPin extends StatelessWidget {
  const _CampusPin({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 42,
          color: AppColors.inkStrong,
        ),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _FilterIllustration extends StatelessWidget {
  const _FilterIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          for (final label in ['Free Wi-Fi', 'Outlets', 'Aircon', 'Open now'])
            Chip(
              label: Text(label),
              backgroundColor: AppColors.bubble,
              side: BorderSide.none,
            ),
          Card(
            margin: const EdgeInsets.only(top: 18),
            child: SizedBox(
              width: double.infinity,
              height: 108,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sample Study Corner\n₱0–₱120 · Free Wi-Fi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsIllustration extends StatelessWidget {
  const _DetailsIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sample Kape Stop',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text('Hours   9 AM–9 PM'),
              const SizedBox(height: 8),
              Text('Estimated spend   ₱80–₱250'),
              const Spacer(),
              const SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: null, child: Text('Directions')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
