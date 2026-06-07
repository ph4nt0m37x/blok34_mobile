import '../dto/search_result.dart';
import '../models/app_user.dart';
import '../models/event.dart';
import '../models/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {

// VENUES

Future<List<Venue>> searchVenues(String query) async {
  final lowerQuery = query.toLowerCase();

  // 1. Name prefix search (Firestore optimized)
  final nameSnap = await FirebaseFirestore.instance
      .collection('venues')
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: '$query\uf8ff')
      .get();

  // 2. Category exact match (assuming stored as enum.name or string)
  final categorySnap = await FirebaseFirestore.instance
      .collection('venues')
      .where('category', isEqualTo: query)
      .get();

  final nameResults = nameSnap.docs
      .map((doc) => Venue.fromJson(doc.data(), doc.id));

  final categoryResults = categorySnap.docs
      .map((doc) => Venue.fromJson(doc.data(), doc.id));

  // 3. Merge results
  final combined = {
    ...nameResults,
    ...categoryResults,
  }.toList();

  // 4. Optional safety filter (catches partial matches)
  final filtered = combined.where((venue) {
    final name = venue.name.toLowerCase();
    final category = venue.category.name.toLowerCase();

    return name.contains(lowerQuery) || category.contains(lowerQuery);
  }).toList();

  return filtered;
}

Future<List<Venue>> getVenuesByCategory(String category) async {
  final snap = await FirebaseFirestore.instance
      .collection('venues')
      .where('category', isEqualTo: category)
      .get();

  return snap.docs
      .map((doc) => Venue.fromJson(doc.data(), doc.id))
      .toList();
}


// EVENTS


Future<List<Event>> searchEvents(String query) async {
  final lowerQuery = query.toLowerCase();
  final now = DateTime.now();

  // 1. TITLE search
  final titleSnap = await FirebaseFirestore.instance
      .collection('events')
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThanOrEqualTo: '$query\uf8ff')
      .get();

  // 2. CATEGORY search
  final categorySnap = await FirebaseFirestore.instance
      .collection('events')
      .where('category', isEqualTo: query)
      .get();

  // Convert to models
  final titleResults = titleSnap.docs
      .map((d) => Event.fromJson(d.data(), d.id));

  final categoryResults = categorySnap.docs
      .map((d) => Event.fromJson(d.data(), d.id));

  // 3. Merge
  final combined = {
    ...titleResults,
    ...categoryResults,
  }.toList();

  // 4. FILTER: upcoming + keyword match
  final filtered = combined.where((event) {
    final isUpcoming = event.startDate.isAfter(now);

    final title = event.title.toLowerCase();
    final desc = event.description.toLowerCase();

    final matchesQuery = query.isEmpty ||
        title.contains(lowerQuery) ||
        desc.contains(lowerQuery);

    return isUpcoming && matchesQuery;
  }).toList();

  // 5. Sort upcoming first
  filtered.sort((a, b) => a.startDate.compareTo(b.startDate));

  return filtered;
}

Future<List<Event>> getEventsByCategory(String category) async {
  final now = Timestamp.now();

  final snap = await FirebaseFirestore.instance
      .collection('events')
      .where('category', isEqualTo: category)
      .where('startDate', isGreaterThanOrEqualTo: now)
      .orderBy('startDate')
      .get();

  return snap.docs
      .map((doc) => Event.fromJson(doc.data(), doc.id))
      .toList();
}


// USERS


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
}