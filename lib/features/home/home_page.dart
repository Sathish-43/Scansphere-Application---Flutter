// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'tickets_page.dart';
import '../events/event_detail_page.dart';
import '../../models/booking.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final String name;
  final String location;
  final String role;

  const HomePage({super.key, required this.name, required this.location, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // *** CHANGED: use repository ValueNotifier instead of Future
  final EventsRepository _repo = EventsRepository();

  // ------------------ ADDED: in-memory lists for favorites and bookings
  final List<Event> _favorites = []; // *** ADDED
  final List<Booking> _bookings = []; // *** ADDED
  // ------------------

  final Color primaryRed = const Color(0xFFe53935);
  final Color accentYellow = const Color(0xFFFFC107);

  final List<Map<String, dynamic>> categories = [
    {'key': 'Music', 'label': 'Music', 'icon': Icons.music_note},
    {'key': 'Movies', 'label': 'Movies', 'icon': Icons.movie},
    {'key': 'Cricket', 'label': 'Cricket', 'icon': Icons.sports_cricket},
    {'key': 'Food', 'label': 'Food', 'icon': Icons.fastfood},
    {'key': 'Others', 'label': 'Others', 'icon': Icons.grid_view},
  ];

  @override
  void initState() {
    super.initState();
    // *** CHANGED: load events via repository (this sets the ValueNotifier)
    _repo.loadEventsFromAssets();
  }

  // Switch tabs
  void _onNavTap(int idx) {
    setState(() => _selectedIndex = idx);
  }

  // Filter events by selected location
  List<Event> _filterByLocation(List<Event> events) {
    return events.where((e) => e.location.toLowerCase() == widget.location.toLowerCase()).toList();
  }

  // ------------------ ADDED: Favorites & Booking helpers ------------------

  bool _isFavorite(Event e) => _favorites.any((x) => x.id == e.id); // *** ADDED

  void _toggleFavorite(Event e) {
    setState(() {
      if (_isFavorite(e)) {
        _favorites.removeWhere((x) => x.id == e.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
      } else {
        _favorites.add(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
      }
    });
  }

  Future<void> _showBookingDialog(Event e) async {
    int qty = 1;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Book: ${e.title}'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Price: \u20B9${e.price.toStringAsFixed(0)} per person'),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: qty > 1 ? () => setState(() => qty--) : null),
                Text('$qty', style: const TextStyle(fontSize: 18)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => qty++)),
              ]),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                onPressed: () => Navigator.of(ctx).pop(qty),
                child: const Text('Confirm',style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        });
      },
    );

    if (res != null && res > 0) {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: e.id,
        title: e.title,
        venue: e.venue,
        location: e.location,
        image: e.image,
        quantity: res,
        totalPrice: e.price * res,
        bookedAt: DateTime.now(),
      );

      setState(() {
        _bookings.add(booking);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
      // optionally switch to Tickets tab:
      setState(() => _selectedIndex = 3);
    }
  }

  void _cancelBooking(String bookingId) {
    setState(() {
      _bookings.removeWhere((b) => b.id == bookingId);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
  }

  // ------------------ END added helpers ------------------

  // Build the Home tab (events listing)
  Widget _buildEventsTab(List<Event> allEvents) {
    final filtered = _filterByLocation(allEvents);
    final upcoming = filtered.take(3).toList();
    final nearby = filtered.skip(3).toList();
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        // *** CHANGED: refresh by reloading repository (will update the ValueNotifier)
        await _repo.loadEventsFromAssets();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            // search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Search Events, Organizer', style: TextStyle(color: Colors.grey.shade600))),
                  Container(
                    decoration: BoxDecoration(color: accentYellow, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.tune, color: Colors.white, size: 18),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Categories
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () {}, child: Text('See all', style: TextStyle(color: primaryRed))),
            ]),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  return Column(children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)], borderRadius: BorderRadius.circular(16)),
                      child: Icon(c['icon'] as IconData, color: primaryRed, size: 32),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: 72, child: Text(c['label'], textAlign: TextAlign.center)),
                  ]);
                },
              ),
            ),

            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Upcoming Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () {}, child: Text('See all', style: TextStyle(color: primaryRed))),
            ]),

            SizedBox(
              height: 296,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final e = upcoming[index];
                  return GestureDetector(
                    // *** CHANGED: open EventDetailPage using MaterialPageRoute and await Booking result
                    onTap: () async {
                      final result = await Navigator.of(context).push<Booking>(
                        MaterialPageRoute(builder: (_) => EventDetailPage(event: e)),
                      );
                      if (result != null) {
                        setState(() {
                          _bookings.add(result);
                          _selectedIndex = 3; // switch to Tickets tab
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.74,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: SizedBox(height: 120, width: double.infinity, child: Image.asset(e.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // ------------------ favorite toggle and category
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: accentYellow, borderRadius: BorderRadius.circular(12)), child: Text(e.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              GestureDetector(
                                onTap: () => _toggleFavorite(e),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _isFavorite(e) ? primaryRed : Colors.grey.shade200,
                                  child: Icon(Icons.favorite, color: _isFavorite(e) ? Colors.white : Colors.black54, size: 16),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Text(e.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(child: Text('${e.venue} • ${DateFormat.MMMd().add_jm().format(e.startTime.toLocal())}', style: const TextStyle(fontSize: 12))),
                            ]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('\u20B9${e.price.toStringAsFixed(0)} /person', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryRed), onPressed: () => _showBookingDialog(e), child: const Text('Book', style: TextStyle(color: Colors.white)))
                            ])
                          ]),
                        )
                      ]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Nearby Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () {}, child: Text('See all', style: TextStyle(color: primaryRed))),
            ]),

            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: nearby.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ev = nearby[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(ev.image, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200))),
                    title: Text(ev.title),
                    subtitle: Text('${ev.venue} • ${DateFormat.MMMd().add_jm().format(ev.startTime.toLocal())}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('\u20B9${ev.price.toStringAsFixed(0)}'),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _toggleFavorite(ev),
                        child: Icon(_isFavorite(ev) ? Icons.favorite : Icons.favorite_border, color: _isFavorite(ev) ? primaryRed : Colors.black54),
                      ),
                    ]),
                    // *** CHANGED: open EventDetailPage via MaterialPageRoute and await Booking result
                    onTap: () async {
                      final result = await Navigator.of(context).push<Booking>(
                        MaterialPageRoute(builder: (_) => EventDetailPage(event: ev)),
                      );
                      if (result != null) {
                        setState(() {
                          _bookings.add(result);
                          _selectedIndex = 3; // switch to Tickets tab
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final location = widget.location;

    // The pages shown by bottom navigation (IndexedStack)
    final pages = [
      // Page 0: Events home tab (we build with ValueListenableBuilder)
      ValueListenableBuilder<List<Event>>(
        valueListenable: _repo.events,
        builder: (context, allEvents, _) {
          return _buildEventsTab(allEvents);
        },
      ),
      // Page 1: Profile (pass sign out)
      ProfilePage(
        name: name,
        onSignOut: () {
          Navigator.of(context).pushReplacementNamed('/');
        },
      ),
      // Page 2: Favorite (pass actual list + remove callback)
      FavoritePage(favorites: _favorites, onRemove: (ev) => _toggleFavorite(ev)),
      // Page 3: Tickets (pass bookings + cancel callback)
      TicketsPage(bookings: _bookings, onCancel: _cancelBooking),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(children: [
          const Icon(Icons.location_on, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(child: Text(location, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),

          // *** CHANGED: make avatar tappable and switch to Profile tab
          // Replaced plain CircleAvatar with InkWell + Semantics for accessibility.
          Semantics(
            label: 'Open profile',
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // switch the bottom nav to Profile tab
                setState(() => _selectedIndex = 1);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundColor: primaryRed,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                ),
              ),
            ),
          ),
        ]),
      ),

      // show the selected tab
      body: IndexedStack(index: _selectedIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Tickets'),
        ],
      ),
    );
  }
}
