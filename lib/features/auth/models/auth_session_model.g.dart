// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSessionModel _$AuthSessionModelFromJson(
  Map<String, dynamic> json,
) => AuthSessionModel(
  accessToken: AuthSessionModel._readAccessToken(json, 'accessToken') as String,
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  refreshToken:
      AuthSessionModel._readRefreshToken(json, 'refreshToken') as String?,
  tokenType:
      AuthSessionModel._readTokenType(json, 'tokenType') as String? ?? 'bearer',
);

Map<String, dynamic> _$AuthSessionModelToJson(AuthSessionModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenType': instance.tokenType,
      'user': instance.user?.toJson(),
    };
