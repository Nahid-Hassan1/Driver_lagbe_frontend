import 'package:flutter/material.dart';

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
        color: value ? const Color(0xFF173239) : const Color(0xFF13242B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? const Color(0xFF2C6B72) : const Color(0xFF26424D),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        activeThumbColor: const Color(0xFF2AE0A0),
        activeTrackColor: const Color(0xFF2A7A66),
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFB7CAD3),
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
