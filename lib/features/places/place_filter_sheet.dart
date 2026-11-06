import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../../app/app_widgets.dart';
import 'place_categories.dart';
import 'place_filters.dart';

/// Preset budget limits in pesos, shown as chips for consistency with the
/// other filter groups. "Any budget" is the separate null state, so no preset
/// acts as a hidden ceiling.
const _budgetChoices = <int>[50, 100, 150, 200, 300, 500];

Future<PlaceFilters?> showPlaceFilterSheet({
  required BuildContext context,
  required AppCopy copy,
  required PlaceFilters initialFilters,
}) {
  return showModalBottomSheet<PlaceFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        _PlaceFilterSheet(copy: copy, initialFilters: initialFilters),
  );
}

class _PlaceFilterSheet extends StatefulWidget {
  const _PlaceFilterSheet({required this.copy, required this.initialFilters});

  final AppCopy copy;
  final PlaceFilters initialFilters;

  @override
  State<_PlaceFilterSheet> createState() => _PlaceFilterSheetState();
}

class _PlaceFilterSheetState extends State<_PlaceFilterSheet> {
  late String? _category = widget.initialFilters.category;
  late int? _maxBudget = widget.initialFilters.maxBudget;
  late Set<String> _amenities = {...widget.initialFilters.amenities};
  late String? _setting = widget.initialFilters.setting;
  late String? _activity = widget.initialFilters.activity;
  late bool _openNow = widget.initialFilters.openNow;

  AppCopy get copy => widget.copy;

  void _reset() {
    setState(() {
      _category = null;
      _maxBudget = null;
      _amenities = {};
      _setting = null;
      _activity = null;
      _openNow = false;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      PlaceFilters(
        category: _category,
        maxBudget: _maxBudget,
        amenities: _amenities,
        setting: _setting,
        activity: _activity,
        openNow: _openNow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    return SizedBox(
      key: const Key('place-filter-sheet'),
      height: layout.sheetHeight(0.9),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 4),
            child: SheetHandle(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    copy.get('filters'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: copy.get('close'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const Key('filter-options'),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _sectionTitle(copy.get('category')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _choice(
                      key: const Key('category-any-filter'),
                      label: copy.get('all'),
                      selected: _category == null,
                      onSelected: () => setState(() => _category = null),
                    ),
                    for (final category in PlaceCategory.values)
                      _choice(
                        key: Key('category-${category.key}-filter'),
                        label: category.label(copy.isTagalog),
                        selected: _category == category.key,
                        onSelected: () =>
                            setState(() => _category = category.key),
                      ),
                  ],
                ),
                _sectionTitle(copy.get('budget')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _choice(
                      key: const Key('budget-any-filter'),
                      label: copy.get('any_price'),
                      selected: _maxBudget == null,
                      onSelected: () => setState(() => _maxBudget = null),
                    ),
                    for (final budget in _budgetChoices)
                      _choice(
                        key: Key('budget-$budget-filter'),
                        label: '₱$budget',
                        selected: _maxBudget == budget,
                        onSelected: () => setState(() => _maxBudget = budget),
                      ),
                  ],
                ),
                _sectionTitle(copy.get('availability')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _choice(
                      key: const Key('open-now-filter'),
                      label: copy.get('open_now'),
                      selected: _openNow,
                      onSelected: () => setState(() => _openNow = !_openNow),
                    ),
                  ],
                ),
                _sectionTitle(copy.get('amenities')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final amenity in const [
                      'wifi',
                      'aircon',
                      'outlets',
                      'capacity',
                    ])
                      _choice(
                        label: copy.get(amenity),
                        selected: _amenities.contains(amenity),
                        onSelected: () => setState(() {
                          if (!_amenities.add(amenity)) {
                            _amenities.remove(amenity);
                          }
                        }),
                      ),
                  ],
                ),
                _sectionTitle(copy.get('setting_filter')),
                Wrap(
                  spacing: 8,
                  children: [
                    _choice(
                      label: copy.get('all'),
                      selected: _setting == null,
                      onSelected: () => setState(() => _setting = null),
                    ),
                    for (final setting in const ['indoor', 'outdoor'])
                      _choice(
                        label: copy.get(setting),
                        selected: _setting == setting,
                        onSelected: () => setState(() => _setting = setting),
                      ),
                  ],
                ),
                _sectionTitle(copy.get('activity_filter')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _choice(
                      label: copy.get('all'),
                      selected: _activity == null,
                      onSelected: () => setState(() => _activity = null),
                    ),
                    for (final activity in const [
                      'study',
                      'eat',
                      'relax',
                      'socialize',
                    ])
                      _choice(
                        label: copy.activity(activity),
                        selected: _activity == activity,
                        onSelected: () => setState(() => _activity = activity),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: layout.usesLargeText
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: _reset,
                          child: Text(copy.get('reset')),
                        ),
                        const SizedBox(height: AppSpacing.unit),
                        FilledButton(
                          key: const Key('apply-filters'),
                          onPressed: _apply,
                          child: Text(copy.get('apply')),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        TextButton(
                          onPressed: _reset,
                          child: Text(copy.get('reset')),
                        ),
                        const Spacer(),
                        FilledButton(
                          key: const Key('apply-filters'),
                          onPressed: _apply,
                          child: Text(copy.get('apply')),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _choice({
    Key? key,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
        color: selected ? AppColors.inkStrong : AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
