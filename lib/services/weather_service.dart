import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_forecast.dart';

class WeatherService {
  Future<List<Weather>> fetchDailyWeather(
      double latitude,
      double longitude,
      ) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&daily=temperature_2m_max,temperature_2m_min,apparent_temperature_max,'
          'precipitation_sum,precipitation_hours,precipitation_probability_max,'
          'wind_speed_10m_max,wind_gusts_10m_max,uv_index_max'
          '&timezone=auto',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load weather data (${response.statusCode})',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(response.body) as Map<String, dynamic>;

    final daily = json['daily'];

    final times = daily['time'];

    return List.generate(times.length, (i) {
      return Weather(
        date: DateTime.parse(daily['time'][i]),
        maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
        minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
        feelsLike:
        (daily['apparent_temperature_max'][i] as num).toDouble(),
        rainMm: (daily['precipitation_sum'][i] as num).toDouble(),
        rainHours:
        (daily['precipitation_hours'][i] as num).toDouble(),
        rainProbability:
        daily['precipitation_probability_max'][i] as int,
        windSpeed:
        (daily['wind_speed_10m_max'][i] as num).toDouble(),
        windGusts:
        (daily['wind_gusts_10m_max'][i] as num).toDouble(),
        uvIndex:
        (daily['uv_index_max'][i] as num).toDouble(),
      );
    });
  }
}