// Config provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_sentry/core/application/error_reporter.dart';
import 'package:test_sentry/core/config/config_service.dart';
import 'package:test_sentry/core/domain/error_reporter_interface.dart';
import 'package:test_sentry/core/error/error_logger.dart';
import 'package:test_sentry/core/infrastructure/sentry_config.dart';
import 'package:test_sentry/core/infrastructure/sentry_error_logger.dart';
import 'package:test_sentry/core/infrastructure/sentry_initializer.dart';

final sentryConfigProvider = FutureProvider<SentryConfig>((ref) async {
  final configService = ref.read(configServiceProvider);
  return SentryConfig.create(configService: configService);
});

final errorReporterUseCaseProvider = Provider<ErrorReporterUseCase>((ref) {
  final reporter = ref.watch(errorReporterProvider);
  return ErrorReporterUseCase(reporter);
});
// Error Logger provider (Domain Interface)
final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  final config = ref.watch(sentryConfigProvider).valueOrNull;
  if (config == null) {
    throw StateError('SentryConfig must be initialized before accessing ErrorLogger');
  }
  return SentryErrorLogger(config);
});

// Error Reporter provider (Domain Interface)
final errorReporterProvider = Provider<ErrorReporterInterface>((ref) {
  final config = ref.watch(sentryConfigProvider).valueOrNull;
  if (config == null) {
    throw StateError('SentryConfig must be initialized before accessing ErrorReporter');
  }
  final errorLogger = ref.watch(errorLoggerProvider) as SentryErrorLogger;
  return SentryInitializer(
    config: config,
    errorLogger: errorLogger,
  );
});

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService()..initialize();
});
