import 'package:blok34_mobile/screens/events/event_form_screen.dart';
import 'package:blok34_mobile/screens/venues/venue_form_screen.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/widgets/event_card.dart';
import 'package:blok34_mobile/widgets/glass_info_card.dart';
import 'package:blok34_mobile/widgets/horizontal_scroll_list.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';
import 'package:provider/provider.dart';
import 'package:blok34_mobile/providers/auth_state_provider.dart';
import 'package:blok34_mobile/services/event_service.dart';

class VenueDetails extends StatefulWidget {
  final Venue venue;

  const VenueDetails({
    super.key,
    required this.venue,
  });

  @override
  State<VenueDetails> createState() => _VenueDetailsState();
}

class _VenueDetailsState extends State<VenueDetails> {
  final EventService _eventService = EventService();
  List<Event> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
  }

  Future<void> _loadUpcomingEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _eventService.getEventsByVenueId(widget.venue.id);

      setState(() {
        _upcomingEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading upcoming events: $e');
      setState(() {
        _upcomingEvents = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthStateProvider>();
    final isOwner = widget.venue.venueManagerId == authProvider.currentUser?.id.toString();
    final canCreateEvent = widget.venue.isPublic && authProvider.currentUser != null || isOwner;

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
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.venue.bannerPath != null
                        ? Image.network(
                      widget.venue.bannerPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=2070&auto=format&fit=crop",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.network(
                      "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=2070&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.5),
                            const Color(0xFF0F0F1A).withValues(alpha: 0.95),
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.venue.isPublic
                              ? Colors.lightBlueAccent.withValues(alpha: 0.15)
                              : Colors.purpleAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: widget.venue.isPublic
                                ? Colors.blueAccent.withValues(alpha: 0.3)
                                : Colors.purpleAccent.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.venue.isPublic ? Icons.public : Icons.lock_outline,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.venue.isPublic ? "Public Venue" : "Private Venue",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Venue name and Action Buttons row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.venue.name,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        // Edit Button (only for owner)
                        if (isOwner)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VenueFormScreen(
                                    venue: widget.venue,
                                  ),
                                ),
                              ).then((_) {
                                // Refresh the page when coming back from edit
                                setState(() {});
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.orange.shade400.withValues(alpha: 0.2),
                                    Colors.red.shade400.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.orange.shade400.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.orange.shade300,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Create Event Button
                        if (canCreateEvent)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventFormScreen(
                                    currentUserId: authProvider.currentUser!.id,
                                    preSelectedVenueId: widget.venue.id, // Optional: pre-select this venue
                                  ),
                                ),
                              ).then((_) {
                                _loadUpcomingEvents();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.cyan.shade400.withValues(alpha: 0.2),
                                    Colors.purple.shade400.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.cyan.shade400.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.cyan.shade300,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Create Event",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.cyan.shade200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Info row - glassmorphic cards
                    Row(
                      children: [
                        Expanded(
                          child: GlassInfoCard(
                            icon: Icons.location_on,
                            label: "Location",
                            value: widget.venue.address,
                            iconColor: Colors.cyan.shade300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassInfoCard(
                            icon: Icons.phone,
                            label: "Phone",
                            value: widget.venue.phone,
                            iconColor: Colors.blue.shade300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassInfoCard(
                            icon: Icons.category,
                            label: "Category",
                            value: TextFormatter.formatCategoryName(widget.venue.category.name),
                            iconColor: Colors.purple.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                            Colors.purple.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.cyan.shade400.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(Icons.info_outline, size: 16, color: Colors.cyanAccent),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "About",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.venue.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Upcoming Events Section
                    _isLoading
                        ? Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Loading events...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : HorizontalScrollList<Event>(
                      items: _upcomingEvents,
                      title: "Upcoming Events",
                      titleIcon: Icons.event_available,
                      itemWidth: 300,
                      itemHeight: 330,
                      itemBuilder: (context, event) {
                        return EventCard(
                            event: event
                        );
                      },
                      emptyStateWidget: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.05),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No upcoming events",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              if (canCreateEvent) ...[
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventFormScreen(
                                          currentUserId: authProvider.currentUser!.id,
                                          preSelectedVenueId: widget.venue.id,
                                        ),
                                      ),
                                    ).then((_) {
                                      _loadUpcomingEvents();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.cyan.shade400.withValues(alpha: 0.2),
                                          Colors.purple.shade400.withValues(alpha: 0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.cyan.shade400.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      "Be the first to create one →",
                                      style: TextStyle(
                                        color: Colors.cyan.shade200,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}