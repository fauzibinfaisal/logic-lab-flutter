import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class HeroCinematicLayer extends StatefulWidget {
  const HeroCinematicLayer({super.key});

  @override
  State<HeroCinematicLayer> createState() => _HeroCinematicLayerState();
}

class _HeroCinematicLayerState extends State<HeroCinematicLayer> {
  late final String _viewType;
  web.HTMLVideoElement? _video;

  @override
  void initState() {
    super.initState();
    _viewType = 'portfolio-hero-video-${identityHashCode(this)}';

    final reducedMotion =
        web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    final video = web.HTMLVideoElement()
      ..src = 'assets/assets/video/hero-cinematic.mp4'
      ..poster = 'assets/assets/video/hero-cinematic-poster.jpg'
      ..autoplay = !reducedMotion
      ..loop = true
      ..muted = true
      ..preload = reducedMotion ? 'none' : 'metadata'
      ..controls = false;
    video
      ..setAttribute('playsinline', '')
      ..setAttribute('aria-hidden', 'true')
      ..setAttribute('tabindex', '-1');
    video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..objectPosition = 'center right'
      ..pointerEvents = 'none'
      ..backgroundColor = '#080D1A';

    _video = video;
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (_) => video,
    );
  }

  @override
  void dispose() {
    _video
      ?..pause()
      ..removeAttribute('src')
      ..load();
    _video = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Semantics(
          container: false,
          excludeSemantics: true,
          child: HtmlElementView(viewType: _viewType),
        ),
      );
}
