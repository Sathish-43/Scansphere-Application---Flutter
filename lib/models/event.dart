// lib/models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final String image;
  final DateTime startTime;
  final DateTime endTime;
  final String venue;
  final String location;
  final String category;
  final double price;
  final int capacity;
  final int ticketsSold;
  final bool active;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.location,
    required this.category,
    required this.price,
    required this.capacity,
    required this.ticketsSold,
    required this.active,
  });

  factory Event.fromJson(Map<String, dynamic> j) => Event(
        id: j['id'].toString(),
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        image: j['image'] ?? '',
        startTime: DateTime.parse(j['startTime'] as String),
        endTime: DateTime.parse(j['endTime'] as String),
        venue: j['venue'] ?? '',
        location: j['location'] ?? '',
        category: j['category'] ?? 'Others',
        price: (j['price'] is num) ? (j['price'] as num).toDouble() : double.tryParse(j['price'].toString()) ?? 0.0,
        capacity: (j['capacity'] is num) ? (j['capacity'] as num).toInt() : int.tryParse(j['capacity'].toString()) ?? 0,
        ticketsSold: (j['ticketsSold'] is num) ? (j['ticketsSold'] as num).toInt() : int.tryParse(j['ticketsSold'].toString()) ?? 0,
        active: j['active'] == null ? true : (j['active'] as bool),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'venue': venue,
        'location': location,
        'category': category,
        'price': price,
        'capacity': capacity,
        'ticketsSold': ticketsSold,
        'active': active,
      };

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    DateTime? startTime,
    DateTime? endTime,
    String? venue,
    String? location,
    String? category,
    double? price,
    int? capacity,
    int? ticketsSold,
    bool? active,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      category: category ?? this.category,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      active: active ?? this.active,
    );
  }
}
