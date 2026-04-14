// screens/settings/settings_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Paramètres
  String _selectedLanguage = 'fr';
  String _selectedTheme = 'light';
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _autoSave = true;
  bool _dataSaverMode = false;
  bool _biometricEnabled = false;
  String _fontSize = 'medium';
  String _animationSpeed = 'normal';

  // Données de l'application
  int _cacheSize = 128; // MB
  int _appVersion = 210; // 2.1.0

  final String _userName = "Jean Dupont";
  final String _userEmail = "jean.dupont@example.com";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'fr';
      _selectedTheme = prefs.getString('theme') ?? 'light';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _emailNotificationsEnabled = prefs.getBool('email_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? true;
      _vibrationEnabled = prefs.getBool('vibration') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _autoSave = prefs.getBool('auto_save') ?? true;
      _dataSaverMode = prefs.getBool('data_saver') ?? false;
      _biometricEnabled = prefs.getBool('biometric') ?? false;
      _fontSize = prefs.getString('font_size') ?? 'medium';
      _animationSpeed = prefs.getString('animation_speed') ?? 'normal';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Français'),
              value: 'fr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                  _saveSetting('language', value);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                  _saveSetting('language', value);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Español'),
              value: 'es',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                  _saveSetting('language', value);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                  _saveSetting('language', value);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
              activeColor: const Color(0xFFB794F4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Clair'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                  _saveSetting('theme', value);
                  _darkMode = false;
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                  _saveSetting('theme', value);
                  _darkMode = true;
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Système'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                  _saveSetting('theme', value);
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Taille de police'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Petite'),
              value: 'small',
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value!;
                  _saveSetting('font_size', value);
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Moyenne'),
              value: 'medium',
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value!;
                  _saveSetting('font_size', value);
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Grande'),
              value: 'large',
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value!;
                  _saveSetting('font_size', value);
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
            RadioListTile(
              title: const Text('Très grande'),
              value: 'xlarge',
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value!;
                  _saveSetting('font_size', value);
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFFB794F4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Redémarrage requis'),
        content: const Text(
          'Les modifications seront appliquées après le redémarrage de l\'application. Voulez-vous redémarrer maintenant ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              // Redémarrer l'application
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB794F4),
            ),
            child: const Text('Redémarrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text('Supprimer le compte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cette action est irréversible. Toutes vos données seront supprimées :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text('• Historique des enquêtes'),
            const Text('• Historique des réclamations'),
            const Text('• Préférences et paramètres'),
            const Text('• Données personnelles'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tapez "SUPPRIMER" pour confirmer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique de suppression
              Navigator.pop(context);
              _showSnackbar(
                'Compte supprimé avec succès',
                const Color(0xFFFF6B6B),
              );
              Future.delayed(const Duration(seconds: 2), () {
                SystemNavigator.pop();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.pause_circle_outline, color: Color(0xFFFF9800)),
            SizedBox(width: 8),
            Text('Désactiver le compte'),
          ],
        ),
        content: const Text(
          'Votre compte sera désactivé. Vous pourrez le réactiver plus tard en vous reconnectant. Vos données seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar('Compte désactivé', const Color(0xFFFF9800));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB794F4),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Vider le cache'),
        content: Text(
          'Voulez-vous vider le cache ? ${_cacheSize} MB seront libérés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cacheSize = 0;
              });
              Navigator.pop(context);
              _showSnackbar('Cache vidé avec succès', const Color(0xFF4CAF50));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB794F4),
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: const Text(
          'Paramètres',
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
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Section Préférences
                    _buildSectionHeader(
                      icon: Icons.settings_rounded,
                      title: 'Préférences',
                      color: const Color(0xFFB794F4),
                    ),
                    _buildPreferencesCard(),

                    // Section Apparence
                    _buildSectionHeader(
                      icon: Icons.palette_rounded,
                      title: 'Apparence',
                      color: const Color(0xFFB794F4),
                    ),
                    _buildAppearanceCard(),

                    // Section Sécurité
                    _buildSectionHeader(
                      icon: Icons.security_rounded,
                      title: 'Sécurité',
                      color: const Color(0xFFB794F4),
                    ),
                    _buildSecurityCard(),

                    // Section Compte
                    _buildSectionHeader(
                      icon: Icons.account_circle_rounded,
                      title: 'Compte',
                      color: const Color(0xFFFF6B6B),
                    ),
                    _buildAccountCard(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB794F4).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFB794F4), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 30,
                color: Color(0xFFB794F4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A9E),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showSnackbar(
                'Modification du profil à venir',
                const Color(0xFFB794F4),
              );
            },
            icon: const Icon(Icons.edit_rounded, color: Color(0xFFB794F4)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'Langue',
            subtitle: _getLanguageName(_selectedLanguage),
            onTap: _showLanguageDialog,
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.palette_rounded,
            title: 'Thème',
            subtitle: _getThemeName(_selectedTheme),
            onTap: _showThemeDialog,
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'Taille de police',
            subtitle: _getFontSizeName(_fontSize),
            onTap: _showFontSizeDialog,
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.animation_rounded,
            title: 'Vitesse d\'animation',
            subtitle: _getAnimationSpeedName(_animationSpeed),
            onTap: () {
              _showSnackbar('Paramètre à venir', const Color(0xFFB794F4));
            },
            color: const Color(0xFFB794F4),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications push',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSetting('notifications', value);
              });
            },
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.email_rounded,
            title: 'Notifications par email',
            value: _emailNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value;
                _saveSetting('email_notifications', value);
              });
            },
            color: const Color(0xFF4CAF50),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'Sons',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
                _saveSetting('sound', value);
              });
            },
            color: const Color(0xFFFF9800),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.vibration_rounded,
            title: 'Vibrations',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
                _saveSetting('vibration', value);
              });
            },
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            title: 'Mode sombre',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                _selectedTheme = value ? 'dark' : 'light';
                _saveSetting('dark_mode', value);
                _saveSetting('theme', _selectedTheme);
              });
            },
            color: const Color(0xFF1A1A2E),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.auto_awesome_rounded,
            title: 'Mode économique',
            subtitle: 'Réduit les animations et les effets visuels',
            value: _dataSaverMode,
            onChanged: (value) {
              setState(() {
                _dataSaverMode = value;
                _saveSetting('data_saver', value);
              });
            },
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.save_rounded,
            title: 'Sauvegarde automatique',
            value: _autoSave,
            onChanged: (value) {
              setState(() {
                _autoSave = value;
                _saveSetting('auto_save', value);
              });
            },
            color: const Color(0xFF4CAF50),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.storage_rounded,
            title: 'Cache',
            subtitle: '$_cacheSize MB utilisés',
            onTap: _clearCache,
            color: const Color(0xFFFF9800),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.backup_rounded,
            title: 'Sauvegarder les données',
            subtitle: 'Exporter vos données',
            onTap: () {
              _showSnackbar(
                'Export des données à venir',
                const Color(0xFFB794F4),
              );
            },
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            title: 'Authentification biométrique',
            subtitle: 'Utiliser l\'empreinte digitale ou Face ID',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
                _saveSetting('biometric', value);
              });
            },
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock_rounded,
            title: 'Changer le mot de passe',
            subtitle: 'Modifier votre mot de passe',
            onTap: () {
              _showSnackbar(
                'Changement de mot de passe à venir',
                const Color(0xFFB794F4),
              );
            },
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '2.1.0 (${_appVersion})',
            onTap: () {},
            color: const Color(0xFFB794F4),
            showArrow: false,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.description_rounded,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire nos conditions',
            onTap: () {
              _showSnackbar('Conditions à venir', const Color(0xFFB794F4));
            },
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Politique de confidentialité',
            subtitle: 'Comment nous protégeons vos données',
            onTap: () {
              _showSnackbar('Politique à venir', const Color(0xFFB794F4));
            },
            color: const Color(0xFFB794F4),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.contact_support_rounded,
            title: 'Support',
            subtitle: 'support@monapp.com',
            onTap: () {
              _showSnackbar('Support à venir', const Color(0xFFB794F4));
            },
            color: const Color(0xFFB794F4),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB794F4).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Se déconnecter',
            subtitle: 'Quitter votre session',
            onTap: _showLogoutDialog,
            color: const Color(0xFFFF9800),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.pause_circle_outline,
            title: 'Désactiver le compte',
            subtitle: 'Suspendre temporairement votre compte',
            onTap: _showDeactivateAccountDialog,
            color: const Color(0xFFFF9800),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Supprimer le compte',
            subtitle: 'Supprimer définitivement votre compte',
            onTap: _showDeleteAccountDialog,
            color: const Color(0xFFFF6B6B),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color color,
    bool showArrow = true,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? const Color(0xFFFF6B6B) : color).withOpacity(
            0.1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? const Color(0xFFFF6B6B) : color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? const Color(0xFFFF6B6B)
              : const Color(0xFF1A1A2E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9E)),
            )
          : null,
      trailing: showArrow
          ? Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? const Color(0xFFFF6B6B) : color,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9E)),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: color,
      activeTrackColor: color.withOpacity(0.3),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, endIndent: 16);
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return 'Français';
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      case 'system':
        return 'Système';
      default:
        return 'Clair';
    }
  }

  String _getFontSizeName(String size) {
    switch (size) {
      case 'small':
        return 'Petite';
      case 'medium':
        return 'Moyenne';
      case 'large':
        return 'Grande';
      case 'xlarge':
        return 'Très grande';
      default:
        return 'Moyenne';
    }
  }

  String _getAnimationSpeedName(String speed) {
    switch (speed) {
      case 'slow':
        return 'Lente';
      case 'normal':
        return 'Normale';
      case 'fast':
        return 'Rapide';
      default:
        return 'Normale';
    }
  }
}
