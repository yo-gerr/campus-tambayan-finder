import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Layout bands used by the app.
///
/// These are deliberately coarse: the product targets phones, so most screens
/// stay fluid and only switch behaviour where the available width or text
/// scale changes what fits.
enum AppWindowSize { compact, regular, expanded }

/// Shared responsive thresholds.
abstract final class AppBreakpoints {
  /// Below this width, pages use tighter margins.
  static const double compact = 360;

  /// At or above this width, content is centered at a readable maximum width.
  static const double expanded = 600;

  /// Above this text scale, rows that would become cramped stack instead.
  static const double largeText = 1.3;

  /// The sidebar stops growing on wider screens.
  static const double drawerMaxWidth = 320;
}

/// Shared spacing tokens.
///
/// Screens should consume these instead of repeating magic numbers for page
/// margins and touch targets. Component-specific padding can stay local.
abstract final class AppSpacing {
  static const double unit = 8;
  static const double page = 24;
  static const double compactPage = 16;
  static const double minTarget = 48;
  static const double maxContentWidth = 600;
}

/// A snapshot of the current width, height, and text scale.
///
/// Use [AppLayout.of] for page-level decisions and
/// [AppLayout.fromConstraints] inside a [LayoutBuilder] when the local box is
/// smaller than the screen (for example, the area below a header).
@immutable
class AppLayout {
  const AppLayout({
    required this.width,
    required this.height,
    this.textScale = 1,
  });

  factory AppLayout.of(BuildContext context) {
    final media = MediaQuery.of(context);
    return AppLayout(
      width: media.size.width,
      height: media.size.height,
      textScale: media.textScaler.scale(1),
    );
  }

  factory AppLayout.fromConstraints(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final media = MediaQuery.of(context);
    return AppLayout(
      width: constraints.hasBoundedWidth
          ? constraints.maxWidth
          : media.size.width,
      height: constraints.hasBoundedHeight
          ? constraints.maxHeight
          : media.size.height,
      textScale: media.textScaler.scale(1),
    );
  }

  final double width;
  final double height;
  final double textScale;

  AppWindowSize get windowSize {
    if (isCompact) return AppWindowSize.compact;
    if (isExpanded) return AppWindowSize.expanded;
    return AppWindowSize.regular;
  }

  bool get isCompact => width < AppBreakpoints.compact;

  bool get isExpanded => width >= AppBreakpoints.expanded;

  bool get usesLargeText => textScale > AppBreakpoints.largeText;

  /// Horizontal page margin for the current band.
  double get pageMargin => isCompact ? AppSpacing.compactPage : AppSpacing.page;

  /// Horizontal inset that both pads the page and caps readable content width.
  ///
  /// On wide screens the extra space becomes a centered gutter rather than
  /// stretching text and cards across the whole display.
  double get contentInset =>
      math.max(pageMargin, (width - AppSpacing.maxContentWidth) / 2);

  /// Sidebar width: most of a phone, capped for tablets and the web preview.
  double get drawerWidth =>
      math.min(width * 0.84, AppBreakpoints.drawerMaxWidth);

  /// Preferred modal-sheet height, giving large text more room when possible.
  double sheetHeight(double fraction) {
    final adjusted = usesLargeText ? math.min(0.95, fraction + 0.07) : fraction;
    return height * adjusted;
  }
}

/// Rebuilds with an [AppLayout] derived from the local constraints.
///
/// This keeps the width/height/text-scale plumbing in one place for screens
/// whose layout depends on the space they actually receive.
class AppResponsiveBuilder extends StatelessWidget {
  const AppResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, AppLayout layout) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, AppLayout.fromConstraints(context, constraints)),
    );
  }
}
