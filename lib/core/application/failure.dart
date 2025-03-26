abstract class Failure {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> properties;

  const Failure({
    required this.message,
    this.error,
    this.stackTrace,
    this.properties = const {},
  });
}

class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required super.message,
    this.statusCode,
    super.error,
    super.stackTrace,
  }) : super(
          properties: {
            'statusCode': statusCode,
          },
        );
}

class CacheFailure extends Failure {
  CacheFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  final List<String> validationErrors;

  ValidationFailure({
    required super.message,
    required this.validationErrors,
    super.error,
    super.stackTrace,
  }) : super(
          properties: {
            'validationErrors': validationErrors,
          },
        );
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.error,
    super.stackTrace,
  });
}
