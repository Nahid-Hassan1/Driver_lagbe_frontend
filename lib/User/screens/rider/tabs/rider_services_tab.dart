import 'package:flutter/material.dart';
import '../rider_palette.dart';

class RiderServicesTab extends StatefulWidget {
  const RiderServicesTab({super.key});

  @override
  State<RiderServicesTab> createState() => _RiderServicesTabState();
}

class _RiderServicesTabState extends State<RiderServicesTab> {
  String _selectedScope = 'Parcel';
  bool _showPromo = true;

  void _showFeatureSheet(String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: riderBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: riderTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: riderTextSecondary,
                  fontSize: 15,
                ),
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
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [riderBlack, riderBackground, riderBlack],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          children: [
            const Text(
              'Parcel & Rental',
              style: TextStyle(
                color: riderTextPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Send parcels or reserve a driver for hourly and day rentals.',
              style: TextStyle(
                color: riderTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            _ScopeChips(
              selectedScope: _selectedScope,
              onTap: (scope) {
                setState(() => _selectedScope = scope);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$scope filter enabled')),
                );
              },
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Popular services'),
            const SizedBox(height: 12),
            _ServiceCardsGrid(
              selectedScope: _selectedScope,
              onTap: (title) {
              _showFeatureSheet(
                title,
                'Open $title and continue with details.',
              );
            }),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Booking planner'),
            const SizedBox(height: 12),
            _PlannerCard(
              onPlanTap: () => _showFeatureSheet(
                'Plan a parcel pickup',
                'Set pickup time, recipient details, and drop instructions.',
              ),
              onRouteTap: () => _showFeatureSheet(
                'Reserve a rental slot',
                'Choose hours, coverage area, and the type of rental you need.',
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Quick tools'),
            const SizedBox(height: 12),
            _QuickToolsRow(
              onTap: (tool) => _showFeatureSheet(
                tool,
                'Open $tool and continue setup.',
              ),
            ),
            if (_showPromo) ...[
              const SizedBox(height: 20),
              _PromoBanner(
                onTap: () => _showFeatureSheet(
                  'Parcel & Rental Offer',
                  'Unlock one parcel discount and one rental upgrade this week.',
                ),
                onClose: () => setState(() => _showPromo = false),
              ),
            ],
          ],
        ),
      ),
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
        color: riderTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({
    required this.selectedScope,
    required this.onTap,
  });

  final String selectedScope;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const scopes = ['Parcel', 'Rental'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: scopes.map((scope) {
        final selected = scope == selectedScope;
        return Material(
          color: selected ? riderAccent : riderSurfaceAlt,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => onTap(scope),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                scope,
                style: TextStyle(
                  color: selected ? riderAccentText : riderTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ServiceCardsGrid extends StatelessWidget {
  const _ServiceCardsGrid({
    required this.selectedScope,
    required this.onTap,
  });

  final String selectedScope;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <_ServiceItem>[
      _ServiceItem(
        scope: 'Parcel',
        title: 'Parcel Express',
        subtitle: 'Fast document and small package delivery',
        icon: Icons.inventory_2_rounded,
        colors: [riderSurfaceRaised, riderSurfaceAlt],
      ),
      _ServiceItem(
        scope: 'Parcel',
        title: 'Fragile Parcel',
        subtitle: 'Extra handling for delicate items',
        icon: Icons.widgets_outlined,
        colors: [riderSurfaceRaised, riderSurfaceAlt],
      ),
      _ServiceItem(
        scope: 'Rental',
        title: 'Hourly Rental',
        subtitle: 'Keep a driver for city errands and meetings',
        icon: Icons.timelapse_rounded,
        colors: [riderSurfaceRaised, riderSurfaceAlt],
      ),
      _ServiceItem(
        scope: 'Rental',
        title: 'Day Rental',
        subtitle: 'Reserve a full-day driver for planned travel',
        icon: Icons.calendar_today_rounded,
        colors: [riderSurfaceRaised, riderSurfaceAlt],
      ),
    ];
    final List<_ServiceItem> filtered = items
        .where((item) => item.scope == selectedScope)
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: filtered.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onTap(item.title),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.colors,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: riderShadow,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, color: Colors.white, size: 28),
                    const SizedBox(height: 24),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: riderTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: riderTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.scope,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String scope;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({
    required this.onPlanTap,
    required this.onRouteTap,
  });

  final VoidCallback onPlanTap;
  final VoidCallback onRouteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: riderSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: riderBorder),
        boxShadow: const [
          BoxShadow(
            color: riderShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onPlanTap,
            leading: const Icon(Icons.local_shipping_outlined, color: riderAccentSoft),
            title: const Text(
              'Schedule a parcel pickup',
              style: TextStyle(color: riderTextPrimary, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Choose recipient, delivery notes, and pickup window',
              style: TextStyle(color: riderTextSecondary),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: riderTextSecondary),
          ),
          const Divider(height: 1, color: riderBorder),
          ListTile(
            onTap: onRouteTap,
            leading: const Icon(Icons.car_rental_rounded, color: riderAccentSoft),
            title: const Text(
              'Reserve a rental slot',
              style: TextStyle(color: riderTextPrimary, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Book hourly or full-day coverage in advance',
              style: TextStyle(color: riderTextSecondary),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: riderTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickToolsRow extends StatelessWidget {
  const _QuickToolsRow({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.track_changes_rounded, 'Tracking'),
      (Icons.person_add_alt_1_rounded, 'Recipients'),
      (Icons.schedule_send_outlined, 'Reserve'),
      (Icons.receipt_long_rounded, 'Quotes'),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: riderSurface,
              borderRadius: BorderRadius.circular(14),
              shadowColor: riderShadow,
              elevation: 1.5,
              child: InkWell(
                onTap: () => onTap(item.$2),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(item.$1, color: riderAccentSoft),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: riderTextPrimary,
                          fontWeight: FontWeight.w700,
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.onTap,
    required this.onClose,
  });

  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: riderAccent,
            boxShadow: const [
              BoxShadow(
                color: riderShadow,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: riderAccentText, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Deal: 3 Rides + 1 Parcel',
                      style: TextStyle(
                        color: riderAccentText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Save on one parcel and one rental booking',
                      style: TextStyle(color: Color(0xFF444444)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: riderAccentText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
