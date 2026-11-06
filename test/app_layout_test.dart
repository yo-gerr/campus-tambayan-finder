import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_layout.dart';

void main() {
  group('AppLayout window bands', () {
    test('classifies compact, regular, and expanded widths', () {
      expect(
        const AppLayout(width: 359, height: 800).windowSize,
        AppWindowSize.compact,
      );
      expect(
        const AppLayout(width: 360, height: 800).windowSize,
        AppWindowSize.regular,
      );
      expect(
        const AppLayout(width: 599, height: 800).windowSize,
        AppWindowSize.regular,
      );
      expect(
        const AppLayout(width: 600, height: 800).windowSize,
        AppWindowSize.expanded,
      );
    });

    test('uses tighter page margins only in the compact band', () {
      expect(const AppLayout(width: 320, height: 640).pageMargin, 16);
      expect(const AppLayout(width: 360, height: 800).pageMargin, 24);
      expect(const AppLayout(width: 800, height: 900).pageMargin, 24);
    });

    test('caps readable content width with a centered gutter', () {
      expect(const AppLayout(width: 320, height: 640).contentInset, 16);
      expect(const AppLayout(width: 390, height: 844).contentInset, 24);
      expect(const AppLayout(width: 600, height: 900).contentInset, 24);
      expect(const AppLayout(width: 800, height: 900).contentInset, 100);
      expect(const AppLayout(width: 1200, height: 900).contentInset, 300);
    });
  });

  group('AppLayout sizing', () {
    test('caps the drawer while keeping most of a narrow screen', () {
      expect(
        const AppLayout(width: 320, height: 640).drawerWidth,
        closeTo(268.8, 0.001),
      );
      expect(const AppLayout(width: 390, height: 844).drawerWidth, 320);
      expect(const AppLayout(width: 800, height: 900).drawerWidth, 320);
    });

    test('gives sheets more height for large text', () {
      final regular = const AppLayout(width: 390, height: 800);
      final large = const AppLayout(width: 390, height: 800, textScale: 1.31);

      expect(regular.usesLargeText, isFalse);
      expect(large.usesLargeText, isTrue);
      expect(regular.sheetHeight(0.85), 680);
      expect(large.sheetHeight(0.85), closeTo(736, 0.001));
      expect(large.sheetHeight(0.95), closeTo(760, 0.001));
    });

    test('treats the large text threshold as exclusive', () {
      expect(
        const AppLayout(width: 390, height: 800, textScale: 1.3).usesLargeText,
        isFalse,
      );
      expect(
        const AppLayout(width: 390, height: 800, textScale: 1.5).usesLargeText,
        isTrue,
      );
    });
  });
}
