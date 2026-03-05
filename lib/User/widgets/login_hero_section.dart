import 'package:flutter/material.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1011), Color(0xFF25282B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Lagbe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find a verified driver whenever you need one.',
            style: TextStyle(
              color: Color(0xFFD5D8DB),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
