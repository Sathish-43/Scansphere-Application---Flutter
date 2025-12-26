import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  static const routeName = "/events";

  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: const Center(
        child: Text("Events listing here..."),
      ),
    );
  }
}
