import 'package:flutter/material.dart';
import 'package:test_sentry/core/application/error_reporter.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final ErrorReporterUseCase _errorReporter;

  AppRouteObserver(this._errorReporter);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _errorReporter.addNavigationBreadcrumb(route.settings.name ?? 'unknown route');
    }
  }
}
