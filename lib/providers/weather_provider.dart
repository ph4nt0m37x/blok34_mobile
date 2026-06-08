import 'package:flutter/cupertino.dart';
import 'package:blok34_mobile/models/weather_forecast.dart';
import 'package:blok34_mobile/services/weather_service.dart';
import 'package:blok34_mobile/services/location_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  List<Weather> _forecast = [];
  bool _isLoading = false;
  DateTime? _lastFetch;
  final LocationService _locationService = LocationService();

  List<Weather> get forecast => _forecast;
  bool get isLoading => _isLoading;

  Future<void> loadWeather() async {
    final pos = await _locationService.getSafeLocation();

    if (_isLoading) return;

    if (_forecast.isEmpty || _lastFetch == null) {
      await refreshWeather(pos.latitude, pos.longitude);
      return;
    }

    final age = DateTime.now().difference(_lastFetch!);

    if (age > const Duration(hours: 1)) {
      await refreshWeather(pos.latitude, pos.longitude);
    }
  }

  Future<void> refreshWeather(
      double latitude,
      double longitude,
      ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _forecast = await _service.fetchDailyWeather(
        latitude,
        longitude,
      );

      _lastFetch = DateTime.now();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}