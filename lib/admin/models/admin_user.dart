import 'package:flutter/material.dart';

enum AdminUserType { customer, driver }

enum DriverVerificationStatus { pending, approved, rejected }

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.status = DriverVerificationStatus.approved,
    this.joinedOn,
  });

  final String id;
  final String name;
  final String phone;
  final AdminUserType type;
  final DriverVerificationStatus status;
  final DateTime? joinedOn;

  bool get isDriver => type == AdminUserType.driver;

  Color get statusColor {
    switch (status) {
      case DriverVerificationStatus.pending:
        return const Color(0xFFC17A00);
      case DriverVerificationStatus.approved:
        return const Color(0xFF1E8E3E);
      case DriverVerificationStatus.rejected:
        return const Color(0xFFC5221F);
    }
  }

  String get statusLabel {
    switch (status) {
      case DriverVerificationStatus.pending:
        return 'Pending';
      case DriverVerificationStatus.approved:
        return 'Approved';
      case DriverVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  String get typeLabel {
    if (type == AdminUserType.driver) {
      return 'Driver';
    }
    return 'Customer';
  }

  AdminUser copyWith({
    DriverVerificationStatus? status,
  }) {
    return AdminUser(
      id: id,
      name: name,
      phone: phone,
      type: type,
      status: status ?? this.status,
      joinedOn: joinedOn,
    );
  }
}
