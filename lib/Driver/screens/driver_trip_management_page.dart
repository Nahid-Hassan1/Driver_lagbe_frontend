import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/driver_passenger_rating.dart';
import '../models/driver_ride_request.dart';
import '../theme/driver_theme.dart';
import 'driver_passenger_rating_page.dart';

class DriverTripManagementPage extends StatefulWidget {
  const DriverTripManagementPage({
    super.key,
    required this.driverName,
    required this.request,
  });

  final String driverName;
  final DriverRideRequest request;

  @override
  State<DriverTripManagementPage> createState() =>
      _DriverTripManagementPageState();
}

class _DriverTripManagementPageState extends State<DriverTripManagementPage> {
  static const LatLng _defaultCenter = LatLng(23.8103, 90.4125);
  static const double _baseFare = 80;
  static const double _perKmFare = 38;
  static const double _perMinuteFare = 2.5;
  bool _tripFinished = false;
  DriverPassengerRating? _passengerRating;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _finishTrip() {
    if (_tripFinished) {
      return;
    }
    setState(() {
      _tripFinished = true;
    });
    _showSnackBar('Trip finished');
  }

  Future<void> _ratePassenger() async {
    if (!_tripFinished) {
      _showSnackBar('Finish trip before rating passenger.');
      return;
    }

    final DriverPassengerRating? rating = await Navigator.of(context)
        .push<DriverPassengerRating>(
          MaterialPageRoute<DriverPassengerRating>(
            builder: (_) => DriverPassengerRatingPage(request: widget.request),
          ),
        );

    if (rating == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _passengerRating = rating;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final DriverRideRequest request = widget.request;
    final double distanceAmount = request.distanceKm * _perKmFare;
    final double timeAmount = request.etaMinutes * _perMinuteFare;
    final double totalFare = _baseFare + distanceAmount + timeAmount;

    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Trip Management')),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  _SquareSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 14,
                            color: DriverThemePalette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.dropoff,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _SquareSection(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: 12.8,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.driver_lagbe',
                            ),
                            const MarkerLayer(
                              markers: [
                                Marker(
                                  point: _defaultCenter,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 36,
                                    color: DriverThemePalette.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SquareSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Passenger',
                          style: TextStyle(
                            fontSize: 14,
                            color: DriverThemePalette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          request.passengerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _tripFinished ? null : _finishTrip,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _tripFinished ? 'Trip Finished' : 'Finish Trip',
                          ),
                        ),
                        if (_tripFinished) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          const Text(
                            'Fare Calculation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FareRow(label: 'Base Fare', value: _baseFare),
                          _FareRow(
                            label:
                                'Distance (${request.distanceKm.toStringAsFixed(1)} km)',
                            value: distanceAmount,
                          ),
                          _FareRow(
                            label: 'Time (${request.etaMinutes} min)',
                            value: timeAmount,
                          ),
                          const SizedBox(height: 6),
                          const Divider(height: 1),
                          const SizedBox(height: 6),
                          _FareRow(
                            label: 'Total Fare',
                            value: totalFare,
                            isTotal: true,
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _ratePassenger,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _passengerRating == null
                                  ? 'Rate Passenger'
                                  : 'Update Passenger Rating (${_passengerRating!.rating}/5)',
                            ),
                          ),
                          if (_passengerRating != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: DriverThemePalette.surfaceSoft,
                                border: Border.all(
                                  color: DriverThemePalette.border,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Passenger Rating Submitted: ${_passengerRating!.rating}/5',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_passengerRating!.comment.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _passengerRating!.comment,
                                      style: const TextStyle(
                                        color: DriverThemePalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
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

class _SquareSection extends StatelessWidget {
  const _SquareSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DriverThemePalette.surface,
        border: Border.all(color: DriverThemePalette.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
      fontSize: isTotal ? 16 : 14,
      color: isTotal
          ? DriverThemePalette.accent
          : DriverThemePalette.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('BDT ${value.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}
