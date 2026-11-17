import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.errors,
  });

  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final Map<String, List<String>>? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success:
          json['success'] as bool? ??
          (json['status'] == 'success' || json['status'] == 200),
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] as Map<String, dynamic>?,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()],
        ),
      ),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null && toJsonT != null) 'data': toJsonT(data as T),
      if (meta != null) 'meta': meta,
      if (errors != null) 'errors': errors,
    };
  }

  @override
  List<Object?> get props => [success, message, data, meta, errors];
}
