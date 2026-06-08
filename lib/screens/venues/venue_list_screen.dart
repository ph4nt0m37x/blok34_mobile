import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blok34_mobile/enums/venue_category.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/widgets/venue_grid.dart';
import 'package:blok34_mobile/screens/venues/venue_form_screen.dart';
import 'package:blok34_mobile/services/venue_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final VenueService _venueService = VenueService();

  VenueCategory? _selectedCategory;
  List<Venue> _allVenues = [];
  List<Venue> _filteredVenues = [];
  bool _isSearching = false;
  bool _isLoading = true;
  Timer? _debounce;
  bool _showCategoryFilter = false;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Venue> venues;
        venues = await _venueService.getAllVenues();

      setState(() {
        _allVenues = venues;
        _filteredVenues = venues;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading venues: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load venues: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _searchVenues(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    setState(() {
      if (query.isEmpty && _selectedCategory == null) {
        _filteredVenues = _allVenues;
      } else {
        _filteredVenues = _allVenues.where((venue) {
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

  Future<void> _navigateToRegisterVenue() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VenueFormScreen(),
      ),
    );

    // Refresh the venues list if a new venue was created
    if (result != null) {
      _loadVenues();
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

            // Loading State
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading venues...",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
                          Text(
                            _selectedCategory != null || _searchController.text.isNotEmpty
                                ? "Try different keywords or filters"
                                : "No venues available yet",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                          ),
                          if (_selectedCategory != null || _searchController.text.isNotEmpty)
                            const SizedBox(height: 16),
                          if (_selectedCategory != null || _searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _clearFilters,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: const Text(
                                  "Clear Filters",
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                  ),
                                ),
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