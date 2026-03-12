import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../booking/booking_confirmation_page.dart';
import '../booking/booking_models.dart';
import '../booking/booking_store.dart';
import '../booking/payment_sheets.dart';
import '../booking/rating_feedback_sheet.dart';
import '../booking/trip_completion_sheet.dart';
import '../booking/trip_progress_card.dart';

const Color _monoBlack = Color(0xFF000000);
const Color _monoBackground = Color(0xFF080808);
const Color _monoSurface = Color(0xFF111111);
const Color _monoSurfaceAlt = Color(0xFF171717);
const Color _monoSurfaceRaised = Color(0xFF1F1F1F);
const Color _monoBorder = Color(0xFF2B2B2B);
const Color _monoBorderStrong = Color(0xFF4A4A4A);
const Color _monoTextPrimary = Colors.white;
const Color _monoTextSecondary = Color(0xFFB8B8B8);
const Color _monoTextMuted = Color(0xFF8C8C8C);
const Color _monoAccent = Colors.white;
const Color _monoAccentSoft = Color(0xFFEDEDED);
const Color _monoAccentText = Colors.black;
const Color _monoOverlay = Color(0xD9121212);

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
      vehicle: 'Bike',
      distanceKm: 1.2,
      etaMin: 4,
      rating: 4.9,
    ),
    _DriverCandidate(
      name: 'Sabbir',
      vehicle: 'Car',
      distanceKm: 2.6,
      etaMin: 7,
      rating: 4.8,
    ),
    _DriverCandidate(
      name: 'Nabil',
      vehicle: 'Bike',
      distanceKm: 3.1,
      etaMin: 9,
      rating: 4.7,
    ),
    _DriverCandidate(
      name: 'Javed',
      vehicle: 'Car',
      distanceKm: 6.4,
      etaMin: 16,
      rating: 4.9,
    ),
    _DriverCandidate(
      name: 'Rafsan',
      vehicle: 'Car',
      distanceKm: 8.2,
      etaMin: 21,
      rating: 4.6,
    ),
  ];
  static const Map<String, LatLng> _locationCoordinates = <String, LatLng>{
    'Current location': LatLng(23.8103, 90.4125),
    'Bashundhara Residential Area': LatLng(23.8195, 90.4386),
    'Banani 11': LatLng(23.7936, 90.4067),
    'Dhanmondi 27': LatLng(23.7461, 90.3742),
    'Uttara Sector 7': LatLng(23.8759, 90.3795),
    'Motijheel Commercial': LatLng(23.7312, 90.4178),
    'Gulshan Circle 2': LatLng(23.7927, 90.4143),
    'Airport Terminal': LatLng(23.8515, 90.4088),
  };
  static const Map<String, int> _driverExperienceYears = <String, int>{
    'Tariq': 6,
    'Sabbir': 5,
    'Nabil': 4,
    'Javed': 8,
    'Rafsan': 3,
  };

  String _pickupLocation = 'Current location';
  String _dropOffLocation = _locationPrompt;
  String _selectedServiceType = 'Car';
  String _driverSearchMode = 'Nearby';
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.cash;
  bool _showBookingManagement = false;
  int _nextBookingId = 3001;
  final BookingStore _bookingStore = BookingStore.instance;

  bool get _canBook => _dropOffLocation != _locationPrompt;

  List<_DriverCandidate> get _filteredDrivers {
    return _driversForSelection(_driverSearchMode, _selectedServiceType);
  }

  List<_DriverCandidate> _driversForSelection(
    String searchMode,
    String serviceType,
  ) {
    final bool nearbyOnly = searchMode == 'Nearby';
    final List<_DriverCandidate> filtered =
        _driverCandidates
            .where(
              (driver) => nearbyOnly
                  ? driver.distanceKm <= 3.5
                  : driver.distanceKm > 3.5,
            )
            .where((driver) => driver.vehicle == serviceType)
            .toList()
          ..sort((a, b) => a.etaMin.compareTo(b.etaMin));
    return filtered;
  }

  LatLng _coordinateForLocation(String location) {
    return _locationCoordinates[location] ??
        _locationCoordinates['Current location']!;
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
      case 'Bike':
        return _RideEstimate(
          priceBdt: 55 + (distanceKm * 20).round() + pickupDelay,
          timeLabel: '${math.max(7, 10 + (distanceKm * 3).round())} min',
          distanceLabel: '${distanceKm.toStringAsFixed(1)} km by bike',
        );
      case 'Car':
        return _RideEstimate(
          priceBdt: 95 + (distanceKm * 34).round() + pickupDelay * 2,
          timeLabel:
              '${math.max(9, 12 + (distanceKm * 4).round() + pickupDelay)} min',
          distanceLabel: '${distanceKm.toStringAsFixed(1)} km by car',
        );
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
      backgroundColor: _monoBlack,
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
                style: const TextStyle(color: _monoTextSecondary, fontSize: 15),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: _monoAccent,
                    foregroundColor: _monoAccentText,
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
      backgroundColor: _monoBlack,
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
                  style: TextStyle(color: _monoTextSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _locationSuggestions.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: _monoBorder, height: 1),
                    itemBuilder: (context, index) {
                      final String location = _locationSuggestions[index];
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(location),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          index == 0
                              ? Icons.my_location_rounded
                              : Icons.location_on_outlined,
                          color: _monoAccentSoft,
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
      backgroundColor: _monoBlack,
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
                    style: TextStyle(color: _monoTextSecondary, fontSize: 15),
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
                        selectedColor: _monoAccent,
                        backgroundColor: _monoSurfaceAlt,
                        labelStyle: TextStyle(
                          color: selected
                              ? _monoAccentText
                              : _monoTextPrimary,
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
                      color: _monoTextMuted,
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
                        backgroundColor: _monoAccent,
                        foregroundColor: _monoAccentText,
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
      backgroundColor: _monoBlack,
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
                      children: ['Bike', 'Car'].map((service) {
                        return ChoiceChip(
                          label: Text(service),
                          selected: serviceType == service,
                          onSelected: (_) =>
                              setModalState(() => serviceType = service),
                          selectedColor: _monoAccent,
                          backgroundColor: _monoSurfaceAlt,
                          labelStyle: TextStyle(
                            color: serviceType == service
                                ? _monoAccentText
                                : _monoTextPrimary,
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
                          selectedColor: _monoAccent,
                          backgroundColor: _monoSurfaceAlt,
                          labelStyle: TextStyle(
                            color: searchMode == mode
                                ? _monoAccentText
                                : _monoTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      color: _monoSurfaceAlt,
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
                                color: _monoAccentSoft,
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
                                color: _monoTextMuted,
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
                            selectedColor: _monoAccent,
                            backgroundColor: _monoSurfaceAlt,
                            labelStyle: TextStyle(
                              color: !isScheduled
                                  ? _monoAccentText
                                  : _monoTextPrimary,
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
                            selectedColor: _monoAccent,
                            backgroundColor: _monoSurfaceAlt,
                            labelStyle: TextStyle(
                              color: isScheduled
                                  ? _monoAccentText
                                  : _monoTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isScheduled) ...[
                      const SizedBox(height: 10),
                      Material(
                        color: _monoSurfaceAlt,
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
                                  color: _monoAccentSoft,
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
                                  color: _monoTextMuted,
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
                        color: _monoTextPrimary,
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
                          backgroundColor: _monoAccent,
                          foregroundColor: _monoAccentText,
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
    final _RideEstimate bikeEstimate = _estimateForRequest(
      pickupLocation: _pickupLocation,
      dropOffLocation: _dropOffLocation,
      serviceType: 'Bike',
      driverSearchMode: _driverSearchMode,
    );
    final _RideEstimate carEstimate = _estimateForRequest(
      pickupLocation: _pickupLocation,
      dropOffLocation: _dropOffLocation,
      serviceType: 'Car',
      driverSearchMode: _driverSearchMode,
    );
    final LatLng pickupPoint = _coordinateForLocation(_pickupLocation);
    final LatLng? dropOffPoint = _dropOffLocation == _locationPrompt
        ? null
        : _coordinateForLocation(_dropOffLocation);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_monoBlack, _monoBackground, _monoBlack],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _bookingStore,
          builder: (context, _) {
            final BookingRequest? ongoingTrip = _bookingStore.firstOngoing;
            final List<BookingRequest> managedBookings =
                _bookingStore.activeManagementBookings.where((booking) {
                  return ongoingTrip == null || booking.id != ongoingTrip.id;
                }).toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              children: [
                _HeaderSection(
                  pickupLocation: _pickupLocation,
                  dropOffLocation: _dropOffLocation,
                  onPickupTap: () => _selectLocation(pickup: true),
                  onDropOffTap: () => _selectLocation(pickup: false),
                  onAvatarTap:
                      widget.onAccountTap ??
                      () => _showFeatureSheet(
                        'Your account',
                        'View profile, payment methods, and app preferences.',
                      ),
                ),
                const SizedBox(height: 14),
                if (ongoingTrip != null) ...[
                  TripInProgressCard(
                    booking: ongoingTrip,
                    onCompleteTap: () => _completeTrip(ongoingTrip),
                  ),
                  const SizedBox(height: 14),
                ],
                _RouteComposerCard(
                  pickupLocation: _pickupLocation,
                  dropOffLocation: _dropOffLocation,
                  pickupPoint: pickupPoint,
                  dropOffPoint: dropOffPoint,
                  selectedServiceType: _selectedServiceType,
                  selectedPaymentMethod: _selectedPaymentMethod,
                  driverSearchMode: _driverSearchMode,
                  availableDrivers: availableDrivers,
                  estimate: estimate,
                  bikeEstimate: bikeEstimate,
                  carEstimate: carEstimate,
                  bikeDriverCount:
                      _driversForSelection(_driverSearchMode, 'Bike').length,
                  carDriverCount:
                      _driversForSelection(_driverSearchMode, 'Car').length,
                  canBook: _canBook,
                  onServiceTypeTap: _setServiceType,
                  onPaymentTap: _selectDefaultPaymentMethod,
                  onSettingsTap: _openDriverSearchSettings,
                  onInstantBookTap: _bookInstant,
                  onScheduleTap: _scheduleBooking,
                ),
                const SizedBox(height: 20),
                _BookingManagementSection(
                  bookings: managedBookings,
                  isExpanded: _showBookingManagement,
                  onToggleExpanded: () {
                    setState(() {
                      _showBookingManagement = !_showBookingManagement;
                    });
                  },
                  onCancelTap: _cancelBooking,
                  onModifyTap: _modifyBooking,
                  onPaymentTap: _changeBookingPayment,
                  onInvoiceTap: _openInvoice,
                  onStartTap: _startTrip,
                  onCompleteTap: _completeTrip,
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
  const _HeaderSection({
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.onPickupTap,
    required this.onDropOffTap,
    required this.onAvatarTap,
  });

  final String pickupLocation;
  final String dropOffLocation;
  final VoidCallback onPickupTap;
  final VoidCallback onDropOffTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double avatarRadius = (screenWidth * 0.05).clamp(18.0, 25.0);
    final double avatarIconSize = (avatarRadius * 0.9).clamp(16.0, 22.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_monoSurfaceAlt, _monoSurface, _monoBlack],
        ),
        border: Border.all(color: _monoBorderStrong),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search location',
                      style: TextStyle(
                        color: _monoTextPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Set pickup and destination, then choose bike or car below.',
                      style: TextStyle(
                        color: _monoTextSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: _monoSurfaceRaised,
                borderRadius: BorderRadius.circular(avatarRadius),
                shadowColor: const Color(0x33000000),
                elevation: 1.5,
                child: InkWell(
                  onTap: onAvatarTap,
                  borderRadius: BorderRadius.circular(avatarRadius),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: _monoSurface,
                    child: Icon(
                      Icons.person,
                      color: _monoTextPrimary,
                      size: avatarIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _monoSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _monoBorder),
            ),
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.search_rounded,
                  label: 'Destination',
                  value: dropOffLocation,
                  accent: _monoAccentSoft,
                  isPlaceholder:
                      dropOffLocation == _RiderHomeTabState._locationPrompt,
                  onTap: onDropOffTap,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Divider(color: _monoBorder, height: 14),
                ),
                _RouteRow(
                  icon: Icons.my_location_rounded,
                  label: 'Pickup',
                  value: pickupLocation,
                  accent: _monoAccent,
                  onTap: onPickupTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteComposerCard extends StatelessWidget {
  const _RouteComposerCard({
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.pickupPoint,
    required this.dropOffPoint,
    required this.selectedServiceType,
    required this.selectedPaymentMethod,
    required this.driverSearchMode,
    required this.availableDrivers,
    required this.estimate,
    required this.bikeEstimate,
    required this.carEstimate,
    required this.bikeDriverCount,
    required this.carDriverCount,
    required this.canBook,
    required this.onServiceTypeTap,
    required this.onPaymentTap,
    required this.onSettingsTap,
    required this.onInstantBookTap,
    required this.onScheduleTap,
  });

  final String pickupLocation;
  final String dropOffLocation;
  final LatLng pickupPoint;
  final LatLng? dropOffPoint;
  final String selectedServiceType;
  final PaymentMethodType selectedPaymentMethod;
  final String driverSearchMode;
  final List<_DriverCandidate> availableDrivers;
  final _RideEstimate estimate;
  final _RideEstimate bikeEstimate;
  final _RideEstimate carEstimate;
  final int bikeDriverCount;
  final int carDriverCount;
  final bool canBook;
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
          colors: [_monoSurfaceAlt, _monoSurface, _monoBlack],
        ),
        border: Border.all(color: _monoBorderStrong),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 270,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: dropOffPoint ?? pickupPoint,
                      initialZoom: dropOffPoint == null ? 12.8 : 12.2,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.driver_lagbe',
                      ),
                      if (dropOffPoint != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [pickupPoint, dropOffPoint!],
                              color: _monoAccent,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pickupPoint,
                            width: 46,
                            height: 46,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _monoAccent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _monoAccentSoft,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: _monoAccentText,
                              ),
                            ),
                          ),
                          if (dropOffPoint != null)
                            Marker(
                              point: dropOffPoint!,
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _monoBlack,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: _monoAccent,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: _monoAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _MapStatusPill(
                      icon: Icons.tune_rounded,
                      label: '$driverSearchMode range',
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _MapStatusPill(
                      icon: selectedServiceType == 'Bike'
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_filled_rounded,
                      label: selectedServiceType,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _monoOverlay,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _monoBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dropOffPoint == null
                                ? 'Choose your destination to preview the route.'
                                : '$pickupLocation -> $dropOffLocation',
                            style: const TextStyle(
                              color: _monoTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Live estimate: BDT ${estimate.priceBdt} • ${estimate.timeLabel}',
                            style: const TextStyle(
                              color: _monoTextSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose your ride',
                  style: TextStyle(
                    color: _monoTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text('Driver range'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VehicleOptionCard(
                  label: 'Bike',
                  subtitle: 'Fast city pickup',
                  icon: Icons.two_wheeler_rounded,
                  estimate: bikeEstimate,
                  drivers: bikeDriverCount,
                  selected: selectedServiceType == 'Bike',
                  accentColor: _monoAccent,
                  onTap: () => onServiceTypeTap('Bike'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VehicleOptionCard(
                  label: 'Car',
                  subtitle: 'Comfort ride',
                  icon: Icons.directions_car_filled_rounded,
                  estimate: carEstimate,
                  drivers: carDriverCount,
                  selected: selectedServiceType == 'Car',
                  accentColor: _monoAccentSoft,
                  onTap: () => onServiceTypeTap('Car'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onPaymentTap,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _monoAccent,
                  border: Border.all(color: const Color(0xFFD8D8D8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _monoBlack,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          selectedPaymentMethod.icon,
                          color: _monoAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Payment method',
                                  style: TextStyle(
                                    color: Color(0xFF4F4F4F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedPaymentMethod.isDigital
                                        ? _monoBlack
                                        : const Color(0xFFE7E7E7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    selectedPaymentMethod.isDigital
                                        ? 'Fast checkout'
                                        : 'Pay on ride',
                                    style: TextStyle(
                                      color: selectedPaymentMethod.isDigital
                                          ? _monoAccent
                                          : _monoBlack,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              selectedPaymentMethod.label,
                              style: const TextStyle(
                                color: _monoBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedPaymentMethod.isDigital
                                  ? 'Secure payment selected for a smoother pickup.'
                                  : 'Switch to digital wallet or card for quicker checkout.',
                              style: const TextStyle(
                                color: Color(0xFF5A5A5A),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                              ),
                              child: Text(
                                selectedPaymentMethod.isDigital
                                    ? 'Recommended for faster driver dispatch'
                                    : 'Tip: digital payment speeds up pickup handoff',
                                style: const TextStyle(
                                  color: _monoBlack,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _monoBlack,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Change',
                              style: TextStyle(
                                color: _monoAccent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: _monoAccent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _monoSurfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _monoBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  availableDrivers.isEmpty
                      ? 'No $selectedServiceType drivers available in the ${driverSearchMode.toLowerCase()} range.'
                      : '${availableDrivers.first.name} can reach you in ${availableDrivers.first.etaMin} min.',
                  style: const TextStyle(
                    color: _monoTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                if (availableDrivers.isEmpty)
                  const Text(
                    'Try another destination or expand the search range.',
                    style: TextStyle(color: _monoTextSecondary, fontSize: 13),
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
                    backgroundColor: _monoAccent,
                    foregroundColor: _monoAccentText,
                    disabledBackgroundColor: _monoSurfaceRaised,
                    disabledForegroundColor: _monoTextMuted,
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
                    foregroundColor: _monoTextPrimary,
                    side: const BorderSide(color: _monoBorderStrong),
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
              'Choose a destination above to unlock the route preview and booking buttons.',
              style: TextStyle(color: _monoTextSecondary, fontSize: 12.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _monoOverlay,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _monoBorderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _monoAccentSoft),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _monoTextPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleOptionCard extends StatelessWidget {
  const _VehicleOptionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.estimate,
    required this.drivers,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final _RideEstimate estimate;
  final int drivers;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? accentColor.withValues(alpha: 0.18)
          : _monoSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accentColor : _monoBorderStrong,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? accentColor : _monoTextSecondary),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: _monoTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _monoTextSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'BDT ${estimate.priceBdt}',
                style: TextStyle(
                  color: selected ? accentColor : _monoTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${estimate.timeLabel} • $drivers drivers',
                style: const TextStyle(
                  color: _monoTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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
                        color: _monoTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: isPlaceholder
                            ? _monoTextSecondary
                            : _monoTextPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _monoTextMuted),
            ],
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
          backgroundColor: _monoSurfaceRaised,
          child: Text(
            driver.name.substring(0, 1),
            style: const TextStyle(
              color: _monoTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${driver.name} - ${driver.vehicle}',
            style: const TextStyle(
              color: _monoTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '${driver.etaMin} min',
          style: const TextStyle(color: _monoTextSecondary, fontSize: 12.5),
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
        color: _monoAccent,
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: _monoAccentText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Est. BDT ${estimate.priceBdt}',
                  style: const TextStyle(
                    color: _monoAccentText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${estimate.timeLabel}  |  ${estimate.distanceLabel}',
                  style: const TextStyle(
                    color: Color(0xFF444444),
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
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onCancelTap,
    required this.onModifyTap,
    required this.onPaymentTap,
    required this.onInvoiceTap,
    required this.onStartTap,
    required this.onCompleteTap,
  });

  final List<BookingRequest> bookings;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<BookingRequest> onCancelTap;
  final ValueChanged<BookingRequest> onModifyTap;
  final ValueChanged<BookingRequest> onPaymentTap;
  final ValueChanged<BookingRequest> onInvoiceTap;
  final ValueChanged<BookingRequest> onStartTap;
  final ValueChanged<BookingRequest> onCompleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _monoSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _monoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _monoSurfaceRaised,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: _monoAccentSoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking management',
                          style: TextStyle(
                            color: _monoTextPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          bookings.isEmpty
                              ? 'No queued rides yet. Scheduled and requested trips will appear here.'
                              : '${bookings.length} booking${bookings.length > 1 ? 's' : ''} ready to manage.',
                          style: const TextStyle(
                            color: _monoTextSecondary,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _monoTextSecondary,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 14),
            if (bookings.isEmpty)
              const Text(
                'Use Book now or Schedule after selecting a drop-off to start managing rides from here.',
                style: TextStyle(color: _monoTextSecondary, fontSize: 13.5),
              )
            else
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
        ],
      ),
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
        color: _monoSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _monoBorder),
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
                    color: _monoTextPrimary,
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
                    color: _monoAccentText,
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
              color: _monoTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${formatBookingDateTime(booking.bookedFor)} | Est. BDT ${booking.estimatedPriceBdt}',
            style: const TextStyle(color: _monoTextSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Driver range: ${booking.driverSearchMode}${booking.assignedDriver == null ? '' : ' | Driver: ${booking.assignedDriver}'}',
            style: const TextStyle(color: _monoTextSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                booking.paymentMethod.icon,
                color: _monoAccentSoft,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment: ${booking.paymentMethod.label}',
                style: const TextStyle(
                  color: _monoTextPrimary,
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
                    foregroundColor: _monoTextPrimary,
                    side: const BorderSide(color: _monoBorderStrong),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onModifyTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _monoSurfaceRaised,
                    foregroundColor: _monoTextPrimary,
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
                      ? _monoSurfaceRaised
                      : _monoAccent,
                  foregroundColor: booking.status == BookingStatus.requested
                      ? _monoTextPrimary
                      : _monoAccentText,
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
        return const Color(0xFFE0E0E0);
      case BookingStatus.ongoing:
        return const Color(0xFFFFFFFF);
      case BookingStatus.completed:
        return const Color(0xFFBDBDBD);
      case BookingStatus.cancelled:
        return const Color(0xFF5E5E5E);
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
        labelStyle: const TextStyle(color: _monoTextSecondary),
        filled: true,
        fillColor: _monoSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _monoBorderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _monoBorderStrong),
        ),
      ),
      dropdownColor: _monoSurfaceAlt,
      style: const TextStyle(color: _monoTextPrimary, fontWeight: FontWeight.w700),
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
