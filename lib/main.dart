library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logic_lab/core/responsive/breakpoints.dart';
import 'package:logic_lab/core/theme/app_theme.dart';
import 'package:logic_lab/routing/app_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatefulWidget {
  final GoRouter? router;

  const PortfolioApp({super.key, this.router});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fauzi — Mobile Engineer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child ?? const SizedBox.shrink(),
        breakpoints: kBreakpoints,
      ),
      routerConfig: _router,
    );
  }
}
