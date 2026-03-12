import 'package:flutter/material.dart';

import 'booking_models.dart';
import '../rider_palette.dart';

Future<PaymentMethodType?> showPaymentMethodSheet({
  required BuildContext context,
  required PaymentMethodType selectedMethod,
}) {
  PaymentMethodType tempSelection = selectedMethod;

  return showModalBottomSheet<PaymentMethodType>(
    context: context,
    backgroundColor: riderBlack,
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
                  'Select payment method',
                  style: TextStyle(
                    color: riderTextPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pay with cash or digital wallet/card.',
                  style: TextStyle(color: riderTextSecondary, fontSize: 14.5),
                ),
                const SizedBox(height: 14),
                ...PaymentMethodType.values.map((method) {
                  final bool selected = tempSelection == method;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selected ? riderSurfaceRaised : riderSurfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? riderAccent
                            : riderBorder,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: riderShadow,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () => setModalState(() => tempSelection = method),
                      leading: Icon(
                        method.icon,
                        color: riderAccentSoft,
                      ),
                      title: Text(
                        method.label,
                        style: const TextStyle(
                          color: riderTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        method.isDigital ? 'Digital payment' : 'Pay by cash',
                        style: const TextStyle(color: riderTextSecondary),
                      ),
                      trailing: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? riderAccent
                            : riderTextMuted,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(tempSelection),
                    style: FilledButton.styleFrom(
                      backgroundColor: riderAccent,
                      foregroundColor: riderAccentText,
                    ),
                    child: const Text('Apply payment method'),
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

Future<void> showBookingInvoiceSheet({
  required BuildContext context,
  required BookingRequest booking,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: riderBlack,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final FareBreakdown fare = booking.fareBreakdown;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice #INV-${booking.id}',
                  style: const TextStyle(
                    color: riderTextPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${booking.pickupLocation} -> ${booking.dropOffLocation}',
                  style: const TextStyle(
                    color: riderTextSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 16),
                _InvoiceRow(label: 'Base fare', amount: fare.baseFare),
                _InvoiceRow(label: 'Distance fare', amount: fare.distanceFare),
                _InvoiceRow(label: 'Service fee', amount: fare.serviceFee),
                _InvoiceRow(
                  label: 'Search surcharge',
                  amount: fare.driverSearchSurcharge,
                ),
                _InvoiceRow(
                  label: 'Scheduling fee',
                  amount: fare.schedulingFee,
                ),
                _InvoiceRow(
                  label: 'Discount',
                  amount: -fare.discount,
                  negative: true,
                ),
                const Divider(color: riderBorder),
                _InvoiceRow(
                  label: 'Total paid',
                  amount: fare.totalBdt,
                  emphasize: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      booking.paymentMethod.icon,
                      color: riderAccentSoft,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment: ${booking.paymentMethod.label}',
                      style: const TextStyle(
                        color: riderTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: riderAccent,
                      foregroundColor: riderAccentText,
                    ),
                    child: const Text('Close invoice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.amount,
    this.negative = false,
    this.emphasize = false,
  });

  final String label;
  final int amount;
  final bool negative;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final Color textColor = emphasize ? riderTextPrimary : riderTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: emphasize ? 16 : 14,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${negative ? '-' : ''}BDT ${amount.abs()}',
            style: TextStyle(
              color: negative ? riderTextMuted : textColor,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
