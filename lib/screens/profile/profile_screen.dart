// screens/profile/profile_screen.dart
import 'package:blok34_mobile/screens/events/event_details_screen.dart';
import 'package:blok34_mobile/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:blok34_mobile/services/auth_service.dart';
import 'package:blok34_mobile/services/user_service.dart';
import 'package:blok34_mobile/services/event_service.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/event_attendance.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_state_provider.dart';
import '../../services/venue_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();

  AppUser? _user;
  List<Event> _createdEvents = [];
  List<Event> _attendingEvents = [];
  List<Event> _interestedEvents = [];
  bool _isLoading = true;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkIfCurrentUser();
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkIfCurrentUser() {
    final currentUser = _authService.getCurrentFirebaseUser();
    if (currentUser != null && currentUser.uid == widget.userId) {
      _isCurrentUser = true;
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data using UserService
      _user = await _userService.getUserById(widget.userId);

      if (_user == null) {
        throw Exception('User not found');
      }

      // Load user's events
      await _loadUserEvents();

    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        _showSnackBar('Error loading profile: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserEvents() async {
    try {
      // Load events created by the user
      _createdEvents = await _eventService.getEventsByCreator(widget.userId);

      // Load events the user is attending
      final attendingRecords = await _eventService.getEventsUserIsAttending(widget.userId);
      final attendingEvents = <Event>[];
      for (final record in attendingRecords) {
        final event = await _eventService.getEventById(record.eventId);
        if (event != null) {
          attendingEvents.add(event);
        }
      }
      _attendingEvents = attendingEvents;

      // Load events the user is interested in
      final interestedRecords = await _eventService.getEventsUserIsInterestedIn(widget.userId);
      final interestedEvents = <Event>[];
      for (final record in interestedRecords) {
        final event = await _eventService.getEventById(record.eventId);
        if (event != null) {
          interestedEvents.add(event);
        }
      }
      _interestedEvents = interestedEvents;

      // Sort events by date
      _createdEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
      _attendingEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
      _interestedEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading user events: $e');
      if (mounted) {
        _showSnackBar('Error loading events: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade900,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToEventDetails(Event event) async {
    final authProvider = context.read<AuthStateProvider>();

    final venue = await VenueService().getVenueById(event.venueId);

    if (venue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Venue not found")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetails(
          event: event,
          venue: venue,
          currentAppUserId: authProvider.currentUser!.id,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.cyanAccent,
            ),
          )
              : CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),

              // Stats Badges
              SliverToBoxAdapter(
                child: _buildStatsBadges(),
              ),

              // Main Content with Tabs
              SliverToBoxAdapter(
                child: _buildTabsSection(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6a0dad), Color(0xFF8a2be2)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6a0dad).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: _user?.photoUrl != null
                    ? Image.network(
                  _user!.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white.withValues(alpha: 0.8),
                    );
                  },
                )
                    : Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${_user?.username ?? 'username'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _user!.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Edit Button for current user
            if (_isCurrentUser)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  // Refresh user data if returning from settings
                  if (result == true) {
                    _loadUserData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.shade400.withValues(alpha: 0.2),
                        Colors.purple.shade400.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.cyan.shade400.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.cyan.shade300,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildBadge(
            icon: Icons.event,
            label: 'Events Created',
            count: _createdEvents.length,
            color: const Color(0xFF6a0dad),
          ),
          const SizedBox(width: 12),
          _buildBadge(
            icon: Icons.check_circle,
            label: 'Attending',
            count: _attendingEvents.length,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildBadge(
            icon: Icons.star,
            label: 'Interested',
            count: _interestedEvents.length,
            color: Colors.cyan,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildTabButton(0, 'Attending', _attendingEvents.length),
                const SizedBox(width: 12),
                _buildTabButton(1, 'Interested', _interestedEvents.length),
              ],
            ),
          ),

          // Tab Content
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(_attendingEvents, 'attending'),
                _buildEventsList(_interestedEvents, 'interested'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, int count) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6a0dad).withValues(alpha: 0.6),
                const Color(0xFF8a2be2).withValues(alpha: 0.6),
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, String type) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'attending' ? Icons.event_busy : Icons.star_border,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'attending'
                  ? 'Not attending any events'
                  : 'No interested events',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'attending'
                  ? '${_user?.name ?? 'This user'} hasn\'t confirmed attendance for any events yet'
                  : '${_user?.name ?? 'This user'} hasn\'t shown interest in any events yet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => _navigateToEventDetails(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Event Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4B0082), Color(0xFF6a0dad)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: event.bannerPath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    event.bannerPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 30,
                      );
                    },
                  ),
                )
                    : const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),

              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(event.startDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} • ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}