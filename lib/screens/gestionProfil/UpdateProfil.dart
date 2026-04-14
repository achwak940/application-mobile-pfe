// screens/profile/profile_edit_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileEditScreen({super.key, required this.userData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  File? _profileImage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _prenomController;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prenomController = TextEditingController(
      text: widget.userData['prenom'] ?? '',
    );
    _nomController = TextEditingController(text: widget.userData['nom'] ?? '');
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData['telephone'] ?? '',
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo mise à jour ! 📸'),
          backgroundColor: Color(0xFF81C784),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Photo de profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        final updatedData = {
          'prenom': _prenomController.text,
          'nom': _nomController.text,
          'email': _emailController.text,
          'telephone': _phoneController.text,
          if (_profileImage != null) 'profileImage': _profileImage,
        };

        Navigator.pop(context, updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès ! ✨'),
            backgroundColor: Color(0xFF81C784),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Image Section
              SlideTransition(
                position: _slideAnimation,
                child: _buildProfileImageSection(),
              ),
              const SizedBox(height: 24),

              // Edit Form Card
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB794F4).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB794F4),
                                    Color(0xFFD4B8FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Informations personnelles',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 20),

                        // Form Fields
                        _buildTextField(
                          controller: _prenomController,
                          label: 'Prénom',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Prénom requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _nomController,
                          label: 'Nom',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nom requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email requis';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Téléphone',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Numéro requis';
                            }
                            if (value.length < 8) {
                              return 'Numéro invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Delete Account Card
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA5A5).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFFFA5A5),
                            size: 22,
                          ),
                        ),
                        title: const Text(
                          'Supprimer le compte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        subtitle: const Text(
                          'Cette action est irréversible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A8A9E),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFFFA5A5),
                            size: 20,
                          ),
                        ),
                        onTap: _showDeleteAccountDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB794F4).withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'profileAvatar',
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (widget.userData.containsKey('profileImage')
                                ? FileImage(widget.userData['profileImage'])
                                : null),
                      child:
                          _profileImage == null &&
                              !widget.userData.containsKey('profileImage')
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB794F4),
                                    Color(0xFFD4B8FF),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB794F4), Color(0xFFD4B8FF)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB794F4).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toucher pour modifier la photo',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFB794F4).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8A8A9E),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFB794F4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFB794F4)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFB794F4), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F4FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
          style: TextStyle(fontSize: 14, color: Color(0xFF8A8A9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF8A8A9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte supprimé avec succès'),
                  backgroundColor: Color(0xFFFFA5A5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA5A5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
