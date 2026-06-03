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

  // SearchResult.fromJson(Map<String, dynamic> json)
  //     : query = json['query'],
  //       users = (json['users'] as List)
  //           .map((e) => AppUser.fromJson(e, e['id']))
  //           .toList(),
  //       events = (json['events'] as List)
  //           .map((e) => Event.fromJson(e, e['id']))
  //           .toList(),
  //       venues = (json['venues'] as List)
  //           .map((e) => Venue.fromJson(e, e['id']))
  //           .toList();
}