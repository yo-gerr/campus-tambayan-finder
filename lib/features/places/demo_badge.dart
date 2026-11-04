import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Marks a listing that is sample data rather than a verified real place.
///
/// The card and the detail sheet previously each built their own version and
/// had drifted apart, so both now use this single presentation.
class DemoBadge extends StatelessWidget {
  const DemoBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.terracotta,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
