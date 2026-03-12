import 'package:flutter/material.dart';

import 'booking_models.dart';
import '../rider_palette.dart';
import 'trip_completion_sheet.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({
    super.key,
    required this.booking,
  });

  final BookingRequest booking;

  @override
  Widget build(BuildContext context) {
    final FareBreakdown fare = booking.fareBreakdown;

    return Scaffold(
      backgroundColor: riderBlack,
      appBar: AppBar(
        backgroundColor: riderBlack,
        foregroundColor: riderTextPrimary,
        title: const Text('Booking Confirmation'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riderSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: riderBorder),
                boxShadow: const [
                  BoxShadow(
                    color: riderShadow,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: riderAccent,
                    size: 56,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ride is confirmed',
                    style: TextStyle(
                      color: riderTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Booking #${booking.id} has been created.',
                    style: const TextStyle(
                      color: riderTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${booking.pickupLocation} -> ${booking.dropOffLocation}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: riderTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatBookingDateTime(booking.bookedFor),
                    style: const TextStyle(
                      color: riderTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riderSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: riderBorder),
                boxShadow: const [
                  BoxShadow(
                    color: riderShadow,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: booking.assignedDriver == null
                  ? const Text(
                      'Driver will be assigned shortly.',
                      style: TextStyle(
                        color: riderTextSecondary,
                        fontSize: 14,
                      ),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: riderSurfaceRaised,
                          child: Text(
                            booking.assignedDriver!.substring(0, 1),
                            style: const TextStyle(
                              color: riderTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.assignedDriver!,
                                style: const TextStyle(
                                  color: riderTextPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${booking.driverVehicle ?? 'Driver'}  |  ${(booking.driverRating ?? 0).toStringAsFixed(1)} rating  |  ${(booking.driverExperienceYears ?? 0)}y exp',
                                style: const TextStyle(
                                  color: riderTextSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(booking.driverDistanceKm ?? 0).toStringAsFixed(1)} km away from you | ETA ${booking.driverEtaMin ?? 0} min',
                                style: const TextStyle(
                                  color: riderAccentSoft,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riderSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: riderBorder),
                boxShadow: const [
                  BoxShadow(
                    color: riderShadow,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice',
                    style: TextStyle(
                      color: riderTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InvoiceRow(label: 'Base fare', amount: fare.baseFare),
                  _InvoiceRow(label: 'Distance fare', amount: fare.distanceFare),
                  _InvoiceRow(label: 'Service fee', amount: fare.serviceFee),
                  _InvoiceRow(label: 'Search surcharge', amount: fare.driverSearchSurcharge),
                  _InvoiceRow(label: 'Scheduling fee', amount: fare.schedulingFee),
                  _InvoiceRow(label: 'Discount', amount: -fare.discount, negative: true),
                  const Divider(color: riderBorder),
                  _InvoiceRow(
                    label: 'Total',
                    amount: fare.totalBdt,
                    emphasize: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(booking.paymentMethod.icon, color: riderAccentSoft),
                      const SizedBox(width: 8),
                      Text(
                        'Payment: ${booking.paymentMethod.label}',
                        style: const TextStyle(
                          color: riderTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  booking.copyWith(
                    status: BookingStatus.ongoing,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: riderAccent,
                foregroundColor: riderAccentText,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Start Trip'),
            ),
          ],
        ),
      ),
    );
  }
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
    final Color textColor = emphasize ? riderTextPrimary : riderTextSecondary;
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
              color: negative ? riderTextMuted : textColor,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
