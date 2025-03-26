# Test Sentry Project

This project is an implementation of Sentry, an error tracking and performance monitoring tool, with a focus on clean architecture, scalability, and performance.

## Features

- Integration with Sentry for error tracking.
- Example setup for monitoring application performance.
- Clean architecture for better scalability and maintainability.
- Error reporting and logging integrated into ViewModels and Repositories.

## Prerequisites

- [Sentry Account](https://sentry.io/)
- Basic knowledge of Flutter and Dart.

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/HamzaChekar123/flutter_sentry_integration
    cd test_sentry
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Configure Sentry:
    - Add your Sentry DSN to the configuration file (e.g., `lib/config.dart` or `.env`).

## Usage

Run the application:
```bash
flutter run
```

## Examples

### Using Error Reporter in a ViewModel

The following example demonstrates how to use the error reporter in a ViewModel to track user actions and errors:

```dart
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final ErrorReporterUseCase _errorReporter;

  AuthViewModel(this._repository, this._errorReporter) 
    : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    _errorReporter.addUserActionBreadcrumb('Login attempt', data: {'email': email});

    final result = await _repository.login(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );

        _errorReporter.addUserActionBreadcrumb(
          'Login failed',
          data: {'reason': failure.message},
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
        );

        _errorReporter.setUserContext(
          userId: user.id,
          email: user.email,
          username: user.displayName,
          additionalData: {
            'accountCreated': user.createdAt.toIso8601String(),
            'hasSubscription': user.hasActiveSubscription,
          },
        );

        _errorReporter.addUserActionBreadcrumb('Login successful');
      },
    );
  }

  void logout() {
    _errorReporter.addUserActionBreadcrumb('User logout');
    _errorReporter.clearUserContext();
    state = AuthState.initial();
  }
}
```

### Using the Error Logger in a Repository

The following example demonstrates how to use the error logger in a repository to log errors and stack traces:

```dart
class ProductRepository implements IProductRepository {
  final ProductApi _api;
  final ErrorLogger _errorLogger;

  ProductRepository(this._api, this._errorLogger);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final result = await _api.getProducts();
      return right(result.map((dto) => dto.toDomain()).toList());
    } on DioException catch (e, stackTrace) {
      final failure = ServerFailure(
        message: 'Failed to fetch products',
        statusCode: e.response?.statusCode,
        error: e,
        stackTrace: stackTrace,
      );
      _errorLogger.logError(
        e, 
        stackTrace,
        message: 'ProductRepository.getProducts failed',
        extras: {'status_code': e.response?.statusCode},
      );
      return left(failure);
    } catch (e, stackTrace) {
      final failure = UnexpectedFailure(
        message: 'Unexpected error fetching products',
        error: e,
        stackTrace: stackTrace,
      );
      _errorLogger.logError(
        e, 
        stackTrace, 
        message: 'ProductRepository.getProducts unexpected error',
      );
      return left(failure);
    }
  }
}
```

## Acknowledgments

- [Sentry Documentation](https://docs.sentry.io/)
- Open-source contributors.
- Inspiration from similar projects.
