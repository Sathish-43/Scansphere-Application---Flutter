// lib/features/home/favorite_page.dart
import 'package:flutter/material.dart';
import '../../models/event.dart';

class FavoritePage extends StatelessWidget {
  final List<Event> favorites;
  final void Function(Event) onRemove;

  const FavoritePage({super.key, required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites'),backgroundColor: Colors.amberAccent,),
        body: const Center(child: Text('No favorite events yet. Tap the heart on any event to save it.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites'),backgroundColor: Colors.amberAccent,),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final ev = favorites[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(ev.image, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
              ),
              title: Text(ev.title),
              subtitle: Text('${ev.venue} • ${ev.location}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => onRemove(ev),
              ),
              onTap: () {
                // Open details
                Navigator.of(context).pushNamed('/event-detail', arguments: ev);
              },
            ),
          );
        },
      ),
    );
  }
}
