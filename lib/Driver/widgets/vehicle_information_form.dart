import 'package:flutter/material.dart';

import '../models/driver_onboarding_data.dart';
import '../theme/driver_theme.dart';

class VehicleInformationForm extends StatelessWidget {
  const VehicleInformationForm({
    super.key,
    required this.formKey,
    required this.hasVehicle,
    required this.vehicleType,
    required this.brandController,
    required this.modelController,
    required this.plateController,
    required this.yearController,
    required this.onHasVehicleChanged,
    required this.onVehicleTypeChanged,
  });

  final GlobalKey<FormState> formKey;
  final bool hasVehicle;
  final String vehicleType;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController plateController;
  final TextEditingController yearController;
  final ValueChanged<bool> onHasVehicleChanged;
  final ValueChanged<String?> onVehicleTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('I have a vehicle to register now'),
            subtitle: const Text(
              'Turn this off to continue without vehicle details.',
              style: TextStyle(color: DriverThemePalette.textMuted),
            ),
            value: hasVehicle,
            onChanged: onHasVehicleChanged,
          ),
          if (!hasVehicle)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'You can add your vehicle later from driver profile settings.',
                style: TextStyle(color: DriverThemePalette.textMuted),
              ),
            ),
          if (hasVehicle) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: vehicleType,
              dropdownColor: DriverThemePalette.surfaceSoft,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
              items: DriverOnboardingData.vehicleTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: onVehicleTypeChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Brand',
                prefixIcon: Icon(Icons.branding_watermark_outlined),
              ),
              validator: (value) {
                if (!hasVehicle) {
                  return null;
                }
                if (value == null || value.trim().isEmpty) {
                  return 'Vehicle brand is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Model',
                prefixIcon: Icon(Icons.directions_car_filled_outlined),
              ),
              validator: (value) {
                if (!hasVehicle) {
                  return null;
                }
                if (value == null || value.trim().isEmpty) {
                  return 'Vehicle model is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'Number Plate',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
              validator: (value) {
                if (!hasVehicle) {
                  return null;
                }
                if (value == null || value.trim().isEmpty) {
                  return 'Number plate is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Manufacturing Year',
                hintText: 'e.g. 2021',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              validator: (value) {
                if (!hasVehicle) {
                  return null;
                }
                if (value == null || value.trim().isEmpty) {
                  return 'Vehicle year is required';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
