// lib/features/admin/events_list_page.dart
import 'package:flutter/material.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import 'event_form_page.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EventsRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Management'),backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newEvent = await Navigator.of(context).push<Event?>(MaterialPageRoute(builder: (_) => const EventFormPage()));
              if (newEvent != null) {
                await repo.addEvent(newEvent);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event added')));
              }
            },
          )
        ],
      ),
      body: ValueListenableBuilder<List<Event>>(
        valueListenable: repo.events,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const Center(child: Text('No events yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = list[i];
              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(e.image, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                  ),
                  title: Text(e.title),
                  subtitle: Text('${e.location} • ${e.venue}\n${e.category} • \$${e.price.toStringAsFixed(0)}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final edited = await Navigator.of(context).push<Event?>(MaterialPageRoute(builder: (_) => EventFormPage(event: e)));
                        if (edited != null) {
                          await repo.updateEvent(edited);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated')));
                        }
                      } else if (v == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete event'),
                            content: const Text('Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('No')),
                              ElevatedButton(onPressed: () => Navigator.pop(_, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await repo.deleteEvent(e.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
                        }
                      } else if (v == 'toggle') {
                        await repo.toggleActive(e.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'toggle', child: Text('Toggle Active')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
