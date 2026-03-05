import 'package:flutter/material.dart';
import 'package:driver_lagbe/admin/screens/admin_page.dart';

import 'signup_role_page.dart';
import 'rider/rider_main_shell_page.dart';
import '../widgets/login_form_section.dart';
import '../widgets/login_hero_section.dart';
import '../widgets/social_login_section.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  static const Map<String, String> _localCredentialStore = <String, String>{
    'admin': 'admin',
    'rider': 'rider',
    'user': 'user',
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    final String username = _usernameController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password')),
      );
      return;
    }

    final String? expectedPassword = _localCredentialStore[username];
    if (expectedPassword == null || expectedPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
      return;
    }

    if (username == 'admin') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AdminPage(),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RiderMainShellPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginHeroSection(),
              const SizedBox(height: 20),
              LoginFormSection(
                usernameController: _usernameController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                rememberMe: _rememberMe,
                onToggleRememberMe: (value) {
                  setState(() => _rememberMe = value);
                },
                onTogglePasswordVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onLogin: _handleLogin,
              ),
              const SizedBox(height: 16),
              SocialLoginSection(
                onGoogleTap: _handleLogin,
                onOtpTap: _handleLogin,
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF63717A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1C6E57),
                        overlayColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.4,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SignupRolePage(),
                          ),
                        );
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
