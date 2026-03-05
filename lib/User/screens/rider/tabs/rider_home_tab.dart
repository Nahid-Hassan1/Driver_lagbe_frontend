import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../booking/booking_confirmation_page.dart';
import '../booking/booking_models.dart';
import '../booking/booking_store.dart';
import '../booking/payment_sheets.dart';
import '../booking/rating_feedback_sheet.dart';
import '../booking/trip_completion_sheet.dart';
import '../booking/trip_progress_card.dart';

class RiderHomeTab extends StatefulWidget {
  const RiderHomeTab({super.key, this.onParcelTap, this.onAccountTap});

  final VoidCallback? onParcelTap;
  final VoidCallback? onAccountTap;

  @override
  State<RiderHomeTab> createState() => _RiderHomeTabState();
}

class _RiderHomeTabState extends State<RiderHomeTab> {
  static const String _locationPrompt = 'Where are you going?';
  static const List<String> _locationSuggestions = <String>[
    'Current location',
    'Bashundhara Residential Area',
    'Banani 11',
    'Dhanmondi 27',
    'Uttara Sector 7',
    'Motijheel Commercial',
    'Gulshan Circle 2',
    'Airport Terminal',
  ];
  static const List<_DriverCandidate> _driverCandidates = <_DriverCandidate>[
    _DriverCandidate(
      name: 'Tariq',
      vehicle: 'Sedan',
      distanceKm: 1.2,
      etaMin: 4,
      rating: 4.9,
    ),
    _DriverCandidate(
      name: 'Sabbir',
      vehicle: 'SUV',
      distanceKm: 2.6,
      etaMin: 7,
      rating: 4.8,
    ),
    _DriverCandidate(
      name: 'Nabil',
      vehicle: 'Private Car',
      distanceKm: 3.1,
      etaMin: 9,
      rating: 4.7,
    ),
    _DriverCandidate(
      name: 'Javed',
      vehicle: 'Microbus',
      distanceKm: 6.4,
      etaMin: 16,
      rating: 4.9,
    ),
    _DriverCandidate(
      name: 'Rafsan',
      vehicle: 'Sedan',
      distanceKm: 8.2,
      etaMin: 21,
      rating: 4.6,
    ),
  ];
  static const Map<String, int> _driverExperienceYears = <String, int>{
    'Tariq': 6,
    'Sabbir': 5,
    'Nabil': 4,
    'Javed': 8,
    'Rafsan': 3,
  };

  String _selectedNeed = 'Daily commute';
  String _pickupLocation = 'Current location';
  String _dropOffLocation = _locationPrompt;
  String _selectedServiceType = 'Trip';
  String _driverSearchMode = 'Nearby';
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.cash;
  int _nextBookingId = 3001;
  final BookingStore _bookingStore = BookingStore.instance;

  bool get _canBook => _dropOffLocation != _locationPrompt;

  List<_DriverCandidate> get _filteredDrivers {
    return _driversForSearchMode(_driverSearchMode);
  }

  List<_DriverCandidate> _driversForSearchMode(String searchMode) {
    final bool nearbyOnly = searchMode == 'Nearby';
    final List<_DriverCandidate> filtered =
        _driverCandidates
            .where(
              (driver) => nearbyOnly
                  ? driver.distanceKm <= 3.5
                  : driver.distanceKm > 3.5,
            )
            .toList()
          ..sort((a, b) => a.etaMin.compareTo(b.etaMin));
    return filtered;
  }

  double _distanceForRoute({
    required String pickupLocation,
    required String dropOffLocation,
  }) {
    if (dropOffLocation == _locationPrompt) {
      return 3.2;
    }
    if (pickupLocation == dropOffLocation) {
      return 1.8;
    }

    final Map<String, double> locationIndex = <String, double>{
      'Current location': 1.2,
      'Bashundhara Residential Area': 2.8,
      'Banani 11': 4.1,
      'Dhanmondi 27': 7.5,
      'Uttara Sector 7': 9.8,
      'Motijheel Commercial': 8.6,
      'Gulshan Circle 2': 5.3,
      'Airport Terminal': 11.0,
    };

    final double pickup = locationIndex[pickupLocation] ?? 2.5;
    final double dropOff = locationIndex[dropOffLocation] ?? 8.0;
    return (((pickup - dropOff).abs() * 2.2) + 2.5).clamp(2.0, 24.0);
  }

  _RideEstimate _estimateForRequest({
    required String pickupLocation,
    required String dropOffLocation,
    required String serviceType,
    required String driverSearchMode,
  }) {
    final double distanceKm = _distanceForRoute(
      pickupLocation: pickupLocation,
      dropOffLocation: dropOffLocation,
    );
    final int pickupDelay = driverSearchMode == 'Nearby' ? 0 : 6;

    switch (serviceType) {
      case 'Hourly':
        return _RideEstimate(
          priceBdt:
              360 +
              (distanceKm * 22).round() +
              (driverSearchMode == 'Far' ? 40 : 0),
          timeLabel: '${(60 + (distanceKm * 5).round())} min booking',
          distanceLabel: '${distanceKm.toStringAsFixed(1)} km route',
        );
      case 'Day':
        return _RideEstimate(
          priceBdt: 2100 + (distanceKm * 14).round(),
          timeLabel: '9 hr coverage',
          distanceLabel: '${distanceKm.toStringAsFixed(1)} km planned',
        );
      default:
        return _RideEstimate(
          priceBdt: 80 + (distanceKm * 36).round() + pickupDelay * 2,
          timeLabel:
              '${math.max(8, 12 + (distanceKm * 4).round() + pickupDelay)} min',
          distanceLabel: '${distanceKm.toStringAsFixed(1)} km trip',
        );
    }
  }

  _RideEstimate get _estimate {
    return _estimateForRequest(
      pickupLocation: _pickupLocation,
      dropOffLocation: _dropOffLocation,
      serviceType: _selectedServiceType,
      driverSearchMode: _driverSearchMode,
    );
  }

  void _showFeatureSheet(String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFB2C2CC), fontSize: 15),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2AE0A0),
                    foregroundColor: const Color(0xFF0A1814),
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

  Future<void> _selectLocation({required bool pickup}) async {
    final String? selectedLocation = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0F1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup ? 'Set pickup location' : 'Set drop-off location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a saved place for fast estimate updates.',
                  style: TextStyle(color: Color(0xFFB2C2CC), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _locationSuggestions.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Color(0xFF29424D), height: 1),
                    itemBuilder: (context, index) {
                      final String location = _locationSuggestions[index];
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(location),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          index == 0
                              ? Icons.my_location_rounded
                              : Icons.location_on_outlined,
                          color: const Color(0xFF8FE6FF),
                        ),
                        title: Text(
                          location,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedLocation == null) {
      return;
    }

    setState(() {
      if (pickup) {
        _pickupLocation = selectedLocation;
      } else {
        _dropOffLocation = selectedLocation;
      }
    });
  }

  void _openDriverSearchSettings() {
    String selectedMode = _driverSearchMode;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Driver search settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how far we search for available drivers.',
                    style: TextStyle(color: Color(0xFFB2C2CC), fontSize: 15),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    children: ['Nearby', 'Far'].map((mode) {
                      final bool selected = selectedMode == mode;
                      return ChoiceChip(
                        label: Text(mode),
                        selected: selected,
                        onSelected: (_) =>
                            setModalState(() => selectedMode = mode),
                        selectedColor: const Color(0xFF2AE0A0),
                        backgroundColor: const Color(0xFF1A3038),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFF062219)
                              : const Color(0xFFE0F4FC),
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedMode == 'Nearby'
                        ? 'Nearby: prioritizes faster pickup within ~3 km.'
                        : 'Far: includes more drivers up to ~10 km away.',
                    style: const TextStyle(
                      color: Color(0xFF9EB4BE),
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _driverSearchMode = selectedMode);
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2AE0A0),
                        foregroundColor: const Color(0xFF0A1814),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setServiceType(String serviceType) {
    setState(() => _selectedServiceType = serviceType);
  }

  Future<void> _selectDefaultPaymentMethod() async {
    final PaymentMethodType? selected = await showPaymentMethodSheet(
      context: context,
      selectedMethod: _selectedPaymentMethod,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() => _selectedPaymentMethod = selected);
  }

  Future<DateTime?> _pickFutureDateTime({DateTime? initialDateTime}) async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        initialDateTime != null && initialDateTime.isAfter(now)
        ? initialDateTime
        : now.add(const Duration(hours: 1));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selectedDate == null) {
      return null;
    }
    if (!mounted) {
      return null;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (selectedTime == null) {
      return null;
    }

    final DateTime scheduledFor = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (!scheduledFor.isAfter(now)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a future date and time.')),
        );
      }
      return null;
    }
    return scheduledFor;
  }

  Future<void> _bookInstant() async {
    if (!_canBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a drop-off location first.')),
      );
      return;
    }

    final List<_DriverCandidate> drivers = _filteredDrivers;
    final _DriverCandidate? assignedDriver = drivers.isNotEmpty
        ? drivers.first
        : null;
    if (assignedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No drivers available right now. Try another search range.',
          ),
        ),
      );
      return;
    }

    final _RideEstimate estimate = _estimate;
    final DateTime rideTime = DateTime.now().add(
      Duration(minutes: assignedDriver.etaMin),
    );

    final BookingRequest booking = BookingRequest(
      id: _nextBookingId++,
      pickupLocation: _pickupLocation,
      dropOffLocation: _dropOffLocation,
      serviceType: _selectedServiceType,
      driverSearchMode: _driverSearchMode,
      estimatedPriceBdt: estimate.priceBdt,
      bookedFor: rideTime,
      isScheduled: false,
      assignedDriver: assignedDriver.name,
      driverVehicle: assignedDriver.vehicle,
      driverRating: assignedDriver.rating,
      driverExperienceYears: _driverExperienceYears[assignedDriver.name] ?? 4,
      driverDistanceKm: assignedDriver.distanceKm,
      driverEtaMin: assignedDriver.etaMin,
      status: BookingStatus.requested,
      completedAt: null,
      riderRating: null,
      riderComment: null,
      paymentMethod: _selectedPaymentMethod,
      fareBreakdown: buildFareBreakdown(
        estimatePriceBdt: estimate.priceBdt,
        serviceType: _selectedServiceType,
        driverSearchMode: _driverSearchMode,
        isScheduled: false,
      ),
    );

    _bookingStore.addBooking(booking);
    if (!mounted) {
      return;
    }

    final BookingRequest? startedBooking = await Navigator.of(context)
        .push<BookingRequest>(
          MaterialPageRoute<BookingRequest>(
            builder: (_) => BookingConfirmationPage(booking: booking),
          ),
        );
    if (!mounted || startedBooking == null) {
      return;
    }
    _bookingStore.upsertBooking(startedBooking);
  }

  Future<void> _scheduleBooking() async {
    if (!_canBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a drop-off location first.')),
      );
      return;
    }

    final DateTime? scheduledFor = await _pickFutureDateTime();
    if (scheduledFor == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final _RideEstimate estimate = _estimate;
    final BookingRequest booking = BookingRequest(
      id: _nextBookingId++,
      pickupLocation: _pickupLocation,
      dropOffLocation: _dropOffLocation,
      serviceType: _selectedServiceType,
      driverSearchMode: _driverSearchMode,
      estimatedPriceBdt: estimate.priceBdt,
      bookedFor: scheduledFor,
      isScheduled: true,
      assignedDriver: null,
      driverVehicle: null,
      driverRating: null,
      driverExperienceYears: null,
      driverDistanceKm: null,
      driverEtaMin: null,
      status: BookingStatus.requested,
      completedAt: null,
      riderRating: null,
      riderComment: null,
      paymentMethod: _selectedPaymentMethod,
      fareBreakdown: buildFareBreakdown(
        estimatePriceBdt: estimate.priceBdt,
        serviceType: _selectedServiceType,
        driverSearchMode: _driverSearchMode,
        isScheduled: true,
      ),
    );

    _bookingStore.addBooking(booking);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scheduled booking #${booking.id} saved')),
    );
  }

  void _cancelBooking(BookingRequest booking) {
    _bookingStore.markCancelled(booking.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Booking #${booking.id} cancelled')));
  }

  Future<void> _modifyBooking(BookingRequest booking) async {
    String pickupLocation = booking.pickupLocation;
    String dropOffLocation = booking.dropOffLocation;
    String serviceType = booking.serviceType;
    String searchMode = booking.driverSearchMode;
    PaymentMethodType paymentMethod = booking.paymentMethod;
    bool isScheduled = booking.isScheduled;
    DateTime bookedFor = booking.bookedFor;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final _RideEstimate preview = _estimateForRequest(
              pickupLocation: pickupLocation,
              dropOffLocation: dropOffLocation,
              serviceType: serviceType,
              driverSearchMode: searchMode,
            );
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
                    Text(
                      'Modify booking #${booking.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BookingEditDropdown(
                      label: 'Pickup',
                      value: pickupLocation,
                      items: _locationSuggestions,
                      onChanged: (value) =>
                          setModalState(() => pickupLocation = value),
                    ),
                    const SizedBox(height: 8),
                    _BookingEditDropdown(
                      label: 'Drop-off',
                      value: dropOffLocation,
                      items: _locationSuggestions
                          .where((item) => item != _locationPrompt)
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => dropOffLocation = value),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Hourly', 'Day', 'Trip'].map((service) {
                        return ChoiceChip(
                          label: Text(service),
                          selected: serviceType == service,
                          onSelected: (_) =>
                              setModalState(() => serviceType = service),
                          selectedColor: const Color(0xFF2AE0A0),
                          backgroundColor: const Color(0xFF1A3038),
                          labelStyle: TextStyle(
                            color: serviceType == service
                                ? const Color(0xFF062219)
                                : const Color(0xFFE0F4FC),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: ['Nearby', 'Far'].map((mode) {
                        return ChoiceChip(
                          label: Text(mode),
                          selected: searchMode == mode,
                          onSelected: (_) =>
                              setModalState(() => searchMode = mode),
                          selectedColor: const Color(0xFF2AE0A0),
                          backgroundColor: const Color(0xFF1A3038),
                          labelStyle: TextStyle(
                            color: searchMode == mode
                                ? const Color(0xFF062219)
                                : const Color(0xFFE0F4FC),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: const Color(0xFF18303A),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          final PaymentMethodType? selected =
                              await showPaymentMethodSheet(
                                context: context,
                                selectedMethod: paymentMethod,
                              );
                          if (selected != null) {
                            setModalState(() => paymentMethod = selected);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                paymentMethod.icon,
                                color: const Color(0xFF8FE6FF),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Payment: ${paymentMethod.label}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF8DA8B4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Instant'),
                            selected: !isScheduled,
                            onSelected: (_) =>
                                setModalState(() => isScheduled = false),
                            selectedColor: const Color(0xFF2AE0A0),
                            backgroundColor: const Color(0xFF1A3038),
                            labelStyle: TextStyle(
                              color: !isScheduled
                                  ? const Color(0xFF062219)
                                  : const Color(0xFFE0F4FC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Scheduled'),
                            selected: isScheduled,
                            onSelected: (_) =>
                                setModalState(() => isScheduled = true),
                            selectedColor: const Color(0xFF2AE0A0),
                            backgroundColor: const Color(0xFF1A3038),
                            labelStyle: TextStyle(
                              color: isScheduled
                                  ? const Color(0xFF062219)
                                  : const Color(0xFFE0F4FC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isScheduled) ...[
                      const SizedBox(height: 10),
                      Material(
                        color: const Color(0xFF18303A),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () async {
                            final DateTime? selected =
                                await _pickFutureDateTime(
                                  initialDateTime: bookedFor,
                                );
                            if (selected != null) {
                              setModalState(() => bookedFor = selected);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(0xFF8FE6FF),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    formatBookingDateTime(bookedFor),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF8DA8B4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Updated estimate: BDT ${preview.priceBdt}',
                      style: const TextStyle(
                        color: Color(0xFFD7EDF5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final BookingRequest updated = booking.copyWith(
                            pickupLocation: pickupLocation,
                            dropOffLocation: dropOffLocation,
                            serviceType: serviceType,
                            driverSearchMode: searchMode,
                            estimatedPriceBdt: preview.priceBdt,
                            bookedFor: isScheduled
                                ? bookedFor
                                : DateTime.now().add(
                                    const Duration(minutes: 10),
                                  ),
                            isScheduled: isScheduled,
                            paymentMethod: paymentMethod,
                            fareBreakdown: buildFareBreakdown(
                              estimatePriceBdt: preview.priceBdt,
                              serviceType: serviceType,
                              driverSearchMode: searchMode,
                              isScheduled: isScheduled,
                            ),
                          );
                          _bookingStore.upsertBooking(updated);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Booking #${booking.id} updated'),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2AE0A0),
                          foregroundColor: const Color(0xFF0A1814),
                        ),
                        child: const Text('Save changes'),
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

  Future<void> _changeBookingPayment(BookingRequest booking) async {
    final PaymentMethodType? selected = await showPaymentMethodSheet(
      context: context,
      selectedMethod: booking.paymentMethod,
    );
    if (!mounted || selected == null) {
      return;
    }

    _bookingStore.upsertBooking(booking.copyWith(paymentMethod: selected));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking #${booking.id} payment updated')),
    );
  }

  Future<void> _openInvoice(BookingRequest booking) async {
    await showBookingInvoiceSheet(context: context, booking: booking);
  }

  void _startTrip(BookingRequest booking) {
    _bookingStore.markOngoing(booking.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking #${booking.id} is now ongoing')),
    );
  }

  Future<void> _completeTrip(BookingRequest booking) async {
    final BookingRequest? completed = _bookingStore.markCompleted(booking.id);
    if (!mounted || completed == null) {
      return;
    }

    await showTripCompletionSheet(context: context, booking: completed);
    if (!mounted) {
      return;
    }

    final RatingFeedbackResult? feedback = await showRatingFeedbackSheet(
      context: context,
      booking: completed,
    );
    if (!mounted || feedback == null) {
      return;
    }

    _bookingStore.submitRating(
      bookingId: completed.id,
      rating: feedback.rating,
      comment: feedback.comment,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your rating and feedback!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_DriverCandidate> availableDrivers = _filteredDrivers;
    final _RideEstimate estimate = _estimate;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1215), Color(0xFF12232B), Color(0xFF070A0B)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _bookingStore,
          builder: (context, _) {
            final List<BookingRequest> managedBookings =
                _bookingStore.activeManagementBookings;
            final BookingRequest? ongoingTrip = _bookingStore.firstOngoing;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              children: [
                _HeaderSection(
                  onAvatarTap:
                      widget.onAccountTap ??
                      () => _showFeatureSheet(
                        'Your account',
                        'View profile, payment methods, and app preferences.',
                      ),
                ),
                const SizedBox(height: 14),
                _ModeSwitcher(
                  onRideTap: () => _showFeatureSheet(
                    'Ride mode',
                    'You are currently in ride mode.',
                  ),
                  onParcelTap:
                      widget.onParcelTap ??
                      () => _showFeatureSheet(
                        'Parcel mode',
                        'Switch to Services tab to send or receive parcels.',
                      ),
                ),
                const SizedBox(height: 14),
                _RouteComposerCard(
                  pickupLocation: _pickupLocation,
                  dropOffLocation: _dropOffLocation,
                  selectedServiceType: _selectedServiceType,
                  selectedPaymentMethod: _selectedPaymentMethod,
                  driverSearchMode: _driverSearchMode,
                  availableDrivers: availableDrivers,
                  estimate: estimate,
                  canBook: _canBook,
                  onPickupTap: () => _selectLocation(pickup: true),
                  onDropOffTap: () => _selectLocation(pickup: false),
                  onServiceTypeTap: _setServiceType,
                  onPaymentTap: _selectDefaultPaymentMethod,
                  onSettingsTap: _openDriverSearchSettings,
                  onInstantBookTap: _bookInstant,
                  onScheduleTap: _scheduleBooking,
                ),
                if (ongoingTrip != null) ...[
                  const SizedBox(height: 12),
                  TripInProgressCard(
                    booking: ongoingTrip,
                    onCompleteTap: () => _completeTrip(ongoingTrip),
                  ),
                ],
                const SizedBox(height: 16),
                _BookingManagementSection(
                  bookings: managedBookings,
                  onCancelTap: _cancelBooking,
                  onModifyTap: _modifyBooking,
                  onPaymentTap: _changeBookingPayment,
                  onInvoiceTap: _openInvoice,
                  onStartTap: _startTrip,
                  onCompleteTap: _completeTrip,
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'What do you need today?',
                  trailing: 'Customize',
                  onTap: () => _showFeatureSheet(
                    'Personalize your home',
                    'Reorder quick needs and default ride preferences.',
                  ),
                ),
                const SizedBox(height: 12),
                _NeedPillsSection(
                  selectedNeed: _selectedNeed,
                  onNeedTap: (need) {
                    setState(() => _selectedNeed = need);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$need selected')));
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Recommended for you',
                  trailing: 'See all',
                  onTap: () => _showFeatureSheet(
                    'Recommendations',
                    'Based on your previous trips and current offers.',
                  ),
                ),
                const SizedBox(height: 12),
                _RecommendedRail(
                  onCardTap: (title) => _showFeatureSheet(
                    title,
                    'Tap continue to view options and book instantly.',
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Your trip tools',
                  trailing: 'Manage',
                  onTap: () => _showFeatureSheet(
                    'Trip tools',
                    'Shortcuts for safety, split fare, and saved places.',
                  ),
                ),
                const SizedBox(height: 12),
                _TripToolsGrid(
                  onToolTap: (title) => _showFeatureSheet(
                    title,
                    'Open this tool to continue setup.',
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Offers near you',
                  trailing: 'View deals',
                  onTap: () => _showFeatureSheet(
                    'Nearby offers',
                    'Limited discounts active around your current location.',
                  ),
                ),
                const SizedBox(height: 12),
                _OfferList(
                  onOfferTap: (title) => _showFeatureSheet(
                    title,
                    'Apply this offer on your next booking.',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double avatarRadius = (screenWidth * 0.045).clamp(16.0, 24.0);
    final double avatarIconSize = (avatarRadius * 0.9).clamp(15.0, 22.0);

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening, Nahid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Ready for your next ride?',
                style: TextStyle(color: Color(0xFFB0C5CF), fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF17323B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A4D58)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.wb_twilight_rounded,
                color: Color(0xFF7DE4FF),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                '27 C',
                style: TextStyle(
                  color: Color(0xFFE5F9FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: const Color(0xFF1A3139),
          borderRadius: BorderRadius.circular(avatarRadius),
          shadowColor: const Color(0x33000000),
          elevation: 1.5,
          child: InkWell(
            onTap: onAvatarTap,
            borderRadius: BorderRadius.circular(avatarRadius),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Color(0xFF26434D),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: avatarIconSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.onRideTap, required this.onParcelTap});

  final VoidCallback onRideTap;
  final VoidCallback onParcelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF101C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF223641)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Ride',
              icon: Icons.directions_car_filled_rounded,
              selected: true,
              onTap: onRideTap,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ModeButton(
              label: 'Parcel',
              icon: Icons.inventory_2_rounded,
              selected: false,
              onTap: onParcelTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2AE0A0) : const Color(0xFF162830),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFF052018)
                    : const Color(0xFFBBD7E2),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF052018)
                      : const Color(0xFFBBD7E2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteComposerCard extends StatelessWidget {
  const _RouteComposerCard({
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.selectedServiceType,
    required this.selectedPaymentMethod,
    required this.driverSearchMode,
    required this.availableDrivers,
    required this.estimate,
    required this.canBook,
    required this.onPickupTap,
    required this.onDropOffTap,
    required this.onServiceTypeTap,
    required this.onPaymentTap,
    required this.onSettingsTap,
    required this.onInstantBookTap,
    required this.onScheduleTap,
  });

  final String pickupLocation;
  final String dropOffLocation;
  final String selectedServiceType;
  final PaymentMethodType selectedPaymentMethod;
  final String driverSearchMode;
  final List<_DriverCandidate> availableDrivers;
  final _RideEstimate estimate;
  final bool canBook;
  final VoidCallback onPickupTap;
  final VoidCallback onDropOffTap;
  final ValueChanged<String> onServiceTypeTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onInstantBookTap;
  final VoidCallback onScheduleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18303A), Color(0xFF11262E), Color(0xFF0D1C22)],
        ),
        border: Border.all(color: const Color(0xFF35505A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Driver Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Material(
                color: const Color(0xFF213942),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onSettingsTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFFA3D1DE),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$driverSearchMode drivers',
                          style: const TextStyle(
                            color: Color(0xFFD8EEF5),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RouteRow(
            icon: Icons.my_location_rounded,
            label: 'Pickup',
            value: pickupLocation,
            accent: const Color(0xFF2AE0A0),
            onTap: onPickupTap,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Divider(color: Color(0xFF2C444E)),
          ),
          _RouteRow(
            icon: Icons.location_on_outlined,
            label: 'Drop-off',
            value: dropOffLocation,
            accent: const Color(0xFF7DE4FF),
            isPlaceholder:
                dropOffLocation == _RiderHomeTabState._locationPrompt,
            onTap: onDropOffTap,
          ),
          const SizedBox(height: 12),
          const Text(
            'Service type',
            style: TextStyle(
              color: Color(0xFFA7C1CC),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Hourly', 'Day', 'Trip'].map((service) {
              return _ServiceTypeChip(
                label: service,
                selected: selectedServiceType == service,
                onTap: () => onServiceTypeTap(service),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Material(
            color: const Color(0xFF18303A),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPaymentTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedPaymentMethod.icon,
                      color: const Color(0xFF8FE6FF),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payment: ${selectedPaymentMethod.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8DA8B4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A313A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E4B56)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${availableDrivers.length} drivers found (${driverSearchMode.toLowerCase()} range)',
                  style: const TextStyle(
                    color: Color(0xFFD5ECF4),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                if (availableDrivers.isEmpty)
                  const Text(
                    'No drivers available in this range now. Try switching search settings.',
                    style: TextStyle(color: Color(0xFFAAC0CB), fontSize: 13),
                  )
                else
                  ...availableDrivers.take(2).map((driver) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _DriverCandidateTile(driver: driver),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _EstimatePanel(estimate: estimate),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: canBook ? onInstantBookTap : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2AE0A0),
                    foregroundColor: const Color(0xFF062219),
                    disabledBackgroundColor: const Color(0xFF325246),
                    disabledForegroundColor: const Color(0xFF95B3A5),
                  ),
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Book now'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canBook ? onScheduleTap : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD8EEF5),
                    side: const BorderSide(color: Color(0xFF3A5963)),
                  ),
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Schedule'),
                ),
              ),
            ],
          ),
          if (!canBook) ...[
            const SizedBox(height: 8),
            const Text(
              'Choose a drop-off to enable booking actions.',
              style: TextStyle(color: Color(0xFFAAC0CB), fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF9BB2BD),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: isPlaceholder
                            ? const Color(0xFFA9C0CA)
                            : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8DA8B4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2AE0A0) : const Color(0xFF1B3139),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF062219)
                  : const Color(0xFFD5ECF4),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverCandidateTile extends StatelessWidget {
  const _DriverCandidateTile({required this.driver});

  final _DriverCandidate driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF244650),
          child: Text(
            driver.name.substring(0, 1),
            style: const TextStyle(
              color: Color(0xFFDFF5FE),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${driver.name} - ${driver.vehicle}',
            style: const TextStyle(
              color: Color(0xFFD7EDF5),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '${driver.etaMin} min',
          style: const TextStyle(color: Color(0xFFA7C1CC), fontSize: 12.5),
        ),
      ],
    );
  }
}

class _EstimatePanel extends StatelessWidget {
  const _EstimatePanel({required this.estimate});

  final _RideEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF245C86), Color(0xFF204D67)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Est. BDT ${estimate.priceBdt}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${estimate.timeLabel}  |  ${estimate.distanceLabel}',
                  style: const TextStyle(
                    color: Color(0xFFE3F2FF),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingManagementSection extends StatelessWidget {
  const _BookingManagementSection({
    required this.bookings,
    required this.onCancelTap,
    required this.onModifyTap,
    required this.onPaymentTap,
    required this.onInvoiceTap,
    required this.onStartTap,
    required this.onCompleteTap,
  });

  final List<BookingRequest> bookings;
  final ValueChanged<BookingRequest> onCancelTap;
  final ValueChanged<BookingRequest> onModifyTap;
  final ValueChanged<BookingRequest> onPaymentTap;
  final ValueChanged<BookingRequest> onInvoiceTap;
  final ValueChanged<BookingRequest> onStartTap;
  final ValueChanged<BookingRequest> onCompleteTap;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF13242B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF26424D)),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: Color(0xFF8FE6FF)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No active bookings yet. Use Book now or Schedule to create one.',
                style: TextStyle(color: Color(0xFFB7CAD3), fontSize: 13.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${bookings.length} active booking${bookings.length > 1 ? 's' : ''}',
          style: const TextStyle(color: Color(0xFFAAC0CB), fontSize: 13.5),
        ),
        const SizedBox(height: 10),
        ...bookings.take(3).map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BookingCard(
              booking: booking,
              onCancelTap: () => onCancelTap(booking),
              onModifyTap: () => onModifyTap(booking),
              onPaymentTap: () => onPaymentTap(booking),
              onInvoiceTap: () => onInvoiceTap(booking),
              onStartTap: () => onStartTap(booking),
              onCompleteTap: () => onCompleteTap(booking),
            ),
          );
        }),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onCancelTap,
    required this.onModifyTap,
    required this.onPaymentTap,
    required this.onInvoiceTap,
    required this.onStartTap,
    required this.onCompleteTap,
  });

  final BookingRequest booking;
  final VoidCallback onCancelTap;
  final VoidCallback onModifyTap;
  final VoidCallback onPaymentTap;
  final VoidCallback onInvoiceTap;
  final VoidCallback onStartTap;
  final VoidCallback onCompleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13242B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26424D)),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${booking.id} - ${booking.serviceType}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  booking.status.label,
                  style: const TextStyle(
                    color: Color(0xFFDFF8FF),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.pickupLocation} -> ${booking.dropOffLocation}',
            style: const TextStyle(
              color: Color(0xFFD7EDF5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${formatBookingDateTime(booking.bookedFor)} | Est. BDT ${booking.estimatedPriceBdt}',
            style: const TextStyle(color: Color(0xFFAAC0CB), fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Driver range: ${booking.driverSearchMode}${booking.assignedDriver == null ? '' : ' | Driver: ${booking.assignedDriver}'}',
            style: const TextStyle(color: Color(0xFFAAC0CB), fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                booking.paymentMethod.icon,
                color: const Color(0xFF8FE6FF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment: ${booking.paymentMethod.label}',
                style: const TextStyle(
                  color: Color(0xFFD0E8F1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onPaymentTap, child: const Text('Change')),
              TextButton(onPressed: onInvoiceTap, child: const Text('Invoice')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      booking.status == BookingStatus.cancelled ||
                          booking.status == BookingStatus.completed
                      ? null
                      : onCancelTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFCFDA),
                    side: const BorderSide(color: Color(0xFF7F4455)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onModifyTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2A4E5C),
                    foregroundColor: const Color(0xFFE2F5FB),
                  ),
                  child: const Text('Modify'),
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.requested ||
              booking.status == BookingStatus.ongoing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: booking.status == BookingStatus.requested
                    ? onStartTap
                    : onCompleteTap,
                style: FilledButton.styleFrom(
                  backgroundColor: booking.status == BookingStatus.requested
                      ? const Color(0xFF2A5C7D)
                      : const Color(0xFF2AE0A0),
                  foregroundColor: booking.status == BookingStatus.requested
                      ? const Color(0xFFDFF4FF)
                      : const Color(0xFF0A1814),
                ),
                child: Text(
                  booking.status == BookingStatus.requested
                      ? 'Start Trip'
                      : 'Complete Trip',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.requested:
        return const Color(0xFF1B4D5F);
      case BookingStatus.ongoing:
        return const Color(0xFF2A5C7D);
      case BookingStatus.completed:
        return const Color(0xFF1E5F4F);
      case BookingStatus.cancelled:
        return const Color(0xFF6A3242);
    }
  }
}

class _BookingEditDropdown extends StatelessWidget {
  const _BookingEditDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFAAC0CB)),
        filled: true,
        fillColor: const Color(0xFF18303A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D4A55)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D4A55)),
        ),
      ),
      dropdownColor: const Color(0xFF17303A),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _RideEstimate {
  const _RideEstimate({
    required this.priceBdt,
    required this.timeLabel,
    required this.distanceLabel,
  });

  final int priceBdt;
  final String timeLabel;
  final String distanceLabel;
}

class _DriverCandidate {
  const _DriverCandidate({
    required this.name,
    required this.vehicle,
    required this.distanceKm,
    required this.etaMin,
    required this.rating,
  });

  final String name;
  final String vehicle;
  final double distanceKm;
  final int etaMin;
  final double rating;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            trailing,
            style: const TextStyle(
              color: Color(0xFF8FE6FF),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _NeedPillsSection extends StatelessWidget {
  const _NeedPillsSection({
    required this.selectedNeed,
    required this.onNeedTap,
  });

  final String selectedNeed;
  final ValueChanged<String> onNeedTap;

  @override
  Widget build(BuildContext context) {
    const options = <String>[
      'Daily commute',
      'Airport drop',
      'Parcel send',
      'Intercity',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final selected = option == selectedNeed;
        return Material(
          color: selected ? const Color(0xFF2AE0A0) : const Color(0xFF15272F),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => onNeedTap(option),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                option,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF062219)
                      : const Color(0xFFCAE2EB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecommendedRail extends StatelessWidget {
  const _RecommendedRail({required this.onCardTap});

  final ValueChanged<String> onCardTap;

  @override
  Widget build(BuildContext context) {
    const items = <_RecommendedItem>[
      _RecommendedItem(
        title: 'Morning Saver',
        subtitle: 'Up to 18% off before 10 AM',
        icon: Icons.wb_sunny_outlined,
        colors: [Color(0xFF2F7EFF), Color(0xFF2556A9)],
      ),
      _RecommendedItem(
        title: 'Comfort+',
        subtitle: 'Quiet rides with top drivers',
        icon: Icons.weekend_outlined,
        colors: [Color(0xFF7046C9), Color(0xFF452B83)],
      ),
      _RecommendedItem(
        title: 'City Bike',
        subtitle: 'Fast pickup in traffic',
        icon: Icons.two_wheeler_rounded,
        colors: [Color(0xFF00A978), Color(0xFF0C6A50)],
      ),
    ];

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onCardTap(item.title),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.colors,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, color: Colors.white, size: 30),
                    const Spacer(),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFE7F2FF),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendedItem {
  const _RecommendedItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _TripToolsGrid extends StatelessWidget {
  const _TripToolsGrid({required this.onToolTap});

  final ValueChanged<String> onToolTap;

  @override
  Widget build(BuildContext context) {
    const items = <_ToolItem>[
      _ToolItem(
        title: 'Saved places',
        subtitle: 'Home, work, and more',
        icon: Icons.bookmark_outline_rounded,
      ),
      _ToolItem(
        title: 'Safety toolkit',
        subtitle: 'Share trip & SOS',
        icon: Icons.shield_outlined,
      ),
      _ToolItem(
        title: 'Split fare',
        subtitle: 'Invite your friends',
        icon: Icons.group_add_outlined,
      ),
      _ToolItem(
        title: 'Ride pass',
        subtitle: 'Weekly savings',
        icon: Icons.confirmation_number_outlined,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: Material(
            color: const Color(0xFF122229),
            borderRadius: BorderRadius.circular(16),
            shadowColor: const Color(0x33000000),
            elevation: 1.5,
            child: InkWell(
              onTap: () => onToolTap(item.title),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, color: const Color(0xFF8FE6FF), size: 24),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB7CAD3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _OfferList extends StatelessWidget {
  const _OfferList({required this.onOfferTap});

  final ValueChanged<String> onOfferTap;

  @override
  Widget build(BuildContext context) {
    const offers = <_OfferItem>[
      _OfferItem(
        title: '25% off Bike rides',
        subtitle: 'Valid till tonight, max BDT 60',
        color: Color(0xFF1B5E52),
      ),
      _OfferItem(
        title: 'Flat BDT 100 off Intercity',
        subtitle: 'Use code TRAVEL100',
        color: Color(0xFF5D3A16),
      ),
    ];

    return Column(
      children: offers.map((offer) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: offer.color,
            borderRadius: BorderRadius.circular(16),
            shadowColor: const Color(0x33000000),
            elevation: 1.5,
            child: InkWell(
              onTap: () => onOfferTap(offer.title),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            offer.subtitle,
                            style: const TextStyle(
                              color: Color(0xFFE8F2F4),
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OfferItem {
  const _OfferItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;
}
