import 'package:flutter/material.dart';

import 'booking_models.dart';

class RatingFeedbackResult {
  const RatingFeedbackResult({
    required this.rating,
    required this.comment,
  });

  final int rating;
  final String comment;
}

Future<RatingFeedbackResult?> showRatingFeedbackSheet({
  required BuildContext context,
  required BookingRequest booking,
}) {
  int selectedRating = booking.riderRating ?? 5;
  final TextEditingController commentController = TextEditingController(
    text: booking.riderComment ?? '',
  );

  return showModalBottomSheet<RatingFeedbackResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0F1A1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate your driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.assignedDriver == null
                        ? 'How was your trip experience?'
                        : 'How was your trip with ${booking.assignedDriver}?',
                    style: const TextStyle(
                      color: Color(0xFFB2C2CC),
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List<Widget>.generate(5, (index) {
                      final int star = index + 1;
                      return IconButton(
                        onPressed: () => setModalState(() => selectedRating = star),
                        icon: Icon(
                          star <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFD166),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add comments (optional)',
                      hintStyle: const TextStyle(color: Color(0xFF8EA2AC)),
                      filled: true,
                      fillColor: const Color(0xFF18303A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2D4A55)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2D4A55)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          RatingFeedbackResult(
                            rating: selectedRating,
                            comment: commentController.text,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2AE0A0),
                        foregroundColor: const Color(0xFF0A1814),
                      ),
                      child: const Text('Submit feedback'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
