import 'package:flutter/material.dart';

import 'booking_models.dart';

Future<PaymentMethodType?> showPaymentMethodSheet({
  required BuildContext context,
  required PaymentMethodType selectedMethod,
}) {
  PaymentMethodType tempSelection = selectedMethod;

  return showModalBottomSheet<PaymentMethodType>(
    context: context,
    backgroundColor: const Color(0xFF0F1A1E),
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pay with cash or digital wallet/card.',
                  style: TextStyle(color: Color(0xFFB2C2CC), fontSize: 14.5),
                ),
                const SizedBox(height: 14),
                ...PaymentMethodType.values.map((method) {
                  final bool selected = tempSelection == method;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1F4B4B)
                          : const Color(0xFF162830),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2AE0A0)
                            : const Color(0xFF2B4450),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () => setModalState(() => tempSelection = method),
                      leading: Icon(
                        method.icon,
                        color: const Color(0xFFBEE3F1),
                      ),
                      title: Text(
                        method.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        method.isDigital ? 'Digital payment' : 'Pay by cash',
                        style: const TextStyle(color: Color(0xFF9EB4BE)),
                      ),
                      trailing: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected
                            ? const Color(0xFF2AE0A0)
                            : const Color(0xFF7F9AA6),
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
                      backgroundColor: const Color(0xFF2AE0A0),
                      foregroundColor: const Color(0xFF0A1814),
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
    backgroundColor: const Color(0xFF0F1A1E),
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${booking.pickupLocation} -> ${booking.dropOffLocation}',
                  style: const TextStyle(
                    color: Color(0xFFB7CAD3),
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
                const Divider(color: Color(0xFF2A434E)),
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
                      color: const Color(0xFF8FE6FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment: ${booking.paymentMethod.label}',
                      style: const TextStyle(
                        color: Color(0xFFD4EAF4),
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
                      backgroundColor: const Color(0xFF2AE0A0),
                      foregroundColor: const Color(0xFF0A1814),
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
    final Color textColor = emphasize ? Colors.white : const Color(0xFFD4EAF4);
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
              color: negative ? const Color(0xFF9CF2B8) : textColor,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
