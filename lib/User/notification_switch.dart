import 'package:flutter/material.dart';

import 'screens/rider/rider_palette.dart';

class NotificationSwitch extends StatelessWidget {
  const NotificationSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: value ? riderSurfaceRaised : riderSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? riderAccent : riderBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: riderShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        activeThumbColor: riderAccent,
        activeTrackColor: riderBorderStrong,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            color: riderTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: riderTextSecondary,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
