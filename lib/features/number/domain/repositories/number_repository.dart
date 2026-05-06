/// Domain-layer contract for number operations.
///
/// Implementations live in the data layer and are injected via the
/// service locator, keeping the domain layer dependency-free.
library;

/// Defines the interface for computing the reverse-difference of a number.
abstract class NumberRepository {
  /// Returns the absolute difference between [number] and its digit-reversal.
  ///
  /// Example: 21 → |21 - 12| = 9
  int computeReverseDifference(int number);
}
