/// Application entry point.
///
/// Initialises dependencies and launches the Flutter widget tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logic_lab/core/di/injection.dart';
import 'package:logic_lab/core/responsive/breakpoints.dart';
import 'package:logic_lab/core/theme/app_theme.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_bloc.dart';
import 'package:logic_lab/features/number/presentation/pages/number_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const LogicLabApp());
}

/// Root widget of the application.
class LogicLabApp extends StatelessWidget {
  const LogicLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogicLab',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: kBreakpoints,
      ),
      home: BlocProvider<NumberBloc>(
        create: (_) => sl<NumberBloc>(),
        child: const NumberPage(),
      ),
    );
  }
}
