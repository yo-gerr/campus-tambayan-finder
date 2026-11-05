import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';

Future<void> showIntroDialog(BuildContext context, AppCopy copy) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: AppColors.bubble,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.explore_outlined,
          color: AppColors.inkStrong,
        ),
      ),
      title: Text(copy.get('guide_title'), textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(copy.get('guide_body'), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            copy.get('guide_map'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedInk,
                ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('dismiss-intro'),
            onPressed: () => Navigator.pop(context),
            child: Text(copy.get('got_it')),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    ),
  );
}
