import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/event.dart';
import 'event_card.dart';

class EventGrid extends StatelessWidget {
  final List<Event> events;

  const EventGrid({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
        );
      },
    );
  }
}