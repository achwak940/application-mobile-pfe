
import 'package:flutter/material.dart';

class SocialButtons extends StatefulWidget {
  const SocialButtons({super.key});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  void _showSocialLoginMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => _showSocialLoginMessage('Google'),
          icon: Image.network(
            'https://img.icons8.com/color/24/google-logo.png',
            height: 24,
            width: 24,
          ),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showSocialLoginMessage('Apple'),
          icon: const Icon(Icons.apple, size: 24),
          label: const Text('Continue with Apple'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: navigateToRegister,
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
