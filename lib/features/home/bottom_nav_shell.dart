// // // lib/features/home/bottom_nav_shell.dart
// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'profile_page.dart';
// import 'favorite_page.dart';
// import 'tickets_page.dart';

// class BottomNavShell extends StatefulWidget {
//   static const routeName = '/app-shell';

//   final String name;
//   final String location;
//   final String role;

//   const BottomNavShell({
//     super.key,
//     required this.name,
//     required this.location,
//     required this.role,
//   });

//   @override
//   State<BottomNavShell> createState() => _BottomNavShellState();
// }

// class _BottomNavShellState extends State<BottomNavShell> {
//   int _selectedIndex = 0;
//   late final List<Widget> _pages;
//   final Color primaryRed = const Color(0xFFe53935);

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       HomePage(name: widget.name, location: widget.location, role: widget.role),
//       ProfilePage(name: widget.name),
//       const FavoritePage(),
//       const TicketsPage(),
//     ];
//   }

//   void _onTap(int idx) => setState(() => _selectedIndex = idx);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: _pages),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTap,
//         selectedItemColor: primaryRed,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorite'),
//           BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Tickets'),
//         ],
//       ),
//     );
//   }
// }
