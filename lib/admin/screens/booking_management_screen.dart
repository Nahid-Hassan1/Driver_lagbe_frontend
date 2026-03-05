import 'package:flutter/material.dart';

import '../models/admin_booking.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final List<String> _driverPool = <String>[
    'Mehedi Hasan',
    'Sabbir Rahman',
    'Tariq Hossain',
    'Farhan Karim',
  ];

  final List<AdminBooking> _bookings = <AdminBooking>[
    AdminBooking(
      id: 'BK-9011',
      customerName: 'Shakib Islam',
      pickup: 'Dhanmondi 27',
      dropoff: 'Gulshan 2',
      requestedAt: DateTime(2026, 3, 2, 9, 10),
      status: BookingStatus.pending,
    ),
    AdminBooking(
      id: 'BK-9012',
      customerName: 'Rabiul Alam',
      pickup: 'Mirpur 10',
      dropoff: 'Airport Terminal',
      requestedAt: DateTime(2026, 3, 2, 10, 5),
      assignedDriver: 'Sabbir Rahman',
      status: BookingStatus.assigned,
    ),
    AdminBooking(
      id: 'BK-9013',
      customerName: 'Nayeem Sultan',
      pickup: 'Uttara Sector 7',
      dropoff: 'Bashundhara R/A',
      requestedAt: DateTime(2026, 3, 1, 18, 45),
      assignedDriver: 'Farhan Karim',
      status: BookingStatus.disputed,
      fare: 780,
    ),
    AdminBooking(
      id: 'BK-9014',
      customerName: 'Ishrak Ahmed',
      pickup: 'Mohakhali',
      dropoff: 'Banani',
      requestedAt: DateTime(2026, 2, 28, 22, 30),
      assignedDriver: 'Tariq Hossain',
      status: BookingStatus.completed,
      fare: 280,
    ),
  ];

  String _formatDateTime(DateTime dateTime) {
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}-$month-$day $hour:$minute';
  }

  void _assignDriver(String bookingId, String driverName) {
    setState(() {
      final int index = _bookings.indexWhere(
        (AdminBooking booking) => booking.id == bookingId,
      );
      if (index < 0) {
        return;
      }
      _bookings[index] = _bookings[index].copyWith(
        assignedDriver: driverName,
        status: BookingStatus.assigned,
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Driver assigned to $bookingId')));
  }

  void _markAsRefunded(String bookingId) {
    setState(() {
      final int index = _bookings.indexWhere(
        (AdminBooking booking) => booking.id == bookingId,
      );
      if (index < 0) {
        return;
      }
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.refunded,
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Refund processed for $bookingId')));
  }

  void _resolveDispute(String bookingId) {
    setState(() {
      final int index = _bookings.indexWhere(
        (AdminBooking booking) => booking.id == bookingId,
      );
      if (index < 0) {
        return;
      }
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.completed,
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Dispute resolved for $bookingId')));
  }

  Future<void> _openAssignDriverDialog(AdminBooking booking) async {
    String? selected = booking.assignedDriver;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Driver • ${booking.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selected,
                      hint: const Text('Choose a driver'),
                      items: _driverPool
                          .map(
                            (String driver) => DropdownMenuItem<String>(
                              value: driver,
                              child: Text(driver),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setModalState(() {
                          selected = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selected == null
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                _assignDriver(booking.id, selected!);
                              },
                        child: const Text('Confirm Assignment'),
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final AdminBooking booking = _bookings[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE3E6EA)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: booking.statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        booking.statusLabel,
                        style: TextStyle(
                          color: booking.statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.customerName,
                  style: const TextStyle(
                    color: Color(0xFF40464D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('From: ${booking.pickup}'),
                Text('To: ${booking.dropoff}'),
                const SizedBox(height: 4),
                Text(
                  'Requested: ${_formatDateTime(booking.requestedAt)}',
                  style: const TextStyle(color: Color(0xFF61666A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Assigned driver: ${booking.assignedDriver ?? 'Not assigned'}',
                  style: const TextStyle(color: Color(0xFF61666A)),
                ),
                if (booking.fare != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fare: BDT ${booking.fare!.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFF61666A)),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openAssignDriverDialog(booking),
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 18,
                      ),
                      label: const Text('Assign Driver'),
                    ),
                    if (booking.status == BookingStatus.disputed)
                      FilledButton.tonalIcon(
                        onPressed: () => _resolveDispute(booking.id),
                        icon: const Icon(Icons.gavel_outlined, size: 18),
                        label: const Text('Resolve Dispute'),
                      ),
                    if (booking.status == BookingStatus.disputed ||
                        booking.status == BookingStatus.completed)
                      OutlinedButton.icon(
                        onPressed: booking.status == BookingStatus.refunded
                            ? null
                            : () => _markAsRefunded(booking.id),
                        icon: const Icon(
                          Icons.replay_circle_filled_outlined,
                          size: 18,
                        ),
                        label: const Text('Refund'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
