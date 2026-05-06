/// BLoC that orchestrates number reversal computation.
///
/// Reacts to [NumberEvent]s and emits [NumberState]s.
/// Business logic is delegated entirely to [ComputeReverseDifference].
///
/// The [debounceDuration] parameter defaults to 400 ms in production and
/// can be set to [Duration.zero] in tests to skip debounce timing.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logic_lab/features/number/domain/usecases/compute_reverse_difference.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_event.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_state.dart';

/// Manages state for the number reversal feature.
class NumberBloc extends Bloc<NumberEvent, NumberState> {
  /// Creates the BLoC bound to [computeReverseDifference].
  ///
  /// Pass [debounceDuration] as [Duration.zero] in tests to disable debounce.
  NumberBloc({
    required ComputeReverseDifference computeReverseDifference,
    Duration debounceDuration = const Duration(milliseconds: 400),
  })  : _computeReverseDifference = computeReverseDifference,
        _debounceDuration = debounceDuration,
        super(const NumberInitial()) {
    on<NumberSubmitted>(_onSubmitted, transformer: _debounce());
    on<NumberReset>(_onReset);
  }

  final ComputeReverseDifference _computeReverseDifference;
  final Duration _debounceDuration;

  /// Handles [NumberSubmitted] after the debounce window closes.
  Future<void> _onSubmitted(
    NumberSubmitted event,
    Emitter<NumberState> emit,
  ) async {
    if (event.input.trim().isEmpty) {
      emit(const NumberError('Please enter a number.'));
      return;
    }

    emit(const NumberLoading());

    // Simulates async work (e.g. a future network call or heavy computation).
    await Future<void>.delayed(const Duration(milliseconds: 300));

    try {
      final parsed = int.parse(event.input);
      final difference = _computeReverseDifference(event.input);
      final reversed = _reverseOf(parsed);
      emit(NumberSuccess(
        original: parsed,
        reversed: reversed,
        difference: difference,
      ));
    } on ArgumentError catch (e) {
      emit(NumberError(e.message.toString()));
    } catch (_) {
      emit(const NumberError('An unexpected error occurred.'));
    }
  }

  void _onReset(NumberReset event, Emitter<NumberState> emit) {
    emit(const NumberInitial());
  }

  /// Reverses the digits of [n] for display purposes.
  int _reverseOf(int n) {
    final reversed = n.abs().toString().split('').reversed.join();
    return int.parse(reversed);
  }

  /// Returns an [EventTransformer] that debounces by [_debounceDuration].
  EventTransformer<NumberSubmitted> _debounce() {
    return (events, mapper) =>
        events.debounceTime(_debounceDuration).asyncExpand(mapper);
  }
}

extension _DebounceX<T> on Stream<T> {
  /// Emits an item from the source only after [duration] of silence.
  Stream<T> debounceTime(Duration duration) {
    if (duration == Duration.zero) return this;

    late StreamController<T> controller;
    Timer? timer;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          (event) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (!controller.isClosed) controller.add(event);
            });
          },
          onError: (Object e, StackTrace s) => controller.addError(e, s),
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
