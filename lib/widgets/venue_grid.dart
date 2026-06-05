import 'package:flutter/material.dart';
import 'venue_card.dart';

import '../models/venue.dart';

class VenueGrid extends StatefulWidget {
  final List<Venue> venues;

  const VenueGrid({super.key, required this.venues});

  @override
  State<StatefulWidget> createState() => _VenueGridState();
}

class _VenueGridState extends State<VenueGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5
      ),
      itemCount: widget.venues.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return VenueCard(venue: widget.venues[index]);
      },
    );
  }
}