import 'package:flutter/material.dart';

import 'notification_switch.dart';

class BookingConfirmationNotification extends StatelessWidget {
  const BookingConfirmationNotification({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationSwitch(
      title: 'Booking confirmation',
      subtitle: 'Receive an alert as soon as your booking is confirmed.',
      value: value,
      onChanged: onChanged,
    );
  }
}
