import 'package:app_template/core/error/failure.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._bookingService);

  final BookingService _bookingService;

  @override
  Future<List<BookingModel>> getBookings() async {
    try {
      return await _bookingService.getBookings();
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }

  @override
  Future<BookingModel> getBookingDetails(String id) async {
    try {
      return await _bookingService.getBookingDetails(id);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}
