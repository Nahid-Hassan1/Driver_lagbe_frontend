import 'package:flutter/material.dart';

enum BookingStatus { pending, assigned, completed, disputed, refunded }

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.customerName,
    required this.pickup,
    required this.dropoff,
    required this.requestedAt,
    this.assignedDriver,
    this.status = BookingStatus.pending,
    this.fare,
  });

  final String id;
  final String customerName;
  final String pickup;
  final String dropoff;
  final DateTime requestedAt;
  final String? assignedDriver;
  final BookingStatus status;
  final double? fare;

  AdminBooking copyWith({
    String? assignedDriver,
    BookingStatus? status,
    double? fare,
    bool clearAssignedDriver = false,
  }) {
    return AdminBooking(
      id: id,
      customerName: customerName,
      pickup: pickup,
      dropoff: dropoff,
      requestedAt: requestedAt,
      assignedDriver: clearAssignedDriver
          ? null
          : (assignedDriver ?? this.assignedDriver),
      status: status ?? this.status,
      fare: fare ?? this.fare,
    );
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.assigned:
        return 'Assigned';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.disputed:
        return 'Disputed';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFF8E8E93);
      case BookingStatus.assigned:
        return const Color(0xFF1A73E8);
      case BookingStatus.completed:
        return const Color(0xFF1E8E3E);
      case BookingStatus.disputed:
        return const Color(0xFFC17A00);
      case BookingStatus.refunded:
        return const Color(0xFFC5221F);
    }
  }
}
