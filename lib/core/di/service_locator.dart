import 'package:get_it/get_it.dart';

/// The app-wide service locator.
///
/// Registrations live in `lib/app/injection_container.dart`. Resolve
/// dependencies only in composition code (`lib/app/` and each feature's
/// `*_routes.dart`), never inside views, BLoCs, repositories or services:
/// those receive their dependencies through constructors.
final GetIt getIt = GetIt.instance;
