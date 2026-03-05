import 'package:flutter/material.dart';

import 'booking_models.dart';

Future<void> showTripCompletionSheet({
  required BuildContext context,
  required BookingRequest booking,
}) {
  final FareBreakdown fare = booking.fareBreakdown;
  final DateTime completedAt = booking.completedAt ?? DateTime.now();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0F1A1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed at ${formatBookingDateTime(completedAt)}',
                  style: const TextStyle(
                    color: Color(0xFFB7CAD3),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${booking.pickupLocation} -> ${booking.dropOffLocation}',
                  style: const TextStyle(
                    color: Color(0xFFD7EDF5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13242B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A434E)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Final invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InvoiceRow(label: 'Base fare', amount: fare.baseFare),
                      _InvoiceRow(label: 'Distance fare', amount: fare.distanceFare),
                      _InvoiceRow(label: 'Service fee', amount: fare.serviceFee),
                      _InvoiceRow(
                        label: 'Search surcharge',
                        amount: fare.driverSearchSurcharge,
                      ),
                      _InvoiceRow(label: 'Scheduling fee', amount: fare.schedulingFee),
                      _InvoiceRow(label: 'Discount', amount: -fare.discount, negative: true),
                      const Divider(color: Color(0xFF2A434E)),
                      _InvoiceRow(
                        label: 'Total paid',
                        amount: fare.totalBdt,
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2AE0A0),
                      foregroundColor: const Color(0xFF0A1814),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.amount,
    this.negative = false,
    this.emphasize = false,
  });

  final String label;
  final int amount;
  final bool negative;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final Color textColor = emphasize ? Colors.white : const Color(0xFFD4EAF4);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: emphasize ? 16 : 14,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${negative ? '-' : ''}BDT ${amount.abs()}',
            style: TextStyle(
              color: negative ? const Color(0xFF9CF2B8) : textColor,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String formatBookingDateTime(DateTime value) {
  const List<String> monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String meridiem = value.hour >= 12 ? 'PM' : 'AM';
  return '${monthNames[value.month - 1]} ${value.day}, ${value.year} at $hour12:$minute $meridiem';
}
