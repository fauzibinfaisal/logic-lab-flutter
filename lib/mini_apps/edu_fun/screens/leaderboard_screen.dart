import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/leaderboard_repository.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduLeaderboardScreen extends StatefulWidget {
  final LeaderboardRepository repository;
  final int initialAge;
  final String? currentNickname;
  final VoidCallback onBack;

  const EduLeaderboardScreen({
    super.key,
    required this.repository,
    required this.initialAge,
    required this.onBack,
    this.currentNickname,
  });

  @override
  State<EduLeaderboardScreen> createState() => _EduLeaderboardScreenState();
}

class _EduLeaderboardScreenState extends State<EduLeaderboardScreen> {
  late int _age;
  LeaderboardPeriod _period = LeaderboardPeriod.allTime;
  late Future<List<LeaderboardEntry>> _entries;

  static const _periodOrder = [
    LeaderboardPeriod.allTime,
    LeaderboardPeriod.week,
    LeaderboardPeriod.today,
  ];

  @override
  void initState() {
    super.initState();
    _age = widget.initialAge;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return EduScreen(
      child: Column(
        children: [
          EduSectionTitle(
            eyebrow: _periodEyebrow(_period),
            title: 'Leaderboard 🏆',
            subtitle: 'Every age has its own fair Number Adventure ranking.',
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                EduPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (final age in [5, 6, 7]) ...[
                            if (age != 5) const SizedBox(width: 8),
                            Expanded(
                              child: _FilterButton(
                                label: 'Age $age',
                                selected: _age == age,
                                onTap: () {
                                  setState(() => _age = age);
                                  _reload();
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          for (final period in _periodOrder)
                            ChoiceChip(
                              label: Text(_periodLabel(period)),
                              selected: _period == period,
                              onSelected: (_) {
                                setState(() => _period = period);
                                _reload();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FutureBuilder<List<LeaderboardEntry>>(
                  future: _entries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LeaderboardState(
                        icon: Icons.hourglass_top_rounded,
                        title: 'Loading champions…',
                        loading: true,
                      );
                    }
                    if (snapshot.hasError) {
                      return _LeaderboardState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Leaderboard unavailable',
                        message:
                            'Check your connection and try again. Your game can still continue.',
                        actionLabel: 'Try Again',
                        onAction: _reload,
                      );
                    }
                    final entries = snapshot.data ?? [];
                    if (entries.isEmpty) {
                      return _LeaderboardState(
                        icon: Icons.emoji_events_outlined,
                        title: 'Be the first champion!',
                        message: 'No scores yet for this age and period.',
                        actionLabel: 'Refresh',
                        onAction: _reload,
                      );
                    }
                    return EduPanel(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < entries.length;
                              index++) ...[
                            if (index > 0)
                              const Divider(color: Colors.white10, height: 1),
                            _LeaderboardRow(
                              entry: entries[index],
                              isCurrentPlayer:
                                  widget.currentNickname?.toLowerCase() ==
                                      entries[index].nickname.toLowerCase(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                Text(
                  'Only nickname, age, score, and rank are public. No location is sent or displayed.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reload() {
    setState(() {
      _entries = widget.repository.getLeaderboard(age: _age, period: _period);
    });
  }

  String _periodLabel(LeaderboardPeriod period) => switch (period) {
        LeaderboardPeriod.today => 'Today',
        LeaderboardPeriod.week => 'This Week',
        LeaderboardPeriod.allTime => 'All Time',
      };

  String _periodEyebrow(LeaderboardPeriod period) => switch (period) {
        LeaderboardPeriod.today => "TODAY'S CHAMPIONS",
        LeaderboardPeriod.week => "THIS WEEK'S CHAMPIONS",
        LeaderboardPeriod.allTime => 'ALL-TIME CHAMPIONS',
      };
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentPlayer;

  const _LeaderboardRow({required this.entry, required this.isCurrentPlayer});

  @override
  Widget build(BuildContext context) {
    final medal = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#${entry.rank}'
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? EduColors.yellow.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              medal,
              style: TextStyle(
                fontSize: entry.rank <= 3 ? 24 : 14,
                color: Colors.white60,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color:
                            isCurrentPlayer ? EduColors.yellow : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '${entry.correctAnswers}/10 · ${_duration(entry.completionTimeMs)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '⭐ ${entry.score}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: EduColors.yellow,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }

  String _duration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

class _LeaderboardState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _LeaderboardState({
    required this.icon,
    required this.title,
    this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => EduPanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              if (loading)
                const CircularProgressIndicator(color: EduColors.yellow)
              else
                Icon(icon, size: 42, color: EduColors.purple),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
                const SizedBox(height: 15),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? EduColors.yellow
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? EduColors.background : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      );
}
