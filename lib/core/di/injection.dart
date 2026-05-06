/// Service locator configuration using get_it.
///
/// Call [configureDependencies] once at app startup to register all
/// singletons and factories before the widget tree is built.
library;

import 'package:get_it/get_it.dart';
import 'package:logic_lab/features/number/data/repositories/number_repository_impl.dart';
import 'package:logic_lab/features/number/domain/repositories/number_repository.dart';
import 'package:logic_lab/features/number/domain/usecases/compute_reverse_difference.dart';
import 'package:logic_lab/features/number/presentation/bloc/number_bloc.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Registers all dependencies in the correct dependency order.
void configureDependencies() {
  // Data layer
  sl.registerLazySingleton<NumberRepository>(() => const NumberRepositoryImpl());

  // Domain layer
  sl.registerLazySingleton<ComputeReverseDifference>(
    () => ComputeReverseDifference(sl<NumberRepository>()),
  );

  // Presentation layer
  sl.registerFactory<NumberBloc>(
    () => NumberBloc(computeReverseDifference: sl<ComputeReverseDifference>()),
  );
}
