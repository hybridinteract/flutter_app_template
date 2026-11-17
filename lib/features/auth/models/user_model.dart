import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account_type.dart';

part 'user_model.g.dart';

/// The backend (FastAPI) uses snake_case, so `toJson` writes snake_case keys.
/// `readValue` helpers accept both snake_case and camelCase when reading.
@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.roles = const ['member'],
    this.permissions = const [],
    this.isSuperuser = false,
    this.isActive = true,
    this.phone,
    this.avatarUrl,
    this.status = 'active',
    this.createdAt,
    this.accountType,
    this.emailVerified = false,
    this.organizationName,
    this.socialHandle,
  });

  final String id;

  @JsonKey(readValue: _readName)
  final String name;

  final String email;

  @JsonKey(readValue: _readRoles)
  final List<String> roles;

  @JsonKey(readValue: _readPermissions)
  final List<String> permissions;

  @JsonKey(readValue: _readIsSuperuser)
  final bool isSuperuser;

  @JsonKey(readValue: _readIsActive)
  final bool isActive;

  final String? phone;

  @JsonKey(readValue: _readAvatarUrl)
  final String? avatarUrl;

  final String status;

  @JsonKey(readValue: _readCreatedAt)
  final DateTime? createdAt;

  /// Brand (`organization`) or creator (`influencer`). Null for staff
  /// accounts and for any value this app version does not know.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final AccountType? accountType;

  final bool emailVerified;

  /// The business name given at signup (brands only). A seed value: the live
  /// name belongs to the organization record.
  final String? organizationName;

  /// The social handle given at signup (creators only).
  final String? socialHandle;

  bool get isOrganization => accountType == AccountType.organization;

  bool get isInfluencer => accountType == AccountType.influencer;

  /// Backwards-compatible getter for single-role access.
  String get role => roles.isNotEmpty ? roles.first : 'member';

  /// Super-admin: Bypasses all permission checks (matches backend is_superuser / developer_admin).
  bool get isDeveloperAdmin =>
      isSuperuser ||
      roles.contains('developer_admin') ||
      role == 'developer_admin';

  /// Admin role check.
  bool get isAdmin =>
      isDeveloperAdmin || roles.contains('admin') || role == 'admin';

  /// Primary RBAC check: Checks atomic permission (e.g., 'users:read', 'products:create').
  bool hasPermission(String permission) =>
      isDeveloperAdmin || permissions.contains(permission);

  /// Checks if user has any of the specified permissions.
  bool hasAnyPermission(List<String> perms) =>
      isDeveloperAdmin || perms.any(permissions.contains);

  /// Checks if user has all of the specified permissions.
  bool hasAllPermissions(List<String> perms) =>
      isDeveloperAdmin || perms.every(permissions.contains);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => {..._$UserModelToJson(this), 'role': role};

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? roles,
    List<String>? permissions,
    bool? isSuperuser,
    bool? isActive,
    String? phone,
    String? avatarUrl,
    String? status,
    DateTime? createdAt,
    AccountType? accountType,
    bool? emailVerified,
    String? organizationName,
    String? socialHandle,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      accountType: accountType ?? this.accountType,
      emailVerified: emailVerified ?? this.emailVerified,
      organizationName: organizationName ?? this.organizationName,
      socialHandle: socialHandle ?? this.socialHandle,
    );
  }

  static Object? _readName(Map json, String key) =>
      json['full_name'] ?? json['name'] ?? '';

  static Object? _readRoles(Map json, String key) {
    if (json['roles'] is List) {
      return (json['roles'] as List).map((e) => e.toString()).toList();
    }
    if (json['role'] is String) {
      return [json['role'] as String];
    }
    return const ['member'];
  }

  static Object? _readPermissions(Map json, String key) {
    if (json['permissions'] is List) {
      return (json['permissions'] as List).map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static Object? _readIsSuperuser(Map json, String key) =>
      json['is_superuser'] ?? json['isSuperuser'] ?? false;

  static Object? _readIsActive(Map json, String key) =>
      json['is_active'] ?? json['isActive'] ?? true;

  static Object? _readAvatarUrl(Map json, String key) =>
      json['avatar_url'] ?? json['avatarUrl'];

  static Object? _readCreatedAt(Map json, String key) =>
      json['created_at'] ?? json['createdAt'];

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    roles,
    permissions,
    isSuperuser,
    isActive,
    phone,
    avatarUrl,
    status,
    createdAt,
    accountType,
    emailVerified,
    organizationName,
    socialHandle,
  ];
}
