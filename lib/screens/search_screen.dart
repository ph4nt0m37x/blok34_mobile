// screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/services/search_service.dart';
import 'package:blok34_mobile/widgets/horizontal_scroll_list.dart';
import 'package:blok34_mobile/widgets/user_card.dart';
import 'package:blok34_mobile/widgets/event_card.dart';
import 'package:blok34_mobile/widgets/venue_card.dart';
import 'package:blok34_mobile/dto/search_result.dart';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  bool _isLoading = false;
  bool _hasSearched = false;
  SearchResult? _searchResult;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

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
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _hasSearched = false;
                                _searchResult = null;
                              });
                            },
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
                    if (_hasSearched && !_isLoading && _searchResult != null) ...[
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
                              (_searchResult!.users.length +
                                  _searchResult!.events.length +
                                  _searchResult!.venues.length).toString(),
                              Icons.search,
                            ),
                            _buildStatItem(
                              "Users",
                              _searchResult!.users.length.toString(),
                              Icons.people,
                            ),
                            _buildStatItem(
                              "Events",
                              _searchResult!.events.length.toString(),
                              Icons.event,
                            ),
                            _buildStatItem(
                              "Venues",
                              _searchResult!.venues.length.toString(),
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
    if (_searchResult == null ||
        (_searchResult!.users.isEmpty &&
            _searchResult!.events.isEmpty &&
            _searchResult!.venues.isEmpty)) {
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
          if (_searchResult!.users.isNotEmpty)
            HorizontalScrollList<AppUser>(
              items: _searchResult!.users,
              title: "Users",
              titleIcon: Icons.people,
              itemWidth: 160,
              itemHeight: 220,
              spacing: 16,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, user) {
                return UserCard(
                  user: user,
                  onActionPressed: () {
                    // Navigate to user profile
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: user.id)));
                  },
                );
              },
              onSeeAllTap: () {
                // Navigate to all users results
              },
            ),

          const SizedBox(height: 24),

          // Events Section
          if (_searchResult!.events.isNotEmpty)
            HorizontalScrollList<Event>(
              items: _searchResult!.events,
              title: "Events",
              titleIcon: Icons.event,
              itemWidth: 300,
              itemHeight: 330,
              spacing: 12,
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
          if (_searchResult!.venues.isNotEmpty)
            HorizontalScrollList<Venue>(
              items: _searchResult!.venues,
              title: "Venues",
              titleIcon: Icons.location_on,
              itemWidth: 280,
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