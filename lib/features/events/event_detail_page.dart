// lib/features/events/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/booking.dart';

class EventDetailPage extends StatelessWidget {
  // We open using MaterialPageRoute and pass an Event object via constructor
  final Event event;

  const EventDetailPage({super.key, required this.event});

  // Small booking creator used when user presses Book Now
  // Returns a Booking or null if cancelled
  Future<Booking?> _showBookDialog(BuildContext context) async {
    int qty = 1;

    final res = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: Text('Book: ${event.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Price: \u20B9${event.price.toStringAsFixed(0)} per person'),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: qty > 1 ? () => setState(() => qty--) : null,
                  ),
                  Text('$qty', style: const TextStyle(fontSize: 18)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => qty++)),
                ]),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(qty),
                child: const Text('Confirm',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe53935)),
              ),
            ],
          );
        });
      },
    );

    if (res == null) return null;
    // create booking
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: event.id,
      title: event.title,
      venue: event.venue,
      location: event.location,
      image: event.image,
      quantity: res,
      totalPrice: event.price * res,
      bookedAt: DateTime.now(),
    );

    return booking;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMMd().add_jm().format(event.startTime.toLocal());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.amberAccent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // image
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(event.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.category, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${event.venue} • $dateText', style: const TextStyle(color: Colors.black54))),
                ]),
                const SizedBox(height: 12),
                Text(event.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),
                Row(children: [
                  Text('\u20B9${event.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final booking = await _showBookDialog(context);
                      if (booking != null) {
                        // Return booking to caller
                        Navigator.of(context).pop(booking);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe53935)),
                    child: const Text('Book Now',style: TextStyle(color: Colors.white),),
                  )
                ]),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
