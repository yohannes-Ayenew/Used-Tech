# Used Tech Client

A Flutter application for buying, selling, and managing used electronics and tech gadgets.

## Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Running the Application

```bash
# Get dependencies
flutter pub get

# Run on an attached device or emulator
flutter run
```

### Running Unit Tests

To run the full suite of unit and widget tests:

```bash
# Run all tests
flutter test

# Run core utility tests
flutter test test/core/utils/
```

## Project Architecture

The application follows Clean Architecture principles divided into core layers and feature modules:
- `lib/core`: Constants, error handling, network drivers, theme definitions, and utility helpers (`Validators`, `CurrencyFormatter`, `ErrorParser`).
- `lib/features`: Feature-based modules containing domain, data, and presentation layers.
- `test/`: Unit, widget, and integration tests mirroring `lib/`.
