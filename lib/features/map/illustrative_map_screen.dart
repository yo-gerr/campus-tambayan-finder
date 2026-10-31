import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_theme.dart';
import '../places/place.dart';
import '../places/place_card.dart';

class IllustrativeMapScreen extends StatelessWidget {
  const IllustrativeMapScreen({
    required this.places,
    required this.copy,
    required this.campus,
    required this.onCampusChanged,
    required this.onPlaceSelected,
    super.key,
  });

  final List<Place> places;
  final AppCopy copy;
  final String campus;
  final ValueChanged<String> onCampusChanged;
  final ValueChanged<Place> onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.get('illustrative_map'),
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            copy.get('map_note'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedInk),
          ),
          const SizedBox(height: 12),
          _MapOriginSelector(
            campus: campus,
            copy: copy,
            onCampusChanged: onCampusChanged,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final maxPinLeft = (width - 112).clamp(0.0, double.infinity);
                  final maxPinTop = (height - 72).clamp(0.0, double.infinity);
                  return Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _SchematicMapPainter()),
                      ),
                      Positioned(
                        left: 18,
                        top: height * 0.43,
                        child: _MapLabel(
                          label: copy.get(
                            campus == 'plv' ? 'campus_plv' : 'campus_cpag',
                          ),
                          icon: Icons.school_outlined,
                          isOrigin: true,
                        ),
                      ),
                      for (final (index, place) in places.indexed)
                        Positioned(
                          left: (place.mapX * maxPinLeft)
                              .clamp(0.0, maxPinLeft),
                          top: (place.mapY * maxPinTop)
                              .clamp(0.0, maxPinTop),
                          child: _PlacePin(
                            place: place,
                            index: index,
                            copy: copy,
                            onTap: () => onPlaceSelected(place),
                          ),
                        ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.93),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            child: Text(
                              copy.get('illustrative_map'),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            copy.get('list_view'),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final place = places[index];
                return SizedBox(
                  width: MediaQuery.sizeOf(context).width - 70,
                  child: PlaceCard(
                    place: place,
                    copy: copy,
                    onTap: () => onPlaceSelected(place),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOriginSelector extends StatelessWidget {
  const _MapOriginSelector({
    required this.campus,
    required this.copy,
    required this.onCampusChanged,
  });

  final String campus;
  final AppCopy copy;
  final ValueChanged<String> onCampusChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'plv', label: Text(copy.get('campus_plv'))),
        ButtonSegment(value: 'cpag', label: Text(copy.get('campus_cpag'))),
      ],
      selected: {campus},
      showSelectedIcon: false,
      onSelectionChanged: (value) => onCampusChanged(value.first),
    );
  }
}

class _PlacePin extends StatelessWidget {
  const _PlacePin({
    required this.place,
    required this.index,
    required this.copy,
    required this.onTap,
  });

  final Place place;
  final int index;
  final AppCopy copy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${copy.get('demo_badge')}: ${place.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('map-pin-${place.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.location_on, color: AppColors.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.label,
    required this.icon,
    this.isOrigin = false,
  });

  final String label;
  final IconData icon;
  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isOrigin ? const Color(0xFFFCF3D8) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SchematicMapPainter extends CustomPainter {
  const _SchematicMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.map;
    canvas.drawRect(Offset.zero & size, background);

    final parkPaint = Paint()..color = const Color(0xFFD8E5CE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.45,
          size.height * 0.34,
          size.width * 0.32,
          size.height * 0.23,
        ),
        const Radius.circular(28),
      ),
      parkPaint,
    );

    final roadPaint = Paint()
      ..color = AppColors.road
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roads = [
      Path()
        ..moveTo(-20, size.height * 0.20)
        ..cubicTo(
          size.width * 0.34,
          size.height * 0.08,
          size.width * 0.56,
          size.height * 0.40,
          size.width + 20,
          size.height * 0.25,
        ),
      Path()
        ..moveTo(size.width * 0.11, size.height + 20)
        ..cubicTo(
          size.width * 0.32,
          size.height * 0.64,
          size.width * 0.52,
          size.height * 0.57,
          size.width * 0.92,
          -20,
        ),
      Path()
        ..moveTo(-20, size.height * 0.78)
        ..cubicTo(
          size.width * 0.26,
          size.height * 0.69,
          size.width * 0.62,
          size.height * 0.94,
          size.width + 20,
          size.height * 0.73,
        ),
    ];
    for (final road in roads) {
      canvas.drawPath(road, roadPaint);
    }

    final minorRoadPaint = Paint()
      ..color = const Color(0xFFF9F7EE)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final minorRoad = Path()
      ..moveTo(size.width * 0.02, size.height * 0.47)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.42,
        size.width * 0.59,
        size.height * 0.53,
        size.width * 0.98,
        size.height * 0.44,
      );
    canvas.drawPath(minorRoad, minorRoadPaint);

    final parcelPaint = Paint()
      ..color = const Color(0xFFD3D6C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.08 + i * 0.19);
      canvas.drawLine(
        Offset(x, size.height * 0.02),
        Offset(x + 24, size.height * 0.14),
        parcelPaint,
      );
      canvas.drawLine(
        Offset(x, size.height * 0.84),
        Offset(x + 19, size.height * 0.98),
        parcelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
