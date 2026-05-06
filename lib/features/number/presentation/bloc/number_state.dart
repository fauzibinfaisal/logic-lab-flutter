/// BLoC states for the number feature.
///
/// States are immutable value objects emitted by [NumberBloc].
library;

import 'package:equatable/equatable.dart';

/// Base class for all number-feature states.
sealed class NumberState extends Equatable {
  const NumberState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the user has submitted any input.
final class NumberInitial extends NumberState {
  const NumberInitial();
}

/// Emitted while the computation is in progress.
final class NumberLoading extends NumberState {
  const NumberLoading();
}

/// Emitted when computation completes successfully.
final class NumberSuccess extends NumberState {
  const NumberSuccess({
    required this.original,
    required this.reversed,
    required this.difference,
  });

  /// The original parsed integer.
  final int original;

  /// The digit-reversed integer.
  final int reversed;

  /// The absolute difference between [original] and [reversed].
  final int difference;

  @override
  List<Object?> get props => [original, reversed, difference];
}

/// Emitted when an error occurs during validation or computation.
final class NumberError extends NumberState {
  const NumberError(this.message);

  /// Human-readable description of the error.
  final String message;

  @override
  List<Object?> get props => [message];
}
