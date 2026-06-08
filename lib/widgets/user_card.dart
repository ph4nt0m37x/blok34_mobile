import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/app_user.dart';

class UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;
  final bool showActionButton;
  final String actionButtonText;
  final IconData actionButtonIcon;
  final VoidCallback? onActionPressed;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.showActionButton = true,
    this.actionButtonText = "View Profile",
    this.actionButtonIcon = Icons.person_outline,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.07),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyan.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white.withValues(alpha: 0.8),
                      );
                    },
                  )
                      : Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // User Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.username,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Action Button
              if (showActionButton)
                GestureDetector(
                  onTap: onActionPressed,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.purple.shade600.withValues(alpha: 0.2),
                          Colors.cyan.shade400.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.purple.shade400.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          actionButtonIcon,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          actionButtonText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}