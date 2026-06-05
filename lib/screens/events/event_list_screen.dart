import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blok34_mobile/enums/event_category.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/widgets/event_grid.dart';

import '../../utils/text_formatter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  EventCategory? _selectedCategory;
  List<Event> _filteredEvents = [];
  bool _isSearching = false;
  Timer? _debounce;

  final List<Event> events = [
    // MOCK EVENTS (UI only)
    Event(
      id: '1',
      title: 'Flutter Meetup',
      description: 'Meet local Flutter developers.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      venueId: 'venue1',
      category: EventCategory.meetup,
      createdByUserId: 'user1',
      bannerPath: null,
    ),
    Event(
      id: '2',
      title: 'Rock Concert',
      description: 'Live music all night.',
      startDate: DateTime.now().add(const Duration(days: 2)),
      venueId: 'venue2',
      category: EventCategory.liveMusic,
      createdByUserId: 'user2',
      bannerPath: null,
    ),
    Event(
      id: '3',
      title: 'Board Games Night',
      description: 'Bring your favorite games.',
      startDate: DateTime.now().add(const Duration(days: 3)),
      venueId: 'venue3',
      category: EventCategory.culturalEvent,
      createdByUserId: 'user3',
      bannerPath: null,
    ),
    Event(
      id: '4',
      title: 'Startup Networking',
      description: 'Meet founders and investors.',
      startDate: DateTime.now().add(const Duration(days: 5)),
      venueId: 'venue4',
      category: EventCategory.beerTasting,
      createdByUserId: 'user4',
      bannerPath: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredEvents = events;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchEvents(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    //  final results = await searchEvents(query);
    // setState(() {
    //   _filteredEvents = results;
    // });

    // for now, filtering locally
    setState(() {
      if (query.isEmpty && _selectedCategory == null) {
        _filteredEvents = events;
      } else {
        _filteredEvents = events.where((event) {
          final matchesQuery = query.isEmpty ||
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase());

          final matchesCategory = _selectedCategory == null ||
              event.category == _selectedCategory;

          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  void _searchByCategory(EventCategory? category) async {
    setState(() {
      _selectedCategory = category;
      _isSearching = category != null;
    });

    if (category != null) {
      // final results = await getEventsByCategory(category); // Your function
      // setState(() {
      //   _filteredEvents = results;
      // });
    }
    // for now, filter locally
    _searchEvents(_searchController.text);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Search Bar Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // SEARCH FIELD (unchanged)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce = Timer(const Duration(milliseconds: 400), () {
                          _searchEvents(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // category dropdown
                  Row(
                    children: [
                      const Text(
                        'Filter by category:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: DropdownButton<EventCategory?>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...EventCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(TextFormatter.formatCategoryName(
                                    category.name,
                                  ),),
                                );
                              }),
                            ],
                            onChanged: _searchByCategory,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // events list
            Padding(
              padding: const EdgeInsets.all(12),
              child: _filteredEvents.isEmpty
                  ? Center(
                child: Column(
                  children: const [
                    Icon(Icons.search_off, size: 64, color: Colors.white70),
                    SizedBox(height: 12),
                    Text("No events found", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
                  : EventGrid(events: _filteredEvents),
            ),
          ],
        ),
      ),
    );
  }
}