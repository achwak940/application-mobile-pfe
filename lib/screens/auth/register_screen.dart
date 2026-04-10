import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  File? _profileImage;

  // Controllers
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Photo ajoutée avec succès! 📸'),
            ],
          ),
          backgroundColor: const Color(0xFF7B2F9D),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Photo de profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisissez une option',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      icon: Icons.photo_library,
                      label: 'Galerie',
                      color: const Color(0xFF9C27B0),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    _buildPickerOption(
                      icon: Icons.camera_alt,
                      label: 'Appareil photo',
                      color: const Color(0xFFE1BEE7),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF4A148C))),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Inscription réussie! ✨',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bienvenue dans notre communauté',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Commencer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F4FF), Color(0xFFF3E5F5), Color(0xFFEDE7F6)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Header
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Center(
                        child: Column(
                          children: [
                            // Decorative circles
                            Stack(
                              children: [
                                Positioned(
                                  left: -20,
                                  top: -20,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE1BEE7),
                                          Colors.transparent,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9C27B0),
                                        Color(0xFFCE93D8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Commençons l\'aventure',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A148C),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Créez votre compte en quelques secondes ⚡',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple.shade300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Enhanced Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerDialog,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF9C27B0,
                                    ).withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF9C27B0,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFFE1BEE7,
                                          ).withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.white,
                                      ),
                                      image: _profileImage != null
                                          ? DecorationImage(
                                              image: FileImage(_profileImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _profileImage == null
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.camera_alt,
                                                  size: 40,
                                                  color: const Color(
                                                    0xFF9C27B0,
                                                  ).withOpacity(0.6),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Ajouter',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF9C27B0,
                                                    ).withOpacity(0.6),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF9C27B0),
                                            Color(0xFFCE93D8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Photo de profil',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.deepPurple.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1BEE7).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Toucher pour modifier',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF9C27B0).withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Modern Form Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // First Name
                                _buildModernTextField(
                                  controller: _prenomController,
                                  label: 'Prénom',
                                  hint: 'Votre prénom',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Prénom requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Last Name
                                _buildModernTextField(
                                  controller: _nomController,
                                  label: 'Nom',
                                  hint: 'Votre nom',
                                  icon: Icons.badge_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nom requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Email
                                _buildModernTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'exemple@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email requis';
                                    }
                                    if (!value.contains('@') ||
                                        !value.contains('.')) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Phone
                                _buildModernTextField(
                                  controller: _phoneController,
                                  label: 'Téléphone',
                                  hint: '12 345 678',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 8,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Numéro requis';
                                    }
                                    if (value.length != 8) {
                                      return '8 chiffres requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password
                                _buildModernTextField(
                                  controller: _passwordController,
                                  label: 'Mot de passe',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(
                                        0xFF9C27B0,
                                      ).withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Mot de passe requis';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimum 6 caractères';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Confirm Password
                                _buildModernTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmer',
                                  hint: 'Confirmez votre mot de passe',
                                  icon: Icons.lock_outline,
                                  obscureText: !_isConfirmPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(
                                        0xFF9C27B0,
                                      ).withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirmation requise';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Mots de passe différents';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button with Animation
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.95, end: 1),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rocket_launch),
                                      SizedBox(width: 10),
                                      Text(
                                        "S'inscrire",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà membre ?',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9C27B0),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Terms
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: Color(0xFF9C27B0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'En créant un compte, vous acceptez nos ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'conditions',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(color: Color(0xFF4A148C)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF9C27B0).withOpacity(0.7),
          ),
          suffixIcon: suffixIcon,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: const TextStyle(color: Color(0xFF9C27B0)),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        validator: validator,
      ),
    );
  }
}
