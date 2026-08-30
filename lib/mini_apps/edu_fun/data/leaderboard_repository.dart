import 'package:logic_lab/mini_apps/edu_fun/data/leaderboard_api_service.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';

class LeaderboardRepository {
  final LeaderboardApiService _api;

  LeaderboardRepository({LeaderboardApiService? api})
      : _api = api ?? LeaderboardApiService();

  bool get isConfigured => _api.isConfigured;

  Future<void> submitSession(EduSession session) => _api.submit(session);

  Future<List<LeaderboardEntry>> getLeaderboard({
    required int age,
    required LeaderboardPeriod period,
  }) =>
      _api.fetch(age: age, period: period);

  void dispose() => _api.close();
}
