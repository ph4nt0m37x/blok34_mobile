// screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
// import 'package:blok34_mobile/services/search_service.dart';
import 'package:blok34_mobile/widgets/horizontal_scroll_list.dart';
import 'package:blok34_mobile/widgets/user_card.dart';
import 'package:blok34_mobile/widgets/event_card.dart';
import 'package:blok34_mobile/widgets/venue_card.dart';
import '../../enums/event_category.dart';
import '../../enums/venue_category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // final SearchService _searchService = SearchService();

  bool _isLoading = false;
  bool _hasSearched = false;
  // SearchResult? _searchResult;

  // Mock data
  List<AppUser> _mockUsers = [];
  List<Event> _mockEvents = [];
  List<Venue> _mockVenues = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock Users
    _mockUsers = [
      AppUser(
        id: '1',
        username: 'johndoe',
        name: 'John Doe',
        email: 'john@example.com',
        photoUrl: null,
      ),
      AppUser(
        id: '2',
        username: 'janesmith',
        name: 'Jane Smith',
        email: 'jane@example.com',
        photoUrl: null,
      ),
      AppUser(
        id: '3',
        username: 'musiclover',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        photoUrl: null,
      ),
      AppUser(
        id: '4',
        username: 'partyqueen',
        name: 'Sarah Williams',
        email: 'sarah@example.com',
        photoUrl: null,
      ),
    ];

    // Mock Events
    _mockEvents = [
      Event(
        id: '1',
        title: 'Summer Music Festival',
        description: 'Join us for an amazing day of live music, food, and fun in the sun! Featuring top local and international artists.',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15, hours: 8)),
        venueId: '1',
        category: EventCategory.liveMusic,
        createdByUserId: 'user1',
        bannerPath: null,
      ),
      Event(
        id: '2',
        title: 'Tech Conference 2026',
        description: 'Annual technology conference featuring workshops, keynotes, and networking opportunities with industry leaders.',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 32)),
        venueId: '2',
        category: EventCategory.techTalk,
        createdByUserId: 'user2',
        bannerPath: null,
      ),
      Event(
        id: '3',
        title: 'Food Truck Rally',
        description: 'Sample delicious food from over 20 local food trucks. Live music and family-friendly activities available.',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 6)),
        venueId: '3',
        category: EventCategory.beerTasting,
        createdByUserId: 'user3',
        bannerPath: null,
      ),
      Event(
        id: '4',
        title: 'Art Exhibition Opening',
        description: 'Opening night of the annual contemporary art exhibition featuring emerging local artists.',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 10, hours: 4)),
        venueId: '4',
        category: EventCategory.art,
        createdByUserId: 'user4',
        bannerPath: null,
      ),
      Event(
        id: '5',
        title: 'Business Networking Mixer',
        description: 'Connect with local business professionals over drinks and appetizers. Bring your business cards!',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5, hours: 3)),
        venueId: '5',
        category: EventCategory.startupEvent,
        createdByUserId: 'user5',
        bannerPath: null,
      ),
    ];

    // Mock Venues
    _mockVenues = [
      Venue(
        id: '1',
        name: 'The Jazz Club',
        category: VenueCategory.bar,
        description: 'Live jazz music every night. Great cocktails and atmosphere.',
        address: '123 Main St, Downtown',
        phone: '+1234567890',
        isPublic: true,
        venueManagerId: 'user1',
        bannerPath: null,
      ),
      Venue(
        id: '2',
        name: 'Convention Center',
        category: VenueCategory.communityCenter,
        description: 'Large venue perfect for conferences and trade shows.',
        address: '456 Convention Blvd',
        phone: '+1234567891',
        isPublic: true,
        venueManagerId: 'user2',
        bannerPath: null,
      ),
      Venue(
        id: '3',
        name: 'Parkside Amphitheater',
        category: VenueCategory.park,
        description: 'Outdoor venue surrounded by nature. Perfect for concerts and festivals.',
        address: '789 Park Avenue',
        phone: '+1234567892',
        isPublic: true,
        venueManagerId: 'user3',
        bannerPath: null,
      ),
      Venue(
        id: '4',
        name: 'The Gallery Space',
        category: VenueCategory.gallery,
        description: 'Modern art gallery with rotating exhibitions.',
        address: '321 Art District',
        phone: '+1234567893',
        isPublic: false,
        venueManagerId: 'user4',
        bannerPath: null,
      ),
      Venue(
        id: '5',
        name: 'Sports Arena',
        category: VenueCategory.stadium,
        description: 'Multi-purpose arena hosting sports events and concerts.',
        address: '555 Arena Drive',
        phone: '+1234567894',
        isPublic: true,
        venueManagerId: 'user5',
        bannerPath: null,
      ),
    ];
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // MOCK SEARCH - Filter based on query
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    final lowerQuery = query.toLowerCase();

    // Filter users
    final filteredUsers = _mockUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.username.toLowerCase().contains(lowerQuery);
    }).toList();

    // Filter events
    final filteredEvents = _mockEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery);
    }).toList();

    // Filter venues
    final filteredVenues = _mockVenues.where((venue) {
      return venue.name.toLowerCase().contains(lowerQuery) ||
          venue.description.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _mockUsers = filteredUsers;
      _mockEvents = filteredEvents;
      _mockVenues = filteredVenues;
      _isLoading = false;
    });

    /* ACTUAL SEARCH CODE - Uncomment when ready
    try {
      final result = await _searchService.search(query);
      setState(() {
        _searchResult = result;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    */
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      // _searchResult = null;
      _loadMockData(); // Reset mock data
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final searchResult = _searchResult; // Uncomment for actual code

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
              Color(0xFF4A0E4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: _performSearch,
                        decoration: InputDecoration(
                          hintText: "Search for events, venues, or users...",
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            onPressed: _clearSearch,
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Search Stats (only show after search)
                    if (_hasSearched && !_isLoading) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              "Total",
                              (_mockUsers.length + _mockEvents.length + _mockVenues.length).toString(),
                              Icons.search,
                            ),
                            _buildStatItem(
                              "Users",
                              _mockUsers.length.toString(),
                              Icons.people,
                            ),
                            _buildStatItem(
                              "Events",
                              _mockEvents.length.toString(),
                              Icons.event,
                            ),
                            _buildStatItem(
                              "Venues",
                              _mockVenues.length.toString(),
                              Icons.location_on,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Results Area
              Expanded(
                child: _buildResultsArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsArea() {
    // Initial state - encourage search
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.search,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Search for anything",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find events, venues, or people",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
        ),
      );
    }

    // No results state
    if (_mockUsers.isEmpty && _mockEvents.isEmpty && _mockVenues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try different keywords",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    // Results view
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Users Section
          if (_mockUsers.isNotEmpty)
            HorizontalScrollList<AppUser>(
              items: _mockUsers,
              title: "Users",
              titleIcon: Icons.people,
              itemWidth: 165,
              itemHeight: 225,
              spacing: 16,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, user) {
                return UserCard(
                  user: user,
                  onActionPressed: () {
                    // Navigate to user profile
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.id)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing profile of ${user.name}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
              onSeeAllTap: () {
                // Navigate to all users results
              },
            ),

          const SizedBox(height: 24),

          // Events Section
          if (_mockEvents.isNotEmpty)
            HorizontalScrollList<Event>(
              items: _mockEvents,
              title: "Events",
              titleIcon: Icons.event,
              itemWidth: 300,
              itemHeight: 350,
              // spacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, event) {
                return EventCard(event: event);
              },
              onSeeAllTap: () {
                // Navigate to all events results
              },
            ),

          const SizedBox(height: 24),

          // Venues Section
          if (_mockVenues.isNotEmpty)
            HorizontalScrollList<Venue>(
              items: _mockVenues,
              title: "Venues",
              titleIcon: Icons.location_on,
              itemWidth: 289,
              itemHeight: 300,
              spacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, venue) {
                return VenueCard(venue: venue);
              },
              onSeeAllTap: () {
                // Navigate to all venues results
              },
            ),
        ],
      ),
    );
  }
}