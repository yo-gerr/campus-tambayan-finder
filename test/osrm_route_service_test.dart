import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:campus_tambayan_finder/features/map/osrm_route_service.dart';

void main() {
  test('formats coordinate key and cache key with 4 decimal places', () {
    expect(OsrmRouteService.formatCoordinateKey(14.7009412), '14.7009');
    expect(OsrmRouteService.formatCoordinateKey(120.983058), '120.9831');

    final origin = LatLng(14.70094, 120.98305);
    final dest = LatLng(14.72001, 120.99002);

    final cacheKey = OsrmRouteService.generateCacheKey(origin, dest, profile: 'driving');
    expect(cacheKey, 'route:14.7009,120.9830:14.7200,120.9900:driving');
  });

  test('fetches route from OSRM demo API on cache miss', () async {
    final mockClient = http_testing.MockClient((request) async {
      expect(request.url.host, 'router.project-osrm.org');
      expect(request.headers['User-Agent'], contains('KamusTambayApp'));

      final body = jsonEncode({
        'code': 'Ok',
        'routes': [
          {
            'distance': 1500.0,
            'duration': 300.0,
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [120.9831, 14.7009],
                [120.9850, 14.7050],
                [120.9900, 14.7200],
              ],
            },
          }
        ],
      });
      return http.Response(body, 200);
    });

    final service = OsrmRouteService(httpClient: mockClient);
    final result = await service.fetchRoute(
      origin: LatLng(14.7009, 120.9831),
      destination: LatLng(14.7200, 120.9900),
    );

    expect(result, isNotNull);
    expect(result!.distanceMeters, 1500.0);
    expect(result.durationSeconds, 300.0);
    expect(result.isCached, isFalse);
    expect(result.points, hasLength(3));
    expect(result.points.first.latitude, closeTo(14.7009, 1e-4));
    expect(result.points.first.longitude, closeTo(120.9831, 1e-4));
  });

  test('returns null when OSRM API returns an error status', () async {
    final mockClient = http_testing.MockClient((request) async {
      return http.Response('Rate limited', 429);
    });

    final service = OsrmRouteService(httpClient: mockClient);
    final result = await service.fetchRoute(
      origin: LatLng(14.7009, 120.9831),
      destination: LatLng(14.7200, 120.9900),
    );

    expect(result, isNull);
  });
}
