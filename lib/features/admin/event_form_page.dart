// lib/features/admin/event_form_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/event.dart';

class EventFormPage extends StatefulWidget {
  final Event? event;
  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _venue = TextEditingController();
  final _price = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();

  String _category = 'Music';
  String _location = 'Salem';
  DateTime _start = DateTime.now().add(const Duration(days: 1));
  DateTime _end = DateTime.now().add(const Duration(days: 1, hours: 3));
  String _imagePath = ''; // asset path or file path
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final e = widget.event!;
      _title.text = e.title;
      _venue.text = e.venue;
      _price.text = e.price.toString();
      _capacity.text = e.capacity.toString();
      _description.text = e.description;
      _category = e.category;
      _location = e.location;
      _start = e.startTime;
      _end = e.endTime;
      _imagePath = e.image;
      _active = e.active;
    }
  }

  Future<void> _pickImage() async {
    final ip = ImagePicker();
    final pick = await ip.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pick != null) {
      setState(() => _imagePath = pick.path);
    }
  }

  Future<void> _pickDateTime({required bool start}) async {
    final d = await showDatePicker(context: context, initialDate: start ? _start : _end, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime(2100));
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start ? _start : _end));
    if (t == null) return;
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() {
      if (start) _start = dt;
      else _end = dt;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_price.text) ?? 0.0;
    final capacity = int.tryParse(_capacity.text) ?? 1;
    if (_end.isBefore(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be after start time')));
      return;
    }

    final id = widget.event?.id ?? const Uuid().v4();
    final e = Event(
      id: id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      image: _imagePath.isNotEmpty ? _imagePath : 'assets/images/default.jpg',
      startTime: _start,
      endTime: _end,
      venue: _venue.text.trim(),
      location: _location,
      category: _category,
      price: price,
      capacity: capacity,
      ticketsSold: widget.event?.ticketsSold ?? 0,
      active: _active,
    );

    Navigator.of(context).pop(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),backgroundColor: Colors.amberAccent
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _category, items: const [
                DropdownMenuItem(value: 'Music', child: Text('Music')),
                DropdownMenuItem(value: 'Movies', child: Text('Movies')),
                DropdownMenuItem(value: 'Cricket', child: Text('Cricket')),
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Others', child: Text('Others')),
              ], onChanged: (v) => setState(() => _category = v ?? 'Music'))),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(value: _location, items: const [
                DropdownMenuItem(value: 'Salem', child: Text('Salem')),
                DropdownMenuItem(value: 'Chennai', child: Text('Chennai')),
              ], onChanged: (v) => setState(() => _location = v ?? 'Salem'))),
            ]),
            const SizedBox(height: 8),
            TextFormField(controller: _venue, decoration: const InputDecoration(labelText: 'Venue'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
            ]),
            const SizedBox(height: 8),
            ListTile(
              title: Text('Start: ${_start.toLocal()}'.split('.').first),
              trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDateTime(start: true)),
            ),
            ListTile(
              title: Text('End: ${_end.toLocal()}'.split('.').first),
              trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDateTime(start: false)),
            ),
            TextFormField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            Row(children: [
              _imagePathWidget(),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Pick image')),
            ]),
            const SizedBox(height: 8),
            SwitchListTile(value: _active, onChanged: (v) => setState(() => _active = v), title: const Text('Active')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
            ])
          ]),
        ),
      ),
    );
  }

  Widget _imagePathWidget() {
    if (_imagePath.isEmpty) {
      return Container(width: 96, height: 96, color: Colors.grey.shade200, child: const Icon(Icons.image));
    }
    // if path points to asset (contains assets/) use Image.asset, else use File
    if (_imagePath.contains('assets/')) {
      return Image.asset(_imagePath, width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 96, height: 96, color: Colors.grey.shade200));
    }
    return Image.file(File(_imagePath), width: 96, height: 96, fit: BoxFit.cover);
  }
}
