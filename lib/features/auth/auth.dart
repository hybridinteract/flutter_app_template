/// Public API of the auth feature.
///
/// Auth owns the user session, so it is the ONLY feature other features may
/// import, and only through this file. Services, repositories and screens of
/// the auth feature stay private to it.
library;

export 'controllers/auth_bloc.dart';
export 'controllers/auth_event.dart';
export 'controllers/auth_state.dart';
export 'models/account_type.dart';
export 'models/user_model.dart';
export 'views/auth_context_extensions.dart';
export 'views/widgets/permission_guard.dart';
