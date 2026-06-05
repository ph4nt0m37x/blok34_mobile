import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {

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
    final snap = await FirebaseFirestore.instance
        .collection('events')
        .where('venueId', isEqualTo: venueId)
        .orderBy('startDate', descending: true)
        .get();

    return snap.docs
        .map((doc) => Event.fromJson(doc.data(), doc.id))
        .toList();
  }



}