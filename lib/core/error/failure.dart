import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../network/api_exception.dart'; // also exports app_exception.dart

abstract class Failure extends Equatable implements Exception {
  const Failure({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode, code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.code = 'NETWORK_ERROR',
  });
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
    super.code = 'AUTH_ERROR',
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.code = 'FORBIDDEN',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested data was not found.',
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Please check the information entered and try again.',
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [message, statusCode, code, fieldErrors];
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message =
        'This conflicts with existing data. Please refresh and try again.',
    super.statusCode = 409,
    super.code = 'CONFLICT',
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please wait a moment and try again.',
    super.statusCode = 429,
    super.code = 'RATE_LIMIT',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.statusCode = 500,
    super.code = 'SERVER_ERROR',
  });
}

class ServerUnavailableFailure extends Failure {
  const ServerUnavailableFailure({
    super.message = 'Service temporarily unavailable. Please try again soon.',
    super.statusCode = 503,
    super.code = 'SERVICE_UNAVAILABLE',
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Local storage operation failed.',
    super.statusCode,
    super.code = 'STORAGE_ERROR',
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.code = 'UNEXPECTED_ERROR',
  });
}

Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;

  if (error is AppException) {
    return switch (error) {
      final NetworkException e => NetworkFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final TimeoutException e => NetworkFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final UnauthorizedException e => AuthenticationFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final ForbiddenException e => ForbiddenFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final NotFoundException e => NotFoundFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final ValidationException e => ValidationFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      ),
      final ConflictException e => ConflictFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final RateLimitException e => RateLimitFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final ServerException e => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final ServerUnavailableException e => ServerUnavailableFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      final StorageException e => StorageFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      _ => UnexpectedFailure(
        message: error.message,
        statusCode: error.statusCode,
      ),
    };
  }

  // Dio errors are translated once, in core/network/api_exception.dart.
  if (error is DioException) {
    return mapExceptionToFailure(mapDioExceptionToAppException(error));
  }

  // Parsing problems (bad JSON shape, failed casts) must not leak their
  // technical text to the UI.
  if (error is FormatException || error is TypeError) {
    return const UnexpectedFailure(
      message: 'Received invalid data from the server. Please try again.',
    );
  }

  // Never expose `error.toString()`: raw exception text is not user-facing.
  return const UnexpectedFailure();
}
