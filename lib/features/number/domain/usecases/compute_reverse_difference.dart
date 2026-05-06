/// Use case that delegates reverse-difference computation to the repository.
///
/// This is the single entry point for domain logic from the presentation layer.
library;

import 'package:logic_lab/features/number/domain/repositories/number_repository.dart';

/// Computes the absolute difference between a number and its digit-reversal.
///
/// Depends on [NumberRepository] which is injected at construction time.
class ComputeReverseDifference {
  /// Creates an instance bound to the provided [repository].
  const ComputeReverseDifference(this._repository);

  final NumberRepository _repository;

  /// Executes the use case with the given [number] string.
  ///
  /// Parses the string to an integer, then delegates to the repository.
  /// Throws [ArgumentError] if [number] is empty or cannot be parsed.
  int call(String number) {
    if (number.isEmpty) throw ArgumentError('Input must not be empty.');
    final parsed = int.tryParse(number);
    if (parsed == null) throw ArgumentError('Input must be a valid integer.');
    return _repository.computeReverseDifference(parsed);
  }
}
