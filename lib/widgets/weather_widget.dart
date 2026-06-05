import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/weather_forecast.dart';


class WeatherWidget extends StatefulWidget {
  final List<Weather> weatherData;

  const WeatherWidget({super.key, required this.weatherData});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _showExtendedForecast = false;

  @override
  Widget build(BuildContext context) {
    if (widget.weatherData.isEmpty) {
      return SizedBox.shrink();
    }

    final today = widget.weatherData.first;

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      color: Colors.white.withValues(alpha: 0.07),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // weather header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_queue, color: Colors.amber[600], size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Weather Forecast',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showExtendedForecast = !_showExtendedForecast;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _showExtendedForecast ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _showExtendedForecast ? 'Show Less' : 'Show More',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Today's Weather
                _buildTodayWeather(today),
                // Extended Forecast
                if (_showExtendedForecast) ...[
                  SizedBox(height: 16),
                  _buildExtendedForecast(),
                  SizedBox(height: 16),
                  _buildWeatherDetails(today),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayWeather(Weather today) {
    IconData weatherIcon;
    Color iconColor;

    if (today.rainProbability > 50) {
      weatherIcon = Icons.cloud_queue;
      iconColor = Colors.blue[300]!;
    } else if (today.maxTemp > 25) {
      weatherIcon = Icons.wb_sunny;
      iconColor = Colors.amber[600]!;
    } else {
      weatherIcon = Icons.cloud;
      iconColor = Colors.grey[400]!;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Weather Icon
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Icon(weatherIcon, color: iconColor, size: 48),
          ),
          // Temperature
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${today.maxTemp.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Feels like ${today.feelsLike.toStringAsFixed(0)}°C',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getDayName(today.date),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getFormattedDate(today.date),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtendedForecast() {
    final upcomingDays = widget.weatherData.skip(1).take(4).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: upcomingDays.length,
          itemBuilder: (context, index) {
            final day = upcomingDays[index];
            IconData weatherIcon;
            Color iconColor;

            if (day.rainProbability > 50) {
              weatherIcon = Icons.cloud_queue;
              iconColor = Colors.blue[300]!;
            } else if (day.maxTemp > 25) {
              weatherIcon = Icons.wb_sunny;
              iconColor = Colors.amber[600]!;
            } else {
              weatherIcon = Icons.cloud;
              iconColor = Colors.grey[400]!;
            }

            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getShortDayName(day.date),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Icon(weatherIcon, color: iconColor, size: 24),
                  SizedBox(height: 8),
                  Text(
                    '${day.maxTemp.toStringAsFixed(0)}°C',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${day.rainProbability.toStringAsFixed(0)}% rain',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeatherDetails(Weather today) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.air,
            label: 'Wind',
            value: '${today.windGusts.toStringAsFixed(0)} km/h',
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _buildDetailItem(
            icon: Icons.water_drop,
            label: 'Rain Hours',
            value: '${today.rainHours.toStringAsFixed(0)} h',
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _buildDetailItem(
            icon: Icons.brightness_5,
            label: 'UV Index',
            value: today.uvIndex.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getShortDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getFormattedDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }
}