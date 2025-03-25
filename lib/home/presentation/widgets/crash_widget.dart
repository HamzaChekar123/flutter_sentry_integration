
import 'package:flutter/material.dart';

class CrashWidget extends StatelessWidget {
  const CrashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    throw Exception("🔥 UI Widget Crash!");
  }
}
