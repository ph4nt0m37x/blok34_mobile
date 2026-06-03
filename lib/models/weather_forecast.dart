class Weather {
  DateTime date;
  double maxTemp;
  double minTemp;
  double feelsLike;
  double rainMm;
  double rainHours;
  int rainProbability;
  double windSpeed;
  double windGusts;
  double uvIndex;

  Weather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.feelsLike,
    required this.rainMm,
    required this.rainHours,
    required this.rainProbability,
    required this.windSpeed,
    required this.windGusts,
    required this.uvIndex,
  });

  Weather.fromJson(Map<String, dynamic> data)
      : date = data['date'].toDate(),
        maxTemp = (data['maxTemp'] as num).toDouble(),
        minTemp = (data['minTemp'] as num).toDouble(),
        feelsLike = (data['feelsLike'] as num).toDouble(),
        rainMm = (data['rainMm'] as num).toDouble(),
        rainHours = (data['rainHours'] as num).toDouble(),
        rainProbability = data['rainProbability'],
        windSpeed = (data['windSpeed'] as num).toDouble(),
        windGusts = (data['windGusts'] as num).toDouble(),
        uvIndex = (data['uvIndex'] as num).toDouble();

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'feelsLike': feelsLike,
      'rainMm': rainMm,
      'rainHours': rainHours,
      'rainProbability': rainProbability,
      'windSpeed': windSpeed,
      'windGusts': windGusts,
      'uvIndex': uvIndex,
    };
  }
}