import 'package:app_template/core/error/failure.dart';
import 'package:app_template/features/booking/controllers/booking_bloc.dart';
import 'package:app_template/features/booking/controllers/booking_event.dart';
import 'package:app_template/features/booking/controllers/booking_state.dart';
import 'package:app_template/features/booking/models/booking_model.dart';
import 'package:app_template/features/booking/repositories/booking_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository repository;

  final booking = BookingModel(
    id: 'b1',
    title: 'Ocean View Room',
    price: 120,
    bookingDate: DateTime(2026, 11, 20),
    userId: 'u1',
  );

  setUp(() => repository = MockBookingRepository());

  test('initial state is BookingInitial', () {
    final bloc = BookingBloc(repository);
    expect(bloc.state, const BookingInitial());
    bloc.close();
  });

  blocTest<BookingBloc, BookingState>(
    'emits [Loading, Success] when bookings load',
    build: () {
      when(() => repository.getBookings()).thenAnswer((_) async => [booking]);
      return BookingBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadBookingsRequested()),
    expect: () => [
      const BookingLoading(),
      BookingSuccess(bookings: [booking]),
    ],
  );

  blocTest<BookingBloc, BookingState>(
    'emits [Loading, Failure] with the Failure message when loading fails',
    build: () {
      when(() => repository.getBookings()).thenThrow(const NetworkFailure());
      return BookingBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadBookingsRequested()),
    expect: () => [
      const BookingLoading(),
      BookingFailure(message: const NetworkFailure().message),
    ],
  );

  blocTest<BookingBloc, BookingState>(
    'emits [Loading, DetailSuccess] when booking details load',
    build: () {
      when(
        () => repository.getBookingDetails('b1'),
      ).thenAnswer((_) async => booking);
      return BookingBloc(repository);
    },
    act: (bloc) => bloc.add(const LoadBookingDetailsRequested('b1')),
    expect: () => [
      const BookingLoading(),
      BookingDetailSuccess(booking: booking),
    ],
  );
}
