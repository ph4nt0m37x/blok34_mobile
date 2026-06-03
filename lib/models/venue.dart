import '../enums/venue_category.dart';


class Venue {
  String id;
  String name;
  VenueCategory category;
  String description;
  String address;
  String? bannerPath;
  String phone;
  bool isPublic;
  String? venueManagerId;

  Venue({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    this.bannerPath,
    required this.phone,
    this.isPublic = true,
    this.venueManagerId,
  });

  Venue.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        name = data['name'],
        category = VenueCategory.values.firstWhere(
              (e) => e.name == data['category'],
        ),
        description = data['description'],
        address = data['address'],
        bannerPath = data['bannerPath'],
        phone = data['phone'],
        isPublic = data['isPublic'] ?? true,
        venueManagerId = data['venueManagerId'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'description': description,
      'address': address,
      'bannerPath': bannerPath,
      'phone': phone,
      'isPublic': isPublic,
      'venueManagerId': venueManagerId,
    };
  }
}