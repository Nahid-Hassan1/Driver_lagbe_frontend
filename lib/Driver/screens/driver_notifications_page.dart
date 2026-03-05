import 'package:flutter/material.dart';

import '../models/driver_notification_item.dart';
import '../theme/driver_theme.dart';
import '../widgets/driver_notification_tile.dart';

class DriverNotificationsPage extends StatefulWidget {
  const DriverNotificationsPage({
    super.key,
    required this.driverName,
    required this.initialNotifications,
  });

  final String driverName;
  final List<DriverNotificationItem> initialNotifications;

  @override
  State<DriverNotificationsPage> createState() => _DriverNotificationsPageState();
}

class _DriverNotificationsPageState extends State<DriverNotificationsPage> {
  late List<DriverNotificationItem> _notifications;
  DriverNotificationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _notifications = List<DriverNotificationItem>.from(
      widget.initialNotifications,
    );
  }

  List<DriverNotificationItem> get _visibleNotifications {
    if (_selectedFilter == null) {
      return _notifications;
    }
    return _notifications.where((item) => item.type == _selectedFilter).toList();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.isRead ? item : item.copyWith(isRead: true))
          .toList();
    });
  }

  void _markAsRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
          .toList();
    });
  }

  int get _unreadCount => _notifications.where((item) => !item.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Notifications'),
          actions: [
            TextButton(
              onPressed: _unreadCount == 0 ? null : _markAllAsRead,
              child: const Text('Mark all read'),
            ),
          ],
        ),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${widget.driverName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'New booking alerts, payment received, and account updates.',
                    style: TextStyle(
                      color: DriverThemePalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('New Booking'),
                        selected:
                            _selectedFilter ==
                            DriverNotificationType.newBookingAlert,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter =
                                DriverNotificationType.newBookingAlert;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Payment'),
                        selected:
                            _selectedFilter ==
                            DriverNotificationType.paymentReceived,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter =
                                DriverNotificationType.paymentReceived;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Account'),
                        selected:
                            _selectedFilter == DriverNotificationType.accountUpdate,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = DriverNotificationType.accountUpdate;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _visibleNotifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No notifications for this category.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: DriverThemePalette.textMuted,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _visibleNotifications.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final DriverNotificationItem item =
                                  _visibleNotifications[index];
                              return DriverNotificationTile(
                                notification: item,
                                onMarkAsRead: () => _markAsRead(item.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
