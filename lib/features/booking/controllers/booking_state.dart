import 'package:equatable/equatable.dart';
import '../models/booking_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  const BookingSuccess({required this.bookings});

  final List<BookingModel> bookings;

  @override
  List<Object?> get props => [bookings];
}

class BookingDetailSuccess extends BookingState {
  const BookingDetailSuccess({required this.booking});

  final BookingModel booking;

  @override
  List<Object?> get props => [booking];
}

class BookingFailure extends BookingState {
  const BookingFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
