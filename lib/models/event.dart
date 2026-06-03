import '../enums/event_category.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime startDate;
  DateTime? endDate;
  String venueId;
  EventCategory category;
  String? createdByUserId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.venueId,
    required this.category,
    this.createdByUserId,
  });

  Event.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        title = data['title'],
        description = data['description'],
        startDate = data['startDate'].toDate(),
        endDate = data['endDate']?.toDate(),
        venueId = data['venueId'],
        category = EventCategory.values.firstWhere(
              (e) => e.name == data['category'],
        ),
        createdByUserId = data['createdByUserId'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'venueId': venueId,
      'category': category.name,
      'createdByUserId': createdByUserId,
    };
  }
}