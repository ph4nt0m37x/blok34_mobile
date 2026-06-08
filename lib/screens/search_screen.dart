import 'package:blok34_mobile/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/widgets/horizontal_scroll_list.dart';
import 'package:blok34_mobile/widgets/user_card.dart';
import 'package:blok34_mobile/widgets/event_card.dart';
import 'package:blok34_mobile/widgets/venue_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _hasSearched = false;

  List<AppUser> _searchResultsUsers = [];
  List<Event> _searchResultsEvents = [];
  List<Venue> _searchResultsVenues = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResultsUsers = [];
      _searchResultsEvents = [];
      _searchResultsVenues = [];
    });

    final lowerQuery = query.toLowerCase().trim();

    try {
      // Search Users
      final usersQuery = await _firestore
          .collection('users')
          .get();

      final users = usersQuery.docs
          .map((doc) => AppUser.fromJson(doc.data(), doc.id))
          .where((user) =>
      user.name.toLowerCase().contains(lowerQuery) ||
          user.username.toLowerCase().contains(lowerQuery))
          .toList();

      // Search Events
      final eventsQuery = await _firestore
          .collection('events')
          .get();

      final events = eventsQuery.docs
          .map((doc) => Event.fromJson(doc.data(), doc.id))
          .where((event) =>
      event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery))
          .toList();

      // Search Venues
      final venuesQuery = await _firestore
          .collection('venues')
          .get();

      final venues = venuesQuery.docs
          .map((doc) => Venue.fromJson(doc.data(), doc.id))
          .where((venue) =>
      venue.name.toLowerCase().contains(lowerQuery) ||
          venue.description.toLowerCase().contains(lowerQuery))
          .toList();

      setState(() {
        _searchResultsUsers = users;
        _searchResultsEvents = events;
        _searchResultsVenues = venues;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResultsUsers = [];
      _searchResultsEvents = [];
      _searchResultsVenues = [];
    });
  }

  int get _totalResults {
    return _searchResultsUsers.length +
        _searchResultsEvents.length +
        _searchResultsVenues.length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    if (_hasSearched && !_isLoading && _totalResults > 0) ...[
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
                              _totalResults.toString(),
                              Icons.search,
                            ),
                            _buildStatItem(
                              "Users",
                              _searchResultsUsers.length.toString(),
                              Icons.people,
                            ),
                            _buildStatItem(
                              "Events",
                              _searchResultsEvents.length.toString(),
                              Icons.event,
                            ),
                            _buildStatItem(
                              "Venues",
                              _searchResultsVenues.length.toString(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
            SizedBox(height: 16),
            Text(
              "Searching...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    // No results state
    if (_searchResultsUsers.isEmpty &&
        _searchResultsEvents.isEmpty &&
        _searchResultsVenues.isEmpty) {
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
          if (_searchResultsUsers.isNotEmpty)
            HorizontalScrollList<AppUser>(
              items: _searchResultsUsers,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: user.id),
                      ),
                    );
                  },
                );
              },
            ),

          if (_searchResultsUsers.isNotEmpty)
            const SizedBox(height: 24),

          // Events Section
          if (_searchResultsEvents.isNotEmpty)
            HorizontalScrollList<Event>(
              items: _searchResultsEvents,
              title: "Events",
              titleIcon: Icons.event,
              itemWidth: 300,
              itemHeight: 350,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, event) {
                return EventCard(event: event);
              },
            ),

          if (_searchResultsEvents.isNotEmpty)
            const SizedBox(height: 24),

          // Venues Section
          if (_searchResultsVenues.isNotEmpty)
            HorizontalScrollList<Venue>(
              items: _searchResultsVenues,
              title: "Venues",
              titleIcon: Icons.location_on,
              itemWidth: 289,
              itemHeight: 300,
              spacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, venue) {
                return VenueCard(venue: venue);
              },
            ),
        ],
      ),
    );
  }
}