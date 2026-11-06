import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';

/// The one control that returns a spoke screen to the hub.
///
/// The home screen is the hub of the navigation, so every other screen carries
/// this instead of a bottom bar. It is a 48 dp target with a navy utility icon
/// and the same hard underside as the bubble cards.
class HomeButton extends StatelessWidget {
  const HomeButton({required this.copy, required this.onPressed, super.key});

  final AppCopy copy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: copy.get('home'),
      child: Tooltip(
        message: copy.get('home'),
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
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const Icon(
                Icons.home_rounded,
                size: 24,
                color: AppColors.inkStrong,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cream header used by every spoke screen: Home control, title, actions.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.copy,
    required this.onHome,
    this.actions = const [],
    super.key,
  });

  final String title;
  final AppCopy copy;
  final VoidCallback onHome;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Row(
          children: [
            HomeButton(
              key: const Key('home-button'),
              copy: copy,
              onPressed: onHome,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (actions.isNotEmpty) ...[const SizedBox(width: 8), ...actions],
          ],
        ),
      ),
    );
  }
}

/// Cream header with the curved sky content band shared by spoke screens.
///
/// The band is clipped rather than painted under an opaque child, so lists
/// scroll beneath its curved edge instead of squaring it off.
class BandScaffold extends StatelessWidget {
  const BandScaffold({
    required this.header,
    required this.child,
    this.topPadding = 46,
    super.key,
  });

  final Widget header;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        Expanded(
          child: ClipPath(
            clipper: const BandClipper(),
            child: ColoredBox(
              color: AppColors.sky,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BandClipper extends CustomClipper<Path> {
  const BandClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 14)
      ..quadraticBezierTo(size.width * 0.5, 44, size.width, 16)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
