// screens/profile/profile_consultation_screen.dart
import 'dart:convert';
import 'package:appmobile/services/profile/consulterProfile.dart';
import 'package:flutter/material.dart';
import 'package:appmobile/models/user_model.dart';
import 'package:appmobile/services/auth/auth.dart';
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

  // Données réelles de l'API
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  final ProfilService _profilService = ProfilService();
  final AuthService _authService = AuthService();

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
    _loadProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _profilService.getMyProfile();

    if (mounted) {
      if (result['success']) {
        setState(() {
          _user = result['profil'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshProfile() async {
    await _loadProfile();
  }

  ImageProvider _getProfileImage() {
    print('🖼️ Chargement image profil...');

    if (_user?.photoProfil == null) {
      print('❌ photoProfil est null');
      return const AssetImage('images/logo1.png');
    }

    if (_user!.photoProfil!.isEmpty) {
      print('❌ photoProfil est vide');
      return const AssetImage('images/logo1.png');
    }

    final photoProfil = _user!.photoProfil!;
    print('📁 photoProfil reçu: "$photoProfil"');

    // URL HTTP complète
    if (photoProfil.startsWith('http://') ||
        photoProfil.startsWith('https://')) {
      print('✅ URL HTTP complète: $photoProfil');
      return NetworkImage(photoProfil);
    }

    // Chemin avec /uploads/ (avec slash)
    if (photoProfil.startsWith('/uploads/')) {
      const baseUrl = 'http://localhost:3000';
      final fullUrl = '$baseUrl$photoProfil';
      print('✅ Chemin /uploads/ converti: $fullUrl');
      return NetworkImage(fullUrl);
    }

    // Chemin sans slash (uploads/profiles/...)
    if (photoProfil.startsWith('uploads/')) {
      const baseUrl = 'http://10.0.2.2:3000';
      final fullUrl = '$baseUrl/$photoProfil';
      print('✅ Chemin uploads/ converti: $fullUrl');
      return NetworkImage(fullUrl);
    }

    // Base64
    try {
      print('🔍 Tentatif décodage Base64...');
      String cleanBase64 = photoProfil;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      cleanBase64 = cleanBase64
          .replaceAll('\n', '')
          .replaceAll(' ', '')
          .replaceAll('\r', '');

      if (cleanBase64.isNotEmpty && cleanBase64.length % 4 == 0) {
        final bytes = base64Decode(cleanBase64);
        if (bytes.isNotEmpty) {
          print('✅ Image Base64 décodée (${bytes.length} bytes)');
          return MemoryImage(bytes);
        }
      }
    } catch (e) {
      print('❌ Erreur décodage Base64: $e');
    }

    print('❌ Utilisation image par défaut');
    return const AssetImage('images/logo1.png');
  }

  void _navigateToEditProfile() {
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileEditScreen(userData: _user!.toJson()),
        ),
      ).then((_) => _refreshProfile());
    }
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
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non disponible';
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: const Color(0xFFB794F4),
        child: Container(
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
                  // AppBar
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: const Color(0xFFB794F4).withOpacity(0.95),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: const [
                              Color(0xFFB794F4),
                              Color(0xFFD4B8FF),
                              Color(0xFFE8DCFF),
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
                                        // Avatar
                                        Hero(
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
                                                image: _isLoading
                                                    ? const AssetImage(
                                                            'images/logo1.png',
                                                          )
                                                          as ImageProvider
                                                    : _getProfileImage(),
                                                fit: BoxFit.cover,
                                                onError: (exception, stackTrace) {
                                                  print(
                                                    'Erreur chargement image: $exception',
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        if (!_isLoading && _user != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _user!.fullName,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color:
                                                          _user!.statut ==
                                                              'ACTIF'
                                                          ? const Color(
                                                              0xFF81C784,
                                                            )
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _user!.statut == 'ACTIF'
                                                          ? 'En ligne'
                                                          : 'Hors ligne',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                        onPressed: _isLoading
                                            ? null
                                            : _navigateToEditProfile,
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
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                color: Color(0xFFB794F4),
                              ),
                            ),
                          )
                        else if (_errorMessage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF8A8A9E),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _refreshProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB794F4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Réessayer'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_user != null)
                          Column(
                            children: [
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
                                      color: (_user!.estVerifie ?? false)
                                          ? const Color(
                                              0xFF4CAF50,
                                            ).withOpacity(0.1)
                                          : const Color(
                                              0xFFFF9800,
                                            ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: (_user!.estVerifie ?? false)
                                            ? const Color(
                                                0xFF4CAF50,
                                              ).withOpacity(0.5)
                                            : const Color(
                                                0xFFFF9800,
                                              ).withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          (_user!.estVerifie ?? false)
                                              ? Icons.verified
                                              : Icons.warning_amber_rounded,
                                          size: 18,
                                          color: (_user!.estVerifie ?? false)
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFFF9800),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          (_user!.estVerifie ?? false)
                                              ? 'Compte vérifié'
                                              : 'Vérification en attente',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: (_user!.estVerifie ?? false)
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
                                      _user!.prenom,
                                    ),
                                    _buildInfoRow(
                                      Icons.badge,
                                      'Nom',
                                      _user!.nom,
                                    ),
                                    _buildInfoRow(
                                      Icons.email_outlined,
                                      'Email',
                                      _user!.email,
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
                                      _user!.telephone ?? 'Non renseigné',
                                      showCopy: _user!.telephone != null,
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
                                      _formatDate(_user!.dateCreation),
                                    ),
                                    _buildInfoRow(
                                      Icons.fiber_manual_record,
                                      'Statut',
                                      _user!.statut ?? 'ACTIF',
                                      valueColor: (_user!.statut == 'ACTIF')
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFF9800),
                                    ),
                                    _buildInfoRow(
                                      Icons.security,
                                      'Rôle',
                                      _user!.role,
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
                            ],
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
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
}
