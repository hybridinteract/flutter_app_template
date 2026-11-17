import 'package:app_template/core/error/failure.dart';
import 'package:app_template/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final requestOptions = RequestOptions(path: '/test');

  DioException badResponse(int statusCode, [Object? data]) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );

  group('mapExceptionToFailure', () {
    test('returns an existing Failure unchanged', () {
      const failure = NotFoundFailure();
      expect(mapExceptionToFailure(failure), same(failure));
    });

    test('maps AppException subtypes to matching Failures', () {
      expect(
        mapExceptionToFailure(const NetworkException()),
        isA<NetworkFailure>(),
      );
      expect(
        mapExceptionToFailure(const UnauthorizedException()),
        isA<AuthenticationFailure>(),
      );
      expect(
        mapExceptionToFailure(const StorageException()),
        isA<StorageFailure>(),
      );
    });

    test('maps Dio timeouts to NetworkFailure', () {
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapExceptionToFailure(error), isA<NetworkFailure>());
    });

    test('maps Dio status codes to typed Failures', () {
      expect(
        mapExceptionToFailure(badResponse(401)),
        isA<AuthenticationFailure>(),
      );
      expect(mapExceptionToFailure(badResponse(403)), isA<ForbiddenFailure>());
      expect(mapExceptionToFailure(badResponse(404)), isA<NotFoundFailure>());
      expect(mapExceptionToFailure(badResponse(409)), isA<ConflictFailure>());
      expect(mapExceptionToFailure(badResponse(422)), isA<ValidationFailure>());
      expect(mapExceptionToFailure(badResponse(429)), isA<RateLimitFailure>());
      expect(mapExceptionToFailure(badResponse(500)), isA<ServerFailure>());
      expect(
        mapExceptionToFailure(badResponse(503)),
        isA<ServerUnavailableFailure>(),
      );
    });

    test('uses the server-provided message for validation errors', () {
      final failure = mapExceptionToFailure(
        badResponse(422, {'message': 'Email is already registered.'}),
      );
      expect(failure.message, 'Email is already registered.');
    });

    test('reads the FastAPI `detail` string as the message', () {
      final failure = mapExceptionToFailure(
        badResponse(403, {
          'detail': 'Email not verified. Check your inbox for the code.',
        }),
      );
      expect(failure, isA<ForbiddenFailure>());
      expect(
        failure.message,
        'Email not verified. Check your inbox for the code.',
      );
    });

    test('reads `detail.message` when detail is an object', () {
      final failure = mapExceptionToFailure(
        badResponse(409, {
          'detail': {
            'message': 'This creator is already on this campaign.',
            'campaign_id': 'c1',
          },
        }),
      );
      expect(failure, isA<ConflictFailure>());
      expect(failure.message, 'This creator is already on this campaign.');
    });

    test('maps a FastAPI 422 list to a message and field errors', () {
      final failure = mapExceptionToFailure(
        badResponse(422, {
          'error': 'Validation Error',
          'detail': [
            {
              'loc': ['body', 'password'],
              'msg': 'Value error, Password must contain at least one digit.',
            },
            {
              'loc': ['body', 'email'],
              'msg': 'value is not a valid email address',
            },
          ],
        }),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Password must contain at least one digit.');
      expect((failure as ValidationFailure).fieldErrors, {
        'password': ['Password must contain at least one digit.'],
        'email': ['value is not a valid email address'],
      });
    });

    test('never exposes Dio technical messages', () {
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
        message: 'HandshakeException: raw technical detail',
      );
      final failure = mapExceptionToFailure(error);
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, isNot(contains('raw technical detail')));
    });

    test('never exposes raw exception text for unknown errors', () {
      final failure = mapExceptionToFailure(
        Exception('SocketException: raw technical detail'),
      );
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, const UnexpectedFailure().message);
    });

    test('maps parsing errors to a friendly message', () {
      Object? caught;
      try {
        // ignore: unused_local_variable
        final value = (1 as dynamic) as String;
      } on TypeError catch (e) {
        caught = e;
      }
      final failure = mapExceptionToFailure(caught!);
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, contains('invalid data'));
      expect(
        mapExceptionToFailure(const FormatException('bad json')).message,
        isNot(contains('bad json')),
      );
    });
  });
}
