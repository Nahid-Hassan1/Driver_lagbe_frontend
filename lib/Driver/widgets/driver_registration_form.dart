import 'package:flutter/material.dart';

import '../theme/driver_theme.dart';
import 'document_verification_field.dart';

class DriverRegistrationForm extends StatelessWidget {
  const DriverRegistrationForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.emailController,
    required this.licenseController,
    required this.nidController,
    required this.licenseVerified,
    required this.nidVerified,
    required this.onVerifyLicense,
    required this.onVerifyNid,
    required this.onLicenseChanged,
    required this.onNidChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController licenseController;
  final TextEditingController nidController;
  final bool licenseVerified;
  final bool nidVerified;
  final VoidCallback onVerifyLicense;
  final VoidCallback onVerifyNid;
  final ValueChanged<String> onLicenseChanged;
  final ValueChanged<String> onNidChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete basic registration before you can go live.',
            style: TextStyle(color: DriverThemePalette.textMuted),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+880 1XXXXXXXXX',
              prefixIcon: Icon(Icons.phone_android_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DocumentVerificationField(
            controller: licenseController,
            label: 'Driving License Number',
            hint: 'DL-XXXXXXXX',
            icon: Icons.badge_outlined,
            verified: licenseVerified,
            onVerify: onVerifyLicense,
            onChanged: onLicenseChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Driving license number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DocumentVerificationField(
            controller: nidController,
            label: 'NID Number',
            hint: '10-17 digit NID',
            icon: Icons.credit_card_outlined,
            verified: nidVerified,
            onVerify: onVerifyNid,
            onChanged: onNidChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'NID number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
