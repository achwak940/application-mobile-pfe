// screens/profile/profile_consultation_screen.dart
import 'package:appmobile/screens/gestionProfil/UpdateProfil.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  // Mock user data
  final Map<String, dynamic> _userData = {
    'prenom': 'Mohamed',
    'nom': 'Ben Ali',
    'email': 'mohamed.benali@email.com',
    'telephone': '12345678',
    'date_creation': '15 Janvier 2024',
    'statut': 'ACTIF',
    'est_verifie': true,
  };

  File? _profileImage;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF9C27B0).withOpacity(0.1),
                            const Color(0xFFE1BEE7).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 80,
                              color: Color(0xFF9C27B0),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Mon Profil',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A148C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _navigateToEditProfile(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Header with Image
                        _buildProfileHeader(),
                        const SizedBox(height: 30),

                        // Stats Cards
                        _buildStatsCards(),
                        const SizedBox(height: 30),

                        // Personal Information Section
                        _buildInfoSection(),
                        const SizedBox(height: 30),

                        // Account Information
                        _buildAccountInfo(),
                        const SizedBox(height: 30),

                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
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
          const SizedBox(height: 16),
          Text(
            '${_userData['prenom']} ${_userData['nom']}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _userData['est_verifie'] == true
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _userData['est_verifie'] == true
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
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
                  size: 16,
                  color: _userData['est_verifie'] == true
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 6),
                Text(
                  _userData['est_verifie'] == true ? 'Vérifié' : 'Non vérifié',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _userData['est_verifie'] == true
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available,
            value: '12',
            label: 'Événements',
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite,
            value: '156',
            label: 'Points',
            color: const Color(0xFFE91E63),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            value: '89',
            label: 'Amis',
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Color(0xFF9C27B0)),
                SizedBox(width: 10),
                Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildInfoTile(
            icon: Icons.person,
            label: 'Prénom',
            value: _userData['prenom'],
          ),
          _buildInfoTile(
            icon: Icons.badge,
            label: 'Nom',
            value: _userData['nom'],
          ),
          _buildInfoTile(
            icon: Icons.email,
            label: 'Email',
            value: _userData['email'],
          ),
          _buildInfoTile(
            icon: Icons.phone,
            label: 'Téléphone',
            value: _userData['telephone'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF9C27B0)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A148C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: Color(0xFF9C27B0)),
              SizedBox(width: 10),
              Text(
                'Informations du compte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildAccountInfoRow(
            icon: Icons.calendar_today,
            label: 'Membre depuis',
            value: _userData['date_creation'],
          ),
          const SizedBox(height: 12),
          _buildAccountInfoRow(
            icon: Icons.circle,
            label: 'Statut',
            value: _userData['statut'],
            valueColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9C27B0).withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF4A148C),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit,
            label: 'Modifier profil',
            color: const Color(0xFF9C27B0),
            onTap: _navigateToEditProfile,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            icon: Icons.logout,
            label: 'Déconnexion',
            color: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
        ),
      ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}
