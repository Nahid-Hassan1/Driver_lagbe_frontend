import 'package:flutter/material.dart';

import 'notification_switch.dart';

class DriverArrivalUpdatesNotification extends StatelessWidget {
  const DriverArrivalUpdatesNotification({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationSwitch(
      title: 'Driver arrival updates',
      subtitle: 'Get updates while the driver is on the way to pickup.',
      value: value,
      onChanged: onChanged,
    );
  }
}
