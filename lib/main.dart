// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize local storage (Hive). If you don't want Hive yet, you can comment this line.
  await LocalStorage.init();
  runApp(const App());
}
