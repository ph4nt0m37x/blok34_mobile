import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blok34_mobile/enums/venue_category.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/widgets/venue_grid.dart';

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
                  // SEARCH FIELD
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
                          _searchVenues(value);
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search venues...',
                        prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
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
                          child: DropdownButton<VenueCategory?>(
                            value: _selectedCategory,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...VenueCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(TextFormatter.formatCategoryName(
                                    category.name,
                                  )),
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

            // venues grid
            Padding(
              padding: const EdgeInsets.all(12),
              child: _filteredVenues.isEmpty
                  ? Center(
                child: Column(
                  children: const [
                    Icon(Icons.search_off, size: 64, color: Colors.white70),
                    SizedBox(height: 12),
                    Text("No venues found", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
                  : VenueGrid(venues: _filteredVenues),
            ),
          ],
        ),
      ),
    );
  }
}