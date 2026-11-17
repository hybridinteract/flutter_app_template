import 'dart:io';
import 'package:dio/dio.dart';
import '../error/app_exception.dart';

export '../error/app_exception.dart';

AppException mapDioExceptionToAppException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutException(
        message:
            'Connection timed out. Please check your network and try again.',
        details: error.error,
      );

    case DioExceptionType.connectionError:
      return NetworkException(
        message:
            'Unable to connect to the server. Please check your internet connection.',
        details: error.error,
      );

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final message =
          extractServerMessage(responseData) ??
          'Received invalid response from server.';

      switch (statusCode) {
        case 400:
          return ValidationException(
            message: message.isNotEmpty
                ? message
                : 'Bad request. Please check your input.',
            statusCode: 400,
            details: responseData,
            fieldErrors: extractFieldErrors(responseData),
          );
        case 401:
          return UnauthorizedException(
            message: message.isNotEmpty
                ? message
                : 'Session expired. Please log in again.',
            statusCode: 401,
            details: responseData,
          );
        case 403:
          return ForbiddenException(
            message: message.isNotEmpty
                ? message
                : 'You do not have permission to perform this action.',
            statusCode: 403,
            details: responseData,
          );
        case 404:
          return NotFoundException(
            message: message.isNotEmpty
                ? message
                : 'Requested resource was not found.',
            statusCode: 404,
            details: responseData,
          );
        case 409:
          return ConflictException(
            message: message.isNotEmpty
                ? message
                : 'This conflicts with existing data. Please refresh and try again.',
            statusCode: 409,
            details: responseData,
          );
        case 422:
          return ValidationException(
            message: message.isNotEmpty
                ? message
                : 'Validation failed. Please verify your data.',
            statusCode: 422,
            details: responseData,
            fieldErrors: extractFieldErrors(responseData),
          );
        case 429:
          return RateLimitException(
            message: message.isNotEmpty
                ? message
                : 'Too many requests. Please wait a moment.',
            statusCode: 429,
            details: responseData,
          );
        case 500:
          return ServerException(
            message: 'Server error. Our team has been notified.',
            statusCode: 500,
            details: responseData,
          );
        case 503:
          return ServerUnavailableException(
            message:
                'Service is temporarily unavailable. Please try again soon.',
            statusCode: 503,
            details: responseData,
          );
        default:
          return UnexpectedException(
            message: message.isNotEmpty
                ? message
                : 'Server responded with error ($statusCode).',
            statusCode: statusCode,
            details: responseData,
          );
      }

    case DioExceptionType.badCertificate:
      return const NetworkException(
        message: 'Security certificate verification failed.',
      );

    case DioExceptionType.cancel:
      return const UnexpectedException(message: 'Request was cancelled.');

    case DioExceptionType.unknown:
    default:
      if (error.error is SocketException) {
        return const NetworkException(
          message: 'No internet connection detected.',
        );
      } else if (error.error is FormatException) {
        return const InvalidJsonException(
          message: 'Malformed data received from server.',
        );
      }
      // Keep Dio's technical message in `details` only; it is not user-facing.
      return UnexpectedException(
        message: 'An unknown network error occurred. Please try again.',
        details: error.message ?? error.error,
      );
  }
}

/// Reads the user-facing message from an error body.
///
/// The FastAPI backend puts it in `detail`, in one of three shapes:
/// - a string: `{"detail": "Email not verified. Check your inbox for the code."}`
/// - an object: `{"detail": {"message": "This creator is already on this campaign.", ...}}`
/// - a list (422 validation): `{"detail": [{"loc": ["body", "email"], "msg": "..."}]}`
///
/// `message` is still read as a fallback for other backends. Returns null when
/// the body carries no usable text, so the caller can use its own default.
String? extractServerMessage(Object? responseData) {
  if (responseData is! Map) return null;

  final detail = responseData['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail.trim();
  if (detail is Map && detail['message'] is String) {
    return detail['message'] as String;
  }
  if (detail is List && detail.isNotEmpty) {
    final first = detail.first;
    if (first is Map && first['msg'] is String) {
      return _cleanValidationMessage(first['msg'] as String);
    }
  }

  final message = responseData['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  return null;
}

/// Field -> messages, from a FastAPI 422 body (`detail` as a list of
/// `{loc, msg}`). The field is the last segment of `loc`, e.g. `email`.
Map<String, List<String>> extractFieldErrors(Object? responseData) {
  if (responseData is! Map) return const {};
  final detail = responseData['detail'];
  if (detail is! List) return const {};

  final errors = <String, List<String>>{};
  for (final item in detail) {
    if (item is! Map || item['msg'] is! String) continue;
    final loc = item['loc'];
    final field = loc is List && loc.isNotEmpty ? loc.last.toString() : '';
    errors
        .putIfAbsent(field, () => [])
        .add(_cleanValidationMessage(item['msg'] as String));
  }
  return errors;
}

/// Pydantic prefixes messages raised by custom validators with
/// "Value error, " (e.g. the password policy). Drop it; the rest is written
/// for users.
String _cleanValidationMessage(String msg) {
  const prefix = 'Value error, ';
  return msg.startsWith(prefix) ? msg.substring(prefix.length) : msg;
}
