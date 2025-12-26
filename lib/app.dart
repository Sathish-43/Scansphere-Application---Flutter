// lib/app.dart
import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'features/auth/registration_page.dart';
import 'features/home/home_page.dart';
import 'features/admin/admin_page.dart';
import 'features/events/events_list_page.dart';
import 'features/events/event_detail_page.dart';
import 'features/home/bottom_nav_shell.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const RegistrationPage(),
        HomePage.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
          return HomePage(
            name: args?['name'] ?? '',
            location: args?['location'] ?? 'Salem',
            role: args?['role'] ?? 'User',
          );
        },

        // If you plan to use BottomNavShell via named route again, uncomment & use it:
        // BottomNavShell.routeName: (ctx) {
        //   final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
        //   return BottomNavShell(
        //     name: args?['name'] ?? '',
        //     location: args?['location'] ?? 'Salem',
        //     role: args?['role'] ?? 'User',
        //   );
        // },

        AdminPage.routeName: (ctx) => const AdminPage(),
        EventsPage.routeName: (ctx) => const EventsPage(),
        // NOTE: EventDetailPage removed from routes because we open it with MaterialPageRoute(event)
        // If you want a named route instead, see the comment below.
      },
    );
  }
}
