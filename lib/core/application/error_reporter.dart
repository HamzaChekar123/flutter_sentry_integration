import 'package:test_sentry/core/domain/error_reporter_interface.dart';

class ErrorReporterUseCase {
  final ErrorReporterInterface _reporter;

  ErrorReporterUseCase(this._reporter);

  Future<void> initialize() => _reporter.initialize();

  void setUserContext({
    required String userId,
    String? email,
    String? username,
    Map<String, dynamic>? additionalData,
  }) {
    _reporter.setUser(
      id: userId,
      email: email,
      username: username,
      data: additionalData,
    );
  }

  void clearUserContext() {
    _reporter.clearContext();
  }

  void addNavigationBreadcrumb(String routeName) {
    _reporter.addBreadcrumb(
      message: 'Navigation: $routeName',
      category: 'navigation',
    );
  }

  void addUserActionBreadcrumb(String action, {Map<String, dynamic>? data}) {
    _reporter.addBreadcrumb(
      message: action,
      category: 'user_action',
      data: data,
    );
  }

  void addNetworkBreadcrumb(
    String url,
    String method,
    int statusCode, {
    Map<String, dynamic>? data,
  }) {
    _reporter.addBreadcrumb(
      message: '$method $url - $statusCode',
      category: 'network',
      data: {
        'url': url,
        'method': method,
        'status_code': statusCode,
        ...?data,
      },
    );
  }
}
