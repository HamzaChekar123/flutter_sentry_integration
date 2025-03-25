import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/config/init_config.dart';
import 'package:test_sentry/home/presentation/home_page.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SentryWidgetsFlutterBinding.ensureInitialized();
    // Initialize Sentry first, before any other operations that might throw errors
    await initializeSentry();

    // Create a Sentry navigation observer for screen tracking
    final sentryNavigatorObserver = SentryNavigatorObserver();

    runApp(
      MyApp(navigatorObserver: sentryNavigatorObserver),
    );
  }, (error, stackTrace) {
    // This is your final fallback for errors that aren't caught elsewhere
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'error_type': 'uncaught_error'}),
    );
  });
}

// Add this to your MyApp widget
class MyApp extends StatelessWidget {
  final SentryNavigatorObserver navigatorObserver;

  const MyApp({super.key, required this.navigatorObserver});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add Sentry navigation observer
      navigatorObservers: [navigatorObserver],
      // Rest of your app configuration
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
