import 'package:flutter/material.dart';

import '../models/driver_earnings_overview.dart';
import '../theme/driver_theme.dart';
import '../widgets/earnings_metric_card.dart';

class DriverEarningsDashboardPage extends StatelessWidget {
  const DriverEarningsDashboardPage({
    super.key,
    required this.driverName,
    this.latestTripFare,
  });

  final String driverName;
  final double? latestTripFare;

  DriverEarningsOverview _buildOverview() {
    const double baseDailyEarnings = 1850;
    const double baseWeeklyEarnings = 12400;
    const int baseDailyTripCount = 7;
    const int baseWeeklyTripCount = 42;

    final double extraFare = latestTripFare ?? 0;
    final bool hasExtraTrip = extraFare > 0;

    final int dailyTripCount = baseDailyTripCount + (hasExtraTrip ? 1 : 0);
    final int weeklyTripCount = baseWeeklyTripCount + (hasExtraTrip ? 1 : 0);

    final double dailyBonus = dailyTripCount >= 8 ? 250 : 100;
    final double weeklyBonus = weeklyTripCount >= 45 ? 1200 : 800;

    return DriverEarningsOverview(
      dailyEarnings: baseDailyEarnings + extraFare + dailyBonus,
      weeklyEarnings: baseWeeklyEarnings + extraFare + weeklyBonus,
      dailyTripCount: dailyTripCount,
      weeklyTripCount: weeklyTripCount,
      dailyBonus: dailyBonus,
      weeklyBonus: weeklyBonus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DriverEarningsOverview overview = _buildOverview();

    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Earnings Dashboard')),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings for $driverName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track daily and weekly performance including bonuses.',
                    style: TextStyle(
                      color: DriverThemePalette.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: EarningsMetricCard(
                          title: 'Daily Earnings',
                          value: 'BDT ${overview.dailyEarnings.toStringAsFixed(0)}',
                          subtitle: 'Includes today bonuses',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EarningsMetricCard(
                          title: 'Weekly Earnings',
                          value: 'BDT ${overview.weeklyEarnings.toStringAsFixed(0)}',
                          subtitle: 'Includes weekly bonuses',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: EarningsMetricCard(
                          title: 'Daily Trip Count',
                          value: '${overview.dailyTripCount}',
                          subtitle: 'Trips completed today',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EarningsMetricCard(
                          title: 'Weekly Trip Count',
                          value: '${overview.weeklyTripCount}',
                          subtitle: 'Trips completed this week',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bonuses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _BonusRow(
                            label: 'Daily Bonus',
                            value: overview.dailyBonus,
                            description: 'Unlocked based on daily trip count',
                          ),
                          const SizedBox(height: 10),
                          _BonusRow(
                            label: 'Weekly Bonus',
                            value: overview.weeklyBonus,
                            description: 'Unlocked based on weekly trip count',
                          ),
                          if (latestTripFare != null) ...[
                            const SizedBox(height: 10),
                            _BonusRow(
                              label: 'Latest Trip Fare',
                              value: latestTripFare!,
                              description: 'Added from recently completed trip',
                            ),
                          ],
                        ],
                      ),
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

class _BonusRow extends StatelessWidget {
  const _BonusRow({
    required this.label,
    required this.value,
    required this.description,
  });

  final String label;
  final double value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.workspace_premium_outlined,
            size: 18,
            color: DriverThemePalette.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: DriverThemePalette.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'BDT ${value.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: DriverThemePalette.accent,
          ),
        ),
      ],
    );
  }
}
