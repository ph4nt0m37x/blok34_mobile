import 'dart:io';

import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/event_attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blok34_mobile/enums/attendance_status.dart';
import 'package:blok34_mobile/enums/event_category.dart';

import 'package:blok34_mobile/services/cloudinary_service.dart';

class EventService {

  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<List<Event>> getAllEvents() async {
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('startDate', descending: true)
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<Event>> getUpcomingEvents() async {
    final now = DateTime.now();

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate')
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<Event?> getEventById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return Event.fromJson(doc.data()!, doc.id);
  }

  Future<void> insertEvent(Event event) async {
    final doc = FirebaseFirestore.instance.collection('events').doc();

    await doc.set(event.toJson());
  }

  Future<void> updateEvent(Event event) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(event.id)
        .update(event.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(id)
        .delete();
  }

  Future<List<Event>> getEventsByCreator(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('createdByUserId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<Event>> getEventsByVenueId(String venueId) async {
    final now = DateTime.now();

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('venueId', isEqualTo: venueId)
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate', descending: true)
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<Event>> getUpcomingEventsByCategory(EventCategory category,) async {
    final now = DateTime.now();

    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('category', isEqualTo: category.name)
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate')
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<String> uploadEventBanner({
    required File imageFile,
    required String eventId,
  }) async {

    final bannerPath = await _cloudinaryService.uploadImage(
      imageFile,
      folder: 'event_banners',
    );

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'bannerPath': bannerPath,
    });

    return bannerPath;
  }

  // ATTENDANCE

  Future<List<EventAttendance>> getAttendingUsers(
      String eventId,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where(
      'status',
      isEqualTo: AttendanceStatus.attending.name,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => EventAttendance.fromJson(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Future<List<EventAttendance>> getInterestedUsers(
      String eventId,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where(
      'status',
      isEqualTo: AttendanceStatus.interested.name,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => EventAttendance.fromJson(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Future<EventAttendance?> getUserAttendance(
      String eventId,
      String userId,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return EventAttendance.fromJson(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  Future<void> setAttendance(
      String eventId,
      String userId,
      AttendanceStatus status,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('event_attendance')
          .add({
        'eventId': eventId,
        'userId': userId,
        'status': status.name,
      });
    } else {
      await snapshot.docs.first.reference.update({
        'status': status.name,
      });
    }
  }

  Future<void> removeAttendance(
      String eventId,
      String userId,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  Future<List<EventAttendance>> getEventsUserIsAttending(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AttendanceStatus.attending.name)
        .get();

    return snapshot.docs
        .map((doc) => EventAttendance.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<EventAttendance>> getEventsUserIsInterestedIn(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('event_attendance')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: AttendanceStatus.interested.name)
        .get();

    return snapshot.docs
        .map((doc) => EventAttendance.fromJson(doc.data(), doc.id))
        .toList();
  }


}