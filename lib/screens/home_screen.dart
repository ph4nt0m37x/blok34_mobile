import 'package:flutter/material.dart';

import '../enums/event_category.dart';
import '../models/event.dart';
import '../models/weather_forecast.dart';
import '../services/weather_service.dart';
import '../widgets/event_grid.dart';
import '../widgets/weather_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();

  List<Weather> weatherData = [];
  bool isLoadingWeather = true;

  final List<Event> events = [
    // MOCK EVENTS (UI only)
    Event(
      id: '1',
      title: 'Flutter Meetup',
      description: 'Meet local Flutter developers.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      venueId: 'venue1',
      category: EventCategory.meetup,
      createdByUserId: 'user1',
      bannerPath: null,
    ),
    Event(
      id: '2',
      title: 'Rock Concert',
      description: 'Live music all night.',
      startDate: DateTime.now().add(const Duration(days: 2)),
      venueId: 'venue2',
      category:

      EventCategory.liveMusic,
      createdByUserId: 'user2',
      bannerPath: null,
    ),
    Event(
      id: '3',
      title: 'Board Games Night',
      description: 'Bring your favorite games.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
      startDate: DateTime.now().add(const Duration(days: 3)),
      venueId: 'venue3',
      category: EventCategory.culturalEvent,
      createdByUserId: 'user3',
      bannerPath: null,
    ),
    Event(
      id: '4',
      title: 'Startup Networking',
      description: 'Meet founders and investors.',
      startDate: DateTime.now().add(const Duration(days: 5)),
      venueId: 'venue4',
      category: EventCategory.beerTasting,
      createdByUserId: 'user4',
      bannerPath: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      final data = await _weatherService.fetchDailyWeather(
        41.9981, // skopje latitude
        21.4254, // skopje longitude
      );

      setState(() {
        weatherData = data;
        isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // WEATHER SECTION
            if (isLoadingWeather)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (weatherData.isNotEmpty)
              WeatherWidget(weatherData: weatherData),

            const SizedBox(height: 12),

            // EVENTS GRID
            Expanded(
              child: EventGrid(events: events),
            ),
          ],
        ),
      ),
    );
  }
}