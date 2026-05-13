/// Application entry point.
///
/// Launches the Flutter widget tree.
library;

import 'package:flutter/material.dart';
import 'package:logic_lab/core/responsive/breakpoints.dart';
import 'package:logic_lab/core/theme/app_theme.dart';
import 'package:logic_lab/company_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartTbkApp());
}

/// Root widget of the application.
class SmartTbkApp extends StatelessWidget {
  const SmartTbkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PT SMART Tbk',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: kBreakpoints,
      ),
      home: const CompanyPage(),
    );
  }
}
