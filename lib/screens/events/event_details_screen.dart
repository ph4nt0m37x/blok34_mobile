import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/models/app_user.dart';
import 'package:blok34_mobile/models/event_attendance.dart';
import 'package:blok34_mobile/services/event_service.dart';
import 'package:blok34_mobile/services/user_service.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';
import 'package:blok34_mobile/utils/date_formatter.dart';

import '../../enums/attendance_status.dart';
import '../../widgets/glass_info_card.dart';
import '../profile/profile_screen.dart';

class EventDetails extends StatefulWidget {
  final Event event;
  final Venue venue;
  final String currentAppUserId;

  const EventDetails({
    super.key,
    required this.event,
    required this.venue,
    required this.currentAppUserId,
  });

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final EventService _eventService = EventService();
  final UserService _userService = UserService();

  List<AppUser> _interestedUsers = [];
  List<AppUser> _attendingUsers = [];
  EventAttendance? _userAttendance;
  AppUser? _creator;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _loadCreator(),
      _loadInterestedUsers(),
      _loadAttendingUsers(),
      _loadUserAttendance(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _loadCreator() async {
    try {
      _creator = await _userService.getUserById(widget.event.createdByUserId);
    } catch (e) {
      print('Error loading creator: $e');
      _creator = null;
    }
  }

  Future<void> _loadInterestedUsers() async {
    try {
      final attendances = await _eventService.getInterestedUsers(widget.event.id);
      final users = <AppUser>[];
      for (final attendance in attendances) {
        final user = await _userService.getUserById(attendance.userId);
        if (user != null) users.add(user);
      }
      setState(() => _interestedUsers = users);
    } catch (e) {
      print('Error loading interested users: $e');
      setState(() => _interestedUsers = []);
    }
  }

  Future<void> _loadAttendingUsers() async {
    try {
      final attendances = await _eventService.getAttendingUsers(widget.event.id);
      final users = <AppUser>[];
      for (final attendance in attendances) {
        final user = await _userService.getUserById(attendance.userId);
        if (user != null) users.add(user);
      }
      setState(() => _attendingUsers = users);
    } catch (e) {
      print('Error loading attending users: $e');
      setState(() => _attendingUsers = []);
    }
  }

  Future<void> _loadUserAttendance() async {
    try {
      final attendance = await _eventService.getUserAttendance(
        widget.event.id,
        widget.currentAppUserId,
      );
      setState(() => _userAttendance = attendance);
    } catch (e) {
      print('Error loading user attendance: $e');
      setState(() => _userAttendance = null);
    }
  }

  Future<void> _toggleInterest() async {
    try {
      if (_userAttendance?.status == AttendanceStatus.interested) {
        await _eventService.removeAttendance(widget.event.id, widget.currentAppUserId);
      } else {
        await _eventService.setAttendance(
          widget.event.id,
          widget.currentAppUserId,
          AttendanceStatus.interested,
        );
      }
      await _loadAllData();
    } catch (e) {
      _showErrorSnackBar('Error updating interest: $e');
    }
  }

  Future<void> _toggleAttendance() async {
    try {
      if (_userAttendance?.status == AttendanceStatus.attending) {
        await _eventService.removeAttendance(widget.event.id, widget.currentAppUserId);
      } else {
        await _eventService.setAttendance(
          widget.event.id,
          widget.currentAppUserId,
          AttendanceStatus.attending,
        );
      }
      await _loadAllData();
    } catch (e) {
      _showErrorSnackBar('Error updating attendance: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ),
        ),
      );
    }

    final isInterested = _userAttendance?.status == AttendanceStatus.interested;
    final isAttending = _userAttendance?.status == AttendanceStatus.attending;

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
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.event.bannerPath != null
                        ? Image.network(
                      widget.event.bannerPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          widget.venue.bannerPath ?? "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=2070&auto=format&fit=crop",
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.network(
                      widget.venue.bannerPath ?? "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=2070&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.5),
                            const Color(0xFF0F0F1A).withValues(alpha: 0.95),
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          TextFormatter.formatCategoryName(widget.event.category.name),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: GlassInfoCard(
                            icon: Icons.calendar_today,
                            label: "Date",
                            value: DateFormatter.formatDate(widget.event.startDate),
                            iconColor: Colors.cyan.shade300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassInfoCard(
                            icon: Icons.access_time,
                            label: "Time",
                            value: DateFormatter.formatTime(widget.event.startDate),
                            iconColor: Colors.blue.shade300,
                          ),
                        ),
                        if (widget.event.endDate != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassInfoCard(
                              icon: Icons.timer,
                              label: "Duration",
                              value: _getDuration(widget.event.startDate, widget.event.endDate!),
                              iconColor: Colors.purple.shade300,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                            Colors.purple.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade400.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.location_on, color: Colors.cyan.shade300, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.venue.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.venue.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_creator != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.03),
                              Colors.cyan.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.cyan, Colors.blue],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _creator!.photoUrl != null
                                    ? Image.network(_creator!.photoUrl!, fit: BoxFit.cover)
                                    : Icon(Icons.person, color: Colors.white.withValues(alpha: 0.8), size: 28),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hosted by",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _creator!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.cyan.shade400.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.cyan.shade400.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                "Creator",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: isInterested ? Icons.star : Icons.star_outline,
                            label: "Interested",
                            count: _interestedUsers.length,
                            isActive: isInterested,
                            activeColor: Colors.amber,
                            onTap: _toggleInterest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: isAttending ? Icons.check_circle : Icons.check_circle_outline,
                            label: "Attending",
                            count: _attendingUsers.length,
                            isActive: isAttending,
                            activeColor: Colors.green,
                            onTap: _toggleAttendance,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                            Colors.purple.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.cyan.shade400.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(Icons.description, size: 16, color: Colors.cyanAccent),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "About this event",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.event.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_interestedUsers.isNotEmpty)
                      _buildPeopleSection(
                        title: "Interested",
                        users: _interestedUsers,
                        icon: Icons.star,
                        color: Colors.amber,
                      ),

                    if (_attendingUsers.isNotEmpty)
                      _buildPeopleSection(
                        title: "Attending",
                        users: _attendingUsers,
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isActive
                ? [
              activeColor.withValues(alpha: 0.2),
              activeColor.withValues(alpha: 0.1),
            ]
                : [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? activeColor : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "$count ${count == 1 ? 'person' : 'people'}",
              style: TextStyle(
                fontSize: 11,
                color: isActive ? activeColor.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSection({
    required String title,
    required List<AppUser> users,
    required IconData icon,
    required Color color,
  }) {
    final displayUsers = users.take(8).toList();
    final remainingCount = users.length - displayUsers.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                "$title • ${users.length}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...displayUsers.map((user) => _buildUserAvatar(user, color)),
              if (remainingCount > 0)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "+$remainingCount",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(AppUser user, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: user.id),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: user.photoUrl != null
                  ? Image.network(user.photoUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person, color: Colors.white.withValues(alpha: 0.8), size: 28),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            user.name,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}