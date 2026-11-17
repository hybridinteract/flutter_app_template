abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() =>
      'AppException(statusCode: $statusCode, message: $message, details: $details)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.details,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Connection timed out. Please try again.',
    super.statusCode,
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
    super.details,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to access this resource.',
    super.statusCode = 403,
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested resource not found.',
    super.statusCode = 404,
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation error occurred.',
    super.statusCode = 422,
    super.details,
    this.fieldErrors = const {},
  });

  /// Field name -> messages, when the server reports per-field errors.
  final Map<String, List<String>> fieldErrors;
}

class ConflictException extends AppException {
  const ConflictException({
    super.message = 'This conflicts with existing data.',
    super.statusCode = 409,
    super.details,
  });
}

class RateLimitException extends AppException {
  const RateLimitException({
    super.message = 'Too many requests. Please slow down and try again later.',
    super.statusCode = 429,
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Server encountered an error. Please try again later.',
    super.statusCode = 500,
    super.details,
  });
}

class ServerUnavailableException extends AppException {
  const ServerUnavailableException({
    super.message = 'Server is currently unavailable. Please try again soon.',
    super.statusCode = 503,
    super.details,
  });
}

class InvalidJsonException extends AppException {
  const InvalidJsonException({
    super.message = 'Failed to parse response from server.',
    super.statusCode,
    super.details,
  });
}

class StorageException extends AppException {
  const StorageException({
    super.message = 'Local storage operation failed.',
    super.statusCode,
    super.details,
  });
}

class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.details,
  });
}
