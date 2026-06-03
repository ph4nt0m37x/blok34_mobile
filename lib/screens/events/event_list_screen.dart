import 'package:flutter/material.dart';
import '/enums/venue_category.dart';
import '/models/event.dart';
import '/models/venue.dart';
import '/models/event_attendance.dart';

class EventsPage extends StatefulWidget {
  final List<Event> events;
  final List<EventAttendance> attendances;
  final List<Venue> venues;

  const EventsPage({
    super.key,
    required this.events,
    required this.attendances,
    required this.venues,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String searchQuery = '';
  String eventStatus = '';

  DateTime now = DateTime.now();

  // ---------------- HELPERS ----------------

  Venue? getVenue(String venueId) {
    return widget.venues.firstWhere(
          (v) => v.id == venueId,
      orElse: () => Venue(
        id: '',
        name: 'Unknown venue',
        category: VenueCategory.values.first,
        description: '',
        address: '',
        phone: '',
      ),
    );
  }

  int getAttendanceCount(String eventId) {
    return widget.attendances.where((a) => a.eventId == eventId).length;
  }

  bool isPast(Event e) =>
      e.endDate != null ? e.endDate!.isBefore(now) : e.startDate.isBefore(now);

  bool isUpcoming(Event e) => e.startDate.isAfter(now);

  bool isOngoing(Event e) =>
      e.startDate.isBefore(now) &&
          (e.endDate == null || e.endDate!.isAfter(now));

  // ---------------- FILTERED EVENTS ----------------

  List<Event> get filteredEvents {
    var list = widget.events;

    if (searchQuery.isNotEmpty) {
      list = list.where((e) {
        return e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            e.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (eventStatus.isNotEmpty) {
      list = list.where((e) {
        switch (eventStatus) {
          case 'upcoming':
            return isUpcoming(e);
          case 'ongoing':
            return isOngoing(e);
          case 'past':
            return isPast(e);
          default:
            return true;
        }
      }).toList();
    }

    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF6A0DAD),
              Color(0xFF8A2BE2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _hero(),
              _searchBar(),
              Expanded(child: _list()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HERO ----------------

  Widget _hero() {
    final upcoming =
        widget.events.where((e) => e.startDate.isAfter(now)).length;

    final ongoing =
        widget.events.where((e) => isOngoing(e)).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Discover Events",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat("Upcoming", upcoming),
              _stat("Ongoing", ongoing),
              _stat("Total", widget.events.length),
            ],
          )
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  // ---------------- SEARCH ----------------

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search events...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip("All", ""),
                _chip("Upcoming", "upcoming"),
                _chip("Ongoing", "ongoing"),
                _chip("Past", "past"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = eventStatus == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => eventStatus = value),
        selectedColor: const Color(0xFF8A2BE2),
        labelStyle:
        TextStyle(color: selected ? Colors.white : Colors.white70),
      ),
    );
  }

  // ---------------- LIST ----------------

  Widget _list() {
    final events = filteredEvents;

    if (events.isEmpty) {
      return const Center(
        child: Text("No events found",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, i) {
        return _card(events[i]);
      },
    );
  }

  // ---------------- CARD ----------------

  Widget _card(Event e) {
    final venue = getVenue(e.venueId);
    final attendees = getAttendanceCount(e.id);

    final past = isPast(e);
    final ongoing = isOngoing(e);
    final upcoming = isUpcoming(e);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // IMAGE
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              image: venue?.bannerPath != null
                  ? DecorationImage(
                image: NetworkImage(venue!.bannerPath!),
                fit: BoxFit.cover,
              )
                  : null,
              color: Colors.deepPurple,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: _statusBadge(past, ongoing, upcoming),
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  e.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        venue?.name ?? "Unknown venue",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${attendees} attending",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "${e.startDate.day}/${e.startDate.month}/${e.startDate.year}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statusBadge(bool past, bool ongoing, bool upcoming) {
    String text;
    Color color;

    if (past) {
      text = "Past";
      color = Colors.grey;
    } else if (ongoing) {
      text = "Live";
      color = Colors.green;
    } else {
      text = "Upcoming";
      color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}