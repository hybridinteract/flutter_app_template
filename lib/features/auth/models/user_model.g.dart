// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: UserModel._readName(json, 'name') as String,
  email: json['email'] as String,
  roles:
      (UserModel._readRoles(json, 'roles') as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['member'],
  permissions:
      (UserModel._readPermissions(json, 'permissions') as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isSuperuser:
      UserModel._readIsSuperuser(json, 'is_superuser') as bool? ?? false,
  isActive: UserModel._readIsActive(json, 'is_active') as bool? ?? true,
  phone: json['phone'] as String?,
  avatarUrl: UserModel._readAvatarUrl(json, 'avatar_url') as String?,
  status: json['status'] as String? ?? 'active',
  createdAt: UserModel._readCreatedAt(json, 'created_at') == null
      ? null
      : DateTime.parse(UserModel._readCreatedAt(json, 'created_at') as String),
  accountType: $enumDecodeNullable(
    _$AccountTypeEnumMap,
    json['account_type'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  emailVerified: json['email_verified'] as bool? ?? false,
  organizationName: json['organization_name'] as String?,
  socialHandle: json['social_handle'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'roles': instance.roles,
  'permissions': instance.permissions,
  'is_superuser': instance.isSuperuser,
  'is_active': instance.isActive,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'account_type': _$AccountTypeEnumMap[instance.accountType],
  'email_verified': instance.emailVerified,
  'organization_name': instance.organizationName,
  'social_handle': instance.socialHandle,
};

const _$AccountTypeEnumMap = {
  AccountType.organization: 'organization',
  AccountType.influencer: 'influencer',
};
