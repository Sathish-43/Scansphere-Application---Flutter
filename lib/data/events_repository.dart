// lib/data/events_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventsRepository {
  // singleton
  EventsRepository._internal();
  static final EventsRepository _instance = EventsRepository._internal();
  factory EventsRepository() => _instance;

  // ValueNotifier so UI can listen for changes
  final ValueNotifier<List<Event>> events = ValueNotifier<List<Event>>([]);

  bool _loaded = false;

  Future<void> loadEventsFromAssets() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/events.json');
      final List<dynamic> arr = jsonDecode(raw) as List<dynamic>;
      final list = arr.map((m) => Event.fromJson(m as Map<String, dynamic>)).toList();
      events.value = list;
      _loaded = true;
    } catch (e) {
      // default to empty list on error
      events.value = [];
      _loaded = true;
      if (kDebugMode) print('Error loading events.json: $e');
    }
  }

  // helpers
  List<Event> getAll() => List.unmodifiable(events.value);

  Future<void> addEvent(Event e) async {
    final newList = [...events.value, e];
    events.value = newList;
  }

  Future<void> updateEvent(Event e) async {
    final newList = events.value.map((x) => x.id == e.id ? e : x).toList();
    events.value = newList;
  }

  Future<void> deleteEvent(String id) async {
    final newList = events.value.where((x) => x.id != id).toList();
    events.value = newList;
  }

  Future<void> toggleActive(String id) async {
    final list = events.value.map((x) {
      if (x.id == id) {
        final copy = x.copyWith(active: !x.active);
        return copy;
      }
      return x;
    }).toList();
    events.value = list;
  }
}
