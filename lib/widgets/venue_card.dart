import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/screens/venues/venue_details_screen.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VenueDetails(venue: venue),
          ),
        );
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
                    venue.bannerPath ?? "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=2070&auto=format&fit=crop",
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
                          Icons.location_city,
                          size: 50,
                          color: Colors.white54,
                        ),
                      );
                    },
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
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 10, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.description,
                    style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 10, color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            venue.phone,
                            style: TextStyle(fontSize: 9, color: textColor.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.category, size: 10, color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            TextFormatter.formatCategoryName(venue.category.name),
                            style: TextStyle(fontSize: 9, color: textColor.withValues(alpha: 0.8)),
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