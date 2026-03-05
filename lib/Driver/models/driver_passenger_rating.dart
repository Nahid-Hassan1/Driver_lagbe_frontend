class DriverPassengerRating {
  const DriverPassengerRating({
    required this.tripId,
    required this.passengerName,
    required this.rating,
    required this.comment,
  });

  final String tripId;
  final String passengerName;
  final int rating;
  final String comment;
}
