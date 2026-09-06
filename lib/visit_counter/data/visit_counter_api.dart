import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract final class VisitScope {
  static const site = 'site';
  static const qibla = 'qibla';
  static const numberAdventure = 'number-adventure';
  static const memoryQuest = 'memory-quest';

  static const values = {
    site,
    qibla,
    numberAdventure,
    memoryQuest,
  };
}

class VisitCounts {
  final Map<String, int> values;

  const VisitCounts(this.values);

  int? operator [](String scope) => values[scope];

  factory VisitCounts.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['counts'];
    if (rawCounts is! Map<String, dynamic>) {
      throw const FormatException('Missing visit counts.');
    }

    return VisitCounts({
      for (final scope in VisitScope.values)
        scope: switch (rawCounts[scope]) {
          final int value when value >= 0 => value,
          final num value when value >= 0 => value.toInt(),
          _ => 0,
        },
    });
  }
}

class VisitCounterApiException implements Exception {
  final String message;

  const VisitCounterApiException(this.message);

  @override
  String toString() => message;
}

class VisitCounterApi {
  static const configuredBaseUrl = String.fromEnvironment(
    'LEADERBOARD_API_URL',
  );

  final String baseUrl;
  final http.Client _client;

  VisitCounterApi({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? configuredBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<VisitCounts> recordVisit(String scope) async {
    _validateScope(scope);
    _ensureConfigured();

    final response = await _client
        .post(
          Uri.parse('$baseUrl/api/v1/visits'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'scope': scope}),
        )
        .timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  Future<VisitCounts> fetchCounts() async {
    _ensureConfigured();
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/visits'),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  void close() => _client.close();

  VisitCounts _parse(http.Response response) {
    if (response.statusCode != 200) {
      throw VisitCounterApiException(_messageFrom(response));
    }
    try {
      return VisitCounts.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      throw const VisitCounterApiException('Invalid visitor response.');
    }
  }

  void _validateScope(String scope) {
    if (!VisitScope.values.contains(scope)) {
      throw const VisitCounterApiException('Unknown visit scope.');
    }
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const VisitCounterApiException(
        'Visitor API is not configured for this build.',
      );
    }
  }

  String _messageFrom(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['error'] as String? ?? 'Visitor request failed.';
    } catch (_) {
      return 'Visitor request failed (${response.statusCode}).';
    }
  }
}
