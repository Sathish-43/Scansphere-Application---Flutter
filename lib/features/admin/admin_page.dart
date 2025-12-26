// lib/features/admin/admin_page.dart
import 'package:flutter/material.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import 'events_list_page.dart';
import 'scanner_page.dart';

class AdminPage extends StatefulWidget {
  static const routeName = '/admin';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final EventsRepository _repo = EventsRepository();

  @override
  void initState() {
    super.initState();
    _repo.loadEventsFromAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.redAccent,
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScannerPage()));
            },
            tooltip: 'Open Scanner',
          )
        ],
      ),backgroundColor: Colors.amberAccent.withOpacity(.2),
      body: ValueListenableBuilder<List<Event>>(
        valueListenable: _repo.events,
        builder: (context, list, _) {
          final totalEvents = list.length;
          final activeEvents = list.where((e) => e.active).length;
          final upcoming = list.where((e) => e.startTime.isAfter(DateTime.now())).length;
          final totalCapacity = list.fold<int>(0, (s, e) => s + e.capacity);
          final ticketsSold = list.fold<int>(0, (s, e) => s + e.ticketsSold);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Align(alignment: Alignment.centerLeft, child: Text('Dashboard',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _smallCard('Total events', totalEvents.toString()),
                    const SizedBox(width: 12),
                    _smallCard('Active', activeEvents.toString()),
                    const SizedBox(width: 12),
                    _smallCard('Upcoming', upcoming.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _smallCard('Capacity', totalCapacity.toString()),
                    const SizedBox(width: 12),
                    _smallCard('Tickets Sold', ticketsSold.toString()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsListPage()));
                        },
                        icon: const Icon(Icons.event),
                        label: const Text('Manage Events'),style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent)
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Align(alignment: Alignment.centerLeft, child: Text('Quick actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsListPage())),
                      icon: const Icon(Icons.list),
                      label: const Text('Events List'),style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent)
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScannerPage())),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Qr Scanner'),style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent)
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _smallCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
