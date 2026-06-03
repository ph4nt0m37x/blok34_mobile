import '../models/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenueService {

  Future<List<Venue>> getAllVenues() async {
    final snap = await FirebaseFirestore.instance
        .collection('venues')
        .orderBy('name')
        .get();

    return snap.docs
        .map((doc) => Venue.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<Venue?> getVenueById(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('venues')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return Venue.fromJson(doc.data()!, doc.id);
  }

  Future<void> insertVenue(Venue venue) async {
    final doc = FirebaseFirestore.instance.collection('venues').doc();

    await doc.set(venue.toJson());
  }

  Future<void> updateVenue(Venue venue) async {
    await FirebaseFirestore.instance
        .collection('venues')
        .doc(venue.id)
        .update(venue.toJson());
  }

  Future<void> deleteVenue(String id) async {
    await FirebaseFirestore.instance
        .collection('venues')
        .doc(id)
        .delete();
  }

  Future<List<Venue>> getVenuesByOwner(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('venues')
        .where('venueManagerId', isEqualTo: userId)
        .get();

    return snap.docs
        .map((doc) => Venue.fromJson(doc.data(), doc.id))
        .toList();
  }

}