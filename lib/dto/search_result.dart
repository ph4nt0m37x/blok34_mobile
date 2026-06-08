import '../models/app_user.dart';
import '../models/event.dart';
import '../models/venue.dart';

class SearchResult {
  String query;
  List<AppUser> users;
  List<Event> events;
  List<Venue> venues;

  SearchResult({
    required this.query,
    required this.users,
    required this.events,
    required this.venues,
  });
}