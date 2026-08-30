import 'package:flutter/material.dart';

enum MiniAppCategory { traveling }

class MiniAppDefinition {
  final String id;
  final String title;
  final String description;
  final MiniAppCategory category;
  final IconData icon;
  final Color accentColor;

  const MiniAppDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.accentColor,
  });
}

class MiniAppCategoryDefinition {
  final MiniAppCategory category;
  final String title;
  final String description;
  final IconData icon;
  final List<MiniAppDefinition> apps;

  const MiniAppCategoryDefinition({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.apps,
  });
}
