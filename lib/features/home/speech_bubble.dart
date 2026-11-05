import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Which hand-drawn bubble from the client mockup to paint.
///
/// The three shapes are not interchangeable: each has its own outline, tail
/// direction, text inset, and decoration. Keeping the geometry here means the
/// home screen and any future surface share one source of truth.
enum HomeBubbleKind { findTambayan, mood, more }

/// A pressable speech bubble with the mockup's hard underside.
///
/// The outline is rebuilt from the original vector path at the widget's own
/// size, so it stays crisp at any width instead of shipping a raster asset.
/// Height follows width, which is what keeps the hub balanced on small phones.
class SpeechBubble extends StatefulWidget {
  const SpeechBubble({
    required this.kind,
    required this.label,
    required this.fill,
    required this.under,
    required this.labelColor,
    required this.onTap,
    required this.width,
    required this.fontSize,
    this.semanticHint,
    super.key,
  });

  final HomeBubbleKind kind;
  final String label;
  final Color fill;
  final Color under;
  final Color labelColor;
  final VoidCallback onTap;
  final double width;
  final double fontSize;
  final String? semanticHint;

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  bool _pressed = false;

  _BubbleSpec get _spec => _specFor(widget.kind);

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final height = widget.width * spec.viewHeight / spec.viewWidth;
    final bodyHeight = widget.width * spec.bodyHeight / spec.viewWidth;
    final textLeft = widget.width * spec.textLeft / spec.viewWidth;

    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.semanticHint,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: Offset(0, _pressed ? 0.018 : 0),
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: SizedBox(
              width: widget.width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BubblePainter(
                        kind: widget.kind,
                        fill: widget.fill,
                        under: widget.under,
                      ),
                    ),
                  ),
                  Positioned(
                    left: textLeft,
                    top: 0,
                    width: widget.width - textLeft,
                    height: bodyHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w800,
                          color: widget.labelColor,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleSpec {
  const _BubbleSpec({
    required this.viewWidth,
    required this.viewHeight,
    required this.bodyHeight,
    required this.textLeft,
  });

  final double viewWidth;
  final double viewHeight;
  final double bodyHeight;
  final double textLeft;
}

const _findSpec = _BubbleSpec(
  viewWidth: 344,
  viewHeight: 166,
  bodyHeight: 130,
  textLeft: 38,
);
const _moodSpec = _BubbleSpec(
  viewWidth: 340,
  viewHeight: 166,
  bodyHeight: 130,
  textLeft: 40,
);
const _moreSpec = _BubbleSpec(
  viewWidth: 275,
  viewHeight: 140,
  bodyHeight: 104,
  textLeft: 92,
);

_BubbleSpec _specFor(HomeBubbleKind kind) => switch (kind) {
  HomeBubbleKind.findTambayan => _findSpec,
  HomeBubbleKind.mood => _moodSpec,
  HomeBubbleKind.more => _moreSpec,
};

Path _findTambayanPath(double sx, double sy) {
  return Path()
    ..moveTo(62 * sx, 8 * sy)
    ..cubicTo(150 * sx, 2 * sy, 250 * sx, 4 * sy, 298 * sx, 14 * sy)
    ..cubicTo(332 * sx, 22 * sy, 340 * sx, 52 * sy, 338 * sx, 84 * sy)
    ..cubicTo(336 * sx, 112 * sy, 304 * sx, 122 * sy, 276 * sx, 124 * sy)
    ..cubicTo(280 * sx, 136 * sy, 290 * sx, 146 * sy, 304 * sx, 152 * sy)
    ..cubicTo(282 * sx, 152 * sy, 260 * sx, 146 * sy, 244 * sx, 128 * sy)
    ..cubicTo(196 * sx, 130 * sy, 146 * sx, 128 * sy, 82 * sx, 124 * sy)
    ..cubicTo(34 * sx, 120 * sy, 6 * sx, 104 * sy, 6 * sx, 70 * sy)
    ..cubicTo(6 * sx, 32 * sy, 30 * sx, 12 * sy, 62 * sx, 8 * sy)
    ..close();
}

Path _moodPath(double sx, double sy) {
  return Path()
    ..moveTo(70 * sx, 8 * sy)
    ..cubicTo(150 * sx, 2 * sy, 250 * sx, 4 * sy, 296 * sx, 14 * sy)
    ..cubicTo(328 * sx, 22 * sy, 336 * sx, 56 * sy, 334 * sx, 88 * sy)
    ..cubicTo(332 * sx, 114 * sy, 304 * sx, 124 * sy, 270 * sx, 126 * sy)
    ..cubicTo(230 * sx, 128 * sy, 160 * sx, 128 * sy, 112 * sx, 126 * sy)
    ..cubicTo(100 * sx, 138 * sy, 92 * sx, 146 * sy, 78 * sx, 152 * sy)
    ..cubicTo(80 * sx, 142 * sy, 80 * sx, 134 * sy, 78 * sx, 124 * sy)
    ..cubicTo(34 * sx, 120 * sy, 8 * sx, 106 * sy, 6 * sx, 72 * sy)
    ..cubicTo(4 * sx, 34 * sy, 34 * sx, 12 * sy, 70 * sx, 8 * sy)
    ..close();
}

Path _morePath(double sx, double sy) {
  return Path()
    ..moveTo(50 * sx, 6 * sy)
    ..cubicTo(110 * sx, 0, 190 * sx, 2 * sy, 232 * sx, 10 * sy)
    ..cubicTo(266 * sx, 18 * sy, 272 * sx, 40 * sy, 270 * sx, 62 * sy)
    ..cubicTo(268 * sx, 86 * sy, 244 * sx, 96 * sy, 214 * sx, 98 * sy)
    ..cubicTo(216 * sx, 108 * sy, 222 * sx, 118 * sy, 232 * sx, 124 * sy)
    ..cubicTo(212 * sx, 124 * sy, 196 * sx, 118 * sy, 184 * sx, 102 * sy)
    ..cubicTo(140 * sx, 104 * sy, 100 * sx, 102 * sy, 62 * sx, 98 * sy)
    ..cubicTo(26 * sx, 94 * sy, 6 * sx, 80 * sy, 6 * sx, 52 * sy)
    ..cubicTo(6 * sx, 24 * sy, 24 * sx, 10 * sy, 50 * sx, 6 * sy)
    ..close();
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.kind, required this.fill, required this.under});

  final HomeBubbleKind kind;
  final Color fill;
  final Color under;

  @override
  void paint(Canvas canvas, Size size) {
    final spec = _specFor(kind);
    final sx = size.width / spec.viewWidth;
    final sy = size.height / spec.viewHeight;
    final path = switch (kind) {
      HomeBubbleKind.findTambayan => _findTambayanPath(sx, sy),
      HomeBubbleKind.mood => _moodPath(sx, sy),
      HomeBubbleKind.more => _morePath(sx, sy),
    };

    // The darker copy sits a few pixels lower, so the bubble reads as a pressed
    // cut-out rather than a flat card.
    canvas.drawPath(
      path.shift(Offset(0, 9 * sy)),
      Paint()..color = under,
    );
    canvas.drawPath(path, Paint()..color = fill);

    switch (kind) {
      case HomeBubbleKind.findTambayan:
        _paintPin(canvas, sx, sy);
      case HomeBubbleKind.mood:
        _paintFaces(canvas, sx, sy);
      case HomeBubbleKind.more:
        _paintInfo(canvas, sx, sy);
    }
  }

  void _paintPin(Canvas canvas, double sx, double sy) {
    canvas.save();
    canvas.translate(52 * sx, -32 * sy);
    canvas.scale(sx, sy);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 66), width: 56, height: 14),
      Paint()..color = AppColors.bubbleUnder,
    );
    final body = Path()
      ..moveTo(32, 56)
      ..cubicTo(32, 56, 12, 36, 12, 22)
      ..cubicTo(12, 10, 21, 2, 32, 2)
      ..cubicTo(43, 2, 52, 10, 52, 22)
      ..cubicTo(52, 36, 32, 56, 32, 56)
      ..close();
    canvas.drawPath(body, Paint()..color = AppColors.pin);
    canvas.drawCircle(const Offset(32, 22), 8, Paint()..color = Colors.white);
    canvas.restore();
  }

  void _paintFaces(Canvas canvas, double sx, double sy) {
    _drawFace(
      canvas,
      x: 226 * sx,
      y: 26 * sy,
      sx: sx,
      sy: sy,
      fill: AppColors.faceHappy,
      feature: AppColors.faceFeature,
      smiling: true,
    );
    _drawFace(
      canvas,
      x: 278 * sx,
      y: 33 * sy,
      sx: sx,
      sy: sy,
      fill: AppColors.faceSad,
      feature: AppColors.faceFeature,
      smiling: false,
    );
    _drawFace(
      canvas,
      x: 245 * sx,
      y: 66 * sy,
      sx: sx,
      sy: sy,
      fill: AppColors.faceGood,
      feature: AppColors.inkStrong,
      smiling: true,
    );
  }

  void _paintInfo(Canvas canvas, double sx, double sy) {
    canvas.save();
    canvas.translate(38 * sx, 32 * sy);
    canvas.scale(sx, sy);
    canvas.drawCircle(const Offset(20, 20), 19, Paint()..color = AppColors.infoBubble);
    canvas.drawCircle(const Offset(20, 11.5), 2.6, Paint()..color = AppColors.brand);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17.4, 16, 5.2, 14),
        const Radius.circular(2.6),
      ),
      Paint()..color = AppColors.brand,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.fill != fill ||
        oldDelegate.under != under;
  }
}

/// The three faces from the mockup, used as illustration outside the hub.
///
/// Kept next to the bubble painter so the mood screen and the home bubble
/// cannot drift into two different face styles.
class MoodFaces extends StatelessWidget {
  const MoodFaces({this.width = 150, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 84 / 96,
      child: CustomPaint(painter: _MoodFacesPainter()),
    );
  }
}

class _MoodFacesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 96;
    _drawFace(
      canvas,
      x: 0,
      y: 0,
      sx: s,
      sy: s,
      fill: AppColors.faceHappy,
      feature: AppColors.faceFeature,
      smiling: true,
    );
    _drawFace(
      canvas,
      x: 52 * s,
      y: 7 * s,
      sx: s,
      sy: s,
      fill: AppColors.faceSad,
      feature: AppColors.faceFeature,
      smiling: false,
    );
    _drawFace(
      canvas,
      x: 19 * s,
      y: 40 * s,
      sx: s,
      sy: s,
      fill: AppColors.faceGood,
      feature: AppColors.inkStrong,
      smiling: true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws one 44x44 face whose top-left corner is at [x], [y].
void _drawFace(
  Canvas canvas, {
  required double x,
  required double y,
  required double sx,
  required double sy,
  required Color fill,
  required Color feature,
  required bool smiling,
}) {
  canvas.save();
  canvas.translate(x, y);
  canvas.scale(sx, sy);
  canvas.drawCircle(const Offset(22, 22), 20, Paint()..color = fill);
  canvas.drawCircle(const Offset(15, 18), 1.8, Paint()..color = feature);
  canvas.drawCircle(const Offset(29, 18), 1.8, Paint()..color = feature);
  final mouth = Path();
  if (smiling) {
    mouth
      ..moveTo(14, 26)
      ..quadraticBezierTo(22, 34, 30, 26);
  } else {
    mouth
      ..moveTo(14, 31)
      ..quadraticBezierTo(22, 24, 30, 31);
  }
  canvas.drawPath(
    mouth,
    Paint()
      ..color = feature
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round,
  );
  canvas.restore();
}
