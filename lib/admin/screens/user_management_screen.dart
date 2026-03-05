import 'package:flutter/material.dart';

import '../models/admin_user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  AdminUserType _selectedType = AdminUserType.customer;

  final List<AdminUser> _users = <AdminUser>[
    AdminUser(
      id: 'CU-1091',
      name: 'Tanvir Ahmed',
      phone: '+8801700112233',
      type: AdminUserType.customer,
      joinedOn: DateTime(2026, 1, 17),
    ),
    AdminUser(
      id: 'CU-1092',
      name: 'Rakib Hossain',
      phone: '+8801711002233',
      type: AdminUserType.customer,
      joinedOn: DateTime(2026, 2, 10),
    ),
    AdminUser(
      id: 'DR-4021',
      name: 'Mehedi Hasan',
      phone: '+8801810102233',
      type: AdminUserType.driver,
      status: DriverVerificationStatus.pending,
      joinedOn: DateTime(2026, 2, 25),
    ),
    AdminUser(
      id: 'DR-4022',
      name: 'Sabbir Rahman',
      phone: '+8801911102233',
      type: AdminUserType.driver,
      status: DriverVerificationStatus.approved,
      joinedOn: DateTime(2026, 1, 12),
    ),
    AdminUser(
      id: 'DR-4023',
      name: 'Imran Khan',
      phone: '+8801612102233',
      type: AdminUserType.driver,
      status: DriverVerificationStatus.rejected,
      joinedOn: DateTime(2025, 12, 30),
    ),
  ];

  List<AdminUser> get _visibleUsers {
    return _users
        .where((AdminUser user) => user.type == _selectedType)
        .toList(growable: false);
  }

  void _updateDriverStatus(String id, DriverVerificationStatus status) {
    setState(() {
      final int index = _users.indexWhere((AdminUser user) => user.id == id);
      if (index < 0) {
        return;
      }
      _users[index] = _users[index].copyWith(status: status);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<AdminUserType>(
                  segments: const <ButtonSegment<AdminUserType>>[
                    ButtonSegment<AdminUserType>(
                      value: AdminUserType.customer,
                      label: Text('Customers'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment<AdminUserType>(
                      value: AdminUserType.driver,
                      label: Text('Drivers'),
                      icon: Icon(Icons.directions_car_outlined),
                    ),
                  ],
                  selected: <AdminUserType>{_selectedType},
                  onSelectionChanged: (Set<AdminUserType> value) {
                    setState(() {
                      _selectedType = value.first;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _visibleUsers.isEmpty
              ? const Center(child: Text('No users found for this section.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _visibleUsers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final AdminUser user = _visibleUsers[index];
                    return Card(
                      elevation: 0,
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
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.statusColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    user.isDriver ? user.statusLabel : 'Active',
                                    style: TextStyle(
                                      color: user.statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.typeLabel} • ${user.id}',
                              style: const TextStyle(
                                color: Color(0xFF61666A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone,
                              style: const TextStyle(
                                color: Color(0xFF40464D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Joined: ${_formatDate(user.joinedOn)}',
                              style: const TextStyle(color: Color(0xFF61666A)),
                            ),
                            if (user.isDriver &&
                                user.status ==
                                    DriverVerificationStatus.pending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _updateDriverStatus(
                                          user.id,
                                          DriverVerificationStatus.rejected,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFC5221F,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFC5221F),
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateDriverStatus(
                                          user.id,
                                          DriverVerificationStatus.approved,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1E8E3E,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
