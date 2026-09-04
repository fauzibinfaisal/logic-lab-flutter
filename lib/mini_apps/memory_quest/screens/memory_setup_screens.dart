import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/memory_quest/models/memory_models.dart';
import 'package:logic_lab/mini_apps/memory_quest/widgets/memory_components.dart';

class MemorySoloSetupScreen extends StatefulWidget {
  final MemoryPlayer? initialPlayer;
  final ValueChanged<MemoryPlayer> onStart;
  final VoidCallback onBack;

  const MemorySoloSetupScreen({
    super.key,
    required this.onStart,
    required this.onBack,
    this.initialPlayer,
  });

  @override
  State<MemorySoloSetupScreen> createState() => _MemorySoloSetupScreenState();
}

class _MemorySoloSetupScreenState extends State<MemorySoloSetupScreen> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPlayer?.nickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MemoryScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MemoryTitle(
              eyebrow: 'SOLO PLAYER',
              title: 'What should we call you?',
              subtitle:
                  'Use a nickname—not a full name. No age or location is needed.',
            ),
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: MemoryPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLength: 16,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Nickname',
                        hintText: 'Example: Bima',
                        errorText: _error,
                        prefixIcon: const Icon(Icons.face_rounded),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    MemoryPrimaryButton(
                      label: 'START GAME',
                      onPressed: _submit,
                      icon: Icons.play_arrow_rounded,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: widget.onBack, child: const Text('Back')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void _submit() {
    final nickname = _controller.text.trim();
    if (!_validNickname(nickname)) {
      setState(() => _error = 'Use 1–16 letters, numbers, spaces, _ or -.');
      return;
    }
    widget.onStart(MemoryPlayer(nickname: nickname));
  }
}

class MemoryDuelSetupScreen extends StatefulWidget {
  final String? suggestedPlayerOne;
  final void Function(String playerOne, String playerTwo) onStart;
  final VoidCallback onBack;

  const MemoryDuelSetupScreen({
    super.key,
    required this.onStart,
    required this.onBack,
    this.suggestedPlayerOne,
  });

  @override
  State<MemoryDuelSetupScreen> createState() => _MemoryDuelSetupScreenState();
}

class _MemoryDuelSetupScreenState extends State<MemoryDuelSetupScreen> {
  late final TextEditingController _one;
  final _two = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _one = TextEditingController(text: widget.suggestedPlayerOne);
  }

  @override
  void dispose() {
    _one.dispose();
    _two.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MemoryScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MemoryTitle(
              eyebrow: 'MEMORY DUEL',
              title: "Who's playing? ⚔️",
              subtitle:
                  'Match a pair to keep your turn. Miss and pass the device.',
            ),
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: MemoryPanel(
                child: Column(
                  children: [
                    _nameField(
                        _one, 'Player 1 nickname', Icons.looks_one_rounded),
                    const SizedBox(height: 12),
                    _nameField(
                        _two, 'Player 2 nickname', Icons.looks_two_rounded),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: MemoryColors.pink),
                      ),
                    ],
                    const SizedBox(height: 18),
                    MemoryPrimaryButton(
                      label: 'START DUEL',
                      onPressed: _submit,
                      icon: Icons.sports_esports_rounded,
                      color: MemoryColors.cyan,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: widget.onBack, child: const Text('Back')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _nameField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) =>
      TextField(
        controller: controller,
        maxLength: 16,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );

  void _submit() {
    final one = _one.text.trim();
    final two = _two.text.trim();
    if (!_validNickname(one) || !_validNickname(two)) {
      setState(() => _error = 'Use 1–16 safe characters for both players.');
      return;
    }
    if (one.toLowerCase() == two.toLowerCase()) {
      setState(() => _error = 'Players need different nicknames.');
      return;
    }
    widget.onStart(one, two);
  }
}

bool _validNickname(String value) =>
    value.isNotEmpty &&
    value.length <= 16 &&
    RegExp(r'^[\p{L}\p{N}_ -]+$', unicode: true).hasMatch(value);
