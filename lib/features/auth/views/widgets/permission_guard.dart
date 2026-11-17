import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/auth_bloc.dart';
import '../../controllers/auth_state.dart';

/// A widget that conditionally displays [child] based on user permissions.
/// Enforces the project's RBAC rule: Check atomic permissions ('resource:action'),
/// never hardcode roles directly in the UI.
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  /// The required permission (e.g. 'users:create', 'reports:read_all').
  final String permission;

  /// Widget rendered when the user has permission (or is developer_admin).
  final Widget child;

  /// Widget rendered when permission is missing. Defaults to [SizedBox.shrink].
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess && state.user.hasPermission(permission)) {
          return child;
        }
        return fallback;
      },
    );
  }
}
