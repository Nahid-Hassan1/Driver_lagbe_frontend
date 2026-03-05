import 'package:flutter/material.dart';

import '../widgets/role_selector_card.dart';
import 'package:driver_lagbe/Driver/screens/driver_onboarding_page.dart';
import 'rider_signup_page.dart';

class SignupRolePage extends StatelessWidget {
  const SignupRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Account Type')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you a driver or a rider?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick one option to continue to the right sign up form.',
                style: TextStyle(
                  color: Color(0xFF61666A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              RoleSelectorCard(
                icon: Icons.person_pin_circle_outlined,
                title: 'I am a Rider',
                subtitle: 'Book a trusted driver for your car and trips.',
                accent: const Color(0xFF0B84F3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RiderSignupPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              RoleSelectorCard(
                icon: Icons.directions_car_filled_outlined,
                title: 'I am a Driver',
                subtitle: 'Offer driving service and earn from bookings.',
                accent: const Color(0xFF06C167),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DriverOnboardingPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
