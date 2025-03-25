

import 'package:flutter/foundation.dart';
import 'package:test_sentry/env/env.dart';

String get sentryDSN => kReleaseMode ? ProdEnv.sentryDSN : DevEnv.sentryDSN;
String get environment =>
    kReleaseMode ? ProdEnv.environment : DevEnv.environment;

String get sentryRelase =>
    kReleaseMode ? ProdEnv.sentryRelase : DevEnv.sentryRelase;