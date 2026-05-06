/// BLoC tests for [NumberBloc].
///
/// All BLoC instances are constructed with [debounceDuration] set to
/// [Duration.zero] so tests are fast and deterministic.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logic_lab/features/number/domain/repositories/number_repository.dart';
import 'package:logic_lab/features/number/domain/usecases/compute_reverse_difference.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_bloc.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_event.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_state.dart';

class _MockNumberRepository extends Mock implements NumberRepository {}

/// Factory that disables debounce for testing.
NumberBloc _buildBloc(NumberRepository repo) => NumberBloc(
      computeReverseDifference: ComputeReverseDifference(repo),
      debounceDuration: Duration.zero,
    );

void main() {
  late _MockNumberRepository repository;

  setUp(() {
    repository = _MockNumberRepository();
  });

  group('NumberBloc', () {
    test('initial state is NumberInitial', () {
      expect(_buildBloc(repository).state, const NumberInitial());
    });

    blocTest<NumberBloc, NumberState>(
      'emits [NumberLoading, NumberSuccess] for valid input "21"',
      build: () {
        when(() => repository.computeReverseDifference(21)).thenReturn(9);
        return _buildBloc(repository);
      },
      act: (bloc) => bloc.add(const NumberSubmitted('21')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const NumberLoading(),
        const NumberSuccess(original: 21, reversed: 12, difference: 9),
      ],
    );

    blocTest<NumberBloc, NumberState>(
      'emits [NumberLoading, NumberSuccess] for input "30"',
      build: () {
        when(() => repository.computeReverseDifference(30)).thenReturn(27);
        return _buildBloc(repository);
      },
      act: (bloc) => bloc.add(const NumberSubmitted('30')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const NumberLoading(),
        const NumberSuccess(original: 30, reversed: 3, difference: 27),
      ],
    );

    blocTest<NumberBloc, NumberState>(
      'emits [NumberError] for empty input without reaching Loading',
      build: () => _buildBloc(repository),
      act: (bloc) => bloc.add(const NumberSubmitted('')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const NumberError('Please enter a number.'),
      ],
    );

    blocTest<NumberBloc, NumberState>(
      'emits [NumberInitial] after NumberReset',
      build: () {
        when(() => repository.computeReverseDifference(21)).thenReturn(9);
        return _buildBloc(repository);
      },
      act: (bloc) async {
        bloc.add(const NumberSubmitted('21'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.add(const NumberReset());
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const NumberLoading(),
        const NumberSuccess(original: 21, reversed: 12, difference: 9),
        const NumberInitial(),
      ],
    );

    blocTest<NumberBloc, NumberState>(
      'returns 0 for palindrome input "121"',
      build: () {
        when(() => repository.computeReverseDifference(121)).thenReturn(0);
        return _buildBloc(repository);
      },
      act: (bloc) => bloc.add(const NumberSubmitted('121')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const NumberLoading(),
        const NumberSuccess(original: 121, reversed: 121, difference: 0),
      ],
    );
  });
}
