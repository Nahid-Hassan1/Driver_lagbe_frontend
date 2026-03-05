import 'package:flutter/material.dart';

import '../models/driver_ride_request.dart';
import '../theme/driver_theme.dart';

class RideRequestCard extends StatelessWidget {
  const RideRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetails,
  });

  final DriverRideRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.passengerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  request.fare,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: DriverThemePalette.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Pickup: ${request.pickup}'),
            const SizedBox(height: 4),
            Text('Dropoff: ${request.dropoff}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: '${request.distanceKm.toStringAsFixed(1)} km'),
                _InfoChip(label: '${request.etaMinutes} min'),
                _InfoChip(label: request.paymentMethod),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DriverThemePalette.textPrimary,
                      side: const BorderSide(color: DriverThemePalette.border),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewDetails,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8FE6FF),
                ),
                child: const Text(
                  'View Trip Details',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DriverThemePalette.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DriverThemePalette.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: DriverThemePalette.textMuted,
        ),
      ),
    );
  }
}
