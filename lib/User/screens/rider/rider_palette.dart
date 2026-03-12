import 'package:flutter/material.dart';

const Color riderBlack = Color(0xFF000000);
const Color riderBackground = Color(0xFF080808);
const Color riderSurface = Color(0xFF111111);
const Color riderSurfaceAlt = Color(0xFF171717);
const Color riderSurfaceRaised = Color(0xFF1F1F1F);
const Color riderBorder = Color(0xFF2B2B2B);
const Color riderBorderStrong = Color(0xFF4A4A4A);
const Color riderTextPrimary = Colors.white;
const Color riderTextSecondary = Color(0xFFB8B8B8);
const Color riderTextMuted = Color(0xFF8C8C8C);
const Color riderAccent = Colors.white;
const Color riderAccentSoft = Color(0xFFEDEDED);
const Color riderAccentText = Colors.black;
const Color riderOverlay = Color(0xD9121212);
const Color riderShadow = Color(0x22000000);

Color riderStatusColor(String statusLabel) {
  switch (statusLabel) {
    case 'Requested':
      return const Color(0xFFE0E0E0);
    case 'Ongoing':
      return riderAccent;
    case 'Cancelled':
      return const Color(0xFF5E5E5E);
    default:
      return const Color(0xFFBDBDBD);
  }
}

BoxDecoration riderCardDecoration({
  double radius = 16,
  bool raised = false,
}) {
  return BoxDecoration(
    color: raised ? riderSurfaceRaised : riderSurface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: raised ? riderBorderStrong : riderBorder),
    boxShadow: const [
      BoxShadow(
        color: riderShadow,
        blurRadius: 10,
        offset: Offset(0, 6),
      ),
    ],
  );
}
