import 'package:flutter/material.dart';

class RiderServicesTab extends StatefulWidget {
  const RiderServicesTab({super.key});

  @override
  State<RiderServicesTab> createState() => _RiderServicesTabState();
}

class _RiderServicesTabState extends State<RiderServicesTab> {
  String _selectedScope = 'All';
  bool _showPromo = true;

  void _showFeatureSheet(String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0F1A1E),
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
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFB2C2CC),
                  fontSize: 15,
                ),
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
              'Services Hub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Move people, parcels, and plans from one place.',
              style: TextStyle(
                color: Color(0xFFB0C5CF),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            _ServiceSearchBox(
              onTap: () => _showFeatureSheet(
                'Search service',
                'Search for any ride, delivery, or rental service.',
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
            _ServiceCardsGrid(onTap: (title) {
              _showFeatureSheet(
                title,
                'Open $title and continue with details.',
              );
            }),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Service planner'),
            const SizedBox(height: 12),
            _PlannerCard(
              onPlanTap: () => _showFeatureSheet(
                'Plan a multi-stop trip',
                'Create one route for pickup, errands, and return.',
              ),
              onRouteTap: () => _showFeatureSheet(
                'Save route',
                'Store this route for one-tap booking later.',
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
                  'Bundle Offer',
                  'Unlock 3 ride coupons and 1 parcel coupon this week.',
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
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ServiceSearchBox extends StatelessWidget {
  const _ServiceSearchBox({required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16303A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E505C)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Color(0xFFAAD7E5)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'What can we move today?',
                  style: TextStyle(
                    color: Color(0xFFD2EAF2),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: Color(0xFFAAD7E5)),
            ],
          ),
        ),
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
    const scopes = ['All', 'Ride', 'Parcel', 'Rental'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: scopes.map((scope) {
        final selected = scope == selectedScope;
        return Material(
          color: selected ? const Color(0xFF2AE0A0) : const Color(0xFF15272F),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => onTap(scope),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                scope,
                style: TextStyle(
                  color: selected ? const Color(0xFF062219) : const Color(0xFFCAE2EB),
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
  const _ServiceCardsGrid({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <_ServiceItem>[
      _ServiceItem(
        title: 'City Ride',
        subtitle: 'Affordable daily trips',
        icon: Icons.local_taxi_rounded,
        colors: [Color(0xFF2668D8), Color(0xFF173A79)],
      ),
      _ServiceItem(
        title: 'Parcel Express',
        subtitle: 'Fast pickup and drop',
        icon: Icons.inventory_2_rounded,
        colors: [Color(0xFF00A978), Color(0xFF0C6A50)],
      ),
      _ServiceItem(
        title: 'Airport Transfer',
        subtitle: 'On-time airport rides',
        icon: Icons.flight_takeoff_rounded,
        colors: [Color(0xFF7046C9), Color(0xFF452B83)],
      ),
      _ServiceItem(
        title: 'Hourly Rental',
        subtitle: 'Keep a driver for hours',
        icon: Icons.timelapse_rounded,
        colors: [Color(0xFF945022), Color(0xFF5E3215)],
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
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
                      color: Color(0x33000000),
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFE8F2FF),
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
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

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
        color: const Color(0xFF152830),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2C4651)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onPlanTap,
            leading: const Icon(Icons.route_rounded, color: Color(0xFF8FE6FF)),
            title: const Text(
              'Plan a multi-stop trip',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Work, errands, and return in one booking',
              style: TextStyle(color: Color(0xFFB8CED7)),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8CED7)),
          ),
          const Divider(height: 1, color: Color(0xFF2C4651)),
          ListTile(
            onTap: onRouteTap,
            leading: const Icon(Icons.bookmark_add_outlined, color: Color(0xFF8FE6FF)),
            title: const Text(
              'Save this route',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Reuse your favorite route anytime',
              style: TextStyle(color: Color(0xFFB8CED7)),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8CED7)),
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
      (Icons.shield_outlined, 'Safety'),
      (Icons.support_agent_outlined, 'Support'),
      (Icons.schedule_send_outlined, 'Schedule'),
      (Icons.receipt_long_rounded, 'Invoices'),
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
                onTap: () => onTap(item.$2),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(item.$1, color: const Color(0xFF8FE6FF)),
                      const SizedBox(height: 6),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: Color(0xFFD5EAF2),
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00A978), Color(0xFF1A7FA0)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Deal: 3 Rides + 1 Parcel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Limited for this week only',
                      style: TextStyle(color: Color(0xFFDFF8FF)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
