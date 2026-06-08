import 'package:flutter/material.dart';
import 'package:blok34_mobile/screens/profile/created_events_screen.dart';
import 'package:blok34_mobile/screens/profile/created_venues_screen.dart';
import 'package:blok34_mobile/screens/profile/settings_screen.dart';
import 'package:blok34_mobile/screens/home_screen.dart';
import 'package:blok34_mobile/screens/events/event_list_screen.dart';
import 'package:blok34_mobile/screens/venues/venue_list_screen.dart';
import 'package:blok34_mobile/screens/search_screen.dart';
import 'package:blok34_mobile/screens/profile/profile_screen.dart';
import 'package:blok34_mobile/widgets/top_nav_bar.dart';
import 'package:blok34_mobile/widgets/bottom_nav_bar.dart';
import 'package:blok34_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../providers/auth_state_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final AuthService _authService = AuthService();
  late final authProvider = context.read<AuthStateProvider>();

  String? get currentUserId =>
      _authService.getCurrentFirebaseUser()?.uid;

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();

      case 1:
        return const EventsScreen();

      case 2:
        return const SearchScreen();

      case 3:
        return const VenuesScreen();

      case 4:
        return ProfileScreen(
          userId: currentUserId ?? '',
        );

      default:
        return const HomeScreen();
    }
  }

  void _onMyEventsTap() {
    if (currentUserId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatedEventsScreen(
          currentUserId: currentUserId!,
        ),
      ),
    );
  }

  void _onMyVenuesTap() {
    if (currentUserId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatedVenuesScreen(
          currentUserId: currentUserId!,
        ),
      ),
    );
  }

  void _onSettingsTap() {
    if (currentUserId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  void _onLogoutTap() {
    // Handle logout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await _authService.logout();

              if (!mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D1B69),
      appBar: TopNavBar(
        userPhotoUrl: authProvider.currentUser?.photoUrl,
        onMyEventsTap: _onMyEventsTap,
        onMyVenuesTap: _onMyVenuesTap,
        onSettingsTap: _onSettingsTap,
        onLogoutTap: _onLogoutTap,
      ),
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
        child: _getCurrentScreen(),
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