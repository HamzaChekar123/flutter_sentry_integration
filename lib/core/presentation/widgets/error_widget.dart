import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_sentry/core/shared/providers.dart';

class ErrorFallbackWidget extends ConsumerWidget {
  const ErrorFallbackWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //* We can use the error reporter to track user interactions with the error screen
    final errorReporter = ref.read(errorReporterUseCaseProvider);

    return Material(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'We apologize for the inconvenience. '
                  'Please try again or contact support if the issue persists.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  errorReporter.addUserActionBreadcrumb('Pressed Restart App');
                  // Add restart app logic here
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Restart App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
