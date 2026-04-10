import 'package:appmobile/widgets/login_form.dart';
import 'package:appmobile/widgets/login_logo.dart';
import 'package:appmobile/widgets/social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:appmobile/widgets/login_logo.dart';
import 'package:appmobile/widgets/login_form.dart';
import 'package:appmobile/widgets/social_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  LoginLogo(),
                  SizedBox(height: 32),
                  WelcomeTitle(),
                  SizedBox(height: 48),
                  LoginForm(),
                  SizedBox(height: 20),
                  SocialButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}