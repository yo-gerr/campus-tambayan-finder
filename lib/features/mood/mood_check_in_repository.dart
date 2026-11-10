import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mood_check_in.dart';

abstract interface class MoodCheckInRepository {
  Future<void> submitCheckIn(MoodCheckIn checkIn);
  Future<Map<String, int>> getAggregateMoods(String placeId);
}

class SupabaseMoodCheckInRepository implements MoodCheckInRepository {
  SupabaseMoodCheckInRepository(this._client, {this.preferences});

  final SupabaseClient? _client;
  final SharedPreferences? preferences;

  static const String _offlineQueueKey = 'mood_check_ins_offline_queue';

  @override
  Future<void> submitCheckIn(MoodCheckIn checkIn) async {
    final client = _client;
    if (client == null) {
      await _saveToOfflineQueue(checkIn);
      return;
    }

    try {
      await client.from('mood_check_ins').insert(checkIn.toJson());
      await _flushOfflineQueue();
    } catch (e) {
      debugPrint('Supabase mood insert failed, saving to local queue: $e');
      await _saveToOfflineQueue(checkIn);
    }
  }

  @override
  Future<Map<String, int>> getAggregateMoods(String placeId) async {
    final client = _client;
    if (client == null) return {};

    try {
      final rows = await client
          .from('mood_check_ins')
          .select('mood')
          .eq('place_id', placeId);

      final counts = <String, int>{};
      for (final row in rows as List<dynamic>) {
        final mood = row['mood'] as String;
        counts[mood] = (counts[mood] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      debugPrint('Could not fetch aggregate moods for $placeId: $e');
      return {};
    }
  }

  Future<void> _saveToOfflineQueue(MoodCheckIn checkIn) async {
    try {
      final prefs = preferences ?? await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_offlineQueueKey) ?? [];
      existing.add(jsonEncode(checkIn.toJson()));
      await prefs.setStringList(_offlineQueueKey, existing);
    } catch (e) {
      debugPrint('Could not save mood to offline queue: $e');
    }
  }

  Future<void> _flushOfflineQueue() async {
    final client = _client;
    if (client == null) return;

    try {
      final prefs = preferences ?? await SharedPreferences.getInstance();
      final queued = prefs.getStringList(_offlineQueueKey);
      if (queued == null || queued.isEmpty) return;

      final remaining = <String>[];
      for (final item in queued) {
        try {
          final data = jsonDecode(item) as Map<String, dynamic>;
          await client.from('mood_check_ins').insert(data);
        } catch (_) {
          remaining.add(item);
        }
      }
      await prefs.setStringList(_offlineQueueKey, remaining);
    } catch (e) {
      debugPrint('Could not flush offline mood queue: $e');
    }
  }
}
