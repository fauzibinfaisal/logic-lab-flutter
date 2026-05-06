/// Golden tests for the [NumberPage] widget.
///
/// Run `flutter test --update-goldens` once to generate baseline snapshots.
/// Subsequent runs compare against those snapshots to detect UI regressions.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:logic_lab/core/responsive/breakpoints.dart';
import 'package:logic_lab/core/theme/app_theme.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_bloc.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_event.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_state.dart';
import 'package:logic_lab/features/number/presentation/pages/number_page.dart';

// ---------------------------------------------------------------------------
// Mock BLoC
// ---------------------------------------------------------------------------

class _MockNumberBloc extends MockBloc<NumberEvent, NumberState>
    implements NumberBloc {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildSubject({
  required NumberState state,
  required Size size,
}) {
  final bloc = _MockNumberBloc();
  whenListen(bloc, Stream.value(state), initialState: state);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    builder: (context, child) => ResponsiveBreakpoints.builder(
      child: child!,
      breakpoints: kBreakpoints,
    ),
    home: BlocProvider<NumberBloc>.value(
      value: bloc,
      child: const NumberPage(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(loadAppFonts);

  group('NumberPage golden tests', () {
    testGoldens('initial state – mobile', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildSubject(state: const NumberInitial(), size: const Size(390, 844)),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, 'number_page_initial_mobile');
    });

    testGoldens('success state – mobile', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildSubject(
          state: const NumberSuccess(
            original: 21,
            reversed: 12,
            difference: 9,
          ),
          size: const Size(390, 844),
        ),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, 'number_page_success_mobile');
    });

    testGoldens('error state – mobile', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildSubject(
          state: const NumberError('Please enter a number.'),
          size: const Size(390, 844),
        ),
        surfaceSize: const Size(390, 844),
      );
      await screenMatchesGolden(tester, 'number_page_error_mobile');
    });

    testGoldens('initial state – desktop', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildSubject(
            state: const NumberInitial(), size: const Size(1280, 800)),
        surfaceSize: const Size(1280, 800),
      );
      await screenMatchesGolden(tester, 'number_page_initial_desktop');
    });
  });
}
