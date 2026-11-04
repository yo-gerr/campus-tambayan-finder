import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';

/// Filled pill for a listing's live open/closed state.
///
/// Green for open, muted grey for closed. Red was rejected on purpose: it
/// reads as an error or a permanent closure rather than "shut for the night".
/// The card and the detail sheet share this widget so the two cannot drift.
class OpenStatusBadge extends StatelessWidget {
  const OpenStatusBadge({required this.open, required this.copy, super.key});

  final bool open;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: open ? AppColors.primary : AppColors.outline,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        copy.get(open ? 'open_now' : 'closed_now'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: open ? AppColors.onPrimary : AppColors.mutedInk,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
