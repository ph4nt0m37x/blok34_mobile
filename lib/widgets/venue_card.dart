import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/venue.dart';

import '../enums/event_category.dart';
import '../models/event.dart';
import '../screens/venues/venue_details_screen.dart';
import '../utils/text_formatter.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    Color text = Colors.white;

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

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VenueDetails(venue: venue, upcomingEvents: events), ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.07),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badge positioned top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: venue.isPublic
                          ? Colors.lightBlueAccent.withValues(alpha: 0.3)
                          : Colors.purpleAccent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: venue.isPublic ? Colors.lightBlueAccent : Colors.purpleAccent,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          venue.isPublic ? Icons.public : Icons.lock_outline,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          venue.isPublic ? "Public" : "Private",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: text,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 10, color: text.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(fontSize: 10, color: text.withValues(alpha: 0.8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.description,
                    style: TextStyle(fontSize: 10, color: text.withValues(alpha: 0.7)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 10, color: text.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            venue.phone,
                            style: TextStyle(fontSize: 9, color: text.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.category, size: 10, color: text.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            TextFormatter.formatCategoryName(venue.category.name),
                            style: TextStyle(fontSize: 9, color: text.withValues(alpha: 0.8)),
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