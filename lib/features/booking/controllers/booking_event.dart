import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingsRequested extends BookingEvent {
  const LoadBookingsRequested();
}

class LoadBookingDetailsRequested extends BookingEvent {
  const LoadBookingDetailsRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
