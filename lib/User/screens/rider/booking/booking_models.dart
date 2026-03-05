import 'package:flutter/material.dart';

enum PaymentMethodType {
  cash,
  bkash,
  nagad,
  card,
}

enum BookingStatus {
  requested,
  ongoing,
  completed,
  cancelled,
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.requested:
        return 'Requested';
      case BookingStatus.ongoing:
        return 'Ongoing';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension PaymentMethodTypeX on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Cash';
      case PaymentMethodType.bkash:
        return 'bKash';
      case PaymentMethodType.nagad:
        return 'Nagad';
      case PaymentMethodType.card:
        return 'Card';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return Icons.payments_outlined;
      case PaymentMethodType.bkash:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethodType.nagad:
        return Icons.phone_android_rounded;
      case PaymentMethodType.card:
        return Icons.credit_card_rounded;
    }
  }

  bool get isDigital => this != PaymentMethodType.cash;
}

class FareBreakdown {
  const FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.serviceFee,
    required this.driverSearchSurcharge,
    required this.schedulingFee,
    required this.discount,
  });

  final int baseFare;
  final int distanceFare;
  final int serviceFee;
  final int driverSearchSurcharge;
  final int schedulingFee;
  final int discount;

  int get totalBdt {
    return baseFare +
        distanceFare +
        serviceFee +
        driverSearchSurcharge +
        schedulingFee -
        discount;
  }
}

FareBreakdown buildFareBreakdown({
  required int estimatePriceBdt,
  required String serviceType,
  required String driverSearchMode,
  required bool isScheduled,
}) {
  final int serviceFee;
  switch (serviceType) {
    case 'Hourly':
      serviceFee = 55;
      break;
    case 'Day':
      serviceFee = 95;
      break;
    default:
      serviceFee = 35;
      break;
  }

  final int driverSearchSurcharge = driverSearchMode == 'Far' ? 24 : 0;
  final int schedulingFee = isScheduled ? 20 : 0;
  final int discount = estimatePriceBdt >= 250 ? 20 : 0;

  int baseFare = (estimatePriceBdt * 0.52).round();
  int distanceFare = estimatePriceBdt -
      (baseFare + serviceFee + driverSearchSurcharge + schedulingFee - discount);

  if (distanceFare < 0) {
    baseFare = (baseFare + distanceFare).clamp(0, estimatePriceBdt);
    distanceFare = 0;
  }

  return FareBreakdown(
    baseFare: baseFare,
    distanceFare: distanceFare,
    serviceFee: serviceFee,
    driverSearchSurcharge: driverSearchSurcharge,
    schedulingFee: schedulingFee,
    discount: discount,
  );
}

class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.serviceType,
    required this.driverSearchMode,
    required this.estimatedPriceBdt,
    required this.bookedFor,
    required this.isScheduled,
    required this.assignedDriver,
    required this.driverVehicle,
    required this.driverRating,
    required this.driverExperienceYears,
    required this.driverDistanceKm,
    required this.driverEtaMin,
    required this.status,
    required this.completedAt,
    required this.riderRating,
    required this.riderComment,
    required this.paymentMethod,
    required this.fareBreakdown,
  });

  final int id;
  final String pickupLocation;
  final String dropOffLocation;
  final String serviceType;
  final String driverSearchMode;
  final int estimatedPriceBdt;
  final DateTime bookedFor;
  final bool isScheduled;
  final String? assignedDriver;
  final String? driverVehicle;
  final double? driverRating;
  final int? driverExperienceYears;
  final double? driverDistanceKm;
  final int? driverEtaMin;
  final BookingStatus status;
  final DateTime? completedAt;
  final int? riderRating;
  final String? riderComment;
  final PaymentMethodType paymentMethod;
  final FareBreakdown fareBreakdown;

  BookingRequest copyWith({
    String? pickupLocation,
    String? dropOffLocation,
    String? serviceType,
    String? driverSearchMode,
    int? estimatedPriceBdt,
    DateTime? bookedFor,
    bool? isScheduled,
    String? assignedDriver,
    String? driverVehicle,
    double? driverRating,
    int? driverExperienceYears,
    double? driverDistanceKm,
    int? driverEtaMin,
    BookingStatus? status,
    DateTime? completedAt,
    int? riderRating,
    String? riderComment,
    PaymentMethodType? paymentMethod,
    FareBreakdown? fareBreakdown,
  }) {
    return BookingRequest(
      id: id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      serviceType: serviceType ?? this.serviceType,
      driverSearchMode: driverSearchMode ?? this.driverSearchMode,
      estimatedPriceBdt: estimatedPriceBdt ?? this.estimatedPriceBdt,
      bookedFor: bookedFor ?? this.bookedFor,
      isScheduled: isScheduled ?? this.isScheduled,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverRating: driverRating ?? this.driverRating,
      driverExperienceYears: driverExperienceYears ?? this.driverExperienceYears,
      driverDistanceKm: driverDistanceKm ?? this.driverDistanceKm,
      driverEtaMin: driverEtaMin ?? this.driverEtaMin,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      riderRating: riderRating ?? this.riderRating,
      riderComment: riderComment ?? this.riderComment,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    );
  }
}
