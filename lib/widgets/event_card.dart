import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/screens/events/event_details_screen.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';
import 'package:blok34_mobile/utils/date_formatter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_state_provider.dart';
import '../services/venue_service.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final VenueService _venueService = VenueService();
  Venue? _venue;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVenue();
  }

  Future<void> _loadVenue() async {
    try {
      final venue = await _venueService.getVenueById(widget.event.venueId);
      setState(() {
        _venue = venue;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading venue: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    final authProvider = context.read<AuthStateProvider>();

    return GestureDetector(
      onTap: () {
        if (_venue != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => EventDetails(
                event: widget.event,
                venue: _venue!,
                currentAppUserId: authProvider.currentUser!.id,
              ),
            ),
          );
        } else {
          // Show error if venue not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Venue not found for this event'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white.withValues(alpha: 0.07),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: widget.event.bannerPath != null
                  ? Image.network(
                      widget.event.bannerPath!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.shade800.withValues(alpha: 0.6),
                                Colors.blue.shade800.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.nightlife_rounded,
                            size: 50,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade800.withValues(alpha: 0.6),
                            Colors.blue.shade800.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: Colors.white54,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatDate(widget.event.startDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatTime(widget.event.startDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: Colors.cyan.shade300,
                                      ),
                                    )
                                  : Text(
                                      _venue?.name ?? 'Venue not found',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textColor.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 14,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            TextFormatter.formatCategoryName(
                              widget.event.category.name,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
