import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_state.dart';

/// Permission helpers for widgets. Requires an [AuthBloc] above in the tree
/// (provided at app level in `lib/app/app.dart`).
extension AuthContextExtensions on BuildContext {
  /// True when the signed-in user has [permission] (or is developer_admin).
  bool hasPermission(String permission) {
    final state = read<AuthBloc>().state;
    return state is AuthSuccess && state.user.hasPermission(permission);
  }

  /// True when the signed-in user is a developer_admin.
  bool get isDeveloperAdmin {
    final state = read<AuthBloc>().state;
    return state is AuthSuccess && state.user.isDeveloperAdmin;
  }
}
