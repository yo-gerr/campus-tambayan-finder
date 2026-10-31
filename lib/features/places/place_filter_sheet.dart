import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import 'place_filters.dart';

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
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
  late double _maxBudget = widget.initialFilters.maxBudget;
  late Set<String> _amenities = {...widget.initialFilters.amenities};
  late String? _setting = widget.initialFilters.setting;
  late String? _activity = widget.initialFilters.activity;

  AppCopy get copy => widget.copy;

  void _reset() {
    setState(() {
      _category = null;
      _maxBudget = 600;
      _amenities = {};
      _setting = null;
      _activity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('place-filter-sheet'),
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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
                    for (final category in const [
                      'tambayan',
                      'coffee',
                      'park',
                      'eatery',
                    ])
                      _choice(
                        key: Key('category-$category-filter'),
                        label: copy.category(category),
                        selected: _category == category,
                        onSelected: () => setState(() => _category = category),
                      ),
                  ],
                ),
                _sectionTitle(copy.get('budget')),
                Text(
                  _maxBudget >= 600
                      ? copy.get('any_price')
                      : '₱${_maxBudget.round()}',
                ),
                Slider(
                  key: const Key('budget-filter'),
                  min: 0,
                  max: 600,
                  divisions: 12,
                  value: _maxBudget,
                  onChanged: (value) => setState(() => _maxBudget = value),
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
              child: Row(
                children: [
                  TextButton(onPressed: _reset, child: Text(copy.get('reset'))),
                  const Spacer(),
                  FilledButton(
                    key: const Key('apply-filters'),
                    onPressed: () => Navigator.pop(
                      context,
                      PlaceFilters(
                        category: _category,
                        maxBudget: _maxBudget,
                        amenities: _amenities,
                        setting: _setting,
                        activity: _activity,
                      ),
                    ),
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
        color: selected ? AppColors.primary : AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
