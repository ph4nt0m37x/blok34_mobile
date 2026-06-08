import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/widgets/venue_card.dart';

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