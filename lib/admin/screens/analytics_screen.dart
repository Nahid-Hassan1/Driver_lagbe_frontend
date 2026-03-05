import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: const [
        _AnalyticsMetricCard(
          title: 'Active Users',
          value: '1,284',
          subtitle: 'Users who used the app in the last 24 hours',
          icon: Icons.people_outline,
          color: Color(0xFF1558B0),
        ),
        SizedBox(height: 10),
        _AnalyticsMetricCard(
          title: 'Popular Routes',
          value: 'Dhanmondi 27 to Gulshan 2',
          subtitle: 'Most requested route this week',
          icon: Icons.route_outlined,
          color: Color(0xFF1E8E3E),
        ),
        SizedBox(height: 10),
        _AnalyticsMetricCard(
          title: 'Peak Times',
          value: '8:00-10:00 AM',
          subtitle: 'Highest booking volume period',
          icon: Icons.access_time_outlined,
          color: Color(0xFFC17A00),
        ),
      ],
    );
  }
}

class _AnalyticsMetricCard extends StatelessWidget {
  const _AnalyticsMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF61666A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
