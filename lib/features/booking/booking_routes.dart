import 'package:app_template/core/di/service_locator.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'controllers/booking_bloc.dart';
import 'views/booking_detail_screen.dart';
import 'views/booking_screen.dart';

/// Routes owned by the booking feature.
///
/// Each route creates its own [BookingBloc] (registered as a factory), so the
/// list and detail screens never overwrite each other's state, and the BLoC is
/// closed automatically when the route is popped.
abstract final class BookingRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: RouteNames.bookings,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BookingBloc>(),
        child: const BookingScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.bookingDetails,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<BookingBloc>(),
        child: BookingDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ),
  ];
}
