import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/application/error_handler.dart';
import 'package:test_sentry/core/presentation/app_widget.dart';

import 'package:test_sentry/core/shared/providers.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //* Create a future provider container to load async dependencies
    final container = ProviderContainer();

    //* Initialize Sentry first to capture any errors during startup
    final sentryConfig = await container.read(sentryConfigProvider.future);
    final errorLogger = container.read(errorLoggerProvider);
    final errorReporter = container.read(errorReporterProvider);

    //* Initialize error reporter
    await errorReporter.initialize();

    //* Create the final container with observers
    final appContainer = ProviderContainer(
      observers: [
        ErrorHandler(errorLogger),
      ],
      //* Keep the initialized providers
      overrides: [
        sentryConfigProvider.overrideWith((ref) async => sentryConfig),
      ],
    );

    //* Run the app within the provider scope
    runApp(
      UncontrolledProviderScope(
        container: appContainer,
        child: const AppWidget(),
      ),
    );
  }, (error, stackTrace) {
    //* This is the last resort error handler
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'source': 'uncaught_zone_error'}),
    );
  });
}
