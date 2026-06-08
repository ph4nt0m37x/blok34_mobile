import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/services/venue_service.dart';
import 'package:flutter/cupertino.dart';

class VenueProvider extends ChangeNotifier {
  final VenueService _service = VenueService();

  List<Venue> _venues = [];
  bool _loaded = false;

  List<Venue> get venues => _venues;
  bool get isLoaded => _loaded;

  Future<void> loadMyVenues(String userId) async {
    if (_loaded) return;

    _venues = await _service.getVenuesByOwner(userId);
    _loaded = true;

    notifyListeners();
  }

  Future<void> refresh(String userId) async {
    _venues = await _service.getVenuesByOwner(userId);
    notifyListeners();
  }
}