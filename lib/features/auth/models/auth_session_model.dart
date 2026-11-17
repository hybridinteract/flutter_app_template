import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'auth_session_model.g.dart';

/// `explicitToJson` serializes the nested [UserModel] with its own `toJson`.
@JsonSerializable(explicitToJson: true)
class AuthSessionModel extends Equatable {
  const AuthSessionModel({
    required this.accessToken,
    this.user,
    this.refreshToken,
    this.tokenType = 'bearer',
  });

  @JsonKey(readValue: _readAccessToken)
  final String accessToken;

  @JsonKey(readValue: _readRefreshToken)
  final String? refreshToken;

  @JsonKey(readValue: _readTokenType)
  final String? tokenType;

  final UserModel? user;

  static Object? _readAccessToken(Map json, String key) =>
      json['access_token'] ?? json['accessToken'] ?? '';

  static Object? _readRefreshToken(Map json, String key) =>
      json['refresh_token'] ?? json['refreshToken'];

  static Object? _readTokenType(Map json, String key) =>
      json['token_type'] ?? json['tokenType'] ?? 'bearer';

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionModelToJson(this);

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, user];
}
