import '../dto/search_result.dart';
import '../models/app_user.dart';
import '../models/event.dart';
import '../models/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Venue>> searchVenues(String query) async {
  final snap = await FirebaseFirestore.instance
      .collection('venues')
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: '$query\uf8ff')
      .get();

  return snap.docs
      .map((doc) => Venue.fromJson(doc.data(), doc.id))
      .toList();
}

Future<List<Event>> searchEvents(String query) async {
  final snap = await FirebaseFirestore.instance
      .collection('events')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThanOrEqualTo: '$query\uf8ff')
      .get();

  return snap.docs
      .map((doc) => Event.fromJson(doc.data(), doc.id))
      .toList();
}

Future<List<AppUser>> searchUsers(String query) async {
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isGreaterThanOrEqualTo: query)
      .where('username', isLessThanOrEqualTo: '$query\uf8ff')
      .get();

  return snap.docs
      .map((d) => AppUser.fromJson(d.data(), d.id))
      .toList();
}

Future<SearchResult> search(String query) async {
  final users = await searchUsers(query);
  final events = await searchEvents(query);
  final venues = await searchVenues(query);

  return SearchResult(
    query: query,
    users: users,
    events: events,
    venues: venues,
  );
}