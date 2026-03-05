class DriverOnboardingData {
  DriverOnboardingData({
    this.vehicleType = 'Private Car',
  });

  static const List<String> vehicleTypes = <String>[
    'Private Car',
    'Microbus',
    'SUV',
    'Sedan',
    'Bike',
    'Pickup',
  ];

  String fullName = '';
  String phone = '';
  String email = '';
  String licenseNumber = '';
  String nidNumber = '';
  bool licenseVerified = false;
  bool nidVerified = false;

  bool hasVehicle = true;
  String vehicleType;
  String vehicleBrand = '';
  String vehicleModel = '';
  String vehiclePlate = '';
  String vehicleYear = '';
}
