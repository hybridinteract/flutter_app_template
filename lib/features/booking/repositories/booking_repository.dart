import '../models/booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getBookings();
  Future<BookingModel> getBookingDetails(String id);
}
