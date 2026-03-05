import 'package:flutter/material.dart';

import 'notification_switch.dart';

class PromoOffersNotification extends StatelessWidget {
  const PromoOffersNotification({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationSwitch(
      title: 'Promo offers',
      subtitle: 'Receive discount offers, coupon codes, and app promotions.',
      value: value,
      onChanged: onChanged,
    );
  }
}
