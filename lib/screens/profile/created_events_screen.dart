// screens/events/my_events_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blok34_mobile/enums/event_category.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/widgets/event_grid.dart';
import 'package:blok34_mobile/screens/events/event_form_screen.dart';
import 'package:blok34_mobile/screens/events/event_details_screen.dart';
import 'package:blok34_mobile/services/event_service.dart';
import 'package:blok34_mobile/services/venue_service.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../events/event_details_screen.dart';

class CreatedEventsScreen extends StatefulWidget {
  final String currentUserId;

  const CreatedEventsScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<CreatedEventsScreen> createState() => _CreatedEventsScreenState();
}

class _CreatedEventsScreenState extends State<CreatedEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EventService _eventService = EventService();
  final VenueService _venueService = VenueService();

  EventCategory? _selectedCategory;
  List<Event> _filteredEvents = [];
  List<Event> _myEvents = [];
  bool _isSearching = false;
  bool _isLoading = true;
  Timer? _debounce;
  bool _showCategoryFilter = false;

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadMyEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch events created by the current user
      final events = await _eventService.getEventsByCreator(widget.currentUserId);

      setState(() {
        _myEvents = events;
        _filteredEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading my events: $e');
      setState(() {
        _myEvents = [];
        _filteredEvents = [];
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load your events');
    }
  }

  void _searchEvents(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    setState(() {
      if (query.isEmpty && _selectedCategory == null) {
        _filteredEvents = _myEvents;
      } else {
        _filteredEvents = _myEvents.where((event) {
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

  void _searchByCategory(EventCategory? category) {
    setState(() {
      _selectedCategory = category;
      _isSearching = category != null;
      _showCategoryFilter = false;
    });

    _searchEvents(_searchController.text);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = null;
      _showCategoryFilter = false;
    });
    _searchEvents('');
  }

  Future<void> _navigateToCreateEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          currentUserId: widget.currentUserId,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadMyEvents();
      _searchEvents(_searchController.text);
    }
  }

  Future<void> _navigateToEditEvent(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          currentUserId: widget.currentUserId,
          event: event,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadMyEvents();
      _searchEvents(_searchController.text);
    }
  }

  Future<void> _navigateToEventDetails(Event event) async {
    try {
      // Fetch venue details for the event
      final venue = await _venueService.getVenueById(event.venueId);

      if (!mounted) return;

      // Check if venue exists
      if (venue == null) {
        _showErrorSnackBar('Venue not found for this event');
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetails(
            event: event,
            venue: venue, // Now venue is non-nullable
            currentAppUserId: widget.currentUserId,
          ),
        ),
      );

      if (result != null && mounted) {
        await _loadMyEvents();
        _searchEvents(_searchController.text);
      }
    } catch (e) {
      print('Error loading venue: $e');
      _showErrorSnackBar('Failed to load event details');
    }
  }

  void _showEventOptions(Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildBottomSheetOption(
                icon: Icons.edit,
                label: 'Edit Event',
                color: Colors.cyan.shade300,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditEvent(event);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.visibility,
                label: 'View Details',
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEventDetails(event);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.people,
                label: 'Manage Attendees',
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  _showManageAttendees(event);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.delete,
                label: 'Delete Event',
                color: Colors.red.shade300,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteEvent(event);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageAttendees(Event event) {
    // TODO: Implement manage attendees screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manage attendees for ${event.title} - Coming Soon'),
        backgroundColor: Colors.cyan.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required Color color,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade300 : Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _confirmDeleteEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        title: const Text('Delete Event', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Delete the event from Firestore
        await _eventService.deleteEvent(event.id);

        // Delete banner from storage if exists
        if (event.bannerPath != null) {
          try {
            final storage = FirebaseStorage.instance;
            final storageRef = storage.ref().child('event_banners').child('${event.id}.jpg');
            await storageRef.delete();
          } catch (e) {
            print('Error deleting banner: $e');
          }
        }

        // Refresh the list
        await _loadMyEvents();
        _searchEvents(_searchController.text);

        if (mounted) {
          _showSuccessSnackBar('${event.title} deleted successfully');
        }
      } catch (e) {
        print('Error deleting event: $e');
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to delete event');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      "My Events",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with event count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _myEvents.length == 1
                          ? "You have created 1 event"
                          : "You have created ${_myEvents.length} events",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
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
                                  _searchEvents(value);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search my events...',
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

                  // Category Filter Chips
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
                            ...EventCategory.values.map((category) {
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

            // Events Grid or Loading State
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading your events...",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: _filteredEvents.isEmpty
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
                              _myEvents.isEmpty ? Icons.event_busy : Icons.search_off,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _myEvents.isEmpty ? "No events yet" : "No events found",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _myEvents.isEmpty
                                ? "Create your first event to get started"
                                : "Try different keywords",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          if (_myEvents.isEmpty) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _navigateToCreateEvent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.cyan.shade400.withValues(alpha: 0.2),
                                      Colors.purple.shade400.withValues(alpha: 0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.cyan.shade400.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 18, color: Colors.cyan.shade300),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Create Event",
                                      style: TextStyle(
                                        color: Colors.cyan.shade200,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverToBoxAdapter(
                  child: EventGrid(
                    events: _filteredEvents,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
      floatingActionButton: _myEvents.isNotEmpty ? Container(
        decoration: BoxDecoration(
          color: Colors.purpleAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.purpleAccent.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateEvent,
          icon: Icon(Icons.add_circle_outline, size: 20, color: Colors.white),
          label: Text(
            "Create Event",
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
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryChip(EventCategory? category, String label) {
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