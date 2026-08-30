import 'package:flutter/material.dart';
import 'package:logic_lab/mini_apps/models/mini_app.dart';

const qiblaMiniApp = MiniAppDefinition(
  id: 'qibla',
  title: 'QIBLA App',
  description:
      'Find the direction of the Qibla wherever your journey takes you.',
  category: MiniAppCategory.traveling,
  icon: Icons.explore_rounded,
  accentColor: Color(0xFF6EE7B7),
);

const miniAppCatalog = [
  MiniAppCategoryDefinition(
    category: MiniAppCategory.traveling,
    title: 'Traveling Apps',
    description: 'Thoughtful utilities designed to travel light.',
    icon: Icons.flight_takeoff_rounded,
    apps: [qiblaMiniApp],
  ),
];
