# LogicLab

A production-ready Flutter application that computes the absolute difference between a number and its digit-reversal. Demonstrates Clean Architecture, BLoC state management, responsive UI, and a full testing suite.

## Features

- Enter any positive integer → get `|original - reversed|`
- Digit-only input enforced via `FilteringTextInputFormatter`
- Animated result / error cards
- Responsive across Mobile, Tablet, and Desktop breakpoints

## Architecture

```
lib/
├── core/
│   ├── di/            # Dependency injection (get_it)
│   ├── responsive/    # Breakpoint definitions
│   └── theme/         # Material 3 theme
└── features/number/
    ├── data/repositories/        # NumberRepositoryImpl
    ├── domain/
    │   ├── repositories/         # NumberRepository (abstract)
    │   └── usecases/             # ComputeReverseDifference
    └── presentation/
        ├── bloc/                 # NumberBloc · Events · States
        └── pages/                # NumberPage (full UI)
```

| Layer        | Responsibility                         |
|--------------|----------------------------------------|
| Data         | Arithmetic implementation              |
| Domain       | Use-case contract & repository interface |
| Presentation | BLoC orchestration + Flutter widgets   |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on your target platform
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run                    # Connected device
```

## Running Tests

```bash
# Unit & BLoC tests (11 tests)
flutter test test/usecase/ test/bloc/ --reporter=expanded

# Generate golden baselines (run once)
flutter test test/golden/ --update-goldens

# Verify goldens
flutter test test/golden/
```

## Business Logic Examples

| Input | Reversed | Result |
|-------|----------|--------|
| 21    | 12       | 9      |
| 30    | 3        | 27     |
| 121   | 121      | 0      |
| 1.2   | → 12 (digits only) → 21 | 9 |

## Dependencies

| Package              | Purpose                         |
|----------------------|---------------------------------|
| `flutter_bloc`       | BLoC state management           |
| `equatable`          | Value equality for states/events|
| `responsive_framework` | Responsive breakpoints        |
| `get_it`             | Dependency injection            |
| `bloc_test`          | BLoC testing utilities          |
| `mocktail`           | Mock generation for tests       |
| `golden_toolkit`     | Widget snapshot tests           |
