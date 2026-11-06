import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';

/// Home-only header: the Kamus Tambay wordmark, emblem in a gold ring, and
/// menu shortcut.
class BrandHeader extends StatelessWidget {
  const BrandHeader({required this.copy, required this.onMenu, super.key});

  final AppCopy copy;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return AppResponsiveBuilder(
      builder: (context, layout) {
        final width = layout.width;
        // Give the wordmark the largest share of the header. The smaller
        // emblem stays visually attached to it, while the wider gap before
        // the hamburger preserves the menu as a separate utility action.
        final ring = (width * 0.2).clamp(60.0, 76.0);
        const wordmarkHeight = 102.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            layout.pageMargin,
            14,
            layout.isCompact ? 12 : 16,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/brand/wordmark.png',
                    height: wordmarkHeight,
                    fit: BoxFit.contain,
                    semanticLabel: 'Kamus Tambay',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _LogoRing(size: ring),
              const SizedBox(width: AppSpacing.unit * 2),
              _MenuButton(copy: copy, onPressed: onMenu),
            ],
          ),
        );
      },
    );
  }
}

class _LogoRing extends StatelessWidget {
  const _LogoRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.04),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.inkStrong,
          border: Border.all(color: AppColors.accent, width: size * 0.055),
          boxShadow: const [
            BoxShadow(
              color: AppColors.surfaceUnder,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/splash.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.copy, required this.onPressed});

  final AppCopy copy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: copy.get('menu'),
      child: Tooltip(
        message: copy.get('menu'),
        child: Container(
          width: AppSpacing.minTarget,
          height: AppSpacing.minTarget,
          decoration: const BoxDecoration(
            color: AppColors.raised,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.surfaceUnder,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const Key('open-menu'),
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const Icon(
                Icons.menu_rounded,
                size: 26,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
