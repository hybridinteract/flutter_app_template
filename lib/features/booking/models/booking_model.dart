import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel extends Equatable {
  const BookingModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    this.status = 'confirmed',
    required this.bookingDate,
    required this.userId,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String status;
  final DateTime bookingDate;
  final String userId;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  BookingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? status,
    DateTime? bookingDate,
    String? userId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    status,
    bookingDate,
    userId,
  ];
}
