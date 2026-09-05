import 'dart:convert';

import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryRepository {
  static const _playerKey = 'memory_quest.player.v1';
  static const _sessionsKey = 'memory_quest.sessions.v1';

  final SharedPreferencesAsync _preferences;

  MemoryRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  Future<MemoryPlayer?> loadPlayer() async {
    final raw = await _preferences.getString(_playerKey);
    if (raw == null) return null;
    try {
      return MemoryPlayer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlayer(MemoryPlayer player) =>
      _preferences.setString(_playerKey, jsonEncode(player.toJson()));

  Future<List<MemorySession>> loadSessions() async {
    final raw = await _preferences.getString(_sessionsKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => MemorySession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(MemorySession session) async {
    final sessions = await loadSessions();
    sessions.insert(0, session);
    await _preferences.setString(
      _sessionsKey,
      jsonEncode(sessions.take(100).map((item) => item.toJson()).toList()),
    );
  }

  Future<MemoryPlayerStats> statsFor(MemoryPlayer player) async {
    final sessions = (await loadSessions())
        .where((session) =>
            session.player.nickname.toLowerCase() ==
            player.nickname.toLowerCase())
        .toList();
    if (sessions.isEmpty) return MemoryPlayerStats.empty;

    return MemoryPlayerStats(
      gamesPlayed: sessions.length,
      bestScore: sessions.map((e) => e.score).reduce(_max),
      highestStage: sessions.map((e) => e.stageReached).reduce(_max),
      totalPairs: sessions.fold(0, (sum, item) => sum + item.pairsFound),
      bestCombo: sessions.map((e) => e.bestCombo).reduce(_max),
      bestAccuracy: sessions.map((e) => e.accuracy).reduce(_maxDouble),
    );
  }

  int _max(int a, int b) => a > b ? a : b;
  double _maxDouble(double a, double b) => a > b ? a : b;
}
