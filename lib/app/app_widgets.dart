import 'package:flutter/material.dart';

/// The grab handle shared by the modal bottom sheets.
///
/// It lives here rather than in each sheet so the detail and filter sheets
/// cannot drift to different handle colors again.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
