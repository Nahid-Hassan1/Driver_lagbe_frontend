import 'package:flutter/material.dart';

import 'package:driver_lagbe/User/booking_confirmation_notification.dart';
import 'package:driver_lagbe/User/driver_arrival_updates_notification.dart';
import 'package:driver_lagbe/User/promo_offers_notification.dart';
import 'package:driver_lagbe/User/trip_start_end_alerts_notification.dart';

class RiderAccountTab extends StatefulWidget {
  const RiderAccountTab({super.key});

  @override
  State<RiderAccountTab> createState() => _RiderAccountTabState();
}

class _RiderAccountTabState extends State<RiderAccountTab> {
  bool _bookingConfirmation = true;
  bool _driverArrivalUpdates = true;
  bool _tripStartEndAlerts = true;
  bool _promoOffers = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1215), Color(0xFF12232B), Color(0xFF070A0B)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          children: [
            const Text(
              'Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage profile, notifications, and ride preferences.',
              style: TextStyle(color: Color(0xFFB0C5CF), fontSize: 14),
            ),
            const SizedBox(height: 14),
            _ProfileHero(onTap: () => _showSimpleSnack('Profile opened')),
            const SizedBox(height: 16),
            _QuickBalanceRow(
              onTap: (title) => _showSimpleSnack('$title opened'),
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Notifications'),
            const SizedBox(height: 10),
            BookingConfirmationNotification(
              value: _bookingConfirmation,
              onChanged: (value) =>
                  setState(() => _bookingConfirmation = value),
            ),
            const SizedBox(height: 8),
            DriverArrivalUpdatesNotification(
              value: _driverArrivalUpdates,
              onChanged: (value) =>
                  setState(() => _driverArrivalUpdates = value),
            ),
            const SizedBox(height: 8),
            TripStartEndAlertsNotification(
              value: _tripStartEndAlerts,
              onChanged: (value) => setState(() => _tripStartEndAlerts = value),
            ),
            const SizedBox(height: 8),
            PromoOffersNotification(
              value: _promoOffers,
              onChanged: (value) => setState(() => _promoOffers = value),
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Manage'),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.wallet_outlined,
              label: 'Payment methods',
              subtitle: 'Cards, mobile wallet, and cash preferences',
              onTap: () => _showSimpleSnack('Payment methods tapped'),
            ),
            _ActionTile(
              icon: Icons.location_on_outlined,
              label: 'Saved places',
              subtitle: 'Home, office, and favorites',
              onTap: () => _showSimpleSnack('Saved places tapped'),
            ),
            _ActionTile(
              icon: Icons.security_outlined,
              label: 'Privacy & safety',
              subtitle: 'Trusted contacts and data controls',
              onTap: () => _showSimpleSnack('Privacy & safety tapped'),
            ),
            _ActionTile(
              icon: Icons.support_agent_outlined,
              label: 'Help center',
              subtitle: 'FAQs, trip issues, and support',
              onTap: () => _showSimpleSnack('Help center tapped'),
            ),
            const SizedBox(height: 14),
            _LogoutButton(onTap: () => _showSimpleSnack('Log out tapped')),
          ],
        ),
      ),
    );
  }

  void _showSimpleSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3B46), Color(0xFF16303A), Color(0xFF10242B)],
            ),
            border: Border.all(color: const Color(0xFF35505A)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33050A0D),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF2AE0A0),
                child: Icon(Icons.person, size: 34, color: Color(0xFF062219)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nahid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '+880 17XXXXXXXX',
                      style: TextStyle(color: Color(0xFFB8CED7), fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Rider Level: Gold',
                      style: TextStyle(
                        color: Color(0xFF8FE6FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFB8CED7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickBalanceRow extends StatelessWidget {
  const _QuickBalanceRow({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <(String, String, IconData)>[
      ('Wallet', 'BDT 860', Icons.account_balance_wallet_outlined),
      ('Points', '2,450', Icons.stars_outlined),
      ('Coupons', '5 active', Icons.local_offer_outlined),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: const Color(0xFF13242B),
              borderRadius: BorderRadius.circular(14),
              shadowColor: const Color(0x33000000),
              elevation: 1.5,
              child: InkWell(
                onTap: () => onTap(item.$1),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      Icon(item.$3, color: const Color(0xFF8FE6FF), size: 20),
                      const SizedBox(height: 6),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: Color(0xFFB7CAD3),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13242B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26424D)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF8FE6FF)),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFB7CAD3), fontSize: 12.5),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFB7CAD3),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3A1B25),
      borderRadius: BorderRadius.circular(14),
      shadowColor: const Color(0x33000000),
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFFC7D6)),
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  color: Color(0xFFFFC7D6),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
