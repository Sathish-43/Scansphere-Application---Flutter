// lib/features/booking/booking_detail_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/booking.dart';

class BookingDetailPage extends StatelessWidget {
  final Booking booking;
  const BookingDetailPage({super.key, required this.booking});

  String get _qrPayload {
    final map = {
      'bookingId': booking.id,
      'eventId': booking.eventId,
      'title': booking.title,
      'venue': booking.venue,
      'location': booking.location,
      'qty': booking.quantity,
      'total': booking.totalPrice,
      'bookedAt': booking.bookedAt.toIso8601String(),
    };
    return jsonEncode(map);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMMd().add_jm().format(booking.bookedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: booking.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking ID copied')));
            },
            tooltip: 'Copy booking id',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // banner / image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: booking.image.isNotEmpty
                    ? Image.asset(
                        booking.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                      )
                    : Container(color: Colors.grey.shade200),
              ),
            ),
            const SizedBox(height: 14),

            // title, venue, qty, price
            Align(
              alignment: Alignment.centerLeft,
              child: Text(booking.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${booking.venue} • ${booking.location}', style: const TextStyle(color: Colors.black54)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Chip(label: Text('Qty: ${booking.quantity}')),
                const SizedBox(width: 8),
                Chip(label: Text('Total: \u20B9${booking.totalPrice.toStringAsFixed(0)}')),
                const Spacer(),
                Text(dateLabel, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),

            const SizedBox(height: 18),

            // QR area
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // QR
                   QrImageView(
  data: _qrPayload,
  size: 200,
  version: QrVersions.auto,
  errorStateBuilder: (cxt, err) => const SizedBox(
    height: 200,
    child: Center(child: Text('Could not generate QR')),
  ),
),
                    const SizedBox(height: 12),
                    const Text('Present this QR at the event entrance', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe53935)),
                    onPressed: () {
                      Navigator.of(context).pop({'action': 'cancel', 'bookingId': booking.id});
                    },
                    child: const Text('Cancel Booking', style:TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
