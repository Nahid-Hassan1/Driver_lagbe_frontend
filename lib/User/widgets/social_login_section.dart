import 'package:flutter/material.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    required this.onGoogleTap,
    required this.onOtpTap,
  });

  final VoidCallback onGoogleTap;
  final VoidCallback onOtpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'or continue with',
            style: TextStyle(color: Color(0xFF61666A)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onGoogleTap,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onOtpTap,
            icon: const Icon(Icons.sms_outlined),
            label: const Text('Continue with OTP'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }
}
