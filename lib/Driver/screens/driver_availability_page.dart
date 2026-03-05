import 'package:flutter/material.dart';

import '../models/driver_notification_item.dart';
import '../models/driver_ride_request.dart';
import '../theme/driver_theme.dart';
import '../widgets/ride_requests_section.dart';
import 'driver_earnings_dashboard_page.dart';
import 'driver_notifications_page.dart';
import 'driver_trip_management_page.dart';

class DriverAvailabilityPage extends StatefulWidget {
  const DriverAvailabilityPage({super.key, required this.driverName});

  final String driverName;

  @override
  State<DriverAvailabilityPage> createState() => _DriverAvailabilityPageState();
}

class _DriverAvailabilityPageState extends State<DriverAvailabilityPage> {
  bool _isOnline = false;

  final List<DriverNotificationItem> _notifications = <DriverNotificationItem>[
    DriverNotificationItem(
      id: 'N-001',
      title: 'New booking alert',
      message: 'You have 2 pending booking requests.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      type: DriverNotificationType.newBookingAlert,
    ),
    DriverNotificationItem(
      id: 'N-002',
      title: 'Payment received',
      message: 'BDT 520 has been added to your wallet from trip RR-122.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      type: DriverNotificationType.paymentReceived,
    ),
    DriverNotificationItem(
      id: 'N-003',
      title: 'Account update',
      message: 'Your driver profile is 90% complete.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: DriverNotificationType.accountUpdate,
    ),
  ];

  final List<DriverRideRequest> _pendingRequests = <DriverRideRequest>[
    const DriverRideRequest(
      id: 'RR-001',
      passengerName: 'S.M.Nahid',
      pickup: 'Sector 11, Uttara',
      dropoff: 'Bashundhara Residential Area, Dhaka',
      fare: 'BDT 450',
      distanceKm: 9.4,
      etaMinutes: 24,
      paymentMethod: 'Cash',
    ),
    const DriverRideRequest(
      id: 'RR-002',
      passengerName: 'No one',
      pickup: 'Bashundhara R/A, Dhaka',
      dropoff: 'Motijheel, Dhaka',
      fare: 'BDT 520',
      distanceKm: 11.2,
      etaMinutes: 30,
      paymentMethod: 'Wallet',
    ),
  ];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addNotification({
    required DriverNotificationType type,
    required String title,
    required String message,
  }) {
    setState(() {
      _notifications.insert(
        0,
        DriverNotificationItem(
          id: 'N-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          message: message,
          createdAt: DateTime.now(),
          type: type,
        ),
      );
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DriverNotificationsPage(
          driverName: widget.driverName,
          initialNotifications: _notifications,
        ),
      ),
    );
  }

  void _showTripDetails(DriverRideRequest request) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DriverThemePalette.surface,
      showDragHandle: true,
      builder: (context) {
        return Theme(
          data: DriverThemePalette.themed(this.context),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip ${request.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DriverThemePalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Passenger: ${request.passengerName}',
                    style: const TextStyle(color: DriverThemePalette.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pickup: ${request.pickup}',
                    style: const TextStyle(color: DriverThemePalette.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dropoff: ${request.dropoff}',
                    style: const TextStyle(color: DriverThemePalette.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distance: ${request.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(color: DriverThemePalette.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ETA: ${request.etaMinutes} minutes',
                    style: const TextStyle(color: DriverThemePalette.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fare: ${request.fare}',
                    style: const TextStyle(
                      color: DriverThemePalette.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payment: ${request.paymentMethod}',
                    style: const TextStyle(color: DriverThemePalette.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _acceptRequest(DriverRideRequest request) {
    setState(() {
      _pendingRequests.removeWhere((item) => item.id == request.id);
    });
    _addNotification(
      type: DriverNotificationType.accountUpdate,
      title: 'Trip accepted',
      message: 'You accepted ${request.id} for ${request.passengerName}.',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DriverTripManagementPage(
          driverName: widget.driverName,
          request: request,
        ),
      ),
    );
  }

  void _rejectRequest(DriverRideRequest request) {
    setState(() {
      _pendingRequests.removeWhere((item) => item.id == request.id);
    });
    _addNotification(
      type: DriverNotificationType.accountUpdate,
      title: 'Trip rejected',
      message: 'You rejected ${request.id}. Waiting for next request.',
    );
    _showSnackBar('Rejected booking from ${request.passengerName}');
  }

  @override
  Widget build(BuildContext context) {
    final String statusText = _isOnline ? 'Online' : 'Offline';
    final Color statusColor =
        _isOnline ? DriverThemePalette.accent : DriverThemePalette.textMuted;

    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Availability'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              tooltip: 'Earnings Dashboard',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        DriverEarningsDashboardPage(driverName: widget.driverName),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ],
        ),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good evening, ${widget.driverName}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready for your next ride?',
                    style: TextStyle(
                      color: DriverThemePalette.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                          const Spacer(),
                          Switch.adaptive(
                            value: _isOnline,
                            onChanged: (value) {
                              setState(() {
                                _isOnline = value;
                              });
                              if (value && _pendingRequests.isNotEmpty) {
                                _addNotification(
                                  type: DriverNotificationType.newBookingAlert,
                                  title: 'New booking alert',
                                  message:
                                      '${_pendingRequests.length} booking request(s) are waiting for your response.',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isOnline ? 'Go Offline' : 'Go Online',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: DriverThemePalette.textMuted,
                    ),
                  ),
                  if (_isOnline) ...[
                    const SizedBox(height: 20),
                    RideRequestsSection(
                      requests: _pendingRequests,
                      onAcceptRequest: _acceptRequest,
                      onRejectRequest: _rejectRequest,
                      onViewRequestDetails: _showTripDetails,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
