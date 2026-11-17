import 'package:app_template/core/constants/api_constants.dart';
import 'package:app_template/core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService(this._dioClient);

  final DioClient _dioClient;

  Future<List<BookingModel>> getBookings() async {
    final response = await _dioClient.get(ApiConstants.bookings);
    final data = response.data;

    final List<dynamic> list;
    if (data is Map<String, dynamic> && data['data'] is List) {
      list = data['data'] as List<dynamic>;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }

    return list
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookingModel> getBookingDetails(String id) async {
    final response = await _dioClient.get('${ApiConstants.bookingDetails}/$id');
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final payload = data['data'] != null
        ? data['data'] as Map<String, dynamic>
        : data;
    return BookingModel.fromJson(payload);
  }
}
