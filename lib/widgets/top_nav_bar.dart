// widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userPhotoUrl;
  final VoidCallback? onMyEventsTap;
  final VoidCallback? onMyVenuesTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  const CustomAppBar({
    super.key,
    this.userPhotoUrl,
    this.onMyEventsTap,
    this.onMyVenuesTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A3E),
            Color(0xFF1A1A3E),
            Color(0xFF1A1A3E),
            Color(0xFF1A1A3E),
            Color(0xFF2D1B69),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SVG Logo
                  SizedBox(
                    width: 100,
                    height: 60,
                    child: CustomPaint(
                      painter: Blok34LogoPainter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "blok34",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // User Avatar with Dropdown
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                color: const Color(0xFF1A1A3E),
                elevation: 8,
                padding: EdgeInsets.zero, // Remove default padding
                constraints: const BoxConstraints(), // Remove constraints
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600, // Solid purple
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                        ? Image.network(
                      userPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.white.withValues(alpha: 0.8),
                        );
                      },
                    )
                        : Icon(
                      Icons.person,
                      size: 24,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'my_events',
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      child: _MenuItemContent(
                        icon: Icons.event,
                        label: "My Events",
                        isDestructive: false,
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'my_venues',
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      child: _MenuItemContent(
                        icon: Icons.location_on,
                        label: "My Venues",
                        isDestructive: false,
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      child: _MenuItemContent(
                        icon: Icons.settings,
                        label: "Settings",
                        isDestructive: false,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      child: _MenuItemContent(
                        icon: Icons.logout,
                        label: "Logout",
                        isDestructive: true,
                      ),
                    ),
                  ),
                ],
                onSelected: (value) {
                  // Then execute the action
                  switch (value) {
                    case 'my_events':
                      onMyEventsTap?.call();
                      break;
                    case 'my_venues':
                      onMyVenuesTap?.call();
                      break;
                    case 'settings':
                      onSettingsTap?.call();
                      break;
                    case 'logout':
                      onLogoutTap?.call();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

// Separate widget for menu item content to avoid reconstruction issues
class _MenuItemContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _MenuItemContent({
    required this.icon,
    required this.label,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive
                ? Colors.red.shade300
                : Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDestructive
                  ? Colors.red.shade300
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the SVG logo
class Blok34LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Abstract building silhouette
    final gradient1 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF4B0082), Color(0xFF6a0dad)],
    );

    // Rect 1 (left building)
    final rect1 = Rect.fromLTWH(15, 10, 25, 40);
    final rect1Paint = Paint()..shader = gradient1.createShader(rect1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect1, const Radius.circular(4)),
      rect1Paint,
    );

    // Rect 2 (middle building)
    final rect2Paint = Paint()..color = const Color(0xFF5D3FD3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, 20, 20, 30),
        const Radius.circular(3),
      ),
      rect2Paint,
    );

    // Rect 3 (right building)
    final rect3Paint = Paint()..color = const Color(0xFF4B0082);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(60, 30, 15, 20),
        const Radius.circular(2),
      ),
      rect3Paint,
    );

    // Stylized bubble pattern
    final purplePaint1 = Paint()..color = const Color(0xFF4B0082);
    final purplePaint2 = Paint()..color = const Color(0xFF5D3FD3);
    final purplePaint3 = Paint()..color = const Color(0xFF6a0dad);

    // First row
    canvas.drawCircle(const Offset(20, 20), 4, purplePaint1);
    canvas.drawCircle(const Offset(35, 20), 4, purplePaint2);
    canvas.drawCircle(const Offset(50, 25), 4, purplePaint3);
    canvas.drawCircle(const Offset(65, 30), 4, purplePaint1);
    canvas.drawCircle(const Offset(80, 25), 4, purplePaint2);
    canvas.drawCircle(const Offset(95, 20), 4, purplePaint3);

    // Second row
    canvas.drawCircle(const Offset(25, 35), 4, purplePaint3);
    canvas.drawCircle(const Offset(40, 40), 4, purplePaint1);
    canvas.drawCircle(const Offset(55, 45), 4, purplePaint2);
    canvas.drawCircle(const Offset(70, 45), 4, purplePaint3);
    canvas.drawCircle(const Offset(85, 40), 4, purplePaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}