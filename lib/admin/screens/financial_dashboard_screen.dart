import 'package:flutter/material.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  final List<_DriverEarning> _driverEarnings = <_DriverEarning>[
    const _DriverEarning(driverName: 'Sabbir Rahman', amount: 28500),
    const _DriverEarning(driverName: 'Farhan Karim', amount: 24120),
    const _DriverEarning(driverName: 'Tariq Hossain', amount: 21980),
    const _DriverEarning(driverName: 'Mehedi Hasan', amount: 19840),
  ];

  final List<_PaymentSettlement> _settlements = <_PaymentSettlement>[
    const _PaymentSettlement(
      id: 'SET-1101',
      recipient: 'Sabbir Rahman',
      amount: 8400,
      status: _SettlementStatus.pending,
    ),
    const _PaymentSettlement(
      id: 'SET-1102',
      recipient: 'Farhan Karim',
      amount: 7600,
      status: _SettlementStatus.settled,
    ),
    const _PaymentSettlement(
      id: 'SET-1103',
      recipient: 'Tariq Hossain',
      amount: 6900,
      status: _SettlementStatus.pending,
    ),
  ];

  double get _totalRevenue => 213450;

  double get _totalDriverEarnings {
    return _driverEarnings.fold<double>(
      0,
      (double previousValue, _DriverEarning item) =>
          previousValue + item.amount,
    );
  }

  double get _totalPendingSettlements {
    return _settlements
        .where((item) => item.status == _SettlementStatus.pending)
        .fold<double>(
          0,
          (double previousValue, _PaymentSettlement item) =>
              previousValue + item.amount,
        );
  }

  String _formatBdt(double amount) {
    return 'BDT ${amount.toStringAsFixed(0)}';
  }

  void _markSettled(String id) {
    setState(() {
      final int index = _settlements.indexWhere((item) => item.id == id);
      if (index < 0) {
        return;
      }
      _settlements[index] = _settlements[index].copyWith(
        status: _SettlementStatus.settled,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settlement marked complete: $id')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        _SummaryCard(
          title: 'Total Revenue',
          value: _formatBdt(_totalRevenue),
          subtitle: 'All completed booking income',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF1558B0),
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          title: 'Driver Earnings',
          value: _formatBdt(_totalDriverEarnings),
          subtitle: 'Total payable to drivers',
          icon: Icons.payments_outlined,
          color: const Color(0xFF1E8E3E),
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          title: 'Pending Settlements',
          value: _formatBdt(_totalPendingSettlements),
          subtitle: 'Amount waiting for payout',
          icon: Icons.pending_actions_outlined,
          color: const Color(0xFFC17A00),
        ),
        const SizedBox(height: 16),
        const Text(
          'Driver Earnings Breakdown',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE3E6EA)),
          ),
          child: ListView.separated(
            itemCount: _driverEarnings.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final _DriverEarning item = _driverEarnings[index];
              return ListTile(
                dense: true,
                title: Text(
                  item.driverName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  _formatBdt(item.amount),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Payment Settlements',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ..._settlements.map((item) {
          final bool isPending = item.status == _SettlementStatus.pending;
          final Color statusColor = isPending
              ? const Color(0xFFC17A00)
              : const Color(0xFF1E8E3E);
          final String statusText = isPending ? 'Pending' : 'Settled';
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE3E6EA)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.id,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recipient: ${item.recipient}',
                    style: const TextStyle(color: Color(0xFF40464D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ${_formatBdt(item.amount)}',
                    style: const TextStyle(color: Color(0xFF40464D)),
                  ),
                  const SizedBox(height: 10),
                  if (isPending)
                    OutlinedButton.icon(
                      onPressed: () => _markSettled(item.id),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark as Settled'),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE3E6EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF61666A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF61666A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SettlementStatus { pending, settled }

class _DriverEarning {
  const _DriverEarning({
    required this.driverName,
    required this.amount,
  });

  final String driverName;
  final double amount;
}

class _PaymentSettlement {
  const _PaymentSettlement({
    required this.id,
    required this.recipient,
    required this.amount,
    this.status = _SettlementStatus.pending,
  });

  final String id;
  final String recipient;
  final double amount;
  final _SettlementStatus status;

  _PaymentSettlement copyWith({
    _SettlementStatus? status,
  }) {
    return _PaymentSettlement(
      id: id,
      recipient: recipient,
      amount: amount,
      status: status ?? this.status,
    );
  }
}
