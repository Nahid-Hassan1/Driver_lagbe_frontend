import 'package:flutter/material.dart';

import 'booking_models.dart';
import '../rider_palette.dart';

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
    backgroundColor: riderBlack,
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
                      color: riderTextPrimary,
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
                      color: riderTextSecondary,
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
                          color: riderAccent,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(color: riderTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add comments (optional)',
                      hintStyle: const TextStyle(color: riderTextMuted),
                      filled: true,
                      fillColor: riderSurfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: riderBorderStrong),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: riderBorderStrong),
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
                        backgroundColor: riderAccent,
                        foregroundColor: riderAccentText,
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
