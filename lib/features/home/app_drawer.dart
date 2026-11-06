import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_section.dart';
import '../../app/app_theme.dart';

/// The app's single navigation drawer.
///
/// It replaces the old More page: links, language, and the version note all
/// live here. Information pages are placeholders until the client supplies
/// approved copy, so the drawer never presents invented legal or mission text.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.copy,
    required this.section,
    required this.onClose,
    required this.onHome,
    required this.onSectionSelected,
    required this.onShowInstructions,
    required this.onLanguageChanged,
    super.key,
  });

  final AppCopy copy;
  final AppSection section;
  final VoidCallback onClose;
  final VoidCallback onHome;
  final ValueChanged<AppSection> onSectionSelected;
  final VoidCallback onShowInstructions;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);

    return Drawer(
      width: layout.drawerWidth,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(layout.pageMargin, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/brand/wordmark.png',
                      height: 58,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      semanticLabel: 'Kamus Tambay',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const Key('drawer-close'),
                    tooltip: copy.get('close_menu'),
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.inkStrong,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: [
                  _NavItem(
                    key: const Key('drawer-home'),
                    icon: Icons.home_rounded,
                    label: copy.get('home'),
                    selected: section == AppSection.home,
                    onTap: onHome,
                  ),
                  _NavItem(
                    key: const Key('drawer-instructions'),
                    icon: Icons.menu_book_rounded,
                    label: copy.get('instructions'),
                    onTap: onShowInstructions,
                  ),
                  _NavItem(
                    key: const Key('drawer-vision'),
                    icon: Icons.flag_outlined,
                    label: copy.get('vision_mission'),
                    selected: section == AppSection.visionMission,
                    onTap: () => onSectionSelected(AppSection.visionMission),
                  ),
                  _NavItem(
                    key: const Key('drawer-privacy'),
                    icon: Icons.lock_outline,
                    label: copy.get('privacy'),
                    selected: section == AppSection.privacy,
                    onTap: () => onSectionSelected(AppSection.privacy),
                  ),
                  _NavItem(
                    key: const Key('drawer-terms'),
                    icon: Icons.description_outlined,
                    label: copy.get('terms'),
                    selected: section == AppSection.terms,
                    onTap: () => onSectionSelected(AppSection.terms),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.get('language'),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.mutedInk),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AppLanguage>(
                            key: const Key('drawer-language'),
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(
                                value: AppLanguage.english,
                                label: Text(
                                  key: const Key('drawer-language-english'),
                                  copy.get('language_english'),
                                ),
                              ),
                              ButtonSegment(
                                value: AppLanguage.tagalog,
                                label: Text(
                                  key: const Key('drawer-language-filipino'),
                                  copy.get('language_filipino'),
                                ),
                              ),
                            ],
                            selected: {copy.language},
                            onSelectionChanged: (selection) =>
                                onLanguageChanged(selection.first),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                layout.pageMargin,
                8,
                layout.pageMargin,
                16,
              ),
              child: Text(
                copy.get('app_version'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 12, color: AppColors.mutedInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.bubble : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            selected: selected,
            button: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: selected ? AppColors.inkStrong : AppColors.ink,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: selected
                                  ? AppColors.inkStrong
                                  : AppColors.ink,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
