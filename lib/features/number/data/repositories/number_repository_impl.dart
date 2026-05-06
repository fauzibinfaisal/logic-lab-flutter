/// Data-layer implementation of [NumberRepository].
///
/// All arithmetic logic is contained here, keeping the domain layer pure.
library;

import 'package:logic_lab/features/number/domain/repositories/number_repository.dart';

/// Implements the reverse-difference computation defined by [NumberRepository].
class NumberRepositoryImpl implements NumberRepository {
  const NumberRepositoryImpl();

  @override
  int computeReverseDifference(int number) {
    final reversed = _reverse(number);
    return (number - reversed).abs();
  }

  /// Reverses the digits of [n], stripping any trailing zeros that become
  /// leading zeros after reversal (e.g. 30 → 3).
  int _reverse(int n) {
    final reversed = n.abs().toString().split('').reversed.join();
    return int.parse(reversed);
  }
}
