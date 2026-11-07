import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../../app/app_widgets.dart';
import 'demo_badge.dart';
import 'google_maps_directions.dart';
import 'open_status_badge.dart';
import 'opening_hours.dart';
import 'place.dart';
import 'place_photo.dart';

typedef DirectionsUrlLauncher = Future<bool> Function(Uri url);

Future<void> showPlaceDetails({
  required BuildContext context,
  required Place place,
  required AppCopy copy,
  DirectionsUrlLauncher? launchDirections,
  DateTime? now,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    builder: (context) => _PlaceDetailSheet(
      place: place,
      copy: copy,
      launchDirections: launchDirections ?? _launchExternalUrl,
      now: now,
    ),
  );
}

class _PlaceDetailSheet extends StatelessWidget {
  const _PlaceDetailSheet({
    required this.place,
    required this.copy,
    required this.launchDirections,
    this.now,
  });

  final Place place;
  final AppCopy copy;
  final DirectionsUrlLauncher launchDirections;
  final DateTime? now;

  // ASSUMPTION: adjust this one line if your Place model names its photo
  // list differently. It only decides how tall the photo area is.
  bool get _hasPhotos => place.coverPhoto != null;

  Future<void> _openDirections(BuildContext context) async {
    if (!place.locationVerified) {
      await _showDirectionsUnavailable(
        context,
        copy.get('directions_location_unverified'),
      );
      return;
    }

    final uri = googleMapsDirectionsUri(place);
    if (uri == null) {
      await _showDirectionsUnavailable(
        context,
        copy.get('directions_coordinates_missing'),
      );
      return;
    }

    var launched = false;
    try {
      launched = await launchDirections(uri);
    } on PlatformException {
      launched = false;
    } on MissingPluginException {
      launched = false;
    }
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.get('directions_could_not_open'))),
      );
    }
  }

  Future<void> _showDirectionsUnavailable(
      BuildContext context,
      String message,
      ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.route_outlined),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.get('got_it')),
          ),
        ],
      ),
    );
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.get('address_copied'))),
    );
  }

  Widget _facts(BuildContext context) {
    final tiles = [
      _FactTile(
        icon: Icons.payments_outlined,
        label: copy.get('price'),
        value: copy.priceRange(place.priceMin, place.priceMax),
      ),
      _FactTile(
        icon: place.setting == 'outdoor'
            ? Icons.park_outlined
            : Icons.storefront_outlined,
        label: copy.get('setting'),
        value: copy.get(place.setting),
      ),
    ];
    // Stack the tiles when the user runs a large system font.
    final large = AppLayout.of(context).usesLargeText;
    if (large) {
      return Column(children: [tiles[0], const SizedBox(height: 10), tiles[1]]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tiles[0]),
          const SizedBox(width: 10),
          Expanded(child: tiles[1]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    final textTheme = Theme.of(context).textTheme;
    final description = copy.isTagalog
        ? place.descriptionTl
        : place.descriptionEn;
    final address = place.address;
    final openingHours = place.openingHours;
    final clock = now ?? DateTime.now();
    final status = openingHours?.isOpenAt(clock);

    return SizedBox(
      height: layout.sheetHeight(0.85),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              key: const Key('place-detail-list'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                const Center(child: SheetHandle()),
                const SizedBox(height: 8),
                // Badges keep their natural size; the close button stays
                // at the right edge.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (place.isDemo)
                              DemoBadge(label: copy.get('demo_badge')),
                            if (status != null)
                              OpenStatusBadge(open: status, copy: copy),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: copy.get('close'),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${copy.category(place.category)} · ${place.area}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedInk,
                  ),
                ),
                const SizedBox(height: 14),
                PlacePhotoGallery(
                  place: place,
                  width: double.infinity,
                  // A missing photo should not take over the screen.
                  height: _hasPhotos ? 210 : 112,
                  borderRadius: 22,
                  loadingLabel: copy.get('loading_photo'),
                  placeholder: PlacePhotoPlaceholder(
                    category: place.category,
                    label: copy.get('no_photo'),
                    iconSize: _hasPhotos ? 40 : 30,
                  ),
                  photoPosition: copy.photoPosition,
                  viewPhotoLabel: copy.get('view_photo'),
                  closeLabel: copy.get('close'),
                  photoCaption: (photo) => copy.isTagalog
                      ? photo.captionTl ?? photo.captionEn
                      : photo.captionEn ?? photo.captionTl,
                ),
                const SizedBox(height: 14),
                _facts(context),
                const SizedBox(height: 10),
                if (openingHours != null)
                  _HoursCard(
                    hours: openingHours,
                    copy: copy,
                    now: clock,
                    status: status,
                    note: place.hours,
                  )
                else
                  _InfoCard(
                    icon: Icons.schedule_outlined,
                    label: copy.get('hours'),
                    value: place.hours ?? copy.get('hours_not_listed'),
                  ),
                if (address != null) ...[
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    label: copy.get('address'),
                    value: address,
                    trailing: const Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: AppColors.mutedInk,
                    ),
                    onTap: () => _copyAddress(context, address),
                  ),
                ],
                const SizedBox(height: 14),
                _NoteBanner(
                  icon: Icons.info_outline,
                  text: place.isDemo
                      ? '${copy.get('sample_data')} $description'
                      : description,
                ),
                if (place.activities.isNotEmpty) ...[
                  _SectionTitle(copy.get('good_for')),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final activity in place.activities)
                        _Pill(
                          icon: _activityIcon(activity),
                          label: copy.activity(activity),
                        ),
                    ],
                  ),
                ],
                _SectionTitle(copy.get('amenities')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: place.amenities.isEmpty
                      ? [
                    _Pill(
                      icon: Icons.info_outline,
                      label: place.isDemo
                          ? copy.get('sample_data')
                          : copy.get('not_listed'),
                    ),
                  ]
                      : [
                    for (final amenity in place.amenities)
                      _Pill(
                        icon: _amenityIcon(amenity),
                        label: copy.get(amenity),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _DirectionsBar(
            copy: copy,
            verified: place.locationVerified,
            onPressed: () => _openDirections(context),
          ),
        ],
      ),
    );
  }
}

Future<bool> _launchExternalUrl(Uri url) {
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

/// Pinned at the bottom so the main action is always one tap away, however
/// long the details are.
class _DirectionsBar extends StatelessWidget {
  const _DirectionsBar({
    required this.copy,
    required this.verified,
    required this.onPressed,
  });

  final AppCopy copy;
  final bool verified;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.directions_outlined);
    final label = Text(copy.get('directions'));
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: verified
                  ? FilledButton.icon(
                key: const Key('place-directions'),
                onPressed: onPressed,
                icon: icon,
                label: label,
              )
                  : FilledButton.tonalIcon(
                key: const Key('place-directions'),
                onPressed: onPressed,
                icon: icon,
                label: label,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              verified
                  ? copy.get('opens_google_maps')
                  : copy.get('location_unverified'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsed: a one-line answer ("Closes 8:00 PM" / "Opens Monday 8:00 AM").
/// Expanded: the full week with today highlighted.
///
/// Only days with data are listed: an unknown day is omitted rather than shown
/// as "Closed", so a half-filled schedule never reads as a closed shop.
class _HoursCard extends StatefulWidget {
  const _HoursCard({
    required this.hours,
    required this.copy,
    required this.now,
    required this.status,
    this.note,
  });

  final OpeningHours hours;
  final AppCopy copy;
  final DateTime now;
  final bool? status;

  /// Free-text summary or exception note kept from the original field.
  final String? note;

  @override
  State<_HoursCard> createState() => _HoursCardState();
}

class _HoursCardState extends State<_HoursCard> {
  bool _expanded = false;

  int get _today => manilaTimeOf(widget.now).weekday;

  int _previous(int weekday) =>
      weekday == DateTime.monday ? DateTime.sunday : weekday - 1;

  String _dayLabel(int weekday) {
    final day = widget.hours.hoursFor(weekday);
    if (day == null) return widget.copy.get('closed');
    return '${widget.copy.timeOfDay(day.openMinutes)}–'
        '${widget.copy.timeOfDay(day.closeMinutes)}';
  }

  /// "Closes 8:00 PM" while open, "Opens 8:00 AM" / "Opens Monday 8:00 AM"
  /// while closed. Null when the schedule cannot answer.
  String? _statusDetail() {
    final status = widget.status;
    if (status == null) return null;
    final manila = manilaTimeOf(widget.now);
    final minute = manila.hour * 60 + manila.minute;
    final weekday = manila.weekday;
    final copy = widget.copy;

    if (status) {
      final today = widget.hours.hoursFor(weekday);
      final DayHours? running =
      (today != null &&
          today.containsMinute(minute) &&
          minute >= today.openMinutes)
          ? today
          : widget.hours.hoursFor(_previous(weekday));
      if (running == null) return null;
      return '${copy.get('closes')} ${copy.timeOfDay(running.closeMinutes)}';
    }

    for (var offset = 0; offset <= 7; offset++) {
      final day = (weekday - 1 + offset) % 7 + 1;
      final window = widget.hours.hoursFor(day);
      if (window == null) continue;
      if (offset == 0 && window.openMinutes <= minute) continue;
      final time = copy.timeOfDay(window.openMinutes);
      final label = offset == 0 ? time : '${copy.weekday(day)} $time';
      return '${copy.get('opens')} $label';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final copy = widget.copy;
    final detail = _statusDetail();
    final todayRange = widget.hours.isKnownOn(_today)
        ? _dayLabel(_today)
        : null;
    final days = [
      for (final weekday in OpeningHours.weekdayKeys.values)
        if (widget.hours.isKnownOn(weekday)) weekday,
    ];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.get('hours'),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedInk,
                          ),
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        if (todayRange != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            todayRange,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedInk,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          copy.get(
                            _expanded ? 'hide_full_week' : 'see_full_week',
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.mutedInk,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final weekday in days)
                    _DayRow(
                      day: copy.weekday(weekday),
                      value: _dayLabel(weekday),
                      highlighted: weekday == _today,
                    ),
                  if (widget.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.note!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedInk,
                        ),
                      ),
                    ),
                ],
              ),
            )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.value,
    required this.highlighted,
  });

  final String day;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary.withAlpha(24) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              day,
              style: style?.copyWith(
                color: highlighted ? null : AppColors.mutedInk,
                fontWeight: highlighted ? FontWeight.w800 : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.end,
            style: style?.copyWith(
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width label and value card, optionally tappable.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteBanner extends StatelessWidget {
  const _NoteBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.inkStrong),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _amenityIcon(String amenity) => switch (amenity) {
  'wifi' => Icons.wifi,
  'aircon' => Icons.ac_unit,
  'outlets' => Icons.power,
  _ => Icons.check_circle_outline,
};

IconData _activityIcon(String activity) => switch (activity) {
  'study' => Icons.menu_book_outlined,
  'eat' => Icons.restaurant_outlined,
  'relax' => Icons.self_improvement_outlined,
  'social' || 'socialize' => Icons.groups_outlined,
  _ => Icons.check_circle_outline,
};