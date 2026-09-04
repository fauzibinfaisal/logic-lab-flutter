import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';

class MemoryLeaderboardException implements Exception {
  final String message;
  const MemoryLeaderboardException(this.message);

  @override
  String toString() => message;
}

class MemoryLeaderboardApi {
  static const configuredBaseUrl = String.fromEnvironment(
    'LEADERBOARD_API_URL',
  );

  final String baseUrl;
  final http.Client _client;

  MemoryLeaderboardApi({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? configuredBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<void> submit(MemorySession session) async {
    _ensureConfigured();
    final response = await _client
        .post(
          Uri.parse('$baseUrl/api/v1/memory/scores'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': session.sessionId,
            'nickname': session.player.nickname,
            'score': session.score,
            'stageReached': session.stageReached,
            'pairsFound': session.pairsFound,
            'accuracyPermille':
                (session.accuracy * 1000).round().clamp(0, 1000),
            'remainingTimeMs': session.remainingTimeMs,
            'fastestStageMs': session.fastestStageMs,
            'durationMs': session.durationMs,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 202) {
      throw MemoryLeaderboardException(_messageFrom(response));
    }
  }

  Future<List<MemoryLeaderboardEntry>> fetch({
    required MemoryLeaderboardPeriod period,
    int limit = 50,
  }) async {
    _ensureConfigured();
    final periodValue = switch (period) {
      MemoryLeaderboardPeriod.today => 'today',
      MemoryLeaderboardPeriod.week => 'week',
      MemoryLeaderboardPeriod.allTime => 'all',
    };
    final uri = Uri.parse('$baseUrl/api/v1/memory/leaderboard').replace(
      queryParameters: {'period': periodValue, 'limit': '$limit'},
    );
    final response = await _client.get(uri, headers: const {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw MemoryLeaderboardException(_messageFrom(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['entries'] as List<dynamic>)
        .map((item) =>
            MemoryLeaderboardEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void close() => _client.close();

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const MemoryLeaderboardException(
        'Memory leaderboard is not configured for this build.',
      );
    }
  }

  String _messageFrom(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['error'] as String? ?? 'Leaderboard request failed.';
    } catch (_) {
      return 'Leaderboard request failed (${response.statusCode}).';
    }
  }
}
