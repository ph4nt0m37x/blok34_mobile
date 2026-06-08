import 'dart:io';

import 'package:image_picker/image_picker.dart';

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

  Future<List<Venue>> getAvailableVenues(String userId) async {
    final publicVenuesFuture = FirebaseFirestore.instance
        .collection('venues')
        .where('isPublic', isEqualTo: true)
        .get();

    final ownedVenuesFuture = FirebaseFirestore.instance
        .collection('venues')
        .where('venueManagerId', isEqualTo: userId)
        .get();

    final results = await Future.wait([
      publicVenuesFuture,
      ownedVenuesFuture,
    ]);

    final Map<String, Venue> venues = {};

    for (final doc in results[0].docs) {
      venues[doc.id] = Venue.fromJson(doc.data(), doc.id);
    }

    for (final doc in results[1].docs) {
      venues[doc.id] = Venue.fromJson(doc.data(), doc.id);
    }

    final venueList = venues.values.toList();

    venueList.sort(
          (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );

    return venueList;
  }

  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

}