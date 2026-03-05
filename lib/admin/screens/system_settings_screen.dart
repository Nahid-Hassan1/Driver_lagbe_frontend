import 'package:flutter/material.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  double _baseFare = 60;
  double _perKmRate = 24;
  double _perMinuteRate = 3;

  bool _freeCancellationWithinFiveMinutes = true;
  bool _chargeRiderForLateCancel = true;
  bool _penalizeDriverNoShow = true;

  final List<_AdminRole> _roles = const <_AdminRole>[
    _AdminRole(
      name: 'Super Admin',
      permissions: 'All modules, user controls, and payout approval',
      color: Color(0xFF1558B0),
    ),
    _AdminRole(
      name: 'Operations Manager',
      permissions: 'Booking workflow, dispute handling, driver assignment',
      color: Color(0xFF1E8E3E),
    ),
    _AdminRole(
      name: 'Support Agent',
      permissions: 'User support, refunds, and ticket updates',
      color: Color(0xFFC17A00),
    ),
  ];

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        _SectionCard(
          icon: Icons.tune_outlined,
          iconColor: const Color(0xFF1558B0),
          title: 'Fare Rates',
          subtitle: 'Configure default ride pricing values.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RateControl(
                label: 'Base Fare (BDT)',
                value: _baseFare,
                min: 30,
                max: 120,
                onChanged: (double value) {
                  setState(() {
                    _baseFare = value;
                  });
                },
              ),
              _RateControl(
                label: 'Per Km Rate (BDT)',
                value: _perKmRate,
                min: 10,
                max: 40,
                onChanged: (double value) {
                  setState(() {
                    _perKmRate = value;
                  });
                },
              ),
              _RateControl(
                label: 'Per Minute Rate (BDT)',
                value: _perMinuteRate,
                min: 1,
                max: 8,
                onChanged: (double value) {
                  setState(() {
                    _perMinuteRate = value;
                  });
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showMessage('Fare rates updated'),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Fare Rates'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.policy_outlined,
          iconColor: const Color(0xFF1E8E3E),
          title: 'Cancellation Policies',
          subtitle: 'Manage rider and driver cancellation rules.',
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Free cancellation within first 5 minutes'),
                value: _freeCancellationWithinFiveMinutes,
                onChanged: (bool value) {
                  setState(() {
                    _freeCancellationWithinFiveMinutes = value;
                  });
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Charge rider fee for late cancellation'),
                value: _chargeRiderForLateCancel,
                onChanged: (bool value) {
                  setState(() {
                    _chargeRiderForLateCancel = value;
                  });
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Apply penalty for driver no-show'),
                value: _penalizeDriverNoShow,
                onChanged: (bool value) {
                  setState(() {
                    _penalizeDriverNoShow = value;
                  });
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showMessage('Cancellation policies updated'),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Policies'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          icon: Icons.admin_panel_settings_outlined,
          iconColor: const Color(0xFFC17A00),
          title: 'Admin Roles & Permissions',
          subtitle: 'Control access levels for internal admin users.',
          child: Column(
            children: [
              ..._roles.map((role) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE3E6EA)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: role.color.withAlpha(28),
                      child: Icon(Icons.security_outlined, size: 16, color: role.color),
                    ),
                    title: Text(
                      role.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(role.permissions),
                    trailing: OutlinedButton(
                      onPressed: () =>
                          _showMessage('Permissions updated for ${role.name}'),
                      child: const Text('Manage'),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE3E6EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF61666A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _RateControl extends StatelessWidget {
  const _RateControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AdminRole {
  const _AdminRole({
    required this.name,
    required this.permissions,
    required this.color,
  });

  final String name;
  final String permissions;
  final Color color;
}
