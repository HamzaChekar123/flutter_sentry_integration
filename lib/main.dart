import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/core/presentation/app_widget.dart';

import 'package:test_sentry/env/environment.dart';

Future<void> main() async {
  final sentryRelase = await getReleaseName();
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      options.release = sentryRelase;
      // Adds request headers and IP for users,
      // visit: https://docs.sentry.io/platforms/dart/data-management/data-collected/ for more info
      options.sendDefaultPii = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: const AppWidget(),
      ),
    ),
  );

  // or define SENTRY_DSN via Dart environment variable (--dart-define)
}

Future<String> getReleaseName() async {
  final packageInfo = await PackageInfo.fromPlatform();
  // Format: package_name@version+build_number
  return '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
}
