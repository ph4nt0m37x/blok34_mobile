import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/event_category.dart';
import '../models/event.dart';
import '../models/weather_forecast.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';
import '../widgets/event_grid.dart';
import '../widgets/weather_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final WeatherService _weatherService = WeatherService();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>()
          .loadWeather( 41.99611, 21.43167);
    });
  }
  Future<void> loadWeather() async {
    try {
      final provider = context.read<WeatherProvider>();

      await provider.loadWeather(
        41.99611,
        21.43167,
      );

      setState(() {
        weatherData = provider.forecast;
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
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Share your next adventure with others in Skopje :)",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("Create New Event"),
                      ),
                    )
                  ],
                ),
              ),


              if (weatherProvider.isLoading)
                const CircularProgressIndicator()
              else if (weatherProvider.forecast.isNotEmpty)
                WeatherWidget(
                  weatherData: weatherProvider.forecast,
                ),

              const SizedBox(height: 24),

              const Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              EventGrid(events: events),
            ],
          ),
        ),
      ),
    )

    );
  }
}