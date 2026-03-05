import 'package:flutter/material.dart';

import '../models/driver_ride_request.dart';
import '../theme/driver_theme.dart';
import 'ride_request_card.dart';

class RideRequestsSection extends StatelessWidget {
  const RideRequestsSection({
    super.key,
    required this.requests,
    required this.onAcceptRequest,
    required this.onRejectRequest,
    required this.onViewRequestDetails,
  });

  final List<DriverRideRequest> requests;
  final ValueChanged<DriverRideRequest> onAcceptRequest;
  final ValueChanged<DriverRideRequest> onRejectRequest;
  final ValueChanged<DriverRideRequest> onViewRequestDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ride Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Accept or reject bookings after reviewing trip details.',
          style: TextStyle(
            color: DriverThemePalette.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No pending ride requests right now.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: DriverThemePalette.textMuted,
                ),
              ),
            ),
          ),
        if (requests.isNotEmpty)
          ...requests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RideRequestCard(
                request: request,
                onAccept: () => onAcceptRequest(request),
                onReject: () => onRejectRequest(request),
                onViewDetails: () => onViewRequestDetails(request),
              ),
            ),
          ),
      ],
    );
  }
}
