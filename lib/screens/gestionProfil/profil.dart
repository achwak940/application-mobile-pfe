// screens/profile/profile_consultation_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appmobile/screens/gestionProfil/UpdateProfil.dart';

class ProfileConsultationScreen extends StatefulWidget {
  const ProfileConsultationScreen({super.key});

  @override
  State<ProfileConsultationScreen> createState() =>
      _ProfileConsultationScreenState();
}

class _ProfileConsultationScreenState extends State<ProfileConsultationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'prenom': 'Jean',
    'nom': 'Dupont',
    'email': 'jean.dupont@email.com',
    'telephone': '+216 12 345 678',
    'date_creation': '15 Janvier 2024',
    'statut': 'ACTIF',
    'est_verifie': true,
    'role': 'Utilisateur Premium',
    'adresse': 'Tunis, Tunisie',
  };

  File? _profileImage;

  // Profile image base64
  final String _profileImageBase64 =
      "data:image/jpeg;base64,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";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ImageProvider _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    try {
      final bytes = base64Decode(_profileImageBase64.split(',').last);
      return MemoryImage(bytes);
    } catch (e) {
      return const AssetImage('assets/default_avatar.png');
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
            colors: [Color(0xFFF8F4FF), Color(0xFFF3E8FF), Color(0xFFEDE0F8)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // AppBar light purple
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: const Color(0xFFB794F4).withOpacity(0.95),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFB794F4),
                            const Color(0xFFD4B8FF),
                            const Color(0xFFE8DCFF),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Avatar with animation
                                      GestureDetector(
                                        onTap: _showImageOptions,
                                        child: Hero(
                                          tag: 'profileAvatar',
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFFB794F4,
                                                  ).withOpacity(0.5),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                              image: DecorationImage(
                                                image: _getProfileImage(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_userData['prenom']} ${_userData['nom']}',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.25,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: Color(0xFF81C784),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'En ligne',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Edit button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: _navigateToEditProfile,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Premium badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4B8FF),
                                      Color(0xFFE8DCFF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Color(0xFFB794F4),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _userData['role'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB794F4),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Verification badge
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _userData['est_verifie'] == true
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : const Color(0xFFFF9800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _userData['est_verifie'] == true
                                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                                    : const Color(0xFFFF9800).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _userData['est_verifie'] == true
                                      ? Icons.verified
                                      : Icons.warning_amber_rounded,
                                  size: 18,
                                  color: _userData['est_verifie'] == true
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _userData['est_verifie'] == true
                                      ? 'Compte vérifié'
                                      : 'Vérification en attente',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _userData['est_verifie'] == true
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informations personnelles
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildInfoCard(
                          title: 'Informations personnelles',
                          icon: Icons.person_outline,
                          gradientColors: const [
                            Color(0xFFB794F4),
                            Color(0xFFD4B8FF),
                          ],
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              'Prénom',
                              _userData['prenom'],
                            ),
                            _buildInfoRow(Icons.badge, 'Nom', _userData['nom']),
                            _buildInfoRow(
                              Icons.email_outlined,
                              'Email',
                              _userData['email'],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Coordonnées
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildInfoCard(
                          title: 'Coordonnées',
                          icon: Icons.contact_phone,
                          gradientColors: const [
                            Color(0xFFFFA5A5),
                            Color(0xFFFFC4C4),
                          ],
                          children: [
                            _buildInfoRow(
                              Icons.phone_android,
                              'Téléphone',
                              _userData['telephone'],
                              showCopy: true,
                            ),
                            _buildInfoRow(
                              Icons.location_on,
                              'Adresse',
                              _userData['adresse'],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Informations du compte
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildInfoCard(
                          title: 'Informations du compte',
                          icon: Icons.account_balance_wallet,
                          gradientColors: const [
                            Color(0xFF81C784),
                            Color(0xFFA5D6A5),
                          ],
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Membre depuis',
                              _userData['date_creation'],
                            ),
                            _buildInfoRow(
                              Icons.fiber_manual_record,
                              'Statut',
                              _userData['statut'],
                              valueColor: const Color(0xFF4CAF50),
                            ),
                            _buildInfoRow(
                              Icons.security,
                              'Sécurité',
                              '2FA activé',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action buttons
                      SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.edit,
                                label: 'Modifier',
                                color: const Color(0xFFB794F4),
                                onTap: _navigateToEditProfile,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.logout,
                                label: 'Déconnexion',
                                color: const Color(0xFFFFA5A5),
                                onTap: _showLogoutDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: Color(0xFFF0F0F0),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showCopy = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFB794F4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFB794F4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A8A9E),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (showCopy)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Numéro copié dans le presse-papier'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF81C784),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB794F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.copy,
                  size: 18,
                  color: Color(0xFFB794F4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB794F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFB794F4),
                  size: 22,
                ),
              ),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB794F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFB794F4),
                  size: 22,
                ),
              ),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditScreen(userData: {}),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
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
              // Navigate to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA5A5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}
