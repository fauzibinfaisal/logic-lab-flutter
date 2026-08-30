import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/edu_fun/data/approximate_location.dart';
import 'package:logic_lab/mini_apps/edu_fun/models/edu_fun_models.dart';
import 'package:logic_lab/mini_apps/edu_fun/widgets/edu_components.dart';

class EduProfileScreen extends StatefulWidget {
  final EduPlayer? initialPlayer;
  final ValueChanged<EduPlayer> onContinue;

  const EduProfileScreen({
    super.key,
    this.initialPlayer,
    required this.onContinue,
  });

  @override
  State<EduProfileScreen> createState() => _EduProfileScreenState();
}

class _EduProfileScreenState extends State<EduProfileScreen> {
  late final TextEditingController _nameController;
  int? _age;
  String _location = 'Unknown';
  bool _findingLocation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialPlayer?.nickname ?? '',
    );
    _age = widget.initialPlayer?.age;
    _location = widget.initialPlayer?.location ?? 'Unknown';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return EduScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EduSectionTitle(
            eyebrow: 'PLAYER SETUP',
            title: 'Who is playing today? 👋',
            subtitle: 'A nickname and age help us choose the right adventure.',
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: EduPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's your nickname?",
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    maxLength: 16,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Example: Bima',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      prefixIcon: const Icon(Icons.face_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'How old are you?',
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final age in [5, 6, 7]) ...[
                        if (age != 5) const SizedBox(width: 10),
                        Expanded(
                          child: _AgeCard(
                            age: age,
                            selected: _age == age,
                            onTap: () => setState(() => _age = age),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: EduColors.cyan.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: EduColors.cyan.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_city_rounded,
                          color: EduColors.cyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _location == 'Unknown'
                                    ? 'Approximate city (optional)'
                                    : _location,
                                style: tt.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Precise coordinates are never saved or sent to the leaderboard.',
                                style: tt.bodySmall?.copyWith(
                                  color: Colors.white54,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _findingLocation ? null : _findCity,
                          child: _findingLocation
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Detect'),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: tt.bodySmall?.copyWith(color: EduColors.pink),
                    ),
                  ],
                  const SizedBox(height: 24),
                  EduPrimaryButton(
                    label: "LET'S PLAY",
                    onPressed: _submit,
                    icon: Icons.rocket_launch_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _findCity() async {
    setState(() => _findingLocation = true);
    try {
      final city = await ApproximateLocation.detectCity();
      if (!mounted) return;
      setState(() {
        _findingLocation = false;
        _location = city ?? 'Unknown';
      });
    } catch (_) {
      if (mounted) setState(() => _findingLocation = false);
    }
  }

  void _submit() {
    final nickname = _nameController.text.trim();
    if (nickname.isEmpty || _age == null) {
      setState(() => _error = 'Choose a nickname and age to continue.');
      return;
    }
    if (!RegExp(r'^[\p{L}\p{N}_ -]+$', unicode: true).hasMatch(nickname)) {
      setState(() => _error = 'Use letters or numbers for the nickname.');
      return;
    }
    widget.onContinue(
      EduPlayer(nickname: nickname, age: _age!, location: _location),
    );
  }
}

class _AgeCard extends StatelessWidget {
  final int age;
  final bool selected;
  final VoidCallback onTap;

  const _AgeCard(
      {required this.age, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Age $age',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 82,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? EduColors.yellow
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? EduColors.yellow : Colors.white12,
              width: 2,
            ),
          ),
          child: Text(
            '$age',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: selected ? EduColors.background : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}
