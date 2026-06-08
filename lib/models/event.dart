import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/event_category.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime startDate;
  DateTime? endDate;
  String venueId;
  EventCategory category;
  String createdByUserId;
  String? bannerPath;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.venueId,
    required this.category,
    required this.createdByUserId,
    this.bannerPath,
  });

  factory Event.fromJson(
      Map<String, dynamic> data,
      String id,
      ) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      venueId: data['venueId'] ?? '',
      category: EventCategory.values.firstWhere(
            (e) => e.name == data['category'],
      ),
      createdByUserId: data['createdByUserId'] ?? '',
      bannerPath: data['bannerPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate':
      endDate != null ? Timestamp.fromDate(endDate!) : null,
      'venueId': venueId,
      'category': category.name,
      'createdByUserId': createdByUserId,
      'bannerPath': bannerPath,
    };
  }
}