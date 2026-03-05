import 'package:flutter/material.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  bool _pushNotificationsEnabled = true;

  final List<_PromoOfferItem> _offers = <_PromoOfferItem>[
    const _PromoOfferItem(
      code: 'RIDE10',
      title: '10% Off on City Rides',
      status: 'Active',
    ),
    const _PromoOfferItem(
      code: 'NEW50',
      title: 'BDT 50 Off for New Users',
      status: 'Scheduled',
    ),
    const _PromoOfferItem(
      code: 'WEEKEND25',
      title: 'Weekend Offer - BDT 25 Off',
      status: 'Expired',
    ),
  ];

  void _showUpdateMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        Card(
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
                    color: const Color(0xFF1558B0).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF1558B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Enable or pause broadcast notifications.',
                        style: TextStyle(
                          color: Color(0xFF61666A),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _pushNotificationsEnabled
                              ? 'Notifications are enabled'
                              : 'Notifications are paused',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _pushNotificationsEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _pushNotificationsEnabled = value;
                          });
                          _showUpdateMessage(
                            value
                                ? 'Push notifications enabled'
                                : 'Push notifications paused',
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _pushNotificationsEnabled
                              ? () => _showUpdateMessage(
                                    'Notification campaign sent to users',
                                  )
                              : null,
                          icon: const Icon(Icons.send_outlined, size: 18),
                          label: const Text('Send Notification'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Promo Codes & Offers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ..._offers.map((item) {
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
                          item.code,
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
                          color: item.statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(color: Color(0xFF40464D)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            _showUpdateMessage('Edited offer: ${item.code}'),
                        child: const Text('Edit'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            _showUpdateMessage('Shared offer: ${item.code}'),
                        child: const Text('Share'),
                      ),
                    ],
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

class _PromoOfferItem {
  const _PromoOfferItem({
    required this.code,
    required this.title,
    required this.status,
  });

  final String code;
  final String title;
  final String status;

  Color get statusColor {
    switch (status) {
      case 'Active':
        return const Color(0xFF1E8E3E);
      case 'Scheduled':
        return const Color(0xFF1558B0);
      default:
        return const Color(0xFFC5221F);
    }
  }
}
