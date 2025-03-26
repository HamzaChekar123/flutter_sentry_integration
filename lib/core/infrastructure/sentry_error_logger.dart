import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/infrastructure/sentry_config.dart';
import '../../../../core/error/error_logger.dart' as domain;

class SentryErrorLogger implements domain.ErrorLogger {
  final SentryConfig config;
  bool _isInitialized = false;

  SentryErrorLogger(this.config);

  @override
  void logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? message,
    Map<String, dynamic>? extras,
  }) {
    if (!_isInitialized) return;

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: message != null ? Hint.withMap({'message': message}) : null,
    );
  }

  @override
  void logMessage(
    String message, {
    domain.SeverityLevel severityLevel = domain.SeverityLevel.info,
    Map<String, dynamic>? extras,
  }) {
    if (!_isInitialized) return;

    final sentryLevel = _mapSeverityLevel(severityLevel);

    Sentry.captureMessage(
      message,
      level: sentryLevel,
    );
  }

  SentryLevel _mapSeverityLevel(domain.SeverityLevel level) {
    switch (level) {
      case domain.SeverityLevel.fatal:
        return SentryLevel.fatal;
      case domain.SeverityLevel.error:
        return SentryLevel.error;
      case domain.SeverityLevel.warning:
        return SentryLevel.warning;
      case domain.SeverityLevel.info:
        return SentryLevel.info;
      case domain.SeverityLevel.debug:
        return SentryLevel.debug;
    }
  }

  void setInitialized(bool value) {
    _isInitialized = value;
  }
}
