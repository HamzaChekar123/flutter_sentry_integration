import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_sentry/core/application/failure.dart';
import 'package:test_sentry/core/error/error_logger.dart';


class ErrorHandler extends ProviderObserver {
  final ErrorLogger _errorLogger;
  
  ErrorHandler(this._errorLogger);
  
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _errorLogger.logError(
      error,
      stackTrace,
      extras: {
        'source': 'provider_error',
        'provider': provider.name ?? provider.runtimeType.toString(),
      },
    );
    super.providerDidFail(provider, error, stackTrace, container);
  }
  
  void handleFailure(Failure failure) {
    _errorLogger.logError(
      failure.error,
      failure.stackTrace,
      message: failure.message,
      extras: {
        'failure_type': failure.runtimeType.toString(),
        ...failure.properties,
      },
    );
  }
}