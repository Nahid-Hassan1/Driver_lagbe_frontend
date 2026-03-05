enum DriverNotificationType {
  newBookingAlert,
  paymentReceived,
  accountUpdate,
}

class DriverNotificationItem {
  const DriverNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final DriverNotificationType type;
  final bool isRead;

  DriverNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    DriverNotificationType? type,
    bool? isRead,
  }) {
    return DriverNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
