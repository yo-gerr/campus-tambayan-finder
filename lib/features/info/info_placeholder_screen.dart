import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../home/app_chrome.dart';

/// Shared layout for an information page whose copy is not approved yet.
///
/// The labelled placeholder keeps the destination navigable without inventing
/// vision, privacy, or legal text. Replace [message] with client-approved copy
/// when it arrives.
class InfoPlaceholderScreen extends StatelessWidget {
  const InfoPlaceholderScreen({
    required this.title,
    required this.message,
    required this.icon,
    required this.copy,
    required this.onMenu,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final AppCopy copy;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    return BandScaffold(
      header: SectionHeader(title: title, copy: copy, onMenu: onMenu),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          layout.contentInset,
          16,
          layout.contentInset,
          32,
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.bubble,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: AppColors.inkStrong),
                ),
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
                    copy.get('pending_review'),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.onDemoContainer),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
