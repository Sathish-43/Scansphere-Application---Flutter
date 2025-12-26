import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('bookingsBox');
  }
}
