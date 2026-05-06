/// Unit tests for [ComputeReverseDifference].
///
/// Tests verify the use-case logic in isolation using a mocked repository.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logic_lab/features/number/domain/repositories/number_repository.dart';
import 'package:logic_lab/features/number/domain/usecases/compute_reverse_difference.dart';

class _MockNumberRepository extends Mock implements NumberRepository {}

void main() {
  late _MockNumberRepository repository;
  late ComputeReverseDifference useCase;

  setUp(() {
    repository = _MockNumberRepository();
    useCase = ComputeReverseDifference(repository);
  });

  group('ComputeReverseDifference', () {
    test('returns result from repository for valid input', () {
      when(() => repository.computeReverseDifference(21)).thenReturn(9);

      final result = useCase('21');

      expect(result, 9);
      verify(() => repository.computeReverseDifference(21)).called(1);
    });

    test('returns 27 for input "30"', () {
      when(() => repository.computeReverseDifference(30)).thenReturn(27);

      final result = useCase('30');

      expect(result, 27);
    });

    test('throws ArgumentError for empty input', () {
      expect(() => useCase(''), throwsArgumentError);
      verifyNever(() => repository.computeReverseDifference(any()));
    });

    test('throws ArgumentError for non-numeric input', () {
      expect(() => useCase('abc'), throwsArgumentError);
      verifyNever(() => repository.computeReverseDifference(any()));
    });

    test('returns 0 for a palindrome number', () {
      when(() => repository.computeReverseDifference(121)).thenReturn(0);

      final result = useCase('121');

      expect(result, 0);
    });
  });
}
