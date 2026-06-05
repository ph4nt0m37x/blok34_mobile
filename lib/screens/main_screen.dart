import 'package:flutter/material.dart';
import 'package:blok34_mobile/screens/home_screen.dart';
import 'package:blok34_mobile/screens/events/event_list_screen.dart';
import 'package:blok34_mobile/screens/venues/venue_list_screen.dart';
import 'package:blok34_mobile/screens/search_screen.dart';
import 'package:blok34_mobile/screens/profile/profile_screen.dart';

import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    EventsScreen(),
    VenuesScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF3B1F75),
              Color(0xFF6A1B9A),
            ],
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}