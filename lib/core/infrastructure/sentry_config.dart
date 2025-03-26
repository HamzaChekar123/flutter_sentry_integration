import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:test_sentry/core/config/config_service.dart';

class SentryConfig {
  final String dsn;
  final String environment;
  final String release;
  final String dist;
  final String appPackageName;
  final List<String> inAppIncludes;
  final bool attachScreenshot;
  final bool attachViewHierarchy;

  const SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    required this.dist,
    required this.appPackageName,
    this.inAppIncludes = const [],
    this.attachScreenshot = false,
    this.attachViewHierarchy = false,
  });

  static Future<SentryConfig> create({
    required ConfigService configService,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final release = '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';

    return SentryConfig(
      dsn: configService.sentryDsn,
      environment: configService.environment,
      release: release,
      dist: packageInfo.buildNumber,
      appPackageName: packageInfo.packageName,
      inAppIncludes: [packageInfo.packageName],
      attachScreenshot: !kReleaseMode,
      attachViewHierarchy: !kReleaseMode,
    );
  }

  bool get isProduction => environment == 'production';
}
