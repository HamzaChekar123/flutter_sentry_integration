
abstract class ErrorLogger {
  void logError(
    dynamic exception, 
    StackTrace? stackTrace, {
    String? message, 
    Map<String, dynamic>? extras,
  });

  void logMessage(
    String message, {
    SeverityLevel severityLevel = SeverityLevel.info,
    Map<String, dynamic>? extras,
  });
}

enum SeverityLevel { fatal, error, warning, info, debug }