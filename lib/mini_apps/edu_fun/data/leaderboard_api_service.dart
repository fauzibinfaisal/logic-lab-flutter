import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';

class LeaderboardApiException implements Exception {
  final String message;
  const LeaderboardApiException(this.message);

  @override
  String toString() => message;
}

class LeaderboardApiService {
  static const configuredBaseUrl = String.fromEnvironment(
    'LEADERBOARD_API_URL',
  );

  final String baseUrl;
  final http.Client _client;

  LeaderboardApiService({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? configuredBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<void> submit(EduSession session) async {
    _ensureConfigured();
    final response = await _client
        .post(
          Uri.parse('$baseUrl/api/v1/scores'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': session.sessionId,
            'nickname': session.player.nickname,
            'age': session.player.age,
            'score': session.score,
            'completionTimeMs': session.durationSeconds * 1000,
            'correctAnswers': session.correct,
            'bestStreak': session.bestStreak,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 202) {
      throw LeaderboardApiException(_messageFrom(response));
    }
  }

  Future<List<LeaderboardEntry>> fetch({
    required int age,
    required LeaderboardPeriod period,
    int limit = 50,
  }) async {
    _ensureConfigured();
    final periodValue = switch (period) {
      LeaderboardPeriod.today => 'today',
      LeaderboardPeriod.week => 'week',
      LeaderboardPeriod.allTime => 'all',
    };
    final uri = Uri.parse('$baseUrl/api/v1/leaderboard').replace(
      queryParameters: {
        'age': '$age',
        'period': periodValue,
        'limit': '$limit',
      },
    );
    final response = await _client.get(uri, headers: const {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw LeaderboardApiException(_messageFrom(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['entries'] as List<dynamic>)
        .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void close() => _client.close();

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const LeaderboardApiException(
        'Leaderboard API is not configured for this build.',
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
