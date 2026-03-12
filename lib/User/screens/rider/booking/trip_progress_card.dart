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
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
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
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            booking.assignedDriver == null
                ? 'Driver assigned'
                : 'Driver ${booking.assignedDriver} is on your trip',
            style: const TextStyle(
              color: Color(0xFFB8B8B8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            value: null,
            minHeight: 6,
            backgroundColor: Color(0xFF2A2A2A),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCompleteTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Complete Trip'),
            ),
          ),
        ],
      ),
    );
  }
}
