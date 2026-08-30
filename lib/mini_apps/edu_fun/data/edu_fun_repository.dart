import 'dart:convert';

import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EduFunRepository {
  static const _playerKey = 'edu_fun.player.v1';
  static const _sessionsKey = 'edu_fun.sessions.v1';

  final SharedPreferencesAsync _preferences;

  EduFunRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  Future<EduPlayer?> loadPlayer() async {
    final raw = await _preferences.getString(_playerKey);
    if (raw == null) return null;
    try {
      return EduPlayer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlayer(EduPlayer player) =>
      _preferences.setString(_playerKey, jsonEncode(player.toJson()));

  Future<List<EduSession>> loadSessions() async {
    final raw = await _preferences.getString(_sessionsKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => EduSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(EduSession session) async {
    final sessions = await loadSessions();
    sessions.insert(0, session);
    final recent = sessions.take(100).map((item) => item.toJson()).toList();
    await _preferences.setString(_sessionsKey, jsonEncode(recent));
  }

  Future<PlayerStats> statsFor(EduPlayer player) async {
    final sessions = (await loadSessions()).where(
      (session) =>
          session.player.nickname.toLowerCase() ==
              player.nickname.toLowerCase() &&
          session.player.age == player.age,
    );
    if (sessions.isEmpty) return PlayerStats.empty;

    return PlayerStats(
      gamesPlayed: sessions.length,
      bestScore: sessions.map((e) => e.score).reduce((a, b) => a > b ? a : b),
      bestAccuracy:
          sessions.map((e) => e.accuracy).reduce((a, b) => a > b ? a : b),
      bestStreak:
          sessions.map((e) => e.bestStreak).reduce((a, b) => a > b ? a : b),
    );
  }
}
