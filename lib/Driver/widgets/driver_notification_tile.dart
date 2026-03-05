import 'package:flutter/material.dart';

import '../models/driver_notification_item.dart';
import '../theme/driver_theme.dart';

class DriverNotificationTile extends StatelessWidget {
  const DriverNotificationTile({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  final DriverNotificationItem notification;
  final VoidCallback onMarkAsRead;

  IconData get _icon {
    switch (notification.type) {
      case DriverNotificationType.newBookingAlert:
        return Icons.local_taxi_outlined;
      case DriverNotificationType.paymentReceived:
        return Icons.payments_outlined;
      case DriverNotificationType.accountUpdate:
        return Icons.manage_accounts_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case DriverNotificationType.newBookingAlert:
        return const Color(0xFF31B8FF);
      case DriverNotificationType.paymentReceived:
        return DriverThemePalette.accent;
      case DriverNotificationType.accountUpdate:
        return const Color(0xFF9A7BFF);
    }
  }

  String _timeAgo(DateTime timestamp) {
    final Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: notification.isRead
                                ? DriverThemePalette.textMuted
                                : DriverThemePalette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: DriverThemePalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: DriverThemePalette.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onMarkAsRead,
                        child: const Text('Mark as read'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
