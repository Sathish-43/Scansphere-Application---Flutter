// lib/models/booking.dart
class Booking {
  final String id;
  final String eventId;
  final String title;
  final String venue;
  final String location;
  final String image;
  final int quantity;
  final double totalPrice;
  final DateTime bookedAt;

  Booking({
    required this.id,
    required this.eventId,
    required this.title,
    required this.venue,
    required this.location,
    required this.image,
    required this.quantity,
    required this.totalPrice,
    required this.bookedAt,
  });
}
