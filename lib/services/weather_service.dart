import '../models/weather_forecast.dart';

class WeatherService {

  List<Weather> fetchDailyWeather(Map<String, dynamic> json) {
    final daily = json['daily'];

    final times = daily['time'];

    return List.generate(times.length, (i) {
      return Weather(
        date: DateTime.parse(daily['time'][i]),
        maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
        minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
        feelsLike: (daily['apparent_temperature_max'][i] as num).toDouble(),
        rainMm: (daily['precipitation_sum'][i] as num).toDouble(),
        rainHours: (daily['precipitation_hours'][i] as num).toDouble(),
        rainProbability: daily['precipitation_probability_max'][i],
        windSpeed: (daily['wind_speed_10m_max'][i] as num).toDouble(),
        windGusts: (daily['wind_gusts_10m_max'][i] as num).toDouble(),
        uvIndex: (daily['uv_index_max'][i] as num).toDouble(),
      );
    });
  }

}