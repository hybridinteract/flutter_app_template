// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationChallengeModel _$VerificationChallengeModelFromJson(
  Map<String, dynamic> json,
) => VerificationChallengeModel(
  email: json['email'] as String?,
  expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
  devCode: json['dev_code'] as String?,
);

Map<String, dynamic> _$VerificationChallengeModelToJson(
  VerificationChallengeModel instance,
) => <String, dynamic>{
  'email': instance.email,
  'expires_in': instance.expiresIn,
  'dev_code': instance.devCode,
};
