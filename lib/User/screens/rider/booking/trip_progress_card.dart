import 'package:flutter/material.dart';

import 'booking_models.dart';

class TripInProgressCard extends StatelessWidget {
  const TripInProgressCard({
    super.key,
    required this.booking,
    required this.onCompleteTap,
  });

  final BookingRequest booking;
  final VoidCallback onCompleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13242B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A5C7D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip in progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${booking.pickupLocation} -> ${booking.dropOffLocation}',
            style: const TextStyle(
              color: Color(0xFFD7EDF5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            booking.assignedDriver == null
                ? 'Driver assigned'
                : 'Driver ${booking.assignedDriver} is on your trip',
            style: const TextStyle(
              color: Color(0xFFAAC0CB),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            value: null,
            minHeight: 6,
            backgroundColor: Color(0xFF203945),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2AE0A0)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCompleteTap,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2AE0A0),
                foregroundColor: const Color(0xFF0A1814),
              ),
              child: const Text('Complete Trip'),
            ),
          ),
        ],
      ),
    );
  }
}
