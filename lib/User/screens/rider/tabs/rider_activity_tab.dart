import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../booking/booking_models.dart';
import '../booking/booking_store.dart';
import '../booking/payment_sheets.dart';
import '../booking/rating_feedback_sheet.dart';
import '../booking/trip_completion_sheet.dart';
import '../rider_palette.dart';

class RiderActivityTab extends StatefulWidget {
  const RiderActivityTab({super.key});

  @override
  State<RiderActivityTab> createState() => _RiderActivityTabState();
}

class _RiderActivityTabState extends State<RiderActivityTab> {
  String _selectedSegment = 'Completed';
  final BookingStore _bookingStore = BookingStore.instance;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [riderBlack, riderBackground, riderBlack],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _bookingStore,
          builder: (context, _) {
            final List<BookingRequest> segmentBookings = _bookingsForSegment()
              ..sort((a, b) =>
                  (b.completedAt ?? b.bookedFor).compareTo(a.completedAt ?? a.bookedFor));
            final int completedCount =
                _bookingStore.byStatus(BookingStatus.completed).length;
            final int upcomingCount = _bookingStore
                .bookings
                .where((booking) =>
                    booking.status == BookingStatus.requested ||
                    booking.status == BookingStatus.ongoing)
                .length;
            final int cancelledCount =
                _bookingStore.byStatus(BookingStatus.cancelled).length;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: riderAccentSoft, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Ride History',
                      style: TextStyle(
                        color: riderTextPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Past rides, invoices, and driver feedback in one place.',
                  style: TextStyle(
                    color: riderTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                _StatsRow(
                  completedCount: completedCount,
                  upcomingCount: upcomingCount,
                  cancelledCount: cancelledCount,
                  onCardTap: (title) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title details opened')),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _SegmentSwitch(
                  selectedSegment: _selectedSegment,
                  onTap: (segment) => setState(() => _selectedSegment = segment),
                ),
                const SizedBox(height: 16),
                if (segmentBookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riderSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: riderBorder),
                    ),
                    child: Text(
                      'No $_selectedSegment trips yet.',
                      style: const TextStyle(color: riderTextSecondary),
                    ),
                  )
                else
                  ...segmentBookings.map((booking) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TimelineCard(
                        title:
                            '${booking.pickupLocation} to ${booking.dropOffLocation}',
                        subtitle: formatBookingDateTime(
                          booking.completedAt ?? booking.bookedFor,
                        ),
                        amount: 'BDT ${booking.fareBreakdown.totalBdt}',
                        status: booking.status.label,
                        rating: booking.riderRating,
                        comment: booking.riderComment,
                        onTap: () => _showBookingDetails(booking),
                        onRateTap: booking.status == BookingStatus.completed
                            ? () => _rateBooking(booking)
                            : null,
                        onDownloadInvoiceTap:
                            booking.status == BookingStatus.completed
                                ? () => _downloadInvoice(booking)
                                : null,
                      ),
                    );
                  }),
                if (_selectedSegment == 'Completed') ...[
                  const SizedBox(height: 12),
                  _RebookCard(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rebook flow opened')),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<BookingRequest> _bookingsForSegment() {
    switch (_selectedSegment) {
      case 'Upcoming':
        return _bookingStore
            .bookings
            .where((booking) =>
                booking.status == BookingStatus.requested ||
                booking.status == BookingStatus.ongoing)
            .toList();
      case 'Cancelled':
        return _bookingStore.byStatus(BookingStatus.cancelled);
      default:
        return _bookingStore.byStatus(BookingStatus.completed);
    }
  }

  Future<void> _rateBooking(BookingRequest booking) async {
    final RatingFeedbackResult? feedback = await showRatingFeedbackSheet(
      context: context,
      booking: booking,
    );
    if (!mounted || feedback == null) {
      return;
    }

    _bookingStore.submitRating(
      bookingId: booking.id,
      rating: feedback.rating,
      comment: feedback.comment,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted')),
    );
  }

  Future<void> _downloadInvoice(BookingRequest booking) async {
    await Clipboard.setData(
      ClipboardData(text: _buildInvoiceText(booking)),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice INV-${booking.id} copied. Paste to save/share.',
        ),
      ),
    );
  }

  String _buildInvoiceText(BookingRequest booking) {
    final FareBreakdown fare = booking.fareBreakdown;
    return '''
Lagbe Ride Invoice
Invoice: INV-${booking.id}
Date: ${formatBookingDateTime(booking.completedAt ?? booking.bookedFor)}
From: ${booking.pickupLocation}
To: ${booking.dropOffLocation}
Service: ${booking.serviceType}
Driver search: ${booking.driverSearchMode}
Payment: ${booking.paymentMethod.label}

Base fare: BDT ${fare.baseFare}
Distance fare: BDT ${fare.distanceFare}
Service fee: BDT ${fare.serviceFee}
Search surcharge: BDT ${fare.driverSearchSurcharge}
Scheduling fee: BDT ${fare.schedulingFee}
Discount: -BDT ${fare.discount}
Total paid: BDT ${fare.totalBdt}
'''.trim();
  }

  void _showBookingDetails(BookingRequest booking) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: riderBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final ButtonStyle sheetActionStyle = OutlinedButton.styleFrom(
          foregroundColor: riderTextPrimary,
          backgroundColor: riderSurfaceAlt,
          side: const BorderSide(color: riderBorderStrong),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          iconColor: riderTextPrimary,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking #${booking.id}',
                style: const TextStyle(
                  color: riderTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.pickupLocation} -> ${booking.dropOffLocation}',
                style: TextStyle(
                  color: riderTextSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Status: ${booking.status.label}',
                style: const TextStyle(
                  color: riderTextSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Time: ${formatBookingDateTime(booking.completedAt ?? booking.bookedFor)}',
                style: const TextStyle(
                  color: riderTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showBookingInvoiceSheet(
                        context: context,
                        booking: booking,
                      ),
                      style: sheetActionStyle,
                      child: const Text('View invoice'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadInvoice(booking),
                      style: sheetActionStyle,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),
              if (booking.status == BookingStatus.completed) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _rateBooking(booking),
                    style: sheetActionStyle,
                    child: Text(
                      booking.riderRating == null ? 'Rate driver' : 'Update rating',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: riderAccent,
                    foregroundColor: riderAccentText,
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.completedCount,
    required this.upcomingCount,
    required this.cancelledCount,
    required this.onCardTap,
  });

  final int completedCount;
  final int upcomingCount;
  final int cancelledCount;
  final ValueChanged<String> onCardTap;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> items = <(String, String)>[
      ('$completedCount', 'Completed'),
      ('$upcomingCount', 'Upcoming'),
      ('$cancelledCount', 'Cancelled'),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: riderSurface,
              borderRadius: BorderRadius.circular(14),
              shadowColor: riderShadow,
              elevation: 1.5,
              child: InkWell(
                onTap: () => onCardTap(item.$2),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: riderTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: riderTextSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SegmentSwitch extends StatelessWidget {
  const _SegmentSwitch({
    required this.selectedSegment,
    required this.onTap,
  });

  final String selectedSegment;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const segments = ['Completed', 'Upcoming', 'Cancelled'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: riderSurfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: riderBorder),
        boxShadow: const [
          BoxShadow(
            color: riderShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: segments.map((segment) {
          final selected = selectedSegment == segment;
          return Expanded(
            child: Material(
              color: selected ? riderAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onTap(segment),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    segment,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? riderAccentText : riderTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.rating,
    required this.comment,
    required this.onTap,
    this.onRateTap,
    this.onDownloadInvoiceTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final int? rating;
  final String? comment;
  final VoidCallback onTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onDownloadInvoiceTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riderSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: riderBorder),
              boxShadow: const [
                BoxShadow(
                  color: riderShadow,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: riderSurfaceRaised,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.route_rounded, color: riderAccentSoft),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: riderTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: riderTextSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amount,
                        style: const TextStyle(
                          color: riderTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: riderStatusColor(status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: riderAccentText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (rating != null || (comment != null && comment!.isNotEmpty)) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    rating == null
                        ? 'Comment: ${comment ?? ''}'
                        : 'Your rating: ${'⭐' * rating!}${comment == null || comment!.isEmpty ? '' : '  |  ${comment!}'}',
                    style: const TextStyle(
                      color: riderAccentSoft,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (status == BookingStatus.completed.label && onRateTap != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onRateTap,
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('Rate driver'),
                  ),
                ),
              ],
              if (status == BookingStatus.completed.label &&
                  onDownloadInvoiceTap != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onDownloadInvoiceTap,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download invoice'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

class _RebookCard extends StatelessWidget {
  const _RebookCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: riderAccent,
          ),
          child: const Row(
            children: [
              Icon(Icons.replay_rounded, color: riderAccentText),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rebook your most frequent route',
                  style: TextStyle(
                    color: riderAccentText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Color(0x99000000), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
