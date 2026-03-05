import 'package:flutter/material.dart';

import 'notification_switch.dart';

class TripStartEndAlertsNotification extends StatelessWidget {
  const TripStartEndAlertsNotification({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationSwitch(
      title: 'Trip start/end alerts',
      subtitle: 'Be notified when your trip starts and when it ends.',
      value: value,
      onChanged: onChanged,
    );
  }
}
