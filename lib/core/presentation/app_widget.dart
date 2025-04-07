import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_sentry/core/presentation/router/app_router_observer.dart';
import 'package:test_sentry/core/shared/providers.dart';
import 'package:test_sentry/home/presentation/home_page.dart';

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the error reporter for navigation breadcrumbs
    //final errorReporter = ref.read(errorReporterUseCaseProvider);

    return const MaterialApp(
      title: 'Flutter DDD App',
      navigatorObservers: [
        // Custom navigator observer to track screen views
        //  AppRouteObserver(errorReporter),
      ],
      home: MyHomePage(
        title: "Sentry Flutter Demo",
      ),
    );
  }
}
