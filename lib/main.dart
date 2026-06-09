library;

import 'package:flutter/material.dart';
import 'package:logic_lab/core/responsive/breakpoints.dart';
import 'package:logic_lab/core/theme/app_theme.dart';
import 'package:logic_lab/portfolio_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fauzi — Mobile Engineer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: kBreakpoints,
      ),
      home: const PortfolioPage(),
    );
  }
}
