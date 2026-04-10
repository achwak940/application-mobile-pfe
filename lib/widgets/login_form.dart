import 'package:appmobile/dialogs/forgot_password_dialog.dart';
import 'package:appmobile/dialogs/success_dialog.dart';
import 'package:appmobile/widgets/login_button.dart';
import 'package:appmobile/dialogs/password_field.dart';
import 'package:flutter/material.dart';
import '../dialogs/password_field.dart';
import './login_button.dart';
import '../dialogs/success_dialog.dart';
import '../dialogs/forgot_password_dialog.dart';

import 'email_dart.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              onContinue: () {
                _emailController.clear();
                _passwordController.clear();
              },
            ),
          );
        }
      });
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailField(controller: _emailController),
          const SizedBox(height: 20),
          PasswordField(controller: _passwordController),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LoginButton(
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 20),
          const _DividerWithText(),
        ],
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey[600])),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}