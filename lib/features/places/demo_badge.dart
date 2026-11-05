import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Marks a listing that is sample data rather than a verified real place.
///
/// The card and the detail sheet share this single presentation so they cannot
/// drift apart. It is a compact pill so it can sit beside the status pill.
class DemoBadge extends StatelessWidget {
  const DemoBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.demoContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onDemoContainer,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
