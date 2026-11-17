import 'dart:async';

import 'package:app_template/core/di/service_locator.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/features/booking/booking_routes.dart';
import 'package:app_template/features/booking/controllers/booking_bloc.dart';
import 'package:app_template/features/booking/models/booking_model.dart';
import 'package:app_template/features/booking/repositories/booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository repository;
  late int blocsCreated;

  final listBooking = BookingModel(
    id: 'b1',
    title: 'Ocean View Room',
    price: 120,
    bookingDate: DateTime(2026, 11, 20),
    userId: 'u1',
  );
  final detailBooking = listBooking.copyWith(
    description: 'Detail-only description',
  );

  setUp(() {
    repository = MockBookingRepository();
    blocsCreated = 0;
    when(() => repository.getBookings()).thenAnswer((_) async => [listBooking]);
    when(
      () => repository.getBookingDetails('b1'),
    ).thenAnswer((_) async => detailBooking);
    getIt.registerFactory<BookingBloc>(() {
      blocsCreated++;
      return BookingBloc(repository);
    });
  });

  tearDown(getIt.reset);

  testWidgets(
    'list and detail routes get separate BLoCs, so the list survives going back',
    (tester) async {
      final router = GoRouter(
        initialLocation: RouteNames.bookings,
        routes: BookingRoutes.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ocean View Room'), findsOneWidget);

      // push() completes only when the route is popped, so don't await it.
      unawaited(router.push(RouteNames.bookingDetailsPath('b1')));
      await tester.pumpAndSettle();
      expect(find.text('Detail-only description'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Ocean View Room'), findsOneWidget);
      expect(blocsCreated, 2);
      verify(() => repository.getBookings()).called(1);
    },
  );
}
