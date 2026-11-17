// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  price: (json['price'] as num).toDouble(),
  status: json['status'] as String? ?? 'confirmed',
  bookingDate: DateTime.parse(json['bookingDate'] as String),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'status': instance.status,
      'bookingDate': instance.bookingDate.toIso8601String(),
      'userId': instance.userId,
    };
