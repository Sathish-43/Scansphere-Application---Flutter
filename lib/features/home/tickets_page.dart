// lib/features/home/tickets_page.dart
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import 'package:intl/intl.dart';
import '../booking/booking_detail_page.dart';

class TicketsPage extends StatelessWidget {
  final List<Booking> bookings;
  final void Function(String bookingId) onCancel;

  const TicketsPage({super.key, required this.bookings, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    // This page is embedded into HomePage (which already has a Scaffold + AppBar).
    // So: don't create another Scaffold here; return a widget that fits inside the body.
    final primaryRed = const Color(0xFFe53935);

    // If you sometimes open TicketsPage standalone (via route), you can wrap it in a Scaffold there.
    if (bookings.isEmpty) {
      return SafeArea(
        child: Column(
          children: const [
            // If parent already has an AppBar, this header is optional.
            // We keep a small in-body message instead of a full AppBar.
            SizedBox(height: 12),
            Center(child: Text('No bookings yet. Book an event to see tickets here.')),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Optional small header inside body (parent AppBar still present).
          Container(
            width: double.infinity,
            color: const Color(0xFFFFC107),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text('My Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // The list must be inside Expanded so it scrolls and doesn't overflow.
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        b.image,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, width: 84, height: 84),
                      ),
                    ),
                    title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${b.venue} • ${b.location}\n${DateFormat.yMMMd().add_jm().format(b.bookedAt.toLocal())}\nQty: ${b.quantity}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\u20B9${b.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 34,
                          child: TextButton(
                            onPressed: () => onCancel(b.id),
                            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                          ),
                        )
                      ],
                    ),
                    onTap: () async {
                      // open BookingDetailPage and wait for result
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BookingDetailPage(booking: b)),
                      );

                      // booking detail can return {'action':'cancel','bookingId': id}
                      if (result is Map && result['action'] == 'cancel' && result['bookingId'] != null) {
                        onCancel(result['bookingId'] as String);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
