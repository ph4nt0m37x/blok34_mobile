import 'package:flutter/material.dart';
import 'package:blok34_mobile/screens/home_screen.dart';
import 'package:blok34_mobile/models/event.dart';

import '../utils/date_formatter.dart';
import '../utils/text_formatter.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    Color text = Colors.white;

    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EventDetails(category: event.id,)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white.withOpacity(0.07),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image - fixed height
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                width: double.infinity,
                height: 160, // Reduced from 180
                fit: BoxFit.cover,
              ),
            ),

            // Content area - NO Expanded here
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: text,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // Date and Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 14, color: text.withOpacity(0.7)),
                          SizedBox(width: 6),
                          Text(
                            DateFormatter.formatDate(event.startDate),
                            style: TextStyle(fontSize: 12, color: text.withOpacity(0.8)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 12),
                          Icon(Icons.access_time, size: 14, color: text.withOpacity(0.7)),
                          SizedBox(width: 6),
                          Text(
                            DateFormatter.formatTime(event.startDate),
                            style: TextStyle(fontSize: 12, color: text.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Description
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 12, color: text.withOpacity(0.7)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 10),

                  // Location and Category Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: text.withOpacity(0.7)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "event.venueId",
                                style: TextStyle(fontSize: 11, color: text.withOpacity(0.8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.category, size: 14, color: text.withOpacity(0.7)),
                          SizedBox(width: 6),
                          Text(
                            TextFormatter.formatCategoryName(
                              event.category.name,
                            ),
                            style: TextStyle(fontSize: 11, color: text.withOpacity(0.8)),
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