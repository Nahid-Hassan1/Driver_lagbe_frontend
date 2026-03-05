import 'package:flutter/material.dart';

import 'User/screens/login_page.dart';
import 'theme/app_theme.dart';

class DriverLagbeApp extends StatelessWidget {
  const DriverLagbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver Lagbe',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
