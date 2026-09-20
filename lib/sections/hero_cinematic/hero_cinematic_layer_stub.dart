import 'package:flutter/material.dart';

class HeroCinematicLayer extends StatelessWidget {
  const HeroCinematicLayer({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/video/hero-cinematic-poster.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.centerRight,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      );
}
