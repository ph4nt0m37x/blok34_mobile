import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double skopjeLat = 41.9961;
  static const double skopjeLng = 21.4317;

  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Requesting location...");
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print("Permission before: $permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("Permission after: $permission");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever");
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Position> getSafeLocation() async {
    try {
      return await getUserLocation();
    } catch (_) {
      return Position(
        latitude: skopjeLat,
        longitude: skopjeLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }
}