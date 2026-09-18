import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/ble_packet_lab/ble_packet_lab_page.dart'
    deferred as ble_packet_lab;
import 'package:logic_lab/mini_apps/edu_fun/edu_fun_page.dart'
    deferred as edu_fun;
import 'package:logic_lab/mini_apps/memory_quest/memory_quest_page.dart'
    deferred as memory_quest;
import 'package:logic_lab/mini_apps/models/mini_app.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_page.dart' deferred as qibla;
import 'package:logic_lab/visit_counter/data/visit_counter_repository.dart';

class DeferredMiniAppPage extends StatefulWidget {
  final MiniAppDefinition app;
  final VoidCallback onExit;
  final VisitCounterRepository? visitCounterRepository;

  const DeferredMiniAppPage({
    super.key,
    required this.app,
    required this.onExit,
    this.visitCounterRepository,
  });

  @override
  State<DeferredMiniAppPage> createState() => _DeferredMiniAppPageState();
}

class _DeferredMiniAppPageState extends State<DeferredMiniAppPage> {
  late final VisitCounterRepository _visitCounterRepository;
  late Future<void> _loadFuture;
  int? _visitCount;
  bool _visitCountLoading = true;

  @override
  void initState() {
    super.initState();
    _visitCounterRepository =
        widget.visitCounterRepository ?? VisitCounterRepository();
    _loadFuture = _load();
    unawaited(_recordVisit());
  }

  @override
  void dispose() {
    if (widget.visitCounterRepository == null) {
      _visitCounterRepository.dispose();
    }
    super.dispose();
  }

  Future<void> _recordVisit() async {
    try {
      final counts = await _visitCounterRepository.recordVisit(widget.app.id);
      if (!mounted) return;
      setState(() {
        _visitCount = counts[widget.app.id];
        _visitCountLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _visitCountLoading = false);
    }
  }

  Future<void> _load() => switch (widget.app.id) {
        'qibla' => qibla.loadLibrary(),
        'ble-packet-lab' => ble_packet_lab.loadLibrary(),
        'number-adventure' => edu_fun.loadLibrary(),
        'memory-quest' => memory_quest.loadLibrary(),
        _ => Future<void>.error('Unknown mini app: ${widget.app.id}'),
      };

  Widget _loadedApp() => switch (widget.app.id) {
        'qibla' => qibla.QiblaPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
            onExit: widget.onExit,
          ),
        'ble-packet-lab' => ble_packet_lab.BlePacketLabPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
            onExit: widget.onExit,
          ),
        'number-adventure' => edu_fun.EduFunPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
            onExit: widget.onExit,
          ),
        'memory-quest' => memory_quest.MemoryQuestPage(
            visitCount: _visitCount,
            visitCountLoading: _visitCountLoading,
            onExit: widget.onExit,
          ),
        _ => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return _loadedApp();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF080D1A),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snapshot.hasError)
                      Icon(
                        Icons.cloud_off_rounded,
                        color: widget.app.accentColor,
                        size: 44,
                      )
                    else
                      CircularProgressIndicator(
                        color: widget.app.accentColor,
                      ),
                    const SizedBox(height: 22),
                    Text(
                      snapshot.hasError
                          ? 'Could not load ${widget.app.title}'
                          : 'Loading ${widget.app.title}…',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (snapshot.hasError) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                setState(() => _loadFuture = _load()),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
                          ),
                          TextButton.icon(
                            onPressed: widget.onExit,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to Mini Apps'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
