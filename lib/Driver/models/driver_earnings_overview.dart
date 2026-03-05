class DriverEarningsOverview {
  const DriverEarningsOverview({
    required this.dailyEarnings,
    required this.weeklyEarnings,
    required this.dailyTripCount,
    required this.weeklyTripCount,
    required this.dailyBonus,
    required this.weeklyBonus,
  });

  final double dailyEarnings;
  final double weeklyEarnings;
  final int dailyTripCount;
  final int weeklyTripCount;
  final double dailyBonus;
  final double weeklyBonus;
}
