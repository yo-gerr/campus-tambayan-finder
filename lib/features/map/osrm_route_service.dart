import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result from OSRM or the Supabase route cache.
class OsrmRouteResult {
  const OsrmRouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.isCached,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final bool isCached;
}

/// Service that fetches OSRM routes, checks Supabase route cache, and logs usage.
class OsrmRouteService {
  OsrmRouteService({
    http.Client? httpClient,
    SupabaseClient? supabaseClient,
  })  : _http = httpClient ?? http.Client(),
        _supabase = supabaseClient ?? _tryGetSupabaseClient();

  final http.Client _http;
  final SupabaseClient? _supabase;

  static const _osrmBaseUrl = 'https://router.project-osrm.org/route/v1';
  static const _userAgent = 'KamusTambayApp/1.0 (Class Demo; student@plv.edu.ph)';

  static SupabaseClient? _tryGetSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Round coordinates to 4 decimal places (~11m precision) to maximize cache hits.
  static String formatCoordinateKey(double val) => val.toStringAsFixed(4);

  static String generateCacheKey(
    LatLng origin,
    LatLng destination, {
    String profile = 'driving',
  }) {
    final origLat = formatCoordinateKey(origin.latitude);
    final origLng = formatCoordinateKey(origin.longitude);
    final destLat = formatCoordinateKey(destination.latitude);
    final destLng = formatCoordinateKey(destination.longitude);
    return 'route:$origLat,$origLng:$destLat,$destLng:$profile';
  }

  /// Fetches the route from cache or OSRM demo server.
  Future<OsrmRouteResult?> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
    String? destPlaceId,
  }) async {
    final cacheKey = generateCacheKey(origin, destination, profile: profile);

    // 1. Try Supabase cache read
    final cached = await _checkCache(cacheKey);
    if (cached != null) {
      _logUsage(cacheKey, 'cache_hit', responseCode: 200);
      return cached;
    }

    // 2. Fetch from OSRM demo API
    final url = Uri.parse(
      '$_osrmBaseUrl/$profile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await _http.get(
        url,
        headers: {'User-Agent': _userAgent, 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' && data['routes'] is List && (data['routes'] as List).isNotEmpty) {
          final route = (data['routes'] as List).first as Map<String, dynamic>;
          final distance = (route['distance'] as num).toDouble();
          final duration = (route['duration'] as num).toDouble();
          final geometry = route['geometry'] as Map<String, dynamic>;
          final coordinates = geometry['coordinates'] as List<dynamic>;

          final points = coordinates.map((coord) {
            final list = coord as List<dynamic>;
            final lng = (list[0] as num).toDouble();
            final lat = (list[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          final result = OsrmRouteResult(
            points: points,
            distanceMeters: distance,
            durationSeconds: duration,
            isCached: false,
          );

          // 3. Save to Supabase route_cache & log OSRM call asynchronously
          _saveCache(
            cacheKey: cacheKey,
            origin: origin,
            destination: destination,
            profile: profile,
            distanceMeters: distance,
            durationSeconds: duration,
            geometryGeoJson: geometry,
            destPlaceId: destPlaceId,
          );
          _logUsage(cacheKey, 'osrm_fetch', responseCode: response.statusCode);

          return result;
        }
      }
      _logUsage(cacheKey, 'osrm_error', responseCode: response.statusCode);
    } catch (e) {
      debugPrint('OSRM Route fetch failed: $e');
      _logUsage(cacheKey, 'osrm_network_error');
    }

    return null;
  }

  Future<OsrmRouteResult?> _checkCache(String cacheKey) async {
    final client = _supabase;
    if (client == null) return null;

    try {
      final response = await client
          .from('route_cache')
          .select()
          .eq('cache_key', cacheKey)
          .maybeSingle();

      if (response != null) {
        final distance = (response['distance_meters'] as num).toDouble();
        final duration = (response['duration_seconds'] as num).toDouble();
        final geometry = response['geometry_geojson'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;

        final points = coordinates.map((coord) {
          final list = coord as List<dynamic>;
          final lng = (list[0] as num).toDouble();
          final lat = (list[1] as num).toDouble();
          return LatLng(lat, lng);
        }).toList();

        return OsrmRouteResult(
          points: points,
          distanceMeters: distance,
          durationSeconds: duration,
          isCached: true,
        );
      }
    } catch (e) {
      debugPrint('Route cache read error: $e');
    }
    return null;
  }

  Future<void> _saveCache({
    required String cacheKey,
    required LatLng origin,
    required LatLng destination,
    required String profile,
    required double distanceMeters,
    required double durationSeconds,
    required Map<String, dynamic> geometryGeoJson,
    String? destPlaceId,
  }) async {
    final client = _supabase;
    if (client == null) return;

    try {
      await client.from('route_cache').upsert({
        'cache_key': cacheKey,
        'dest_place_id': destPlaceId,
        'origin_lat': origin.latitude,
        'origin_lng': origin.longitude,
        'dest_lat': destination.latitude,
        'dest_lng': destination.longitude,
        'profile': profile,
        'distance_meters': distanceMeters,
        'duration_seconds': durationSeconds,
        'geometry_geojson': geometryGeoJson,
      });
    } catch (e) {
      debugPrint('Route cache write error: $e');
    }
  }

  Future<void> _logUsage(
    String cacheKey,
    String requestType, {
    int? responseCode,
  }) async {
    final client = _supabase;
    if (client == null) return;

    try {
      await client.from('osrm_usage_logs').insert({
        'cache_key': cacheKey,
        'request_type': requestType,
        'response_code': responseCode,
      });
    } catch (_) {
      // Usage logging is non-critical
    }
  }
}
