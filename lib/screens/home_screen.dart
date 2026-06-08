import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blok34_mobile/providers/weather_provider.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/services/event_service.dart';
import 'package:blok34_mobile/screens/events/event_form_screen.dart';
import 'package:blok34_mobile/widgets/event_grid.dart';
import 'package:blok34_mobile/widgets/weather_widget.dart';

import '../providers/auth_state_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  late Future<List<Event>> _upcomingEventsFuture;

  @override
  void initState() {
    super.initState();
    _upcomingEventsFuture = _eventService.getUpcomingEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather(41.99611, 21.43167);
    });
  }

  void _navigateToCreateEvent() {
    final authProvider = context.read<AuthStateProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          currentUserId: authProvider.currentUser!.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
              Color(0xFF4A0E4E),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Welcome Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Life happens offline.",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Share. Discover. Repeat.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Weather Widget
                  if (weatherProvider.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (weatherProvider.forecast.isNotEmpty)
                    WeatherWidget(weatherData: weatherProvider.forecast),

                  const SizedBox(height: 24),

                  // Upcoming Events Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.cyan.shade400.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.event_available,
                            size: 16,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Events Grid
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<List<Event>>(
                  future: _upcomingEventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final events = snapshot.data ?? [];

                    if (events.isEmpty) {
                      return SizedBox(
                        height: 400,
                        child: Center(
                          child: Text(
                            "No upcoming events",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return EventGrid(events: events);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.cyan.shade400.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.cyan.shade400.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.shade400.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateEvent,
          icon: Icon(
            Icons.add_circle_outline,
            size: 20,
            color: Colors.cyan.shade300,
          ),
          label: Text(
            "Create Event",
            style: TextStyle(
              color: Colors.cyan.shade200,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          extendedPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
