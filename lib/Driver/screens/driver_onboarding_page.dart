import 'package:flutter/material.dart';

import '../models/driver_onboarding_data.dart';
import '../theme/driver_theme.dart';
import '../widgets/driver_registration_form.dart';
import '../widgets/vehicle_information_form.dart';
import 'driver_availability_page.dart';

class DriverOnboardingPage extends StatefulWidget {
  const DriverOnboardingPage({super.key});

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _vehicleFormKey = GlobalKey<FormState>();

  final DriverOnboardingData _data = DriverOnboardingData();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();

  final TextEditingController _vehicleBrandController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _vehicleYearController = TextEditingController();

  int _currentStep = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _nidController.dispose();
    _vehicleBrandController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  void _verifyLicense() {
    if (_licenseController.text.trim().isEmpty) {
      _showSnackBar('Enter license number before verification.');
      return;
    }

    setState(() {
      _data.licenseVerified = true;
    });
  }

  void _verifyNid() {
    if (_nidController.text.trim().isEmpty) {
      _showSnackBar('Enter NID number before verification.');
      return;
    }

    setState(() {
      _data.nidVerified = true;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateRegistrationStep() {
    final bool isFormValid =
        _registrationFormKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return false;
    }

    if (!_data.licenseVerified || !_data.nidVerified) {
      _showSnackBar('Verify both license and NID to continue.');
      return false;
    }

    _data
      ..fullName = _fullNameController.text.trim()
      ..phone = _phoneController.text.trim()
      ..email = _emailController.text.trim()
      ..licenseNumber = _licenseController.text.trim()
      ..nidNumber = _nidController.text.trim();

    return true;
  }

  bool _validateVehicleStep() {
    if (!_data.hasVehicle) {
      _data
        ..vehicleBrand = ''
        ..vehicleModel = ''
        ..vehiclePlate = ''
        ..vehicleYear = '';
      return true;
    }

    final bool isFormValid = _vehicleFormKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return false;
    }

    _data
      ..vehicleBrand = _vehicleBrandController.text.trim()
      ..vehicleModel = _vehicleModelController.text.trim()
      ..vehiclePlate = _vehiclePlateController.text.trim()
      ..vehicleYear = _vehicleYearController.text.trim();

    return true;
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_validateRegistrationStep()) {
        setState(() {
          _currentStep = 1;
        });
      }
      return;
    }

    if (_validateVehicleStep()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DriverAvailabilityPage(driverName: _data.fullName),
        ),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DriverThemePalette.themed(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Driver Onboarding')),
        body: DriverThemePalette.withBackground(
          child: SafeArea(
            child: Stepper(
              currentStep: _currentStep,
              onStepTapped: (value) {
                if (value <= _currentStep) {
                  setState(() {
                    _currentStep = value;
                  });
                }
              },
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(140, 52),
                        ),
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == 0
                              ? 'Continue'
                              : 'Submit Onboarding',
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(140, 52),
                        ),
                        onPressed: details.onStepCancel,
                        child: Text(_currentStep == 0 ? 'Back' : 'Previous'),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Registration'),
                  subtitle: const Text('License + NID verification'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: DriverRegistrationForm(
                    formKey: _registrationFormKey,
                    fullNameController: _fullNameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    licenseController: _licenseController,
                    nidController: _nidController,
                    licenseVerified: _data.licenseVerified,
                    nidVerified: _data.nidVerified,
                    onVerifyLicense: _verifyLicense,
                    onVerifyNid: _verifyNid,
                    onLicenseChanged: (_) {
                      if (_data.licenseVerified) {
                        setState(() {
                          _data.licenseVerified = false;
                        });
                      }
                    },
                    onNidChanged: (_) {
                      if (_data.nidVerified) {
                        setState(() {
                          _data.nidVerified = false;
                        });
                      }
                    },
                  ),
                ),
                Step(
                  title: const Text('Vehicle Information'),
                  subtitle: const Text('If applicable'),
                  isActive: _currentStep >= 1,
                  state: _currentStep == 1
                      ? StepState.indexed
                      : StepState.disabled,
                  content: VehicleInformationForm(
                    formKey: _vehicleFormKey,
                    hasVehicle: _data.hasVehicle,
                    vehicleType: _data.vehicleType,
                    brandController: _vehicleBrandController,
                    modelController: _vehicleModelController,
                    plateController: _vehiclePlateController,
                    yearController: _vehicleYearController,
                    onHasVehicleChanged: (value) {
                      setState(() {
                        _data.hasVehicle = value;
                      });
                    },
                    onVehicleTypeChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _data.vehicleType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
