import 'package:flutter/material.dart';

import '../theme/driver_theme.dart';

class DocumentVerificationField extends StatelessWidget {
  const DocumentVerificationField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.verified,
    required this.onVerify,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool verified;
  final VoidCallback onVerify;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  static const Color _verifiedColor = Color(0xFF06C167);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: verified
                ? const Icon(
                    Icons.verified_rounded,
                    color: _verifiedColor,
                  )
                : const Icon(Icons.pending_actions_outlined),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: verified
                  ? _verifiedColor
                  : DriverThemePalette.textPrimary,
              side: BorderSide(
                color: verified
                    ? _verifiedColor
                    : DriverThemePalette.border,
              ),
            ),
            onPressed: onVerify,
            icon: Icon(
              verified ? Icons.check_circle_outline_rounded : Icons.badge_outlined,
            ),
            label: Text(verified ? 'Verified' : 'Verify Document'),
          ),
        ),
      ],
    );
  }
}
