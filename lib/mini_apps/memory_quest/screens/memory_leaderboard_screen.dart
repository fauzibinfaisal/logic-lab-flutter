import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/data/memory_leaderboard_repository.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemoryLeaderboardScreen extends StatefulWidget {
  final MemoryLeaderboardRepository repository;
  final String? currentNickname;
  final VoidCallback onBack;

  const MemoryLeaderboardScreen({
    super.key,
    required this.repository,
    required this.onBack,
    this.currentNickname,
  });

  @override
  State<MemoryLeaderboardScreen> createState() =>
      _MemoryLeaderboardScreenState();
}

class _MemoryLeaderboardScreenState extends State<MemoryLeaderboardScreen> {
  MemoryLeaderboardPeriod _period = MemoryLeaderboardPeriod.today;
  late Future<List<MemoryLeaderboardEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.repository.leaderboard(_period);
  }

  @override
  Widget build(BuildContext context) => MemoryScreen(
        child: Column(
          children: [
            const MemoryTitle(
              eyebrow: 'MEMORY CHAMPIONS',
              title: 'How far can you remember? 🏆',
              subtitle:
                  'Only each player’s best Solo score appears for the selected period.',
            ),
            const SizedBox(height: 22),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  MemoryPanel(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        for (final period in MemoryLeaderboardPeriod.values)
                          ChoiceChip(
                            label: Text(_label(period)),
                            selected: _period == period,
                            onSelected: (_) {
                              setState(() {
                                _period = period;
                                _entries =
                                    widget.repository.leaderboard(period);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FutureBuilder<List<MemoryLeaderboardEntry>>(
                    future: _entries,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LeaderboardState(
                          title: 'Loading memory champions…',
                          icon: Icons.hourglass_top_rounded,
                          loading: true,
                        );
                      }
                      if (snapshot.hasError) {
                        return _LeaderboardState(
                          title: 'Leaderboard unavailable',
                          message:
                              'Your game still works and scores remain saved on this device.',
                          icon: Icons.cloud_off_rounded,
                          actionLabel: 'Try Again',
                          onAction: _reload,
                        );
                      }
                      final entries = snapshot.data ?? [];
                      if (entries.isEmpty) {
                        return _LeaderboardState(
                          title: 'Be the first Memory Champion!',
                          message: 'No Solo scores yet for this period.',
                          icon: Icons.emoji_events_outlined,
                          actionLabel: 'Refresh',
                          onAction: _reload,
                        );
                      }
                      return MemoryPanel(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            for (var index = 0;
                                index < entries.length;
                                index++) ...[
                              if (index > 0)
                                const Divider(color: Colors.white10, height: 1),
                              _LeaderboardRow(
                                entry: entries[index],
                                current:
                                    widget.currentNickname?.toLowerCase() ==
                                        entries[index].nickname.toLowerCase(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Public scores contain nickname and game results only—never location.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  void _reload() => setState(() {
        _entries = widget.repository.leaderboard(_period);
      });

  String _label(MemoryLeaderboardPeriod value) => switch (value) {
        MemoryLeaderboardPeriod.today => 'Today',
        MemoryLeaderboardPeriod.week => 'This Week',
        MemoryLeaderboardPeriod.allTime => 'All Time',
      };
}

class _LeaderboardRow extends StatelessWidget {
  final MemoryLeaderboardEntry entry;
  final bool current;

  const _LeaderboardRow({required this.entry, required this.current});

  @override
  Widget build(BuildContext context) {
    final rank = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#${entry.rank}',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: current ? MemoryColors.cyan.withValues(alpha: 0.09) : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(rank,
                style: TextStyle(fontSize: entry.rank <= 3 ? 23 : 13)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: current ? MemoryColors.cyan : Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'Stage ${entry.stageReached} · ${entry.pairsFound} pairs · ${(entry.accuracyPermille / 10).round()}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '⭐ ${compactScore(entry.score)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: MemoryColors.yellow,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _LeaderboardState({
    required this.title,
    required this.icon,
    this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => MemoryPanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator(color: MemoryColors.cyan)
              else
                Icon(icon, size: 42, color: MemoryColors.purple),
              const SizedBox(height: 13),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (message != null) ...[
                const SizedBox(height: 7),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white54),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 13),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}
