import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blok34_mobile/enums/venue_category.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/widgets/venue_grid.dart';
import 'package:blok34_mobile/screens/venues/venue_form_screen.dart';

import '../../utils/text_formatter.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  VenueCategory? _selectedCategory;
  List<Venue> _filteredVenues = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _showCategoryFilter = false;

  final List<Venue> venues = [
    // MOCK VENUES (UI only)
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
      name: 'Coffee & Code',
      category: VenueCategory.cafe,
      description: 'Cozy coffee shop perfect for working and meetings.',
      address: '456 Oak Ave, Arts District',
      phone: '+1234567891',
      isPublic: true,
      venueManagerId: 'user2',
      bannerPath: null,
    ),
    Venue(
      id: '3',
      name: 'Grand Stadium',
      category: VenueCategory.stadium,
      description: 'Large venue for sports and concerts.',
      address: '789 Sports Blvd',
      phone: '+1234567892',
      isPublic: true,
      venueManagerId: 'user3',
      bannerPath: null,
    ),
    Venue(
      id: '4',
      name: 'Art Gallery Downtown',
      category: VenueCategory.gallery,
      description: 'Contemporary art exhibitions and events.',
      address: '321 Gallery Row',
      phone: '+1234567893',
      isPublic: true,
      venueManagerId: 'user4',
      bannerPath: null,
    ),
    Venue(
      id: '5',
      name: 'The Secret Spot',
      category: VenueCategory.bar,
      description: 'Hidden gem with craft beers.',
      address: '555 Hidden Lane',
      phone: '+1234567894',
      isPublic: false,
      venueManagerId: 'user5',
      bannerPath: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredVenues = venues;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _searchVenues(String query) {

    //  final results = await searchVenues(query);
    // setState(() {
    //   _filteredVenues = results;
    // });


    setState(() {
      _isSearching = query.isNotEmpty;
    });

    setState(() {
      if (query.isEmpty && _selectedCategory == null) {
        _filteredVenues = venues;
      } else {
        _filteredVenues = venues.where((venue) {
          final matchesQuery = query.isEmpty ||
              venue.name.toLowerCase().contains(query.toLowerCase()) ||
              venue.description.toLowerCase().contains(query.toLowerCase()) ||
              venue.address.toLowerCase().contains(query.toLowerCase());

          final matchesCategory = _selectedCategory == null ||
              venue.category == _selectedCategory;

          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  void _searchByCategory(VenueCategory? category) {
    setState(() {
      _selectedCategory = category;
      _isSearching = category != null;
      _showCategoryFilter = false;
    });

    if (category != null) {
      // final results = await getVenuesByCategory(category); // Your function
      // setState(() {
      //   _filteredVenues = results;
      // });
    }

    //local filtering
    _searchVenues(_searchController.text);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = null;
      _showCategoryFilter = false;
    });
    _searchVenues('');
  }

  void _navigateToRegisterVenue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenueFormScreen(
          // currentUserId: '', // Replace with actual user ID
        ),
      ),
    );
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Browse Venues",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar Row with Filter Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
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
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 400), () {
                                  _searchVenues(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search venues...',
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
                                  onPressed: _clearFilters,
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
                        ),
                        const SizedBox(width: 12),
                        // Filter Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCategoryFilter = !_showCategoryFilter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _selectedCategory != null
                                      ? Colors.cyan.shade400.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.08),
                                  _selectedCategory != null
                                      ? Colors.purple.shade400.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.03),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _selectedCategory != null
                                    ? Colors.cyan.shade400.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              size: 22,
                              color: _selectedCategory != null
                                  ? Colors.cyan.shade300
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Filter Display
                  if (_selectedCategory != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade400.withValues(alpha: 0.15),
                              Colors.purple.shade400.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyan.shade400.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category, size: 14, color: Colors.cyan.shade300),
                            const SizedBox(width: 6),
                            Text(
                              TextFormatter.formatCategoryName(_selectedCategory!.name),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.cyan.shade200,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _clearFilters,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Category Filter Chips (appears when filter button is tapped)
                  if (_showCategoryFilter) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // All Categories Chip
                            _buildCategoryChip(null, "All Categories"),
                            // Category Chips
                            ...VenueCategory.values.map((category) {
                              return _buildCategoryChip(
                                category,
                                TextFormatter.formatCategoryName(category.name),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Venues Grid
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: _filteredVenues.isEmpty
                  ? SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: Center(
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
                        const Text(
                          "No venues found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Try different keywords",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : SliverToBoxAdapter(
                child: VenueGrid(venues: _filteredVenues),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.cyan.shade400.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.cyan.shade400.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.shade400.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToRegisterVenue,
          icon: Icon(Icons.add_business, size: 20, color: Colors.white),
          label: Text(
            "Register Venue",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryChip(VenueCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        _searchByCategory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.shade400.withValues(alpha: 0.25),
              Colors.purple.shade400.withValues(alpha: 0.2),
            ],
          )
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.cyan.shade400.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.cyan.shade200
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}