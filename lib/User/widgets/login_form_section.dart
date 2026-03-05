import 'package:flutter/material.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onToggleRememberMe,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final ValueChanged<bool> onToggleRememberMe;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Login',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            //child: Text(
            //'Same login for riders and admins',
            // style: TextStyle(color: Color(0xFF61666A), fontSize: 13),
            // ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: usernameController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) => onToggleRememberMe(value ?? false),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1C6E57),
                  overlayColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.2,
                  ),
                ),
                onPressed: () {},
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: onLogin, child: const Text('Log in')),
        ],
      ),
    );
  }
}
