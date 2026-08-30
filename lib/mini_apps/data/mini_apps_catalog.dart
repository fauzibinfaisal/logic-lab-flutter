import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/models/mini_app.dart';

const qiblaMiniApp = MiniAppDefinition(
  id: 'qibla',
  title: 'QIBLA App',
  description:
      'Find the direction of the Qibla wherever your journey takes you.',
  eyebrow: 'TRAVEL UTILITY',
  category: MiniAppCategory.traveling,
  icon: Icons.explore_rounded,
  accentColor: Color(0xFF6EE7B7),
);

const numberAdventureMiniApp = MiniAppDefinition(
  id: 'number-adventure',
  title: 'Number Adventure',
  description:
      'Play 10 colorful math and logic challenges made for young thinkers aged 5–7.',
  eyebrow: 'EDU FUN GAME',
  category: MiniAppCategory.eduFun,
  icon: Icons.psychology_alt_rounded,
  accentColor: Color(0xFFFFC857),
);

const miniAppCatalog = [
  MiniAppCategoryDefinition(
    category: MiniAppCategory.traveling,
    title: 'Traveling Apps',
    description: 'Thoughtful utilities designed to travel light.',
    icon: Icons.flight_takeoff_rounded,
    apps: [qiblaMiniApp],
  ),
  MiniAppCategoryDefinition(
    category: MiniAppCategory.eduFun,
    title: 'Edu Fun',
    description: 'Playful learning experiences for curious young minds.',
    icon: Icons.auto_awesome_rounded,
    apps: [numberAdventureMiniApp],
  ),
];
