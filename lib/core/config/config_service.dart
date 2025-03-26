class ConfigService {
  late String _environment;
  late String _sentryDsn;
  late bool _isInitialized = false;

  // Getters
  String get environment => _ensureInitialized(_environment);
  String get sentryDsn => _ensureInitialized(_sentryDsn);
  bool get isProduction => environment == 'production';

  // Initialize with environment variables
  Future<void> initialize({String envFile = '.env'}) async {
    if (_isInitialized) return;

    _sentryDsn = sentryDsn;
    _environment = environment;
    _isInitialized = true;
  }

  // Helper method to ensure the service is initialized
  T _ensureInitialized<T>(T value) {
    if (!_isInitialized) {
      throw StateError('ConfigService must be initialized before use');
    }
    return value;
  }
}
