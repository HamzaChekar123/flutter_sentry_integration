import 'package:envied/envied.dart';

part 'env.g.dart';

// ignore: avoid_classes_with_only_static_members
@Envied(path: '.env.dev')
abstract class DevEnv {
  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDSN = _DevEnv.sentryDSN;

  @EnviedField(varName: 'SENTRY_ENVIRONMENT', obfuscate: true)
  static final String environment = _DevEnv.environment;

  @EnviedField(varName: 'SENTRY_RELEASE', obfuscate: true)
  static final String sentryRelase = _ProdEnv.sentryRelase;
}

// ignore: avoid_classes_with_only_static_members
@Envied(path: '.env.prod')
abstract class ProdEnv {
  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDSN = _ProdEnv.sentryDSN;

  @EnviedField(varName: 'SENTRY_ENVIRONMENT', obfuscate: true)
  static final String environment = _ProdEnv.environment;

  @EnviedField(varName: 'SENTRY_RELEASE', obfuscate: true)
  static final String sentryRelase = _ProdEnv.sentryRelase;
}
