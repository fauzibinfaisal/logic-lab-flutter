import 'package:logic_lab/mini_apps/memory_quest/data/memory_leaderboard_api.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';

class MemoryLeaderboardRepository {
  final MemoryLeaderboardApi _api;

  MemoryLeaderboardRepository({MemoryLeaderboardApi? api})
      : _api = api ?? MemoryLeaderboardApi();

  Future<void> submit(MemorySession session) => _api.submit(session);

  Future<List<MemoryLeaderboardEntry>> leaderboard(
    MemoryLeaderboardPeriod period,
  ) =>
      _api.fetch(period: period);

  void dispose() => _api.close();
}
