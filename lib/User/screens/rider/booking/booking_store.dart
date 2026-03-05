import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'booking_models.dart';

class BookingStore extends ChangeNotifier {
  BookingStore._();

  static final BookingStore instance = BookingStore._();

  final List<BookingRequest> _bookings = <BookingRequest>[];

  UnmodifiableListView<BookingRequest> get bookings =>
      UnmodifiableListView<BookingRequest>(_bookings);

  List<BookingRequest> byStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  List<BookingRequest> get activeManagementBookings {
    return _bookings
        .where((booking) =>
            booking.status == BookingStatus.requested ||
            booking.status == BookingStatus.ongoing)
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  BookingRequest? get firstOngoing {
    final Iterable<BookingRequest> ongoing =
        _bookings.where((booking) => booking.status == BookingStatus.ongoing);
    if (ongoing.isEmpty) {
      return null;
    }
    return ongoing.first;
  }

  void addBooking(BookingRequest booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void upsertBooking(BookingRequest booking) {
    final int index = _bookings.indexWhere((item) => item.id == booking.id);
    if (index == -1) {
      _bookings.insert(0, booking);
    } else {
      _bookings[index] = booking;
    }
    notifyListeners();
  }

  BookingRequest? markOngoing(int bookingId) {
    final int index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index == -1) {
      return null;
    }
    final BookingRequest updated = _bookings[index].copyWith(
      status: BookingStatus.ongoing,
    );
    _bookings[index] = updated;
    notifyListeners();
    return updated;
  }

  BookingRequest? markCompleted(int bookingId) {
    final int index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index == -1) {
      return null;
    }
    final BookingRequest updated = _bookings[index].copyWith(
      status: BookingStatus.completed,
      completedAt: DateTime.now(),
    );
    _bookings[index] = updated;
    notifyListeners();
    return updated;
  }

  BookingRequest? markCancelled(int bookingId) {
    final int index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index == -1) {
      return null;
    }
    final BookingRequest updated = _bookings[index].copyWith(
      status: BookingStatus.cancelled,
    );
    _bookings[index] = updated;
    notifyListeners();
    return updated;
  }

  BookingRequest? submitRating({
    required int bookingId,
    required int rating,
    required String comment,
  }) {
    final int index = _bookings.indexWhere((item) => item.id == bookingId);
    if (index == -1) {
      return null;
    }
    final BookingRequest updated = _bookings[index].copyWith(
      riderRating: rating,
      riderComment: comment.trim().isEmpty ? null : comment.trim(),
    );
    _bookings[index] = updated;
    notifyListeners();
    return updated;
  }
}
