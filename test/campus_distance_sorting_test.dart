import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/map/campus_map_anchors.dart';

void main() {
  test('anchorForCampus returns correct anchor for PLV Annex and CPAG', () {
    final plv = anchorForCampus('plv');
    final cpag = anchorForCampus('cpag');

    expect(plv.id, 'plv-annex');
    expect(cpag.id, 'cpag');
  });

  test('distanceMetersBetween calculates positive distance', () {
    final plvLocation = campusMapAnchors[0].location;
    final cpagLocation = campusMapAnchors[1].location;

    final distance = distanceMetersBetween(plvLocation, cpagLocation);
    expect(distance, greaterThan(100));
    expect(distance, lessThan(1000));
  });
}
