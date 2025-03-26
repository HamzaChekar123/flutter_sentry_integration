import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/domain/error_reporter_interface.dart';
import 'package:test_sentry/core/infrastructure/sentry_config.dart';
import 'package:test_sentry/core/infrastructure/sentry_error_logger.dart';
import 'package:test_sentry/core/presentation/widgets/error_widget.dart';

class SentryInitializer implements ErrorReporterInterface {
  final SentryConfig config;
  final SentryErrorLogger errorLogger;
  bool _isInitialized = false;

  SentryInitializer({
    required this.config,
    required this.errorLogger,
  });

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await SentryFlutter.init(
      (options) {
        //* Core configuration
        options.dsn = config.dsn;
        options.release = config.release;
        options.environment = config.environment;
        options.dist = config.dist;

        //* Better stack traces
        options.considerInAppFramesByDefault = false;
        for (final package in config.inAppIncludes) {
          options.addInAppInclude(package);
        }

        //* Performance monitoring
        options.tracesSampleRate = config.isProduction ? 0.1 : 1.0;
        options.profilesSampleRate = config.isProduction ? 0.1 : 1.0;
        options.enableAutoPerformanceTracing = true;

        //* Debugging tools
        options.attachScreenshot = config.attachScreenshot;
        options.attachViewHierarchy = config.attachViewHierarchy;

        //* App behavior monitoring
        options.enableAutoSessionTracking = true;
        options.enableNativeCrashHandling = true;
        options.anrEnabled = true;
        options.enablePrintBreadcrumbs = true;

        // Error handling
        options.beforeSend = _filterEvents;
      },
    );

    _isInitialized = true;
    errorLogger.setInitialized(true);

    _registerErrorHandlers();
  }

  SentryEvent? _filterEvents(SentryEvent event, dynamic hint) {
    //* Skip debug mode events
    if (kDebugMode) {
      return null;
    }

    //* Handle network errors
    final exception = event.throwable;
    if (exception is DioException && exception.response == null) {
      //* Network connectivity errors
      return null;
    }

    //* Process backend errors with custom fingerprinting
    final exceptions = event.exceptions;
    if (exceptions != null && exceptions.isNotEmpty) {
      final exceptionValue = exceptions.first.value;
      if (exceptionValue != null && exceptionValue.contains("500")) {
        return event.copyWith(fingerprint: ['backend-error']);
      }
    }

    return event;
  }

  void _registerErrorHandlers() {
    //* Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      errorLogger.logError(
        details.exception,
        details.stack,
        extras: {'source': 'flutter_error', 'context': details.context?.toString()},
      );
    };

    //* Platform dispatcher errors
    PlatformDispatcher.instance.onError = (error, stack) {
      errorLogger.logError(
        error,
        stack,
        extras: {'source': 'platform_dispatcher'},
      );
      return true;
    };

    //* Custom error widget when app UI fails to build
    if (kReleaseMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        errorLogger.logError(
          details.exception,
          details.stack,
          extras: {'source': 'error_widget'},
        );
        return const ErrorFallbackWidget();
      };
    }
  }

  @override
  void setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        email: email,
        username: username,
        data: data,
      ));
    });
  }

  @override
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    String? type,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      type: type,
    ));
  }

  @override
  void clearContext() {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) => scope.clear());
  }
}
