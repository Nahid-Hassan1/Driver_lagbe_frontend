import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'screens/admin_login_page.dart';

class DriverLagbeAdminApp extends StatelessWidget {
  const DriverLagbeAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver Lagbe Admin',
      theme: AppTheme.lightTheme,
      home: const AdminLoginPage(),
    );
  }
}
