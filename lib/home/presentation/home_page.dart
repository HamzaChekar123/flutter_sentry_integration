import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:test_sentry/home/presentation/widgets/crash_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        //* Center is a layout widget. It takes a single child and positions it
        //* in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CrashWidget()));
              },
              child: const Text("Test UI Crash"),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: testAsyncError,
              child: Text("Test Async Error"),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: testManualError,
              child: Text("Test Manual Error"),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: testPlatformError,
              child: Text("Test Platform Error"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void testPlatformError() {
  try {
    throw const SocketException("🔥 Network Error - No Internet!");
  } catch (error, stackTrace) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}

void testAsyncError() async {
  await Future.delayed(const Duration(seconds: 1));
  throw Exception("🔥 Unhandled Async Error!");
}

void testManualError() {
  try {
    throw Exception("🔥 Manually Captured Error!");
  } catch (error, stackTrace) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}
