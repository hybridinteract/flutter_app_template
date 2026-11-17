import 'package:app_template/core/error/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._bookingRepository) : super(const BookingInitial()) {
    on<LoadBookingsRequested>(_onLoadBookings);
    on<LoadBookingDetailsRequested>(_onLoadBookingDetails);
  }

  final BookingRepository _bookingRepository;

  Future<void> _onLoadBookings(
    LoadBookingsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final bookings = await _bookingRepository.getBookings();
      emit(BookingSuccess(bookings: bookings));
    } on Failure catch (failure) {
      emit(BookingFailure(message: failure.message));
    } catch (_) {
      emit(const BookingFailure(message: 'Failed to load bookings.'));
    }
  }

  Future<void> _onLoadBookingDetails(
    LoadBookingDetailsRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final booking = await _bookingRepository.getBookingDetails(event.id);
      emit(BookingDetailSuccess(booking: booking));
    } on Failure catch (failure) {
      emit(BookingFailure(message: failure.message));
    } catch (_) {
      emit(const BookingFailure(message: 'Failed to load booking details.'));
    }
  }
}
