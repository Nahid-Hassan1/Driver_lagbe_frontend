class DriverRideRequest {
  const DriverRideRequest({
    required this.id,
    required this.passengerName,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distanceKm,
    required this.etaMinutes,
    required this.paymentMethod,
  });

  final String id;
  final String passengerName;
  final String pickup;
  final String dropoff;
  final String fare;
  final double distanceKm;
  final int etaMinutes;
  final String paymentMethod;
}
