import 'package:flutter/material.dart';
import 'event_card.dart';

import 'package:blok34_mobile/models/event.dart';

class EventGrid extends StatefulWidget {
  final List<Event> events;

  const EventGrid({super.key, required this.events});

  @override
  State<StatefulWidget> createState() => _EventGridState();
}

class _EventGridState extends State<EventGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 4,
          // crossAxisSpacing: 4,
          childAspectRatio: 2.4
      ),
      itemCount: widget.events.length,
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return EventCard(event: widget.events[index]);
      },
    );
  }
}