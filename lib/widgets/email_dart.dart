import 'package:flutter/material.dart';

class EmailField extends StatefulWidget {
  final TextEditingController controller;
  
  const EmailField({super.key, required this.controller});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> with SingleTickerProviderStateMixin {
  String? _errorText;
  late AnimationController _shakeController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _triggerShake() {
    _shakeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _shakeController.reset());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(5 * _shakeController.value, 0),
          child: child,
        );
      },
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          final error = _validateEmail(value);
          if (error != null && _errorText == null) _triggerShake();
          return error;
        },
        onChanged: (_) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
        onTap: () => setState(() => _isFocused = true),
        onEditingComplete: () => setState(() => _isFocused = false),
        decoration: InputDecoration(
          labelText: 'Email Address',
          hintText: 'you@example.com',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: _isFocused ? Colors.deepPurple.shade700 : Colors.grey.shade500,
          ),
          labelStyle: TextStyle(
            color: _isFocused ? Colors.deepPurple.shade700 : Colors.grey.shade600,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
          errorText: _errorText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
          ),
        ),
      ),
    );
  }
}