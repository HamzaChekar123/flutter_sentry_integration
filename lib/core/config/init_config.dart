import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/functions/functions.dart';
import 'package:test_sentry/core/presentation/error_screen_page.dart';
import 'package:test_sentry/env/environment.dart';

Future<void> initializeSentry() async {
  // Get app version info
  final packageInfo = await PackageInfo.fromPlatform();
  final release = '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';

  // Get device info for context
  final deviceInfo = DeviceInfoPlugin();
  final deviceData = await getDeviceData(deviceInfo);

  await SentryFlutter.init(
    (options) {
      // Core configuration
      options.dsn = sentryDSN;
      options.environment = environment;
      options.release = release;
      options.dist = packageInfo.buildNumber;

      // Privacy & data
      options.sendDefaultPii = true; // Only enable if you have user consent

      // Performance monitoring
      options.tracesSampleRate = environment == 'production' ? 0.1 : 1.0; // Sample less in production
      options.profilesSampleRate = environment == 'production' ? 0.1 : 1.0;
      options.enableAutoPerformanceTracing = true;
      options.enableTimeToFullDisplayTracing = true;
      options.enableUserInteractionTracing = true;

      // Debugging tools
      options.attachScreenshot = !kReleaseMode; // Only in development
      options.attachViewHierarchy = !kReleaseMode;
      options.screenshotQuality = SentryScreenshotQuality.low;

      // App behavior monitoring
      options.enableAutoSessionTracking = true;
      options.enableNativeCrashHandling = true;
      options.anrEnabled = true;

      // Error handling
      options.beforeSend = (event, hint) {
        // Don't send events in debug mode
        if (kDebugMode && environment != 'development') {
          return null;
        }

        // Custom fingerprinting
        final exceptions = event.exceptions;
        if (exceptions != null && exceptions.isNotEmpty) {
          final exceptionValue = exceptions.first.value;
          if (exceptionValue != null) {
            // Backend error pattern
            if (exceptionValue.contains("500")) {
              return event.copyWith(fingerprint: ['backend-error']);
            }

            // Network error patterns
            if (exceptionValue.contains("SocketException") || exceptionValue.contains("TimeoutException")) {
              return event.copyWith(fingerprint: ['network-connectivity-error']);
            }

            // Authentication errors
            if (exceptionValue.contains("401") || exceptionValue.contains("403")) {
              return event.copyWith(fingerprint: ['authentication-error']);
            }
          }
        }

        // Add global context to all events
        return event.copyWith(
          contexts: Contexts(
            device: SentryDevice(
              model: deviceData['model'],
            ),
            app: SentryApp(
              version: packageInfo.version,
              build: packageInfo.buildNumber,
              identifier: packageInfo.packageName,
            ),
          ),
        );
      };
    },
    appRunner: runAppWithErrorHandlers(),
  );
}

void Function() runAppWithErrorHandlers() {
  return () {
    runZonedGuarded(() {
      // Flutter error handler
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kDebugMode) {
          FlutterError.presentError(details);
        } else {
          FlutterError.presentError(details);
          Sentry.captureException(details.exception, stackTrace: details.stack);
        }
      };

      // Platform dispatcher error handler
      PlatformDispatcher.instance.onError = (error, stack) {
        Sentry.captureException(error, stackTrace: stack);
        return true;
      };

      // Custom error widget
      ErrorWidget.builder = (FlutterErrorDetails details) {
        Sentry.captureException(details.exception, stackTrace: details.stack);
        return const ErrorScreenPage();
      };
      // Return a user-friendly error page
    }, (error, stackTrace) {
      // This catches errors that aren't caught by other handlers
      Sentry.configureScope((scope) {
        scope.setTag('error_type', 'uncaught_error');
      });

      Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    });
  };
}
