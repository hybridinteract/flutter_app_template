import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient({Dio? dio, ApiInterceptor? interceptor, String? baseUrl})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? AppConfig.instance.baseUrl,
              connectTimeout: const Duration(
                seconds: AppConstants.connectTimeoutSeconds,
              ),
              receiveTimeout: const Duration(
                seconds: AppConstants.receiveTimeoutSeconds,
              ),
              sendTimeout: const Duration(
                seconds: AppConstants.sendTimeoutSeconds,
              ),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ) {
    if (interceptor != null) {
      this.dio.interceptors.add(interceptor);
    }
  }

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
