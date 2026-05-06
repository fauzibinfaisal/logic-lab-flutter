/// BLoC events for the number feature.
///
/// Events are immutable value objects dispatched by the UI layer.
library;

import 'package:equatable/equatable.dart';

/// Base class for all number-feature events.
sealed class NumberEvent extends Equatable {
  const NumberEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user submits a number for computation.
final class NumberSubmitted extends NumberEvent {
  const NumberSubmitted(this.input);

  /// The raw string value from the text field.
  final String input;

  @override
  List<Object?> get props => [input];
}

/// Fired when the user clears or resets the input field.
final class NumberReset extends NumberEvent {
  const NumberReset();
}
