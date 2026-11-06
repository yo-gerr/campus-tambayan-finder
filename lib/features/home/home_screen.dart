import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import 'brand_header.dart';
import 'speech_bubble.dart';

/// The hub of the app.
///
/// Three speech bubbles lead to discovery, the (still informational) mood
/// check-in, and the navigation drawer. The layout follows the client mockup:
/// cream header, curved sky band, and the student figure in the lower-right
/// corner. Sizes are derived from the screen width so the hub holds together
/// on small phones, and the bubble column scrolls when the height or text
/// scale needs it.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.copy,
    required this.onFindTambayan,
    required this.onMood,
    required this.onMenu,
    super.key,
  });

  final AppCopy copy;
  final VoidCallback onFindTambayan;
  final VoidCallback onMood;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppResponsiveBuilder(
        builder: (context, layout) {
          final width = layout.width;
          final height = layout.height;
          // Lower the whole sky scene slightly, leaving the enlarged brand
          // group clear at the top while retaining the original bubble order.
          final bandTop = (height * 0.175 + 16).clamp(134.0, 180.0);
          final footerHeight = (height * 0.085).clamp(30.0, 72.0);
          final bubbleFont = (width * 0.0667).clamp(20.0, 30.0);
          final sideInset = width * 0.056;
          final gap = width * 0.03;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _HomeBandPainter(
                    top: bandTop,
                    bottom: height - footerHeight,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(
                    color: AppColors.background,
                    child: BrandHeader(copy: copy, onMenu: onMenu),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: width * 0.09 + 16,
                        bottom: gap,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: sideInset),
                            child: SpeechBubble(
                              key: const Key('home-find-tambayan'),
                              kind: HomeBubbleKind.findTambayan,
                              label: copy.get('home_find'),
                              fill: AppColors.bubble,
                              under: AppColors.bubbleUnder,
                              labelColor: AppColors.ink,
                              width: width * 0.882,
                              fontSize: bubbleFont,
                              onTap: onFindTambayan,
                            ),
                          ),
                          SizedBox(height: gap),
                          Padding(
                            padding: EdgeInsets.only(left: width * 0.067),
                            child: SpeechBubble(
                              key: const Key('home-mood'),
                              kind: HomeBubbleKind.mood,
                              label: copy.get('home_mood'),
                              fill: AppColors.surface,
                              under: AppColors.surfaceUnder,
                              labelColor: AppColors.ink,
                              width: width * 0.872,
                              fontSize: bubbleFont * 0.92,
                              onTap: onMood,
                            ),
                          ),
                          SizedBox(height: gap),
                          Padding(
                            padding: EdgeInsets.only(left: width * 0.054),
                            child: SpeechBubble(
                              key: const Key('home-more'),
                              kind: HomeBubbleKind.more,
                              label: copy.get('home_more'),
                              fill: AppColors.brand,
                              under: AppColors.primary,
                              labelColor: AppColors.onPrimary,
                              width: width * 0.705,
                              fontSize: bubbleFont,
                              onTap: onMenu,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: footerHeight,
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.footerPill,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (height >= 700)
                Positioned(
                  right: width * 0.05,
                  bottom: footerHeight * 0.95,
                  width: width * 0.131,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Image.asset(
                        'assets/brand/student_male.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeBandPainter extends CustomPainter {
  _HomeBandPainter({required this.top, required this.bottom});

  final double top;
  final double bottom;

  @override
  void paint(Canvas canvas, Size size) {
    // Two downward bows: the wide one under the header and the shallower one
    // above the footer, matching the mockup's 148/192/150 and 706/724/742.
    final path = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(
        size.width * 0.5,
        top + size.height * 0.103,
        size.width,
        top + size.height * 0.002,
      )
      ..lineTo(size.width, bottom)
      ..quadraticBezierTo(
        size.width * 0.5,
        bottom + size.height * 0.021,
        0,
        bottom + size.height * 0.043,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.sky);
  }

  @override
  bool shouldRepaint(_HomeBandPainter oldDelegate) {
    return oldDelegate.top != top || oldDelegate.bottom != bottom;
  }
}
