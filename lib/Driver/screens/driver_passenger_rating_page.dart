import 'package:flutter/material.dart';

import '../models/driver_passenger_rating.dart';
import '../models/driver_ride_request.dart';
import '../theme/driver_theme.dart';
import '../widgets/star_rating_input.dart';

class DriverPassengerRatingPage extends StatefulWidget {
  const DriverPassengerRatingPage({
    super.key,
    required this.request,
  });

  final DriverRideRequest request;

  @override
  State<DriverPassengerRatingPage> createState() =>
      _DriverPassengerRatingPageState();
}

class _DriverPassengerRatingPageState extends State<DriverPassengerRatingPage> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please select a rating before submit.')),
        );
      return;
    }

    final DriverPassengerRating rating = DriverPassengerRating(
      tripId: widget.request.id,
      passengerName: widget.request.passengerName,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
    );

    Navigator.of(context).pop(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Rate Passenger')),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip ${widget.request.id}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.request.passengerName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Pickup: ${widget.request.pickup}'),
                          const SizedBox(height: 4),
                          Text('Dropoff: ${widget.request.dropoff}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How was this passenger?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StarRatingInput(
                    rating: _selectedRating,
                    onRatingChanged: (value) {
                      setState(() {
                        _selectedRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      hintText: 'Share your experience with this passenger',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _submitRating,
                    child: const Text('Submit Rating'),
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
